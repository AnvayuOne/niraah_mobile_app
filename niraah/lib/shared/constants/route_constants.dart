class RouteConstants {
  const RouteConstants._();

  static const String splash = '/';
  static const String intro = '/intro';
  static const String welcome = '/welcome';
  static const String signIn = '/sign-in';
  static const String signInCode = '/sign-in/code';
  static const String signInPassword = '/sign-in/password';
  static const String signInAuthenticator = '/sign-in/authenticator';
  static const String signInSecondCheck = '/sign-in/second-check';
  static const String signInNewAuthenticator = '/sign-in/authenticator/new';
  static const String accountStatus = '/account/status';
  static const String admin = '/admin';
  static const String setup = '/setup';
  static const String providerStatus = '/provider/status';
  static const String accountDetails = '/account/details';
  static const String assessmentStart = '/assessment/start';
  static const String assessment = '/assessment';
  static const String processing = '/assessment/processing';
  static const String preScore = '/assessment/result';
  static const String minimumAge = '/account/paused';
  static const String plans = '/plans';
  static const String home = '/home';
  static const String bookDoctor = '/specialists';
  static const String support = '/support';
  static const String symptoms = '/symptoms';
  static const String cycle = '/cycle';
  static const String chat = '/chat';
  static const String meals = '/meals';
  static const String mealScan = '/meals/scan';

  /// `/area/<name>`: an area with no screen yet.
  static const String area = '/area';

  // Practice tab (spec 010 §7).
  static const String practice = '/practice';
  static const String practiceLibrary = '/practice/library';
  static const String practiceHistory = '/practice/history';
  static const String practiceSession = '/practice/session';

  /// A live class room: `/classes/<class id>/room` (spec 014 §8).
  static const String classes = '/classes';

  // Me tab and the areas reached from it (spec 010 §9-§13).
  static const String me = '/me';
  static const String profile = '/me/profile';
  static const String privacy = '/me/privacy';
  static const String notificationSettings = '/me/notifications';
  static const String programs = '/programs';
  static const String carePlan = '/care-plan';
  static const String checkIns = '/check-ins';
  static const String labs = '/labs';
  static const String community = '/community';
  static const String messages = '/messages';

  // Consults (spec 014; spec 010 §9). `bookDoctor` is "Find a specialist"; `/specialists/<id>` is a profile.
  static const String bookPooled = '/consults/book';
  static const String appointments = '/appointments';

  /// Camera, microphone and connection check (spec 014 §4.4).
  static const String deviceCheck = '/device-check';
  static const String wellnessAdvice = '/wellness-advice';

  // Manage plan and invoices (spec 008 §4, §8; spec 010 §5.6).
  static const String managePlan = '/me/plan';
  static const String invoices = '/me/invoices';

  // Sign-in settings (spec 003 "Sessions", "Changing a mobile number", "Recovery").
  static const String signedInDevices = '/me/devices';
  static const String changeNumber = '/me/number';
  static const String recoveryEmail = '/me/recovery-email';
}
