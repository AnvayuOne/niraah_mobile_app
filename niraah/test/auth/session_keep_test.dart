import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/auth/session_store.dart';
import 'package:niraah/core/network/niraah_api.dart';

/// A server like the live one: access tokens expire, refresh tokens are single use (a second use is refused),
/// and every answer takes a moment so requests overlap. `offline` makes the refresh fail on the network.
class FakeServer implements HttpClientAdapter {
  String validAccess = 'at-1';
  final Set<String> liveRefresh = <String>{'rt-1'};
  int refreshCalls = 0;
  int n = 1;
  bool offline = false;

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    if (o.path == '/auth/refresh') {
      refreshCalls++;
      if (offline) throw DioException.connectionError(requestOptions: o, reason: 'no signal');
      final String rt = '${(o.data as Map)['refreshToken']}';
      if (!liveRefresh.remove(rt)) return _json(401, <String, dynamic>{'error': <String, dynamic>{'code': 'unauthenticated', 'message': 'Session ended'}});
      n++;
      validAccess = 'at-$n';
      liveRefresh.add('rt-$n');
      return _json(200, <String, dynamic>{
        'user': <String, dynamic>{'id': 'u1', 'role': 'member', 'status': 'active', 'displayName': null, 'workspace': 'member'},
        'tokens': <String, dynamic>{'accessToken': 'at-$n', 'refreshToken': 'rt-$n', 'expiresAt': '2026-12-01T00:00:00Z'},
      });
    }
    if (o.headers['Authorization'] != 'Bearer $validAccess') {
      return _json(401, <String, dynamic>{'error': <String, dynamic>{'code': 'unauthenticated', 'message': 'Please sign in.'}});
    }
    return _json(200, <String, dynamic>{'user': <String, dynamic>{'role': 'member', 'workspace': 'member'}, 'path': o.path});
  }

  static ResponseBody _json(int status, Object body) =>
      ResponseBody.fromString(jsonEncode(body), status, headers: <String, List<String>>{Headers.contentTypeHeader: <String>[Headers.jsonContentType]});

  @override
  void close({bool force = false}) {}
}

void main() {
  late FakeServer server;
  late MemorySessionStore store;
  late NiraahApi api;

  setUp(() async {
    server = FakeServer();
    store = MemorySessionStore();
    await store.write(const SessionTokens(accessToken: 'at-1', refreshToken: 'rt-1'));
    api = NiraahApi(dio: Dio(BaseOptions(baseUrl: 'http://api.test/api/v1'))..httpClientAdapter = server, store: store);
    NiraahApi.sessionLost.value = false;
  });

  test('when the access token has expired, screens loading at once share one refresh and all succeed', () async {
    server.validAccess = 'expired-on-server';
    final List<ApiResult<Map<String, dynamic>>> all = await Future.wait(<Future<ApiResult<Map<String, dynamic>>>>[
      api.get('/me/home'),
      api.get('/me/workspace'),
      api.get('/me/plan'),
    ]);
    expect(all.every((ApiResult<Map<String, dynamic>> r) => r is ApiOk), isTrue);
    expect(server.refreshCalls, 1);
    expect((await store.read())?.refreshToken, 'rt-2');
    expect(NiraahApi.sessionLost.value, isFalse);
  });

  test('a request that 401s after another already refreshed retries with the new token, without a second refresh', () async {
    server.validAccess = 'expired-on-server';
    expect(await api.get('/me/home'), isA<ApiOk<Map<String, dynamic>>>());
    // A late answer for a request sent with the old token: it must not spend the (now used) old refresh token.
    expect(await api.get('/me/plan'), isA<ApiOk<Map<String, dynamic>>>());
    expect(server.refreshCalls, 1);
    expect(NiraahApi.sessionLost.value, isFalse);
  });

  test('no signal during a refresh keeps her signed in', () async {
    server.validAccess = 'expired-on-server';
    server.offline = true;
    final ApiResult<Map<String, dynamic>> r = await api.get('/me/home');
    expect(r, isA<ApiFail<Map<String, dynamic>>>());
    expect(await store.read(), isNotNull, reason: 'tokens are kept');
    expect(NiraahApi.sessionLost.value, isFalse);
    // Signal back: the same tokens refresh and the screen loads.
    server.offline = false;
    expect(await api.get('/me/home'), isA<ApiOk<Map<String, dynamic>>>());
  });

  test('a refresh the server refuses ends the session and sends her to sign in', () async {
    server.validAccess = 'expired-on-server';
    server.liveRefresh.clear();
    final ApiResult<Map<String, dynamic>> r = await api.get('/me/home');
    expect(r, isA<ApiFail<Map<String, dynamic>>>());
    expect(await store.read(), isNull);
    expect(NiraahApi.sessionLost.value, isTrue);
  });

  test('opening the app resumes a saved session', () async {
    final Map<String, dynamic>? s = await api.resumeSession();
    expect((s?['user'] as Map?)?['workspace'], 'member');
  });

  test('opening the app with no saved session asks her to sign in', () async {
    await store.clear();
    expect(await api.resumeSession(), isNull);
  });
}
