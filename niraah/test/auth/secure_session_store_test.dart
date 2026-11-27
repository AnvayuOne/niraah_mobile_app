import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/auth/session_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a stale saved session is replaced by the new sign-in at once', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{'niraah.session.access': 'old-a', 'niraah.session.refresh': 'old-r'});
    final SecureSessionStore store = SecureSessionStore();
    expect((await store.read())!.accessToken, 'old-a');
    await store.write(const SessionTokens(accessToken: 'new-a', refreshToken: 'new-r'));
    expect((await store.read())!.accessToken, 'new-a');
    expect((await SecureSessionStore().read())!.accessToken, 'new-a', reason: 'saved for the next launch too');
  });

  test('after sign-out nothing is read back', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    final SecureSessionStore store = SecureSessionStore();
    await store.write(const SessionTokens(accessToken: 'a', refreshToken: 'r'));
    await store.clear();
    expect(await store.read(), isNull);
  });
}
