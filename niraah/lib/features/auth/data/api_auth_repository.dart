import '../../../core/network/niraah_api.dart';
import '../../../shared/helpers/result.dart';
import '../domain/auth_repository.dart';

/// Member sign-in and the second check on `/api/v1` (spec 003 T16). Failure messages come from the
/// server and are safe to show; they never say whether an account exists.
class ApiAuthRepository implements AuthRepository, SecondCheckRepository {
  ApiAuthRepository(this._api);

  final NiraahApi _api;

  static CodeOutcome outcomeFor(String workspace) => switch (workspace) {
        'member_new' => CodeOutcome.newAccount,
        'assessment_gate' => CodeOutcome.assessmentGate,
        'member' => CodeOutcome.home,
        'second_check' => CodeOutcome.secondCheck,
        'paused' => CodeOutcome.paused,
        'deletion_pending' => CodeOutcome.deletionPending,
        _ => CodeOutcome.suspended,
      };

  @override
  Future<Result<void>> requestCode(String phoneE164) async {
    final ApiResult<Map<String, dynamic>> r = await _api.post('/auth/code/request', <String, dynamic>{'phone': phoneE164, 'device': await _api.device()});
    return switch (r) {
      ApiOk<Map<String, dynamic>>() => const Success<void>(null),
      // The human check is not yet available in the app; the message tells her to wait (plan 003).
      ApiFail<Map<String, dynamic>>(:final ApiError error) => FailureResult<void>(error.message),
    };
  }

  @override
  Future<Result<CodeOutcome>> verifyCode(String phoneE164, String code) async {
    final ApiResult<Map<String, dynamic>> r =
        await _api.post('/auth/code/verify', <String, dynamic>{'phone': phoneE164, 'code': code, 'device': await _api.device()});
    switch (r) {
      case ApiOk<Map<String, dynamic>>(:final Map<String, dynamic> data):
        await _api.saveTokens(data);
        return Success<CodeOutcome>(outcomeFor('${(data['user'] as Map?)?['workspace']}'));
      case ApiFail<Map<String, dynamic>>(:final ApiError error):
        return FailureResult<CodeOutcome>(error.message);
    }
  }

  @override
  Future<Result<void>> signInWithPassword(String email, String password) async =>
      // Providers and admins sign in through ProviderAuthRepository.
      const FailureResult<void>('not_connected');

  @override
  Future<Result<void>> saveAccountDetails({
    required String displayName,
    required String termsVersion,
    required String privacyVersion,
    String? recoveryEmail,
  }) async {
    // POST /me/account (spec 010 "Create account"): the name and the accepted terms and privacy
    // versions. A recovery email needs a fresh proof (second check), so it is added afterwards from
    // Me > Privacy, never here; [recoveryEmail] is accepted for the interface and not sent.
    final ApiResult<Map<String, dynamic>> r = await _api.post('/me/account', <String, dynamic>{
      'displayName': displayName.trim(),
      'termsVersion': termsVersion,
      'privacyVersion': privacyVersion,
    });
    return switch (r) {
      ApiOk<Map<String, dynamic>>() => const Success<void>(null),
      ApiFail<Map<String, dynamic>>(:final ApiError error) => FailureResult<void>(error.message),
    };
  }

  // --- Second check ---

  @override
  Future<SecondCheckOptions?> options() async {
    final ApiResult<Map<String, dynamic>> r = await _api.get('/auth/second-check');
    if (r is! ApiOk<Map<String, dynamic>>) return null;
    final List<dynamic> methods = (r.data['methods'] as List<dynamic>?) ?? <dynamic>[];
    return SecondCheckOptions(
      methods: methods
          .map((dynamic m) => switch ('$m') {
                'recovery_email' => SecondCheckMethod.recoveryEmail,
                'date_of_birth' => SecondCheckMethod.dateOfBirth,
                _ => SecondCheckMethod.knownDevice,
              })
          .toList(),
      contactSupport: r.data['contactSupport'] == true,
    );
  }

  @override
  Future<bool> sendEmailCode() async => (await _api.post('/auth/second-check/email')) is ApiOk;

  @override
  Future<SecondCheckAnswer> answer(SecondCheckMethod method, String answer) async {
    final String key = switch (method) {
      SecondCheckMethod.recoveryEmail => 'recovery_email',
      SecondCheckMethod.dateOfBirth => 'date_of_birth',
      SecondCheckMethod.knownDevice => 'known_device',
    };
    final String value = method == SecondCheckMethod.knownDevice ? await _api.store.deviceId() : answer.trim();
    final ApiResult<Map<String, dynamic>> r = await _api.post('/auth/second-check/answer', <String, dynamic>{'method': key, 'answer': value});
    return switch (r) {
      ApiOk<Map<String, dynamic>>() => const SecondCheckPassed(),
      ApiFail<Map<String, dynamic>>(:final ApiError error) => SecondCheckWrong(error.message, ended: error.code == 'rate_limited'),
    };
  }

  @override
  Future<bool> notMyAccount() async => (await _api.post('/auth/second-check/not-my-account', <String, dynamic>{'confirm': true})) is ApiOk;

  @override
  Future<void> signOut() async {
    await _api.post('/auth/sign-out');
    await _api.store.clear();
  }
}
