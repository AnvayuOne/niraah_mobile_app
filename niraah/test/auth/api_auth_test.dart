import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/auth/session_store.dart';
import 'package:niraah/core/network/niraah_api.dart';
import 'package:niraah/features/auth/data/api_auth_repository.dart';
import 'package:niraah/features/auth/domain/auth_repository.dart';
import 'package:niraah/features/provider_auth/data/api_provider_auth_repository.dart';
import 'package:niraah/features/provider_auth/domain/provider_auth.dart';
import 'package:niraah/shared/helpers/result.dart';

/// Answers requests from a script and records what was sent (spec 003 T16 on mobile).
class ScriptedAdapter implements HttpClientAdapter {
  final List<(int, Object)> replies = <(int, Object)>[];
  final List<RequestOptions> requests = <RequestOptions>[];
  final List<Object?> bodies = <Object?>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    bodies.add(options.data);
    final (int status, Object body) = replies.isEmpty ? (200, <String, dynamic>{}) : replies.removeAt(0);
    return ResponseBody.fromString(jsonEncode(body), status, headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> user(String workspace, {String role = 'member'}) => <String, dynamic>{
      'user': <String, dynamic>{'id': 'u1', 'role': role, 'status': 'active', 'displayName': null, 'workspace': workspace},
      'tokens': <String, dynamic>{'accessToken': 'at-1', 'refreshToken': 'rt-1', 'expiresAt': '2026-11-15T10:00:00.000Z'},
    };

Map<String, dynamic> error(String code, String message, {String? field}) => <String, dynamic>{
      'error': <String, dynamic>{'code': code, 'message': message, 'field': ?field},
      'requestId': 'r',
    };

void main() {
  late ScriptedAdapter adapter;
  late MemorySessionStore store;
  late NiraahApi api;

  setUp(() {
    adapter = ScriptedAdapter();
    store = MemorySessionStore();
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://api.test/api/v1'))..httpClientAdapter = adapter;
    api = NiraahApi(dio: dio, store: store);
  });

  group('member sign-in on /api/v1', () {
    test('says it is the mobile app, sends a device id, and keeps tokens only in the session store (AC28)', () async {
      final ApiAuthRepository repo = ApiAuthRepository(api);
      adapter.replies.add((200, <String, dynamic>{'status': 'sent', 'resendAfterSeconds': 30, 'expiresInSeconds': 600}));
      expect(await repo.requestCode('+919876543210'), isA<Success<void>>());
      expect(adapter.requests.first.headers['x-niraah-client'], 'mobile');
      expect((adapter.bodies.first! as Map<String, dynamic>)['device'], containsPair('deviceId', isNotEmpty));

      adapter.replies.add((200, user('second_check')));
      final Result<CodeOutcome> r = await repo.verifyCode('+919876543210', '123456');
      expect((r as Success<CodeOutcome>).data, CodeOutcome.secondCheck);
      expect(store.tokens?.accessToken, 'at-1');
      expect(routeForOutcome(CodeOutcome.secondCheck), '/sign-in/second-check');
    });

    test('limits and wrong codes come back as the server words them', () async {
      final ApiAuthRepository repo = ApiAuthRepository(api);
      adapter.replies.add((429, error('rate_limited', 'Too many attempts. Try again in 1 minute.')));
      expect((await repo.requestCode('+919876543210') as FailureResult<void>).message, 'Too many attempts. Try again in 1 minute.');
    });

    test('maps every workspace to a place', () {
      expect(ApiAuthRepository.outcomeFor('member_new'), CodeOutcome.newAccount);
      expect(ApiAuthRepository.outcomeFor('assessment_gate'), CodeOutcome.assessmentGate);
      expect(ApiAuthRepository.outcomeFor('member'), CodeOutcome.home);
      expect(ApiAuthRepository.outcomeFor('paused'), CodeOutcome.paused);
      expect(ApiAuthRepository.outcomeFor('deletion_pending'), CodeOutcome.deletionPending);
      expect(ApiAuthRepository.outcomeFor('suspended'), CodeOutcome.suspended);
    });

    test('a 401 refreshes once with the stored refresh token, then retries', () async {
      await store.write(const SessionTokens(accessToken: 'old', refreshToken: 'rt-old'));
      adapter.replies
        ..add((401, error('unauthenticated', 'Please sign in.')))
        ..add((200, user('member')))
        ..add((200, <String, dynamic>{'methods': <String>['date_of_birth'], 'contactSupport': false}));
      final SecondCheckOptions? o = await ApiAuthRepository(api).options();
      expect(o!.methods, <SecondCheckMethod>[SecondCheckMethod.dateOfBirth]);
      expect(adapter.requests.map((RequestOptions r) => r.path), <String>['/auth/second-check', '/auth/refresh', '/auth/second-check']);
      expect(adapter.bodies[1], <String, dynamic>{'refreshToken': 'rt-old'});
      expect(adapter.requests.last.headers['Authorization'], 'Bearer at-1');
    });

    test('the known-device answer sends the stored device id, not what was typed', () async {
      await ApiAuthRepository(api).answer(SecondCheckMethod.knownDevice, 'typed');
      expect(adapter.bodies.single, <String, dynamic>{'method': 'known_device', 'answer': await store.deviceId()});
    });

    test('three wrong answers end the session (AC44)', () async {
      adapter.replies.add((429, error('rate_limited', 'Too many attempts. Try again tomorrow, or contact support.')));
      final SecondCheckAnswer a = await ApiAuthRepository(api).answer(SecondCheckMethod.dateOfBirth, '1990-01-01');
      expect(a, isA<SecondCheckWrong>().having((SecondCheckWrong w) => w.ended, 'ended', isTrue));
    });
  });

  group('provider sign-in on /api/v1', () {
    test('a password alone never signs in; the pending id carries to the authenticator step (AC20)', () async {
      final ApiProviderAuthRepository repo = ApiProviderAuthRepository(api);
      adapter.replies.add((200, <String, dynamic>{'pendingId': 'sealed-1'}));
      expect((await repo.checkPassword('dr@clinic.in', 'pw')).ok, isTrue);
      expect(store.tokens, isNull);
      adapter.replies.add((200, user('doctor', role: 'doctor')));
      final ProviderSession? s = await repo.verifySecondFactor('123456', SecondFactorKind.authenticator);
      expect(s!.role, ProviderRole.doctor);
      expect(adapter.bodies[1], containsPair('pendingId', 'sealed-1'));
      expect(store.tokens?.accessToken, 'at-1');
    });

    test('a recovery code that works requires a new authenticator before any session (AC25)', () async {
      final ApiProviderAuthRepository repo = ApiProviderAuthRepository(api);
      adapter.replies
        ..add((200, <String, dynamic>{'pendingId': 'sealed-1'}))
        ..add((200, <String, dynamic>{'next': 'enrol_authenticator', 'pendingId': 'sealed-2'}))
        ..add((200, <String, dynamic>{'factorId': 'f1', 'secret': 'ABC', 'otpauthUri': 'otpauth://totp/x'}));
      await repo.checkPassword('dr@clinic.in', 'pw');
      await expectLater(repo.verifySecondFactor('abcd-efgh', SecondFactorKind.recovery), throwsA(isA<NewAuthenticatorRequired>()));
      expect(store.tokens, isNull);
      final AuthenticatorSetup? setup = await repo.startReenrol();
      expect(setup!.secret, 'ABC');
      expect(adapter.bodies[2], <String, dynamic>{'pendingId': 'sealed-2'});
    });

    test('every password failure is the same generic failure (AC4)', () async {
      adapter.replies.add((401, error('sign_in_failed', 'That email or password is not right.')));
      expect((await ApiProviderAuthRepository(api).checkPassword('x@y.in', 'pw')).failure, StepFailure.generic);
    });

    test('an admin is routed to the web-only notice', () async {
      expect(homeFor(ApiProviderAuthRepository.sessionFrom(user('admin', role: 'admin'))), '/admin');
    });
  });
}
