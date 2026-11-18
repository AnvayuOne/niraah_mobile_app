import '../../../shared/helpers/result.dart';
import '../domain/auth_repository.dart';

/// Used by `main.dart` until spec 003's endpoints exist.
class UnavailableAuthRepository implements AuthRepository {
  const UnavailableAuthRepository();

  @override
  Future<Result<void>> requestCode(String phoneE164) async => const FailureResult<void>('not_connected');

  @override
  Future<Result<CodeOutcome>> verifyCode(String phoneE164, String code) async => const FailureResult<CodeOutcome>('not_connected');

  @override
  Future<Result<void>> signInWithPassword(String email, String password) async => const FailureResult<void>('not_connected');

  @override
  Future<Result<void>> saveAccountDetails({
    required String displayName,
    required String termsVersion,
    required String privacyVersion,
    String? recoveryEmail,
  }) async =>
      const FailureResult<void>('not_connected');
}
