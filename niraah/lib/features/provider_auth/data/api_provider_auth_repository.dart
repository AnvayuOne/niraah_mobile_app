import '../../../core/network/niraah_api.dart';
import '../domain/provider_auth.dart';

/// Provider and admin sign-in and invited set-up on `/api/v1` (spec 003 T16). The pending sign-in and
/// the set-up session are sealed values from the server, kept in memory only for the next step.
class ApiProviderAuthRepository implements ProviderAuthRepository {
  ApiProviderAuthRepository(this._api);

  final NiraahApi _api;
  String? _pendingId;
  String? _reenrolId;
  String? _setupId;
  String? _factorId;

  @override
  bool get sampleMode => false;

  static ProviderSession sessionFrom(Map<String, dynamic> data) {
    final Map<dynamic, dynamic> u = (data['user'] as Map?) ?? <dynamic, dynamic>{};
    final ProviderRole role = ProviderRole.values.firstWhere((ProviderRole r) => r.name == '${u['role']}', orElse: () => ProviderRole.doctor);
    return ProviderSession(
      role: role,
      status: u['workspace'] == 'provider_status' ? ProviderStatus.underReview : ProviderStatus.active,
      name: '${u['displayName'] ?? ''}',
      speciality: '',
    );
  }

  @override
  Future<StepResult> checkPassword(String email, String password) async {
    final ApiResult<Map<String, dynamic>> r = await _api.post('/auth/password', <String, dynamic>{'email': email, 'password': password});
    if (r is! ApiOk<Map<String, dynamic>>) return const StepResult.failed(StepFailure.generic);
    _pendingId = '${r.data['pendingId']}';
    return const StepResult.ok();
  }

  @override
  Future<ProviderSession?> verifySecondFactor(String code, SecondFactorKind kind) async {
    if (_pendingId == null) return null;
    final ApiResult<Map<String, dynamic>> r = await _api.post('/auth/second-factor', <String, dynamic>{
      'pendingId': _pendingId,
      'kind': kind.name,
      'code': code.trim(),
      'device': await _api.device(),
    });
    if (r is! ApiOk<Map<String, dynamic>>) return null;
    if (r.data['next'] == 'enrol_authenticator') {
      _reenrolId = '${r.data['pendingId']}';
      throw const NewAuthenticatorRequired();
    }
    await _api.saveTokens(r.data);
    return sessionFrom(r.data);
  }

  @override
  Future<AuthenticatorSetup?> startReenrol() async {
    if (_reenrolId == null) return null;
    return _setup(await _api.post('/auth/recovery/authenticator', <String, dynamic>{'pendingId': _reenrolId}));
  }

  @override
  Future<ProviderSession?> confirmReenrol(String factorId, String code) async {
    final ApiResult<Map<String, dynamic>> r = await _api.post('/auth/recovery/authenticator/confirm', <String, dynamic>{
      'pendingId': _reenrolId,
      'factorId': factorId,
      'code': code,
      'device': await _api.device(),
    });
    if (r is! ApiOk<Map<String, dynamic>>) return null;
    await _api.saveTokens(r.data);
    return sessionFrom(r.data);
  }

  AuthenticatorSetup? _setup(ApiResult<Map<String, dynamic>> r) {
    if (r is! ApiOk<Map<String, dynamic>>) return null;
    _factorId = '${r.data['factorId']}';
    return AuthenticatorSetup(factorId: _factorId!, secret: '${r.data['secret']}', otpauthUri: '${r.data['otpauthUri']}');
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _api.post('/auth/forgot-password', <String, dynamic>{'email': email});
  }

  @override
  Future<ProviderSession?> currentSession() async {
    final ApiResult<Map<String, dynamic>> r = await _api.get('/auth/session');
    if (r is! ApiOk<Map<String, dynamic>>) return null;
    if ((r.data['user'] as Map?)?['role'] == 'member') return null;
    return sessionFrom(r.data);
  }

  @override
  Future<void> signOut() async {
    await _api.post('/auth/sign-out');
    await _api.store.clear();
  }

  @override
  Future<InviteInfo?> getInvite(String token) async {
    final ApiResult<Map<String, dynamic>> r = await _api.get('/auth/setup/invite?token=${Uri.encodeQueryComponent(token)}');
    if (r is! ApiOk<Map<String, dynamic>>) return null;
    final ProviderRole role = ProviderRole.values.firstWhere((ProviderRole x) => x.name == '${r.data['role']}', orElse: () => ProviderRole.doctor);
    return InviteInfo(email: '${r.data['email']}', name: '${r.data['name']}', role: role);
  }

  @override
  Future<PasswordRejection?> setPassword(String token, String password) async {
    final ApiResult<Map<String, dynamic>> r = await _api.post('/auth/setup/password', <String, dynamic>{'token': token, 'password': password});
    switch (r) {
      case ApiOk<Map<String, dynamic>>(:final Map<String, dynamic> data):
        _setupId = '${data['setupId']}';
        return null;
      case ApiFail<Map<String, dynamic>>(:final ApiError error):
        return error.message.toLowerCase().contains('breach') ? PasswordRejection.breached : PasswordRejection.tooShort;
    }
  }

  @override
  Future<AuthenticatorSetup?> startAuthenticator(String token) async {
    if (_setupId == null) return null;
    return _setup(await _api.post('/auth/setup/authenticator', <String, dynamic>{'setupId': _setupId}));
  }

  @override
  Future<List<String>?> confirmAuthenticator(String token, String code) async {
    final ApiResult<Map<String, dynamic>> r =
        await _api.post('/auth/setup/authenticator/confirm', <String, dynamic>{'setupId': _setupId, 'factorId': _factorId, 'code': code});
    if (r is! ApiOk<Map<String, dynamic>>) return null;
    _setupId = '${r.data['setupId']}';
    return ((r.data['recoveryCodes'] as List<dynamic>?) ?? <dynamic>[]).map((dynamic c) => '$c').toList();
  }

  @override
  Future<ProviderSession> finishSetup(String token) async {
    final ApiResult<Map<String, dynamic>> r =
        await _api.post('/auth/setup/finish', <String, dynamic>{'setupId': _setupId, 'savedRecoveryCodes': true, 'device': await _api.device()});
    if (r is! ApiOk<Map<String, dynamic>>) throw StateError((r as ApiFail<Map<String, dynamic>>).error.message);
    await _api.saveTokens(r.data);
    return sessionFrom(r.data);
  }
}
