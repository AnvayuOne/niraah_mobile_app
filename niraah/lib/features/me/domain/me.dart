/// The Me tab as the server returns it (spec 010 §13, "Navigation", "Limits and plans"), matching
/// packages/contracts/src/member.ts `Workspace`, `Profile`, `Privacy`, `Exports`; billing.ts `CurrentPlan`;
/// messaging.ts `NotificationSettings`. The server decides every area's state; the app only shows it (AC4).
library;

/// One area of her workspace: available, locked with the plans that include it, or starting after the trial.
class AreaState {
  const AreaState({required this.key, required this.name, required this.status, this.description, this.plans = const <String>[], this.startsOn, this.text});

  final String key;
  final String name;

  /// `available`, `locked` or `starts_after_trial`. An area her account can never use is not listed at all.
  final String status;
  final String? description;
  final List<String> plans;
  final String? startsOn;
  final String? text;

  bool get available => status == 'available';
}

class Workspace {
  const Workspace({required this.displayName, required this.accountKind, required this.areas});

  final String? displayName;
  final String accountKind;
  final List<AreaState> areas;

  AreaState? area(String key) {
    for (AreaState a in areas) {
      if (a.key == key) return a;
    }
    return null;
  }

  bool get teen => accountKind == 'teen';
}

class Profile {
  const Profile({
    required this.displayName,
    required this.phone,
    required this.language,
    required this.timeZone,
    required this.dateOfBirth,
    required this.heightCm,
    required this.goals,
    required this.recoveryEmail,
    required this.personalisedAi,
    required this.accountKind,
  });

  final String? displayName;
  final String? phone;
  final String language;
  final String timeZone;

  /// Read-only after the assessment; corrected through support (spec 010 §13 "Profile" 1).
  final String? dateOfBirth;
  final double? heightCm;
  final List<String> goals;
  final String? recoveryEmail;
  final bool personalisedAi;
  final String accountKind;
}

class CurrentPlan {
  const CurrentPlan({required this.name, required this.status, required this.priceDisplay, required this.renewsAt, required this.endsAt, required this.cancelled, required this.retired});

  final String name;
  final String status;
  final String? priceDisplay;
  final String? renewsAt;
  final String? endsAt;
  final bool cancelled;
  final bool retired;
}

class Consent {
  const Consent({required this.id, required this.who, required this.role, required this.kind, required this.category, required this.purpose, required this.givenOn});

  final String id;
  final String who;
  final String? role;
  final String kind;
  final String category;
  final String purpose;
  final String givenOn;
}

class StaffAccess {
  const StaffAccess({required this.on, required this.reason});

  final String on;
  final String reason;
}

class PrivacyDocument {
  const PrivacyDocument({required this.consents, required this.staffAccess, required this.personalisedAi, required this.accountKind});

  final List<Consent> consents;
  final List<StaffAccess> staffAccess;
  final bool personalisedAi;
  final String accountKind;
}

class DataExport {
  const DataExport({required this.id, required this.status, required this.requestedAt, required this.expiresAt});

  final String id;

  /// `requested`, `preparing`, `ready` or `expired`, as the server names them.
  final String status;
  final String requestedAt;
  final String? expiresAt;

  bool get ready => status == 'ready';
}

class ChannelSwitch {
  const ChannelSwitch({required this.channel, required this.enabled});

  final String channel;
  final bool enabled;
}

class NotificationCategory {
  const NotificationCategory({required this.key, required this.name, required this.locked, required this.lockedReason, required this.channels});

  final String key;
  final String name;

  /// Notices the service must send (security, payment, appointment changes): shown as always on, with the reason.
  final bool locked;
  final String? lockedReason;
  final List<ChannelSwitch> channels;
}

class NotificationSettings {
  const NotificationSettings({required this.categories, required this.discreetNote});

  final List<NotificationCategory> categories;
  final String discreetNote;
}

abstract class MeRepository {
  Future<Workspace> workspace();

  Future<Profile> profile();

  Future<Profile> updateProfile({String? displayName, double? heightCm, List<String>? goals});

  /// Her current plan, or null when she has none yet.
  Future<CurrentPlan?> currentPlan();

  Future<PrivacyDocument> privacy();

  /// Withdraws at once (spec 001); returns the updated screen (AC44).
  Future<PrivacyDocument> withdrawConsent(String id);

  Future<void> setPersonalisedAi(bool on);

  Future<void> deleteChatHistory();

  Future<List<DataExport>> exports();

  Future<List<DataExport>> requestExport();

  /// The export as JSON; needs a fresh sign-in check (AC45).
  Future<Map<String, dynamic>> downloadExport(String id, String proofId);

  /// Sends a code to her current number before a sensitive action (spec 003 "Sensitive actions").
  Future<void> requestFreshCode();

  /// The code she received; returns a 10-minute proof.
  Future<String> verifyFreshCode(String code);

  /// Starts the grace period; returns the date deletion happens (AC46).
  Future<String> requestDeletion(String proofId);

  Future<void> cancelDeletion();

  Future<NotificationSettings> notificationSettings();

  Future<NotificationSettings> setNotification(String category, String channel, bool enabled);

  Future<void> signOut();
}
