import '../../../shared/constants/route_constants.dart';
import '../../../shared/helpers/result.dart';

/// Result of a correct code (spec 003 "Member: one-time code" 7, "Account states at sign-in").
enum CodeOutcome {
  /// The number had no account: one was created and needs its details.
  newAccount,
  signedIn,

  /// Registered with details, assessment not finished.
  assessmentGate,

  /// Active member: straight to home.
  home,

  /// Long absence, or a new device on an account with health data (spec 003 "Second check").
  secondCheck,

  /// Paused, suspended or pending deletion: a neutral screen with no data.
  paused,
  suspended,
  deletionPending,

  /// Staff who signed in with a code (demo staff numbers on local and staging): their own workspace.
  doctor,
  dietitian,
  instructor,
  admin,

  /// A provider whose application is not approved yet.
  providerStatus,
}

/// Where each outcome lands (mirrors the web's homeForWorkspace).
String routeForOutcome(CodeOutcome o) => switch (o) {
      CodeOutcome.newAccount => RouteConstants.accountDetails,
      CodeOutcome.signedIn || CodeOutcome.assessmentGate => RouteConstants.assessmentStart,
      CodeOutcome.home => RouteConstants.home,
      CodeOutcome.secondCheck => RouteConstants.signInSecondCheck,
      CodeOutcome.paused => '${RouteConstants.accountStatus}?state=paused',
      CodeOutcome.suspended => '${RouteConstants.accountStatus}?state=suspended',
      CodeOutcome.deletionPending => '${RouteConstants.accountStatus}?state=deletion_pending',
      CodeOutcome.doctor => '/doctor',
      CodeOutcome.dietitian => '/dietitian',
      CodeOutcome.instructor => '/instructor',
      CodeOutcome.admin => RouteConstants.admin,
      CodeOutcome.providerStatus => RouteConstants.providerStatus,
    };

/// The second check (spec 003 "Second check"). Nothing about the account is shown until it passes.
enum SecondCheckMethod { recoveryEmail, dateOfBirth, knownDevice }

class SecondCheckOptions {
  const SecondCheckOptions({required this.methods, required this.contactSupport});

  final List<SecondCheckMethod> methods;
  final bool contactSupport;
}

sealed class SecondCheckAnswer {
  const SecondCheckAnswer();
}

class SecondCheckPassed extends SecondCheckAnswer {
  const SecondCheckPassed();
}

class SecondCheckWrong extends SecondCheckAnswer {
  const SecondCheckWrong(this.message, {this.ended = false});

  final String message;

  /// Three wrong answers end the session (AC44).
  final bool ended;
}

abstract interface class SecondCheckRepository {
  Future<SecondCheckOptions?> options();
  Future<bool> sendEmailCode();

  /// For [SecondCheckMethod.knownDevice] the answer is ignored; the app sends its own device id.
  Future<SecondCheckAnswer> answer(SecondCheckMethod method, String answer);

  /// "This is not my account": a new, empty account under this number (AC45).
  Future<bool> notMyAccount();

  Future<void> signOut();
}

/// Sign-in (spec 003). Members use a mobile number and a one-time code;
/// providers and admins use email, password and an authenticator.
abstract interface class AuthRepository {
  /// Sends a code. The same response whether or not an account exists.
  Future<Result<void>> requestCode(String phoneE164);

  /// Verifies the code. The server holds the session; the app stores no
  /// readable token itself (constitution §5.9).
  Future<Result<CodeOutcome>> verifyCode(String phoneE164, String code);

  /// Email and password for providers and admins. Every failure gives the
  /// same message (spec 003).
  Future<Result<void>> signInWithPassword(String email, String password);

  /// Create-account details (spec 010 §1.3).
  Future<Result<void>> saveAccountDetails({
    required String displayName,
    required String termsVersion,
    required String privacyVersion,
    String? recoveryEmail,
  });
}

/// What was typed into the single "Mobile number or email" field (spec 003).
sealed class SignInInput {
  const SignInInput();

  /// Digits (with or without +91, spaces or dashes) are a mobile number;
  /// anything containing "@" is an email; anything else is not accepted.
  static SignInInput parse(String raw) {
    final String s = raw.trim();
    if (s.contains('@')) return EmailInput(s);
    if (s.isNotEmpty && RegExp(r'^\+?[0-9][0-9\s-]*$').hasMatch(s)) {
      final String digits = s.replaceAll(RegExp(r'[^0-9]'), '');
      final String local = digits.length == 12 && digits.startsWith('91') ? digits.substring(2) : digits;
      return PhoneInput(local);
    }
    return const UnrecognisedInput();
  }
}

class PhoneInput extends SignInInput {
  const PhoneInput(this.localDigits);

  final String localDigits;

  /// Indian mobile numbers at launch: 10 digits starting 6 to 9.
  bool get isValid => RegExp(r'^[6-9][0-9]{9}$').hasMatch(localDigits);

  String get e164 => '+91$localDigits';

  /// Shown on the code step.
  String get display => '+91 ${localDigits.substring(0, 5)} ${localDigits.substring(5)}';
}

class EmailInput extends SignInInput {
  const EmailInput(this.email);

  final String email;
}

class UnrecognisedInput extends SignInInput {
  const UnrecognisedInput();
}
