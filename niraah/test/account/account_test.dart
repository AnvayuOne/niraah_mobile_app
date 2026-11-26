import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/errors/api_exception.dart';
import 'package:niraah/features/account/data/api_account_repository.dart';
import 'package:niraah/features/account/domain/account.dart';
import 'package:niraah/features/account/presentation/account_pages.dart';

import '../helpers/fake_api.dart';

class FakeAccount implements AccountRepository {
  final List<String> calls = <String>[];
  bool failEnd = false;

  @override
  Future<List<SignedInSession>> sessions() async => <SignedInSession>[
        SignedInSession(id: 'old', deviceType: 'web', city: 'Pune', lastActiveAt: DateTime(2026, 11, 1), current: false),
        SignedInSession(id: 'new', deviceType: 'android', city: null, lastActiveAt: DateTime(2026, 11, 17), current: false),
        SignedInSession(id: 'me', deviceType: 'android', city: 'Bengaluru', lastActiveAt: DateTime(2026, 11, 10), current: true),
      ];

  @override
  Future<void> endSession(String id) async {
    calls.add('end:$id');
    if (failEnd) throw ApiException(message: 'Could not end it.');
  }

  @override
  Future<void> signOutEverywhere() async => calls.add('all');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeAdapter adapter;
  late ApiAccountRepository repo;

  setUp(() {
    adapter = FakeAdapter();
    repo = ApiAccountRepository(fakeApi(adapter));
  });

  group('Signed-in devices (spec 003 "Sessions" 7, 8)', () {
    test('lists sessions with device, city and last active; ends one or all', () async {
      adapter
        ..reply(<String, dynamic>{
          'sessions': <Object>[
            <String, dynamic>{'id': 's1', 'deviceType': 'android', 'city': 'Pune', 'lastActiveAt': '2026-11-17T10:00:00.000Z', 'current': true},
          ],
        })
        ..reply(<String, dynamic>{'status': 'accepted'})
        ..reply(<String, dynamic>{'status': 'accepted'});
      final SignedInSession s = (await repo.sessions()).single;
      expect(adapter.last.path, '/auth/sessions');
      expect((s.city, s.current), ('Pune', true));
      await repo.endSession('s2');
      expect(adapter.last.path, '/auth/sessions/end');
      expect(adapter.lastBody, <String, dynamic>{'sessionId': 's2'});
      await repo.signOutEverywhere();
      expect(adapter.last.path, '/auth/sign-out-everywhere');
    });

    test('the cubit puts this device first, then the most recent, and reports a refused end', () async {
      final FakeAccount f = FakeAccount();
      final SessionsCubit c = SessionsCubit(f);
      await c.load();
      expect(c.state.sessions.map((SignedInSession s) => s.id), <String>['me', 'new', 'old']);
      expect(await c.end('old'), isNull);
      f.failEnd = true;
      expect(await c.end('new'), isA<ApiException>());
      expect(c.state.busy, isFalse);
      expect(await c.endAll(), isNull);
      expect(f.calls, <String>['end:old', 'end:new', 'all']);
    });
  });

  group('Changing a mobile number (spec 003 "Changing a mobile number")', () {
    test('starts with the fresh proof and the new number, then confirms with its code (rule 1)', () async {
      adapter
        ..reply(<String, dynamic>{'status': 'sent', 'resendAfterSeconds': 30, 'expiresInSeconds': 600})
        ..reply(<String, dynamic>{'status': 'changed'});
      await repo.startNumberChange(proofId: 'p1', phone: ' 98765 43210 ');
      expect(adapter.last.path, '/me/phone/change');
      expect(adapter.lastBody, <String, dynamic>{'proofId': 'p1', 'phone': '98765 43210'});
      await repo.confirmNumberChange('123456');
      expect(adapter.last.path, '/me/phone/change/confirm');
      expect(adapter.lastBody, <String, dynamic>{'code': '123456'});
    });

    test('a number that cannot be used gets the same neutral refusal (rule 2)', () async {
      adapter.reply(<String, dynamic>{'error': <String, dynamic>{'code': 'invalid_code', 'message': "That code didn't work."}}, 400);
      expect(repo.confirmNumberChange('000000'), throwsA(isA<ApiException>()));
    });

    test('a pending change can be read and cancelled (rule 4)', () async {
      adapter
        ..reply(<String, dynamic>{'changes': <Object>[<String, dynamic>{'id': 'c1', 'newNumberEnding': '3210', 'effectiveAt': '2026-11-19T10:00:00.000Z'}]})
        ..reply(<String, dynamic>{'status': 'cancelled'});
      final PendingNumberChange c = (await repo.pendingNumberChanges()).single;
      expect(c.newNumberEnding, '3210');
      await repo.cancelNumberChange('c1');
      expect(adapter.last.path, '/me/phone/changes/cancel');
      expect(adapter.lastBody, <String, dynamic>{'requestId': 'c1'});
    });
  });

  test('a recovery email is set or removed with a fresh proof (spec 003 "Recovery" 4)', () async {
    adapter
      ..reply(<String, dynamic>{'status': 'accepted'})
      ..reply(<String, dynamic>{'status': 'accepted'});
    await repo.setRecoveryEmail(proofId: 'p1', email: ' meera@example.com ');
    expect(adapter.last.path, '/me/recovery-email');
    expect(adapter.lastBody, <String, dynamic>{'proofId': 'p1', 'email': 'meera@example.com'});
    await repo.removeRecoveryEmail('p2');
    expect(adapter.last.path, '/me/recovery-email/remove');
    expect(adapter.lastBody, <String, dynamic>{'proofId': 'p2'});
  });
}
