import '../../../core/network/niraah_api.dart';
import '../domain/account.dart';

/// Sign-in settings on `/api/v1` (spec 003): `GET /auth/sessions`, `POST /auth/sessions/end`, `POST /auth/sign-out-everywhere`,
/// `POST /me/phone/change`, `/me/phone/change/confirm`, `GET /me/phone/changes`, `POST /me/phone/changes/cancel`,
/// `POST /me/recovery-email`, `POST /me/recovery-email/remove`.
class ApiAccountRepository implements AccountRepository {
  ApiAccountRepository(this._api);

  final NiraahApi _api;

  @override
  Future<List<SignedInSession>> sessions() async => <SignedInSession>[
        for (final dynamic x in (await _api.get('/auth/sessions')).orThrow()['sessions'] as List<dynamic>)
          SignedInSession(
            id: '${(x as Map<String, dynamic>)['id']}',
            deviceType: '${x['deviceType']}',
            city: x['city'] as String?,
            lastActiveAt: DateTime.parse(x['lastActiveAt'] as String).toLocal(),
            current: x['current'] == true,
          ),
      ];

  @override
  Future<void> endSession(String id) async => (await _api.post('/auth/sessions/end', <String, dynamic>{'sessionId': id})).orThrow();

  @override
  Future<void> signOutEverywhere() async {
    (await _api.post('/auth/sign-out-everywhere')).orThrow();
    await _api.store.clear();
  }

  @override
  Future<void> startNumberChange({required String proofId, required String phone}) async =>
      (await _api.post('/me/phone/change', <String, dynamic>{'proofId': proofId, 'phone': phone.trim()})).orThrow();

  @override
  Future<void> confirmNumberChange(String code) async => (await _api.post('/me/phone/change/confirm', <String, dynamic>{'code': code})).orThrow();

  @override
  Future<List<PendingNumberChange>> pendingNumberChanges() async => <PendingNumberChange>[
        for (final dynamic x in (await _api.get('/me/phone/changes')).orThrow()['changes'] as List<dynamic>)
          PendingNumberChange(
            id: '${(x as Map<String, dynamic>)['id']}',
            newNumberEnding: '${x['newNumberEnding']}',
            effectiveAt: DateTime.parse(x['effectiveAt'] as String).toLocal(),
          ),
      ];

  @override
  Future<void> cancelNumberChange(String id) async => (await _api.post('/me/phone/changes/cancel', <String, dynamic>{'requestId': id})).orThrow();

  @override
  Future<void> setRecoveryEmail({required String proofId, required String email}) async =>
      (await _api.post('/me/recovery-email', <String, dynamic>{'proofId': proofId, 'email': email.trim()})).orThrow();

  @override
  Future<void> removeRecoveryEmail(String proofId) async => (await _api.post('/me/recovery-email/remove', <String, dynamic>{'proofId': proofId})).orThrow();
}
