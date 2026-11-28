import '../../doctor/domain/doctor.dart';
import '../../home/data/unavailable_home_repository.dart';
import '../domain/provider_auth.dart';

/// Used by `main.dart` until spec 003's provider endpoints exist.
class UnavailableProviderAuthRepository implements ProviderAuthRepository {
  const UnavailableProviderAuthRepository();

  @override
  bool get sampleMode => false;

  @override
  Future<StepResult> checkPassword(String email, String password) async => throw const HomeNotConnected();

  @override
  Future<ProviderSession?> verifySecondFactor(String code, SecondFactorKind kind) async => throw const HomeNotConnected();

  @override
  Future<AuthenticatorSetup?> startReenrol() async => null;

  @override
  Future<ProviderSession?> confirmReenrol(String factorId, String code) async => null;

  @override
  Future<AuthenticatorSetup?> startAuthenticator(String token) async => null;

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<ProviderSession?> currentSession() async => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<InviteInfo?> getInvite(String token) async => null;

  @override
  Future<PasswordRejection?> setPassword(String token, String password) async => throw const HomeNotConnected();

  @override
  Future<List<String>?> confirmAuthenticator(String token, String code) async => throw const HomeNotConnected();

  @override
  Future<ProviderSession> finishSetup(String token) async => throw const HomeNotConnected();
}

/// Used by `main.dart` until spec 011's endpoints exist.
class UnavailableDoctorRepository implements DoctorRepository {
  const UnavailableDoctorRepository();

  @override
  Future<DoctorDashboard> getDashboard() async => throw const HomeNotConnected();

  @override
  Future<List<QueueItem>> getQueue() async => throw const HomeNotConnected();

  @override
  Future<ClaimResult> claim(String id) async => throw const HomeNotConnected();

  @override
  Future<void> release(String id) async => throw const HomeNotConnected();

  @override
  Future<ReviewDetail> editObservation(String id, int index, String? text) async => throw const HomeNotConnected();

  @override
  Future<CompleteResult> complete(String id, ReviewOutcome outcome, String note, {bool next = false}) async => throw const HomeNotConnected();

  @override
  Future<void> scoringConcern(String id, String note) async => throw const HomeNotConnected();
}
