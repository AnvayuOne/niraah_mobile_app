import 'package:equatable/equatable.dart';

/// Provider and admin sign-in (spec 003), matching
/// apps/web/src/features/provider-auth/types.ts.

/// Admins sign in here too, but their workspace is web only (spec 001 "Clients at launch").
enum ProviderRole { doctor, dietitian, instructor, admin }

enum ProviderStatus { active, underReview }

/// The signed-in provider as the server reports it; the client routes by role
/// (spec 001 AC1).
class ProviderSession extends Equatable {
  const ProviderSession({required this.role, required this.status, required this.name, required this.speciality, this.missing = const <String>[]});

  final ProviderRole role;
  final ProviderStatus status;
  final String name;
  final String speciality;

  /// What her application still needs, while under review.
  final List<String> missing;

  @override
  List<Object?> get props => <Object?>[role, status, name, speciality, missing];
}

/// Every failure has the same shape, so nothing reveals whether an account
/// exists, is suspended or is not set up (spec 003 "Not revealing accounts", AC4).
enum StepFailure { generic, locked }

class StepResult {
  const StepResult.ok() : failure = null;
  const StepResult.failed(StepFailure this.failure);

  final StepFailure? failure;

  bool get ok => failure == null;
}

enum SecondFactorKind { authenticator, recovery }

class InviteInfo extends Equatable {
  const InviteInfo({required this.email, required this.name, required this.role});

  final String email;
  final String name;
  final ProviderRole role;

  @override
  List<Object?> get props => <Object?>[email, name, role];
}

enum PasswordRejection { tooShort, breached }

abstract interface class ProviderAuthRepository {
  /// True only in the sample build, which shows the sample hints.
  bool get sampleMode;

  /// Password step. Success opens the authenticator step; it never signs in on
  /// its own (AC20).
  Future<StepResult> checkPassword(String email, String password);

  /// Authenticator step, or a single-use recovery code in its place
  /// (spec 003 recovery 2). Null when the code is not right. Throws
  /// [NewAuthenticatorRequired] after a recovery code that worked: a new
  /// authenticator must be added before any session (AC25).
  Future<ProviderSession?> verifySecondFactor(String code, SecondFactorKind kind);

  /// After [NewAuthenticatorRequired]: the key and code to scan.
  Future<AuthenticatorSetup?> startReenrol();

  /// Confirms the new authenticator and signs in; null when the code is not right.
  Future<ProviderSession?> confirmReenrol(String factorId, String code);

  /// Always the same answer (AC5).
  Future<void> forgotPassword(String email);

  Future<ProviderSession?> currentSession();

  Future<void> signOut();

  // Invited set-up (spec 003 "Setting up a provider or admin account").

  /// Null for an expired, used or unknown link.
  Future<InviteInfo?> getInvite(String token);

  /// Null when accepted.
  Future<PasswordRejection?> setPassword(String token, String password);

  /// The authenticator key to add (set-up step 2), after the password step.
  Future<AuthenticatorSetup?> startAuthenticator(String token);

  /// Ten single-use recovery codes, or null when the code is not right.
  Future<List<String>?> confirmAuthenticator(String token, String code);

  Future<ProviderSession> finishSetup(String token);
}

/// Where a signed-in provider lands: her role's workspace, or the status page
/// until approved (spec 001 AC1, AC5). Mirrors route.ts `homeFor`.
String homeFor(ProviderSession session) {
  if (session.role == ProviderRole.admin) return '/admin';
  if (session.status != ProviderStatus.active) return '/provider/status';
  return switch (session.role) {
    ProviderRole.doctor => '/doctor',
    ProviderRole.dietitian => '/dietitian',
    ProviderRole.instructor => '/instructor',
    ProviderRole.admin => '/admin',
  };
}

/// An authenticator to add: the key to type, the otpauth URI, and the factor to confirm.
class AuthenticatorSetup extends Equatable {
  const AuthenticatorSetup({required this.factorId, required this.secret, required this.otpauthUri});

  final String factorId;
  final String secret;
  final String otpauthUri;

  @override
  List<Object?> get props => <Object?>[factorId, secret, otpauthUri];
}

/// A recovery code worked; a new authenticator is needed before any session (spec 003 AC25).
class NewAuthenticatorRequired implements Exception {
  const NewAuthenticatorRequired();
}
