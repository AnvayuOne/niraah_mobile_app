// SAMPLE ONLY (constitution §2 rule 6), imported only from sample wiring.

import '../features/auth/domain/auth_repository.dart';

/// Any date of birth passes in the sample; the real check is server-side (spec 003 "Second check").
class SampleSecondCheckRepository implements SecondCheckRepository {
  @override
  Future<SecondCheckOptions?> options() async =>
      const SecondCheckOptions(methods: <SecondCheckMethod>[SecondCheckMethod.dateOfBirth], contactSupport: false);

  @override
  Future<bool> sendEmailCode() async => true;

  @override
  Future<SecondCheckAnswer> answer(SecondCheckMethod method, String answer) async =>
      answer.trim().isEmpty ? const SecondCheckWrong('That does not match our records.') : const SecondCheckPassed();

  @override
  Future<bool> notMyAccount() async => true;

  @override
  Future<void> signOut() async {}
}
