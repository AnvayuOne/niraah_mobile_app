/// Her sign-in settings (spec 003 "Sessions" 7-8, "Changing a mobile number", "Recovery" 4; spec 010 §13 "Profile" 2,
/// "Privacy" 7), matching packages/contracts/src/auth.ts `SessionList` and security.ts `NumberChangeStart`,
/// `PendingChanges`, `RecoveryEmailSet`. Each sensitive change needs a fresh code first (spec 003 "Sensitive actions").
library;

import 'package:equatable/equatable.dart';

class SignedInSession extends Equatable {
  const SignedInSession({required this.id, required this.deviceType, required this.city, required this.lastActiveAt, required this.current});

  final String id;
  final String deviceType;

  /// Approximate, by city; null when unknown.
  final String? city;
  final DateTime lastActiveAt;

  /// This device.
  final bool current;

  @override
  List<Object?> get props => <Object?>[id, deviceType, city, lastActiveAt, current];
}

/// A change of number waiting for its 24 hours, which the old number can cancel (spec 003 "Changing a mobile number" 4).
class PendingNumberChange extends Equatable {
  const PendingNumberChange({required this.id, required this.newNumberEnding, required this.effectiveAt});

  final String id;
  final String newNumberEnding;
  final DateTime effectiveAt;

  @override
  List<Object?> get props => <Object?>[id, newNumberEnding, effectiveAt];
}

abstract class AccountRepository {
  Future<List<SignedInSession>> sessions();

  Future<void> endSession(String id);

  /// Ends every session of the account, this one included (spec 003 "Sessions" 7).
  Future<void> signOutEverywhere();

  /// Sends a code to the new number. Needs a fresh proof.
  Future<void> startNumberChange({required String proofId, required String phone});

  /// The code from the new number; the change takes effect and every other session ends.
  Future<void> confirmNumberChange(String code);

  Future<List<PendingNumberChange>> pendingNumberChanges();

  Future<void> cancelNumberChange(String id);

  /// Counts once she opens the link sent to it (spec 003 "Recovery" 4).
  Future<void> setRecoveryEmail({required String proofId, required String email});

  Future<void> removeRecoveryEmail(String proofId);
}
