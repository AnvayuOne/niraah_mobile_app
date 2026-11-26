// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Niraah';

  @override
  String get back => 'Back';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get continueLabel => 'Continue';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonBody => 'This part of Niraah is still being built.';

  @override
  String get goHome => 'Go to home';

  @override
  String get somethingWentWrong =>
      'We couldn\'t load this just now. Your answers are safe.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get loading => 'Loading';

  @override
  String get notConnectedYet =>
      'This screen isn\'t connected to Niraah\'s servers yet.';

  @override
  String get navHome => 'Home';

  @override
  String get navCycle => 'Cycle';

  @override
  String get navAiCare => 'AI Care';

  @override
  String get navPractice => 'Practice';

  @override
  String get navMe => 'Me';

  @override
  String get splashLabel => 'Niraah, women\'s wellness';

  @override
  String get introTitle1 => 'Know your cycle, know yourself';

  @override
  String get introBody1 =>
      'Track your period, ovulation and symptoms, all in one calm place.';

  @override
  String get introTitle2 => 'Care for PCOS, fertility and more';

  @override
  String get introBody2 =>
      'Guidance for hormones, nutrition and movement, shaped around you.';

  @override
  String get introTitle3 => 'Checked by real doctors';

  @override
  String get introBody3 =>
      'On plans that include it, a Niraah doctor reviews your care.';

  @override
  String introSlideLabel(int current, int total) {
    return 'Slide $current of $total';
  }

  @override
  String get welcomeTitle => 'Your holistic wellness journey';

  @override
  String get welcomeBody =>
      'Niraah helps you understand your cycle, hormones and daily habits, with AI guidance and care from doctors and dietitians.';

  @override
  String get welcomeWellness =>
      'Niraah is a wellness service. It does not replace your own doctor and is not for emergencies.';

  @override
  String get welcomeContinue => 'Get started';

  @override
  String get signInTitle => 'Welcome to Niraah';

  @override
  String get signInBody =>
      'Enter your mobile number and we\'ll send you a code.';

  @override
  String get signInFieldLabel => 'Mobile number or email';

  @override
  String get signInCountryCode => '+91';

  @override
  String get signInContinueHint => 'Enter a mobile number or an email';

  @override
  String get signInUnrecognised => 'Enter a mobile number or an email';

  @override
  String get signInPhoneInvalid =>
      'Check the number: an Indian mobile number has 10 digits.';

  @override
  String get signInNumberHint => 'We\'ll send a 6-digit code by SMS.';

  @override
  String get signInEmailHint =>
      'Doctors, dietitians, instructors and staff sign in with email.';

  @override
  String get passwordTitle => 'Enter your password';

  @override
  String passwordFor(String email) {
    return 'Signing in as $email';
  }

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordContinueHint => 'Enter your password to continue';

  @override
  String get passwordRejected => 'That email or password is not right.';

  @override
  String get passwordForgot => 'Forgot password?';

  @override
  String get passwordChangeEmail => 'Use a different email';

  @override
  String get codeTitle => 'Enter your code';

  @override
  String codeBody(String masked) {
    return 'We sent a 6-digit code to $masked.';
  }

  @override
  String get codeFieldLabel => '6-digit code';

  @override
  String get codeContinueHint => 'Enter the 6 digits to continue';

  @override
  String get codeVerify => 'Verify';

  @override
  String codeResendIn(int seconds) {
    return 'Send a new code in ${seconds}s';
  }

  @override
  String get codeResend => 'Send a new code';

  @override
  String codeExpiresIn(String minutes, String seconds) {
    return 'Code expires in $minutes:$seconds';
  }

  @override
  String get codeExpired => 'This code has expired. Send a new one.';

  @override
  String get codeChangeNumber => 'Change number';

  @override
  String get codeNotAccepted =>
      'That code didn\'t work. Check it and try again.';

  @override
  String get detailsTitle => 'Let\'s set up your account';

  @override
  String get detailsBody => 'Just a couple of things before we begin.';

  @override
  String get detailsNameLabel => 'What should we call you?';

  @override
  String get detailsNameHint => 'Your first name';

  @override
  String get detailsEmailLabel => 'Recovery email (optional)';

  @override
  String get detailsEmailHelp =>
      'Only used to help you get back into your account. You can\'t sign in with it.';

  @override
  String get detailsEmailInvalid =>
      'Check the email address, or leave it empty.';

  @override
  String get detailsAgree =>
      'I agree to the Terms of Service and the Privacy Notice.';

  @override
  String get detailsTermsLink => 'Read the Terms of Service';

  @override
  String get detailsPrivacyLink => 'Read the Privacy Notice';

  @override
  String get detailsContinue => 'Continue';

  @override
  String get detailsContinueHint => 'Add your name and agree to continue';

  @override
  String get consentTitle => 'Before we begin';

  @override
  String get consentBody =>
      'A few gentle questions about your cycle, mood and daily life help us understand where you are today.';

  @override
  String consentDuration(int minutes) {
    return 'About $minutes minutes';
  }

  @override
  String get consentResume =>
      'You can stop at any time and pick up where you left off.';

  @override
  String get consentReviewByPlan =>
      'On plans that include it, a Niraah doctor reviews your result. On the free plan, your result comes from our doctor-built rules and AI.';

  @override
  String get consentHealthData =>
      'I agree that Niraah may store and use my health answers to personalise my care.';

  @override
  String get consentDoctorReview =>
      'When my plan includes it, let a Niraah doctor review my result.';

  @override
  String get consentStart => 'Start';

  @override
  String get consentStartHint => 'Tick the first box to continue';

  @override
  String consentTextVersion(String version) {
    return 'Consent text version $version';
  }

  @override
  String get assessmentSection => 'About you';

  @override
  String assessmentStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get assessmentChooseToContinue => 'Choose an answer to continue';

  @override
  String get assessmentSeeResult => 'See my result';

  @override
  String get assessmentChooseDate => 'Choose your date of birth';

  @override
  String assessmentDateChosen(String date) {
    return 'Born $date';
  }

  @override
  String assessmentScaleSelected(String label) {
    return 'Selected: $label';
  }

  @override
  String get assessmentTextHint => 'Type here';

  @override
  String get assessmentSaveFailed =>
      'We couldn\'t save that answer. Check your connection and try again.';

  @override
  String get assessmentUpdateApp =>
      'This question needs a newer version of the app. Please update Niraah to continue.';

  @override
  String get minimumAgeTitle => 'Niraah is for adults for now';

  @override
  String get minimumAgeBody =>
      'Thank you for your interest. Niraah\'s care is designed for women aged 18 and over, so we\'ve paused this account. Nothing you shared about your health has been stored.';

  @override
  String get minimumAgeWrongDate =>
      'If you entered your date of birth by mistake, our support team can correct it.';

  @override
  String get minimumAgeContact => 'Contact support';

  @override
  String get processingTitle => 'Reading your answers';

  @override
  String get processingBody => 'This takes a few seconds.';

  @override
  String get prescoreTitle => 'Your wellness pre-score';

  @override
  String prescoreOutOf(int maximum) {
    return 'out of $maximum';
  }

  @override
  String prescoreScoreLabel(int total, int maximum, String band) {
    return 'Your pre-score is $total out of $maximum. $band.';
  }

  @override
  String get prescoreNotDiagnosis =>
      'This is not a diagnosis. It\'s a starting point for your care.';

  @override
  String get prescoreNoticed => 'What we noticed';

  @override
  String get prescoreAreas => 'Your areas';

  @override
  String get prescoreProgram => 'Suggested for you';

  @override
  String get prescoreFreeNoDoctor =>
      'Niraah has not passed this to a doctor. Please see a doctor yourself soon.';

  @override
  String get nextBookDoctor => 'Book a doctor';

  @override
  String get nextSeePlans => 'See plans';

  @override
  String get nextGoHome => 'Go to home';

  @override
  String get clinicianNotRequired => 'Built on guidance from our doctors.';

  @override
  String clinicianIncludedIn(String plans) {
    return 'A doctor\'s review is included with $plans.';
  }

  @override
  String clinicianAwaiting(String target) {
    return 'A doctor will review this within $target.';
  }

  @override
  String get clinicianVerified => 'Clinician Verified';

  @override
  String clinicianVerifiedBy(String name, String speciality) {
    return '$name · $speciality';
  }

  @override
  String clinicianFollowUp(String name) {
    return '$name would like to talk with you';
  }

  @override
  String get clinicianBook => 'Book a consult';

  @override
  String get plansTitle => 'Choose your plan';

  @override
  String get plansBody =>
      'Every plan includes AI Care chat. You can change or cancel any time.';

  @override
  String get plansRecommended => 'Recommended for you';

  @override
  String get plansCurrent => 'Your plan';

  @override
  String get plansFreePrice => 'Free';

  @override
  String get plansFreeNote => 'No payment needed';

  @override
  String plansEvery(int count, String unit) {
    return 'every $count $unit';
  }

  @override
  String plansFor(int count, String unit) {
    return 'for $count $unit';
  }

  @override
  String plansIncludesGst(String validity) {
    return '$validity, including GST';
  }

  @override
  String plansUnitDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$_temp0';
  }

  @override
  String plansUnitWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'weeks',
      one: 'week',
    );
    return '$_temp0';
  }

  @override
  String plansUnitMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'months',
      one: 'month',
    );
    return '$_temp0';
  }

  @override
  String plansUnitYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'years',
      one: 'year',
    );
    return '$_temp0';
  }

  @override
  String plansStartTrial(int days) {
    return 'Start $days-day free trial';
  }

  @override
  String plansChoose(String name) {
    return 'Choose $name';
  }

  @override
  String get plansContinueFree => 'Continue free';

  @override
  String plansUnlimited(String name) {
    return '$name: unlimited';
  }

  @override
  String plansLimit(String name, int amount, String period) {
    return '$name: $amount a $period';
  }

  @override
  String plansQuantity(String name, int amount, String period) {
    return '$name: $amount a $period';
  }

  @override
  String get plansPaymentLater =>
      'Payment in the app opens soon. You can keep using the free plan until then.';

  @override
  String get homeTitle => 'Home';

  @override
  String homeGreeting(String part, String name) {
    return 'Good $part, $name';
  }

  @override
  String homeGreetingNoName(String part) {
    return 'Good $part';
  }

  @override
  String get homePartMorning => 'morning';

  @override
  String get homePartAfternoon => 'afternoon';

  @override
  String get homePartEvening => 'evening';

  @override
  String get homeRingLabel => 'Your cycle';

  @override
  String homeDay(int n) {
    return 'Day $n';
  }

  @override
  String get homePhaseMenstrual => 'Period';

  @override
  String get homePhaseFollicular => 'Follicular phase';

  @override
  String get homePhaseOvulatory => 'Ovulatory phase';

  @override
  String get homePhaseLuteal => 'Luteal phase';

  @override
  String get homeEstimatedSuffix => 'estimated';

  @override
  String homeNextInSame(int a) {
    String _temp0 = intl.Intl.pluralLogic(
      a,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return 'Next period estimated in $a $_temp0';
  }

  @override
  String homeNextIn(int a, int b) {
    return 'Next period estimated in $a to $b days';
  }

  @override
  String homeNextBetween(String from, String to) {
    return 'Estimated between $from and $to';
  }

  @override
  String get homeLate => 'Your period is later than estimated.';

  @override
  String get homeFromAssessment =>
      'This estimate is based on your health check-in. Log two cycles for a closer one.';

  @override
  String get homeNoWindow =>
      'Not enough data yet to estimate your next period.';

  @override
  String get homeInvitation => 'Tell us when your last period started.';

  @override
  String get homeInvitationLabel => 'First day of your last period';

  @override
  String get homeSave => 'Save';

  @override
  String get homeSaveInactive => 'Choose a date to save';

  @override
  String get homeOffPregnant =>
      'Predictions are paused because you\'ve told us you\'re pregnant.';

  @override
  String get homeOffHormonalContraception =>
      'Predictions are paused because you\'ve told us you use hormonal contraception.';

  @override
  String get homeOffNoPeriods =>
      'Predictions are paused because you\'ve told us you\'re not having periods.';

  @override
  String get homeOffBreastfeeding =>
      'Predictions are paused while you\'re breastfeeding.';

  @override
  String get homeLogTitle => 'Today';

  @override
  String get homeLogFlow => 'Flow';

  @override
  String get homeLogMood => 'Mood';

  @override
  String get homeLogEnergy => 'Energy';

  @override
  String get homeLogSymptoms => 'Symptoms';

  @override
  String get homeNotLogged => 'Add';

  @override
  String get homeFlowNone => 'None';

  @override
  String get homeFlowSpotting => 'Spotting';

  @override
  String get homeFlowLight => 'Light';

  @override
  String get homeFlowMedium => 'Medium';

  @override
  String get homeFlowHeavy => 'Heavy';

  @override
  String get homeMoodCalm => 'Calm';

  @override
  String get homeMoodHappy => 'Happy';

  @override
  String get homeMoodLow => 'Low';

  @override
  String get homeMoodAnxious => 'Anxious';

  @override
  String get homeMoodIrritable => 'Irritable';

  @override
  String get homeEnergyLow => 'Low';

  @override
  String get homeEnergyOkay => 'Okay';

  @override
  String get homeEnergyHigh => 'High';

  @override
  String homePickerTitle(String field) {
    return '$field today';
  }

  @override
  String get homeClose => 'Close';

  @override
  String get homeSaved => 'Saved';

  @override
  String get homeSuggestionTitle => 'For today';

  @override
  String get homeAiMark => 'AI';

  @override
  String get homeFromLibrary => 'From Niraah\'s wellness library';

  @override
  String get homePrescoreTitle => 'Your wellness pre-score';

  @override
  String homePrescoreLine(int total, int max, String band) {
    return '$total out of $max · $band';
  }

  @override
  String get homeViewResult => 'View result';

  @override
  String get homeHide => 'Hide';

  @override
  String get homeHidePrescore => 'Hide pre-score card';

  @override
  String get homeReviewNotRequired => 'Built on guidance from our doctors.';

  @override
  String homeReviewAwaiting(String target) {
    return 'A doctor will review this within $target.';
  }

  @override
  String get homeGateTitle => 'Your health check-in comes first';

  @override
  String homeGateBody(int min) {
    String _temp0 = intl.Intl.pluralLogic(
      min,
      locale: localeName,
      other: 'minutes',
      one: 'minute',
    );
    return 'It takes about $min $_temp0. Everything else opens when you\'ve finished.';
  }

  @override
  String get homeGateBodyNoTime =>
      'Everything else opens when you\'ve finished.';

  @override
  String get homeGateAction => 'Continue';

  @override
  String get navLabel => 'Main';

  @override
  String navComingSoon(String area) {
    return '$area arrives in a later phase of the build.';
  }

  @override
  String get cycleTitle => 'Cycle';

  @override
  String get cycleLogPeriod => 'Log a period';

  @override
  String get cycleLogSymptoms => 'Log symptoms';

  @override
  String get cycleCalendarTitle => 'Calendar';

  @override
  String get cyclePrevMonth => 'Previous month';

  @override
  String get cycleNextMonth => 'Next month';

  @override
  String get cycleLegendLogged => 'Period, logged';

  @override
  String get cycleLegendPredicted => 'Next period, estimated';

  @override
  String get cycleLegendToday => 'Today';

  @override
  String get cycleDayLogged => 'period, logged';

  @override
  String get cycleDayPredicted => 'next period estimated';

  @override
  String get cycleDayToday => 'today';

  @override
  String get cycleDayHasLog => 'has a log';

  @override
  String get cycleHistoryTitle => 'Your cycles';

  @override
  String get cycleHistoryEmpty =>
      'Your cycle history appears here once you\'ve logged two periods.';

  @override
  String cycleHistoryRow(int cycle) {
    return '$cycle-day cycle';
  }

  @override
  String cyclePeriodDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return 'period $n $_temp0';
  }

  @override
  String get cycleCurrentCycle => 'Current cycle';

  @override
  String cycleAverage(int n) {
    return 'Average $n days';
  }

  @override
  String cycleRangeSame(int a) {
    return 'Each $a days';
  }

  @override
  String cycleRange(int a, int b) {
    return 'Range $a to $b days';
  }

  @override
  String cyclePatternSame(int count, int min) {
    return 'Your last $count cycles were each $min days.';
  }

  @override
  String cyclePattern(int count, int min, int max) {
    return 'Your last $count cycles ranged from $min to $max days.';
  }

  @override
  String get cycleSituationTitle => 'Your situation';

  @override
  String get cycleSituationHint =>
      'These change what we estimate. You can change them at any time.';

  @override
  String get cycleSituationNone => 'None of these';

  @override
  String get cycleMarkerPregnant => 'I\'m pregnant';

  @override
  String get cycleMarkerBreastfeeding => 'I\'m breastfeeding';

  @override
  String get cycleMarkerHormonalContraception => 'I use hormonal contraception';

  @override
  String get cycleMarkerNoPeriods => 'I\'m not currently having periods';

  @override
  String get cycleEdit => 'Change';

  @override
  String get cyclePeriodStartedHere => 'My period started this day';

  @override
  String get cyclePeriodEndedHere => 'My period ended this day';

  @override
  String get cycleRemovePeriod => 'Remove this period';

  @override
  String get cycleNote => 'Note';

  @override
  String get cycleSaveNote => 'Save note';

  @override
  String get cycleSaveNoteInactive => 'Write a note to save';

  @override
  String get cycleErrorEndBeforeStart =>
      'The end day is before the start day. Choose a later day.';

  @override
  String get cycleErrorFuture => 'Choose today or an earlier day.';

  @override
  String get cycleErrorOverlaps =>
      'This overlaps a period you\'ve already logged. Change that one instead.';

  @override
  String get cyclePeriodSheetTitle => 'Log a period';

  @override
  String get cycleStartLabel => 'First day';

  @override
  String get cycleEndLabel => 'Last day (if it has ended)';

  @override
  String get cycleSavePeriod => 'Save period';

  @override
  String get cycleSavePeriodInactive => 'Choose the first day to save';

  @override
  String get symptomsTitle => 'Symptoms';

  @override
  String get symptomsBack => 'Cycle';

  @override
  String get symptomsFrequent => 'You log these often';

  @override
  String get symptomsPick => 'Choose a symptom to log it';

  @override
  String get symptomsSeverityLabel => 'How strong is it?';

  @override
  String symptomsSeverityValue(int n) {
    return '$n out of 10';
  }

  @override
  String get symptomsNoteLabel => 'Note (optional)';

  @override
  String get symptomsSave => 'Save';

  @override
  String symptomsSaved(String name) {
    return '$name saved';
  }

  @override
  String get symptomsDone => 'Done';

  @override
  String get symptomsHistoryTitle => 'Recent';

  @override
  String get symptomsHistoryEmpty =>
      'Symptoms you log appear here, with where you were in your cycle.';

  @override
  String symptomsHistoryRow(String name, int severity) {
    return '$name · $severity out of 10';
  }

  @override
  String symptomsPhaseOnDay(String phase) {
    return '$phase, estimated';
  }

  @override
  String get symptomsSeverityRefused => 'Choose a number from 1 to 10.';

  @override
  String get commonLoadError =>
      'We couldn\'t load this screen. Your data is safe.';

  @override
  String get chatTitle => 'AI Care';

  @override
  String get chatNewChat => 'New conversation';

  @override
  String get chatConversations => 'Your conversations';

  @override
  String get chatNoConversations => 'Your conversations appear here.';

  @override
  String get chatStarterTitle => 'You could ask';

  @override
  String get chatInputLabel => 'Message AI Care';

  @override
  String get chatInputPlaceholder => 'Ask about your cycle, food, sleep…';

  @override
  String get chatSend => 'Send';

  @override
  String get chatSendInactive => 'Type a message to send';

  @override
  String get chatSources => 'Sources';

  @override
  String get chatSourceSheetTitle => 'Source';

  @override
  String get chatIncomplete => 'This answer stopped before it finished.';

  @override
  String get chatTryAgain => 'Try again';

  @override
  String get chatPersonalisedOn => 'Using your cycle and logs';

  @override
  String get chatPersonalisedOff => 'General answers: personalisation is off';

  @override
  String get chatPersonalisedSettings => 'Change in privacy settings';

  @override
  String chatRemaining(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'messages',
      one: 'message',
    );
    return '$n $_temp0 left today';
  }

  @override
  String get chatLimitTitle => 'You\'ve used today\'s messages';

  @override
  String chatLimitText(int limit, String resets) {
    return 'Your plan includes $limit AI Care messages a day. They refill on $resets.';
  }

  @override
  String chatLimitPlans(String plans) {
    return '$plans include more messages.';
  }

  @override
  String get chatSeePlans => 'See plans';

  @override
  String get chatRename => 'Rename';

  @override
  String get chatRenameLabel => 'Conversation name';

  @override
  String get chatSave => 'Save';

  @override
  String get chatDelete => 'Delete';

  @override
  String get chatDeleteConfirm =>
      'Delete this conversation? This can\'t be undone.';

  @override
  String get chatDeleteYes => 'Delete conversation';

  @override
  String get chatCancel => 'Cancel';

  @override
  String get chatBack => 'Conversations';

  @override
  String get chatYou => 'You';

  @override
  String get chatAssistant => 'AI Care';

  @override
  String get chatThinking => 'AI Care is writing';

  @override
  String get pvPasswordForgotSent =>
      'If that email has an account, we have sent a link.';

  @override
  String get pvPasswordLocked => 'Too many attempts. Try again in 15 minutes.';

  @override
  String get pvPasswordSampleHint =>
      'Sample mode: use a sample account with the password niraah-sample-pass.';

  @override
  String get pvAuthTitle => 'Enter your authenticator code';

  @override
  String get pvAuthBody =>
      'Open your authenticator app and enter the 6-digit code for Niraah.';

  @override
  String get pvAuthLabel => '6-digit code';

  @override
  String get pvAuthVerify => 'Verify';

  @override
  String get pvAuthInactive => 'Enter the 6 digits to continue';

  @override
  String get pvAuthFailed => 'That code is not right. Try the current code.';

  @override
  String get pvAuthUseRecovery => 'Use a recovery code instead';

  @override
  String get pvAuthRecoveryLabel => 'Recovery code';

  @override
  String get pvAuthRecoveryHint => 'Each recovery code works once.';

  @override
  String get pvAuthUseAuthenticator => 'Use my authenticator app';

  @override
  String get pvAuthSampleHint => 'Sample mode: any 6 digits will work.';

  @override
  String get pvSetupInvalidTitle => 'This link is no longer valid';

  @override
  String get pvSetupInvalidBody =>
      'Ask the person who invited you for a new one.';

  @override
  String pvSetupWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get pvSetupStep1 => 'Set a password';

  @override
  String get pvSetupStep2 => 'Add an authenticator';

  @override
  String get pvSetupStep3 => 'Save recovery codes';

  @override
  String pvSetupStepOf(int n, int total) {
    return 'Step $n of $total';
  }

  @override
  String get pvSetupPasswordLabel => 'New password';

  @override
  String get pvSetupPasswordHint =>
      'At least 12 characters. Longer is stronger; no other rules.';

  @override
  String get pvSetupPasswordTooShort => 'Use at least 12 characters.';

  @override
  String get pvSetupPasswordBreached =>
      'This password has appeared in a data breach. Choose a different one.';

  @override
  String get pvSetupNext => 'Continue';

  @override
  String get pvSetupPasswordInactive => 'Enter a password to continue';

  @override
  String get pvSetupAuthTitle => 'Add an authenticator app';

  @override
  String get pvSetupAuthBody =>
      'Scan this in your authenticator app, then enter the 6-digit code it shows.';

  @override
  String get pvSetupAuthKeyLabel => 'Setup key';

  @override
  String get pvSetupAuthSampleKey => 'SAMPLE KEY NOT FOR USE';

  @override
  String get pvSetupCodesTitle => 'Save your recovery codes';

  @override
  String get pvSetupCodesBody =>
      'If you lose your phone, each code lets you in once. Keep them somewhere safe and private.';

  @override
  String get pvSetupCodesConfirm => 'I have saved these codes';

  @override
  String get pvSetupFinish => 'Finish set-up';

  @override
  String get pvSetupFinishInactive => 'Confirm you\'ve saved the codes';

  @override
  String get pvStatusTitle => 'Your application';

  @override
  String get pvStatusBody =>
      'Complete your details and send them for review. An admin checks them, and you can see members once you\'re approved.';

  @override
  String get pvStatusMissingTitle => 'Still needed';

  @override
  String get pvStatusNothingMissing =>
      'Nothing more is needed from you right now.';

  @override
  String get pvSignOut => 'Sign out';

  @override
  String get pvShellNav => 'Doctor';

  @override
  String get pvShellHome => 'Home';

  @override
  String get pvShellPatients => 'Patients';

  @override
  String get pvShellQueue => 'Queue';

  @override
  String get pvShellSchedule => 'Schedule';

  @override
  String get pvShellMore => 'More';

  @override
  String pvShellComingSoon(String area) {
    return '$area arrives in a later step of Phase 4.';
  }

  @override
  String pvShellRoleSoon(String role) {
    return 'The $role workspace arrives in a later phase.';
  }

  @override
  String get pvRoleDietitian => 'dietitian';

  @override
  String get pvRoleInstructor => 'instructor';

  @override
  String pvDashGreeting(String name) {
    return 'Good day, $name';
  }

  @override
  String get pvDashNeedsMe => 'Needs you';

  @override
  String get pvDashUrgentAlerts => 'Urgent alerts';

  @override
  String get pvDashReviews => 'Pre-score reviews';

  @override
  String get pvDashOldestOverdue => 'Oldest is overdue';

  @override
  String get pvDashOldestUnderHour => 'Oldest due in under an hour';

  @override
  String pvDashOldestDue(int h) {
    return 'Oldest due in $h h';
  }

  @override
  String get pvDashCarePlans => 'Care plans to sign';

  @override
  String get pvDashLabResults => 'Lab results to review';

  @override
  String get pvDashMessages => 'Unread messages';

  @override
  String get pvDashDrafts => 'Prescriptions in draft';

  @override
  String get pvDashToday => 'Today';

  @override
  String get pvDashNoAppointments => 'No appointments today.';

  @override
  String get pvDashJoin => 'Join';

  @override
  String get pvDashJoinSoon => 'Join opens 10 minutes before';

  @override
  String pvDashOnCallNow(String to) {
    return 'You\'re on call until $to.';
  }

  @override
  String pvDashOnCallLater(String from, String to) {
    return 'Not on call now. Next on call $from–$to.';
  }

  @override
  String get pvDashOpenQueue => 'Open queue';

  @override
  String get pvDashOnCall => 'You\'re on call now.';

  @override
  String get pvDashNotOnCall => 'Not on call now.';

  @override
  String get pvDashJoinOnWeb => 'Join from the web app for now';

  @override
  String get pvDashClinicalReview => 'Clinical review';

  @override
  String pvQueueFlags(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n flags',
      one: '1 flag',
    );
    return '$_temp0';
  }

  @override
  String get pvQueueOpenedByMe => 'Opened by you';

  @override
  String get pvReviewTitle => 'Pre-score review';

  @override
  String get pvQueueTitle => 'Pre-score reviews';

  @override
  String get pvQueueEmpty => 'No reviews waiting. Well done.';

  @override
  String get pvQueueOverdue => 'Overdue';

  @override
  String get pvQueueDueUnderHour => 'Due in under an hour';

  @override
  String pvQueueDue(int h) {
    return 'Due in $h h';
  }

  @override
  String get pvQueueDedicated => 'Your patient';

  @override
  String get pvQueueNoFlags => 'No flags';

  @override
  String get pvQueueUrgent => 'Urgent';

  @override
  String get pvQueueAttention => 'Attention';

  @override
  String get pvQueueInfo => 'Info';

  @override
  String get pvQueueHoldingAnother =>
      'Finish or release your current review first.';

  @override
  String get pvQueueGone => 'This review has already been completed.';

  @override
  String get pvQueuePick => 'Choose a review to open it.';

  @override
  String get pvReviewBack => 'Queue';

  @override
  String get pvReviewSummary => 'AI clinician summary';

  @override
  String get pvReviewSummaryNote =>
      'Drafted by AI from her answers. Check it against the answers.';

  @override
  String get pvReviewFlags => 'Flags';

  @override
  String get pvReviewScores => 'Score';

  @override
  String pvReviewTotal(int t, int m, String band) {
    return '$t out of $m · $band';
  }

  @override
  String get pvReviewScoreLocked =>
      'Score, band and flags come from the questionnaire\'s rules and can\'t be changed here.';

  @override
  String get pvReviewObservations => 'What she will see';

  @override
  String get pvReviewEdited => 'Edited';

  @override
  String get pvReviewOriginalAi => 'Original AI text';

  @override
  String get pvReviewEdit => 'Edit';

  @override
  String get pvReviewRemove => 'Remove';

  @override
  String get pvReviewRestore => 'Restore';

  @override
  String get pvReviewSave => 'Save';

  @override
  String get pvReviewCancel => 'Cancel';

  @override
  String get pvReviewAnswers => 'Her answers';

  @override
  String get pvReviewConsent => 'Consent';

  @override
  String get pvReviewConsentView => 'View';

  @override
  String get pvReviewConsentNone => 'No consent';

  @override
  String get pvReviewAccept => 'Accept as is';

  @override
  String get pvReviewVerifyNext => 'Verify and next';

  @override
  String get pvReviewFollowUp => 'Request follow-up';

  @override
  String get pvReviewFollowUpLabel => 'Note to her (required)';

  @override
  String get pvReviewFollowUpSend => 'Send follow-up request';

  @override
  String get pvReviewFollowUpInactive => 'Write a note to send';

  @override
  String get pvReviewNoteLabel => 'Short note to her (optional)';

  @override
  String get pvReviewConcern => 'Scoring concern';

  @override
  String get pvReviewConcernLabel => 'What looks wrong with the scoring?';

  @override
  String get pvReviewConcernSend => 'Send to clinical reviewer';

  @override
  String get pvReviewConcernInactive => 'Describe the concern to send';

  @override
  String get pvReviewConcernSent =>
      'Sent to the clinical reviewer. The result is unchanged.';

  @override
  String pvReviewClaimNote(int min) {
    return 'This review is yours for $min minutes.';
  }

  @override
  String get pvReviewRelease => 'Release';

  @override
  String get pvReviewDone => 'Review completed.';

  @override
  String get pvRoleAdminWebOnly =>
      'The admin workspace is on the web. Sign in on a computer to use it.';

  @override
  String get scTitle => 'Is this your account?';

  @override
  String get scBody =>
      'It\'s been a while, or this is a new device. Before we open the account, show us it\'s you.';

  @override
  String get scDobLabel => 'Your date of birth';

  @override
  String get scDobPlaceholder => 'Choose your date of birth';

  @override
  String scDobChosen(String date) {
    return 'Date of birth: $date';
  }

  @override
  String get scEmailOption => 'Send a code to my recovery email';

  @override
  String get scEmailSent => 'We\'ve sent a code to your recovery email.';

  @override
  String get scEmailCodeLabel => 'Code from the email';

  @override
  String get scDeviceOption => 'Use this device';

  @override
  String get scDeviceBody =>
      'This device has been used with this account before.';

  @override
  String get scCheck => 'Check';

  @override
  String get scInactive => 'Fill this in to continue';

  @override
  String get scNotMine => 'This is not my account';

  @override
  String get scNotMineTitle => 'Start a new account?';

  @override
  String get scNotMineBody =>
      'We\'ll give this number a new, empty account. The old account is not opened or shown to you.';

  @override
  String get scNotMineConfirm => 'Yes, start a new account';

  @override
  String get scCancel => 'Go back';

  @override
  String get scSupport =>
      'We can\'t confirm it\'s you here. Contact support and we\'ll help you get back in.';

  @override
  String get stSuspendedTitle => 'Your account is not available';

  @override
  String get stSuspendedBody => 'Contact support.';

  @override
  String get stPausedTitle => 'Your account is paused';

  @override
  String get stPausedBody => 'Contact support, or delete your account.';

  @override
  String get stDeletionTitle => 'Your account is being deleted';

  @override
  String get stDeletionBody =>
      'You can cancel the deletion here within the grace period, or sign out.';

  @override
  String get reauthTitle => 'Add a new authenticator';

  @override
  String get reauthBody =>
      'Your recovery code worked. Add your authenticator app again before you continue.';

  @override
  String get setupKeyLoading => 'Getting your setup key…';

  @override
  String get mealsTitle => 'Meals';

  @override
  String get mealsHomeTitle => 'Your meals today';

  @override
  String get mealsHomeBody =>
      'Snap your plate and we will work out what is on it.';

  @override
  String get mealsHomeNone => 'Nothing logged yet today.';

  @override
  String mealsHomeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals logged today',
      one: '1 meal logged today',
    );
    return '$_temp0';
  }

  @override
  String get mealsScanAction => 'Scan a meal';

  @override
  String get mealsTakePhoto => 'Take a photo';

  @override
  String get mealsChoosePhoto => 'Choose from gallery';

  @override
  String get mealsScanIntro =>
      'Take a clear photo from above, with the whole plate in view.';

  @override
  String get mealsReading => 'Reading your meal…';

  @override
  String get mealsResultTitle => 'Here is what we found';

  @override
  String get mealsResultHint =>
      'Check each dish and its portion. Nothing is saved until you tap Save.';

  @override
  String get mealsNotSureHint => 'Tap to choose the dish';

  @override
  String get mealsRemove => 'Remove';

  @override
  String get mealsSlot => 'Which meal is this?';

  @override
  String get mealsSlotBreakfast => 'Breakfast';

  @override
  String get mealsSlotLunch => 'Lunch';

  @override
  String get mealsSlotDinner => 'Dinner';

  @override
  String get mealsSlotSnack => 'Snack';

  @override
  String get mealsSave => 'Save meal';

  @override
  String get mealsSaveInactive => 'Choose every dish to save';

  @override
  String get mealsSaved => 'Meal saved';

  @override
  String get mealsDone => 'Done';

  @override
  String get mealsScanAnother => 'Scan another meal';

  @override
  String get mealsUnavailable =>
      'The meal scanner isn’t available right now. Please try again in a little while.';

  @override
  String get mealsLimit => 'You have used today’s meal scans.';

  @override
  String get mealsSearchTitle => 'Which dish is this?';

  @override
  String get mealsSearchHint => 'Search, e.g. dal, idli, roti';

  @override
  String get mealsSearchNone => 'No dish found. Try another name.';

  @override
  String get mealsTotals => 'This meal';

  @override
  String get mealsDayTotals => 'Today so far';

  @override
  String mealsKcal(String value) {
    return '$value kcal';
  }

  @override
  String mealsProtein(String value) {
    return 'Protein $value g';
  }

  @override
  String mealsCarbs(String value) {
    return 'Carbs $value g';
  }

  @override
  String mealsFat(String value) {
    return 'Fat $value g';
  }

  @override
  String mealsFibre(String value) {
    return 'Fibre $value g';
  }

  @override
  String get mealsAiMark =>
      'Identified by AI · nutrients from the Indian food table';

  @override
  String get mealsTodayEmpty => 'No meals logged today yet.';

  @override
  String get mealsTagLowGi => 'Low GI';

  @override
  String get mealsTagHighProtein => 'High protein';

  @override
  String get mealsTagHighFibre => 'High fibre';

  @override
  String get mealsTagPcosFriendly => 'PCOS-friendly';

  @override
  String get mealsTagUnder400 => 'Under 400 kcal';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get stCancelDeletion => 'Cancel deletion';

  @override
  String areaStartsOn(String date) {
    return 'This starts when your trial ends and your first payment goes through, on $date.';
  }

  @override
  String areaIncludedIn(String plans) {
    return 'Included in: $plans';
  }

  @override
  String get areaSeePlans => 'See plans';

  @override
  String areaNotOnPlan(String area) {
    return '$area isn\'t on your plan.';
  }

  @override
  String get practiceTitle => 'Practice';

  @override
  String get practiceForToday => 'For today';

  @override
  String practiceForPhase(String phase) {
    return 'Chosen for your $phase phase.';
  }

  @override
  String get practiceNoPhase => 'Yoga and breathwork, at your own pace.';

  @override
  String get practiceTodayEmpty =>
      'Nothing picked for today yet. The library has sessions for any day.';

  @override
  String get practiceBrowse => 'Browse the library';

  @override
  String get practiceMore => 'More';

  @override
  String practiceMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String practiceLevel(String level) {
    return 'Level: $level';
  }

  @override
  String get practiceCaptions => 'Captions';

  @override
  String get practicePlay => 'Play the session';

  @override
  String get practiceNoVideo =>
      'The video for this session is not available yet.';

  @override
  String get practiceFinished => 'I\'ve finished this session';

  @override
  String get practiceLogged => 'Saved to what you did';

  @override
  String get practiceLibraryTitle => 'Library';

  @override
  String get practiceLibraryEmpty =>
      'No sessions match these filters. Try fewer filters.';

  @override
  String practiceUpTo(int minutes) {
    return 'Up to $minutes min';
  }

  @override
  String get practiceHistoryTitle => 'What you did';

  @override
  String get practiceHistoryEmpty =>
      'Sessions you finish will show here, week by week.';

  @override
  String practiceWeekOf(String date) {
    return 'Week of $date';
  }

  @override
  String practiceWeekSummary(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
    );
    return '$_temp0, $minutes min';
  }

  @override
  String get practiceLiveTitle => 'Live classes';

  @override
  String get practiceClassesEmpty => 'No live classes in the next two weeks.';

  @override
  String get practiceClassesAfterTrial =>
      'Live classes start with your first payment.';

  @override
  String practicePlacesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places left',
      one: '1 place left',
    );
    return '$_temp0';
  }

  @override
  String get practiceClassFull => 'This class is full';

  @override
  String get practiceBook => 'Book a place';

  @override
  String get practiceBooked => 'Your place is booked';

  @override
  String get meYourPlan => 'Your plan';

  @override
  String get meNoPlan => 'No plan yet';

  @override
  String mePlanRenews(String date) {
    return 'Renews on $date';
  }

  @override
  String mePlanEnds(String date) {
    return 'Ends on $date';
  }

  @override
  String mePlanRetired(String date) {
    return 'This plan is no longer offered. You keep it until $date.';
  }

  @override
  String get meSeePlans => 'See plans';

  @override
  String get meAreas => 'More for you';

  @override
  String get meLocked => 'not on your plan';

  @override
  String get meSettings => 'Settings';

  @override
  String get meWellness =>
      'Niraah supports your wellbeing. It does not replace your own doctor and is not an emergency service.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileName => 'Name you\'d like us to use';

  @override
  String get profileHeight => 'Height (cm)';

  @override
  String get profileHeightRange => 'Enter a height between 50 and 250 cm.';

  @override
  String get profileGoals => 'Your goals';

  @override
  String get profileAddGoal => 'Add a goal';

  @override
  String profileRemoveGoal(String goal) {
    return 'Remove $goal';
  }

  @override
  String get profileSave => 'Save';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get profileAccount => 'Account';

  @override
  String get profilePhone => 'Mobile number';

  @override
  String get profileRecoveryEmail => 'Recovery email';

  @override
  String get profileDob => 'Date of birth';

  @override
  String get profileDobNote => 'To correct this, contact support.';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileTimeZone => 'Time zone';

  @override
  String get profileNotSet => 'Not set';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacyWhoCanSee => 'Who can see my data';

  @override
  String get privacyNoConsents => 'No one else can see your health data.';

  @override
  String privacyGivenOn(String date) {
    return 'Given on $date';
  }

  @override
  String get privacyWithdraw => 'Withdraw';

  @override
  String get privacyWithdrawTitle => 'Withdraw access?';

  @override
  String privacyWithdrawBody(String who, String category) {
    return '$who will no longer see your $category data. This takes effect at once.';
  }

  @override
  String get privacyWithdrawn => 'Access withdrawn';

  @override
  String get privacyStaffAccess => 'When Niraah staff opened your data';

  @override
  String get privacyNoStaffAccess =>
      'Niraah staff have not opened your health data.';

  @override
  String get privacyAiTitle => 'Personalised AI';

  @override
  String get privacyAiSwitch => 'Use my data to personalise AI answers';

  @override
  String get privacyAiOn => 'On: AI features use your logs and answers.';

  @override
  String get privacyAiOff => 'Off: AI features use only what you type.';

  @override
  String get privacyChatTitle => 'AI Care chat history';

  @override
  String get privacyChatBody =>
      'All your AI Care conversations will be deleted. This cannot be undone.';

  @override
  String get privacyChatDelete => 'Delete all conversations';

  @override
  String get privacyChatDeleted => 'Conversations deleted';

  @override
  String get privacyExportTitle => 'Export my data';

  @override
  String get privacyExportBody =>
      'We prepare a copy of everything you\'ve given us and let you know when it\'s ready. Opening it needs a quick sign-in check.';

  @override
  String get privacyExportRequest => 'Request an export';

  @override
  String get privacyExportRequested => 'We\'re preparing your export';

  @override
  String privacyExportRequestedOn(String date) {
    return 'Requested $date';
  }

  @override
  String get privacyExportPreparing => 'Being prepared';

  @override
  String privacyExportReadyUntil(String date) {
    return 'Ready until $date';
  }

  @override
  String get privacyExportExpired => 'Expired';

  @override
  String get privacyExportFailed =>
      'This export didn\'t finish. Please request a new one.';

  @override
  String get privacyExportOpen => 'Open';

  @override
  String get privacyExportCopy => 'Copy';

  @override
  String get privacyExportCopied => 'Copied';

  @override
  String get privacyDeleteTitle => 'Delete my account';

  @override
  String get privacyDeleteSummary =>
      'Your account and data are deleted after a grace period, in which you can sign in and cancel. Records the law requires us to keep, such as invoices, are kept. An active plan is cancelled.';

  @override
  String get privacyDeleteBody =>
      'After the grace period your account and data are deleted and cannot be recovered. Records the law requires, such as invoices, are kept. Your plan is cancelled now. Next, we\'ll check it\'s you.';

  @override
  String get privacyDeleteContinue => 'Continue';

  @override
  String get privacyDeleteAction => 'Delete my account';

  @override
  String privacyDeleteStarted(String date) {
    return 'Your account will be deleted on $date.';
  }

  @override
  String get freshTitle => 'Check it\'s you';

  @override
  String get freshBody => 'We sent a 6-digit code to your mobile number.';

  @override
  String get freshConfirm => 'Confirm';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifPush => 'App notifications';

  @override
  String get notifSms => 'SMS';

  @override
  String get notifEmail => 'Email';

  @override
  String notifAlwaysOn(String reason) {
    return 'Always on. $reason';
  }

  @override
  String get programsTitle => 'Programs';

  @override
  String get programsAll => 'Programs';

  @override
  String get programsEmpty => 'No programs are open right now.';

  @override
  String get programsSuggested => 'Suggested for you';

  @override
  String programsLength(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks',
      one: '1 week',
    );
    return '$_temp0';
  }

  @override
  String get programsJoin => 'Join this program';

  @override
  String get programsStartOn => 'Choose a start day';

  @override
  String programsJoined(String name) {
    return 'You\'ve joined $name';
  }

  @override
  String programsWeek(int week) {
    return 'Week $week';
  }

  @override
  String programsWeekOf(int week, int weeks) {
    return 'Week $week of $weeks';
  }

  @override
  String programsStarted(String date) {
    return 'Started $date';
  }

  @override
  String get programsPaused => 'Paused. Your progress is kept.';

  @override
  String get programsPause => 'Pause';

  @override
  String get programsResume => 'Resume';

  @override
  String get programsPausedNote => 'Program paused';

  @override
  String get programsResumed => 'Program resumed';

  @override
  String get programsLeave => 'Leave program';

  @override
  String get programsLeft => 'You\'ve left the program';

  @override
  String get careTitle => 'Care plan';

  @override
  String get careNone =>
      'When your doctor signs a care plan for you, it will appear here.';

  @override
  String careSignedBy(String doctor, String date) {
    return 'Signed by $doctor on $date';
  }

  @override
  String get careYourDoctor => 'your doctor';

  @override
  String get careNutrition => 'Nutrition';

  @override
  String get careMovement => 'Movement';

  @override
  String get careSleep => 'Sleep';

  @override
  String get careSupplements => 'Supplements';

  @override
  String get careTodayTasks => 'Today\'s tasks';

  @override
  String get careNoTasks => 'No tasks for today.';

  @override
  String get careWeek => 'Your week';

  @override
  String careWeekDay(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks done',
      one: '1 task done',
    );
    return '$date: $_temp0';
  }

  @override
  String get careHistory => 'Earlier plans';

  @override
  String get checkInsTitle => 'Weekly check-in';

  @override
  String get checkInsNoneDue => 'No check-in this week. Your trend is below.';

  @override
  String checkInsThisWeek(String date) {
    return 'Week of $date';
  }

  @override
  String get checkInsWeight => 'Weight in kg (optional)';

  @override
  String get checkInsWaist => 'Waist in cm (optional)';

  @override
  String get checkInsEnergy => 'Energy this week';

  @override
  String get checkInsCravings => 'Cravings this week';

  @override
  String checkInsScale(int value) {
    return '$value of 5';
  }

  @override
  String get checkInsScaleEnds => '1 is low, 5 is high';

  @override
  String get checkInsNote => 'Anything else (optional)';

  @override
  String get checkInsSubmit => 'Save check-in';

  @override
  String get checkInsSaved => 'Check-in saved';

  @override
  String get checkInsTrend => 'Your trend';

  @override
  String get checkInsTrendEmpty => 'Your check-ins will show here over time.';

  @override
  String checkInsEnergyValue(int value) {
    return 'energy $value';
  }

  @override
  String checkInsCravingsValue(int value) {
    return 'cravings $value';
  }

  @override
  String checkInsWeightValue(String value) {
    return '$value kg';
  }

  @override
  String checkInsWaistValue(String value) {
    return 'waist $value cm';
  }

  @override
  String get labsTitle => 'Lab tests';

  @override
  String get labsReports => 'Your reports';

  @override
  String get labsEmpty => 'Add a lab report to keep your results in one place.';

  @override
  String get labsAdd => 'Add a report';

  @override
  String get labsReport => 'Report';

  @override
  String labsTestedOn(String date) {
    return 'Tested on $date';
  }

  @override
  String labsRange(String low, String high) {
    return 'Lab\'s range $low to $high';
  }

  @override
  String get labsOutside => 'Outside the lab\'s range';

  @override
  String get labsCollection => 'Home collection';

  @override
  String get labsOrder => 'Book home collection';

  @override
  String get labsAfterTrial =>
      'Home collection starts when your trial ends and your first payment goes through.';

  @override
  String get labsNotIncluded =>
      'Home collection isn\'t on your plan. You can still add your own reports.';

  @override
  String get labsCollectionUnavailable =>
      'Home collection isn\'t available right now.';

  @override
  String get labsPickDate => 'Choose the test date';

  @override
  String get labsPickDateFirst => 'Choose the test date to save';

  @override
  String get labsResults => 'Results';

  @override
  String get labsResultsHelp =>
      'Copy each result and the range printed on your report. Leave this empty to save the report only.';

  @override
  String get labsMarker => 'Test name';

  @override
  String get labsValue => 'Value';

  @override
  String get labsUnit => 'Unit';

  @override
  String get labsLow => 'Range from';

  @override
  String get labsHigh => 'Range to';

  @override
  String get labsAddResult => 'Add another result';

  @override
  String get labsResultIncomplete => 'Each result needs a name and a number.';

  @override
  String get labsSave => 'Save report';

  @override
  String get labsChooseTests => 'Choose tests';

  @override
  String get labsFasting => 'Needs fasting';

  @override
  String get labsPartner => 'Lab';

  @override
  String get labsAddress => 'Address for collection';

  @override
  String get labsAddressLine => 'House, street and area';

  @override
  String get labsCity => 'City';

  @override
  String get labsPincode => 'PIN code';

  @override
  String get labsTime => 'Collection time';

  @override
  String get labsPickTime => 'Choose a day and time';

  @override
  String get labsTimeNote => 'The lab confirms the exact time with you.';

  @override
  String get labsOrderSubmit => 'Request collection';

  @override
  String get labsOrderIncomplete => 'Choose tests, an address and a time';

  @override
  String get communityTitle => 'Community';

  @override
  String get communityRulesTitle => 'Community rules';

  @override
  String get communityAcceptRules => 'I agree to the rules';

  @override
  String get communityAcceptFirst => 'Agree to the community rules to post.';

  @override
  String get communityCircles => 'Circles';

  @override
  String get communityNoCircles => 'No circles are open yet.';

  @override
  String get communityJoin => 'Join';

  @override
  String get communityLeave => 'Leave';

  @override
  String get communityFeedEmpty =>
      'No posts here yet. You could start the conversation.';

  @override
  String get communityNewPost => 'New post';

  @override
  String get communityWrite => 'Write your post';

  @override
  String get communityPostAnonymously => 'Post anonymously';

  @override
  String get communityAnonymousNote =>
      'Other members won\'t see your name or photo.';

  @override
  String get communitySend => 'Post';

  @override
  String get communityPosted => 'Posted';

  @override
  String get communityReplied => 'Reply posted';

  @override
  String get communityThread => 'Post';

  @override
  String get communityReply => 'Reply';

  @override
  String communityReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replies',
      one: '1 reply',
      zero: 'No replies',
    );
    return '$_temp0';
  }

  @override
  String get communityEdited => 'edited';

  @override
  String get communityEditedNote => 'Post updated';

  @override
  String get communityBeingReviewed => 'Your post is being reviewed';

  @override
  String get communityYou => 'You';

  @override
  String get communityYouAnonymous => 'You, anonymously';

  @override
  String get communityAnonymous => 'Anonymous member';

  @override
  String get communityMember => 'Member';

  @override
  String get communityMore => 'More options';

  @override
  String get communityEdit => 'Edit';

  @override
  String get communityDelete => 'Delete';

  @override
  String get communityDeleted => 'Deleted';

  @override
  String get communityReport => 'Report';

  @override
  String get communityReportTitle => 'Why are you reporting this?';

  @override
  String get communityReported => 'Thank you. Our moderators will look at it.';

  @override
  String get communityMute => 'Mute this author';

  @override
  String get communityMuted => 'You won\'t see posts from this author';

  @override
  String get communityReasonHarmful => 'Harmful health advice';

  @override
  String get communityReasonHarassment => 'Harassment';

  @override
  String get communityReasonSpam => 'Spam';

  @override
  String get communityReasonPersonal => 'Personal information';

  @override
  String get communityReasonSelfHarm => 'Someone may be at risk';

  @override
  String get communityReasonOther => 'Something else';

  @override
  String get homeManagePlan => 'Manage plan';

  @override
  String get homeOpenCarePlan => 'Open care plan';

  @override
  String get homeNextTitle => 'Coming up';

  @override
  String get homeNextClass => 'Live class';

  @override
  String get homeNextConsult => 'Consult';

  @override
  String homeNextConsultWith(String name) {
    return 'Consult with $name';
  }

  @override
  String get homeCheckInTitle => 'Your weekly check-in';

  @override
  String get homeCheckInBody =>
      'A few quick questions about your week, whenever suits you.';

  @override
  String get homeCheckInAction => 'Start check-in';

  @override
  String get drUnnamed => 'Member';

  @override
  String get drSearchName => 'Search by name';

  @override
  String get drPast => 'Past patients';

  @override
  String get drRelDedicated => 'Dedicated';

  @override
  String get drRelConsult => 'Consult';

  @override
  String get drRelReview => 'Review';

  @override
  String get drOpenAlert => 'Open alert';

  @override
  String get drPlanAwaiting => 'Care plan awaiting';

  @override
  String get drNoPatients =>
      'No members have a care relationship with you right now.';

  @override
  String get drNoPastPatients => 'No past patients.';

  @override
  String drNext(String date) {
    return 'Next $date';
  }

  @override
  String get drPastPatient => 'Past patient';

  @override
  String drDietitian(String name) {
    return 'Dietitian: $name';
  }

  @override
  String get drConsent => 'Consent';

  @override
  String get drConsentView => 'View';

  @override
  String get drConsentNone => 'No consent';

  @override
  String get drFlags => 'Flags';

  @override
  String get drMessages => 'Messages';

  @override
  String get drBrief => 'Clinician brief';

  @override
  String get drBriefOpen => 'Show the brief';

  @override
  String drNotShared(String categories) {
    return 'She has not shared: $categories';
  }

  @override
  String get drNotSharedSection => 'She has not shared this.';

  @override
  String get drSecSummary => 'Summary';

  @override
  String get drSecAssessment => 'Assessment';

  @override
  String get drSecCycle => 'Cycle and symptoms';

  @override
  String get drSecCarePlan => 'Care plan';

  @override
  String get drSecAdvice => 'Wellness advice';

  @override
  String get drSecLabs => 'Labs';

  @override
  String get drSecMeals => 'Meals';

  @override
  String get drSecShared => 'Shared from AI chat';

  @override
  String get drSecNotes => 'Notes';

  @override
  String get drSecTimeline => 'Timeline';

  @override
  String get drAddNote => 'Add a note';

  @override
  String get drNoteHint => 'Visible to clinicians caring for her, never to her';

  @override
  String get drSave => 'Save';

  @override
  String get drSaved => 'Saved';

  @override
  String get drRecommendTests => 'Recommend tests';

  @override
  String get drRecommendNote =>
      'Note for her (optional), for example \"fasting\"';

  @override
  String get drRecommend => 'Recommend';

  @override
  String get drRecommended => 'Tests recommended';

  @override
  String get drOpenDraft => 'Open the care plan draft';

  @override
  String get drCarePlans => 'Care plans to sign';

  @override
  String get drCarePlan => 'Care plan';

  @override
  String get drNoCarePlans => 'No care plans are waiting for you.';

  @override
  String drDue(String date) {
    return 'Due $date';
  }

  @override
  String get drClaimedByMe => 'Yours';

  @override
  String get drOfferedToMe => 'Offered to you';

  @override
  String get drSharedQueue => 'Shared queue';

  @override
  String get drRevision => 'Revision';

  @override
  String get drEmptyPlan => 'No AI draft: write it yourself';

  @override
  String drReturnNoteWas(String note) {
    return 'Returned with: $note';
  }

  @override
  String get drAiSuggestion => 'AI suggestion';

  @override
  String get drNoSuggestion => 'No suggestion for this section.';

  @override
  String get drYourVersion => 'Your version';

  @override
  String drClearedBecause(String reason) {
    return 'Left out: $reason';
  }

  @override
  String get drAccepted => 'Accepted';

  @override
  String get drEdited => 'Edited';

  @override
  String get drCleared => 'Left out';

  @override
  String get drUndecided => 'Not decided yet';

  @override
  String get drAccept => 'Accept';

  @override
  String get drEdit => 'Edit';

  @override
  String get drClear => 'Leave out';

  @override
  String get drClearSection => 'Leave this section out';

  @override
  String get drClearReason => 'Reason (optional)';

  @override
  String get drDoseWarning =>
      'This text reads as a dose or a medicine. Confirm it is yours to give, or that it only refers to a medicine she already takes from her own doctor.';

  @override
  String get drDoseConfirm => 'Confirm';

  @override
  String get drTasks => 'Daily tasks';

  @override
  String get drNoTasks => 'No tasks yet.';

  @override
  String get drAddTask => 'Add a task';

  @override
  String get drTaskTitle => 'Task';

  @override
  String get drRemoveTask => 'Remove task';

  @override
  String get drDaily => 'Daily';

  @override
  String get drWeekdays => 'Weekdays';

  @override
  String get drWeekly => 'Weekly';

  @override
  String get drProposedByAi => 'proposed by AI';

  @override
  String get drSign => 'Sign the care plan';

  @override
  String get drSignTitle => 'Sign this care plan?';

  @override
  String get drSigned => 'Signed. She can see it now.';

  @override
  String get drDecideAll => 'Decide every section to sign';

  @override
  String get drKeepOne => 'Keep at least one section to sign';

  @override
  String get drConfirmDoses => 'Confirm the dose-like text to sign';

  @override
  String get drReturn => 'Return for a new draft';

  @override
  String get drReturnHint => 'What should change? The AI is given this note.';

  @override
  String get drReturned => 'A new draft has been made with your note';

  @override
  String get drRevise => 'Revise this plan';

  @override
  String get drRevisionStarted => 'A revision has been started';

  @override
  String get drAlerts => 'Alerts';

  @override
  String get drAlertsOpen => 'Open';

  @override
  String get drAlertsResolved => 'Resolved';

  @override
  String get drNoAlerts => 'No alerts.';

  @override
  String get drUrgent => 'Urgent';

  @override
  String drAge(int minutes) {
    return '$minutes min ago';
  }

  @override
  String get drOnCallAlert => 'On call';

  @override
  String get drNotOpened => 'Not opened';

  @override
  String get drAlertOpen => 'Open';

  @override
  String get drAlertAcknowledged => 'Acknowledged';

  @override
  String get drAlertResolved => 'Resolved';

  @override
  String get drOpenProfile => 'Open her profile';

  @override
  String get drAcknowledge => 'Acknowledge';

  @override
  String get drAcknowledged => 'Acknowledged';

  @override
  String get drAskToBook => 'Ask her to book';

  @override
  String get drAskedToBook => 'She has been asked to book';

  @override
  String get drResolve => 'Resolve';

  @override
  String get drResolveHint => 'What was done (required)';

  @override
  String get drResolved => 'Resolved';

  @override
  String get drLabResults => 'Lab results to review';

  @override
  String get drNoLabResults => 'No lab results are waiting for you.';

  @override
  String get drFlagged => 'Flagged';

  @override
  String get drTypedByMember => 'Typed in by her';

  @override
  String get drTypedByMemberLong =>
      'These values were typed in by her from her report.';

  @override
  String get drLabReport => 'Lab report';

  @override
  String get drReview => 'Your review';

  @override
  String get drReviewed => 'Reviewed';

  @override
  String get drCommentForHer => 'Comment for her, in plain words (optional)';

  @override
  String get drMarkReviewed => 'Mark reviewed';

  @override
  String get drConfirmOwnDoctor =>
      'It refers to a medicine from her own doctor';

  @override
  String get drAdviceDrafts => 'Wellness advice drafts';

  @override
  String get drNoDrafts => 'No drafts.';

  @override
  String drUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String get drCorrection => 'Correction';

  @override
  String get drWellnessAdvice => 'Wellness advice';

  @override
  String get drWriteAdvice => 'Write wellness advice';

  @override
  String get drAssessment => 'Assessment';

  @override
  String get drAssessmentHelp =>
      'In plain words. Do not name a disease as diagnosed.';

  @override
  String get drSupplements => 'Supplements';

  @override
  String get drAddSupplement => 'Add a supplement';

  @override
  String get drChooseSupplement => 'Choose from the catalogue';

  @override
  String get drNoSupplements =>
      'The catalogue has no approved supplements yet.';

  @override
  String get drRemoveLine => 'Remove';

  @override
  String get drSupplementsOnly =>
      'Health supplements from the catalogue only. No prescription medicine and no hormonal product.';

  @override
  String get drDosePattern => 'Dose pattern';

  @override
  String get drTiming => 'Timing';

  @override
  String get drBeforeFood => 'Before food';

  @override
  String get drAfterFood => 'After food';

  @override
  String get drWithFood => 'With food';

  @override
  String get drAnyTime => 'Any time';

  @override
  String get drDuration => 'Duration';

  @override
  String get drInstructions => 'Instructions';

  @override
  String get drAdvice => 'Advice';

  @override
  String get drSeeDoctorLine => 'See a doctor in person';

  @override
  String get drTestsAdvised => 'Tests advised';

  @override
  String get drCommaSeparated => 'Separate with commas';

  @override
  String get drNoFollowUp => 'No follow-up date';

  @override
  String drFollowUpOn(String date) {
    return 'Follow up on $date';
  }

  @override
  String get drSetFollowUp => 'Set follow-up';

  @override
  String drWordingCheck(String field) {
    return '$field names a medicine or a dose. Remove it, or confirm it only refers to a medicine she already takes from her own doctor.';
  }

  @override
  String get drSaveDraft => 'Save draft';

  @override
  String get drSignAdvice => 'Sign and send';

  @override
  String get drAdviceSigned =>
      'Signed. She has been told there is something new in her app.';

  @override
  String drAdviceSignedOn(String date) {
    return 'Signed $date';
  }

  @override
  String drVerificationCode(String code) {
    return 'Verification code: $code';
  }

  @override
  String get drDiscard => 'Discard draft';

  @override
  String get drDiscarded => 'Draft discarded';

  @override
  String get drMedicinesNotShared =>
      'She has not shared her assessment, so reported medicines and allergies are not shown.';

  @override
  String get drMedicinesNotRecorded => 'Medicines and allergies: not recorded.';

  @override
  String get drOnMedicationFlag =>
      'She said she takes medicine. Details are not recorded.';

  @override
  String drMedicinesReported(String medicines, String allergies) {
    return 'Reported medicines: $medicines. Allergies: $allergies.';
  }

  @override
  String drApproval(String status) {
    return 'Approval: $status';
  }

  @override
  String drReverify(String date) {
    return 'Re-verification by $date';
  }

  @override
  String drRegistration(String number, String council) {
    return 'Registration $number, $council';
  }

  @override
  String get drNoRegistration =>
      'No registration number on file. You can\'t sign until it is added.';

  @override
  String drRating(String average, int count) {
    return 'Rating $average from $count reviews';
  }

  @override
  String get drOnCallSwitch => 'I\'m on call now';

  @override
  String get drBio => 'Bio';

  @override
  String get drLanguages => 'Languages';

  @override
  String get drSpecialities => 'Consult specialities';

  @override
  String get drRegistrationNote =>
      'To change your registration or qualifications, send a new document to Niraah for review.';

  @override
  String get drReviewerTasks => 'Clinical review';

  @override
  String get drReviewerOnWeb => 'Approving these tasks isn\'t in the app yet.';

  @override
  String get earnTitle => 'Earnings';

  @override
  String get earnAvailable => 'Available';

  @override
  String get earnPending => 'Pending';

  @override
  String get earnPaid => 'Paid';

  @override
  String get earnReversed => 'Reversed';

  @override
  String earnAvailableOn(String date) {
    return 'available $date';
  }

  @override
  String get earnCashOut => 'Cash out';

  @override
  String get earnNothingAvailable => 'Nothing available to cash out yet';

  @override
  String get earnPayoutRequested => 'Cash-out requested';

  @override
  String get earnLines => 'Earning lines';

  @override
  String get earnNoLines => 'No earnings yet.';

  @override
  String get earnRules => 'What each kind of work pays';

  @override
  String earnRuleAmount(String kind, String amount) {
    return '$kind: $amount';
  }

  @override
  String earnRuleShare(String kind, String percent) {
    return '$kind: $percent% of the fee';
  }

  @override
  String get earnPayouts => 'Payouts';

  @override
  String get earnNoPayouts => 'No payouts yet.';

  @override
  String earnTaxWithheld(String amount) {
    return 'Tax withheld $amount';
  }

  @override
  String earnRequestedOn(String date) {
    return 'Requested $date';
  }

  @override
  String get schedTitle => 'Schedule';

  @override
  String schedTimeZone(String zone) {
    return 'Times in $zone';
  }

  @override
  String get schedNoHours =>
      'You have no consult hours set, so members can\'t book you.';

  @override
  String get schedNextTwoWeeks => 'Next two weeks';

  @override
  String get schedNoAppointments => 'No appointments in the next two weeks.';

  @override
  String get schedHold => 'Being booked';

  @override
  String get schedBeingBooked => 'Being booked';

  @override
  String get schedConfirmed => 'Confirmed';

  @override
  String get schedInProgress => 'In progress';

  @override
  String get schedCompleted => 'Completed';

  @override
  String get schedCancelled => 'Cancelled';

  @override
  String get schedNoShow => 'No-show';

  @override
  String get schedWeeklyHours => 'Weekly hours';

  @override
  String get schedNoWeeklyHours => 'No weekly hours set.';

  @override
  String get schedConsults => 'Consults';

  @override
  String get schedReviewsOnCall => 'Reviews and on call';

  @override
  String get schedHoursOnWeb => 'Changing weekly hours isn\'t in the app yet.';

  @override
  String get schedExceptions => 'Blocked time and extra hours';

  @override
  String get schedAddException => 'Block time or add hours';

  @override
  String get schedExceptionKind => 'What is this time?';

  @override
  String get schedBlocked => 'Blocked';

  @override
  String get schedExtra => 'Extra consult hours';

  @override
  String get schedFrom => 'From';

  @override
  String get schedTo => 'To';

  @override
  String get schedSaved => 'Saved';

  @override
  String get schedRemove => 'Remove';

  @override
  String get staffCheckTitle => 'Check it\'s you';

  @override
  String get staffCheckBody =>
      'Enter your password and the code from your authenticator app to sign.';

  @override
  String get staffCheckPassword => 'Password';

  @override
  String get staffCheckCode => 'Authenticator code';

  @override
  String get msgTitle => 'Messages';

  @override
  String get msgNoThreads => 'No conversations yet.';

  @override
  String get msgNotOnPlan => 'Messaging your care team isn\'t on your plan.';

  @override
  String msgUnread(int count) {
    return '$count unread';
  }

  @override
  String get msgReadOnly => 'You can read this conversation but not reply.';

  @override
  String get msgStart => 'Start a conversation';

  @override
  String get msgConsentTitle => 'Share your messages?';

  @override
  String msgConsentBody(String name) {
    return '$name will be able to read what you send in this conversation.';
  }

  @override
  String get msgConsentAgree => 'Agree and continue';

  @override
  String get msgWrite => 'Write a message';

  @override
  String get msgSend => 'Send';

  @override
  String get msgDeleted => 'Message deleted';

  @override
  String get msgSharedFromChat => 'Shared from AI Care';

  @override
  String get msgEdit => 'Edit message';

  @override
  String get msgSendAnyway => 'It refers to her own doctor\'s medicine: send';

  @override
  String msgAway(String date, String note) {
    return 'Away until $date. $note';
  }

  @override
  String get msgSetAway => 'Set away';

  @override
  String get msgAwayTitle => 'Away note';

  @override
  String get msgAwayNote => 'A line members will see';

  @override
  String get msgAwayUntil => 'Back on';

  @override
  String msgAwaySet(String date) {
    return 'Away until $date';
  }

  @override
  String get dtClients => 'Clients';

  @override
  String get dtReview => 'Review';

  @override
  String get dtFoodLogs => 'Food logs to review';

  @override
  String get dtPlansToBuild => 'Meal plans to build';

  @override
  String dtEndingSoon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ending within 7 days',
      one: '1 ending within 7 days',
      zero: 'None ending this week',
    );
    return '$_temp0';
  }

  @override
  String get dtCheckIns => 'Check-ins to read';

  @override
  String get dtPastClients => 'Past clients';

  @override
  String get dtNoClients => 'No clients with a care relationship right now.';

  @override
  String get dtPlanNone => 'No plan';

  @override
  String get dtPlanDraft => 'Draft';

  @override
  String get dtPlanScheduled => 'Scheduled';

  @override
  String get dtPlanActive => 'Active';

  @override
  String get dtPlanEnded => 'Ended';

  @override
  String dtPlanUntil(String date) {
    return 'until $date';
  }

  @override
  String dtLastCheckIn(String date) {
    return 'Last check-in $date';
  }

  @override
  String get dtUnreviewedLogs => 'Food logs to review';

  @override
  String get dtSecMealPlan => 'Meal plan';

  @override
  String get dtSecProgress => 'Progress';

  @override
  String dtDoctor(String name) {
    return 'Doctor: $name';
  }

  @override
  String get dtNewPlan => 'New meal plan';

  @override
  String get dtMealPlan => 'Meal plan';

  @override
  String get dtMealPlans => 'Meal plans';

  @override
  String get dtRecipes => 'Recipes';

  @override
  String get dtRecipe => 'Recipe';

  @override
  String get dtSpecialities => 'Specialities';

  @override
  String dtPlanPeriods(String periods) {
    return 'Plan periods: $periods';
  }

  @override
  String get dtNoCheckIns => 'No check-ins yet.';

  @override
  String dtYourReply(String text) {
    return 'Your reply: $text';
  }

  @override
  String get dtMarkRead => 'Mark read';

  @override
  String get dtMarkedRead => 'Marked read';

  @override
  String get dtReply => 'Reply';

  @override
  String get dtReplyHint => 'A short, kind note';

  @override
  String get dtReplied => 'Reply sent';

  @override
  String get dtMissed => 'Missed weeks';

  @override
  String get dtNudge => 'Send a gentle nudge';

  @override
  String get dtNudged => 'Nudge sent';

  @override
  String get dtNudgeSent => 'Nudge sent';

  @override
  String get dtAssign => 'Assign a check-in questionnaire';

  @override
  String get dtAssigned => 'Questionnaire assigned';

  @override
  String get dtNoQuestionnaires =>
      'No check-in questionnaires are published yet.';

  @override
  String get dtSchedule => 'How often?';

  @override
  String get dtFortnightly => 'Fortnightly';

  @override
  String get dtMonthly => 'Monthly';

  @override
  String get dtEndsOn => 'Ends on';

  @override
  String get dtNoUnreadCheckIns => 'All check-ins are read.';

  @override
  String get dtRefer => 'Refer to her doctor';

  @override
  String get dtReferHint => 'Your note for her doctor';

  @override
  String get dtReferred => 'Referred to her doctor';

  @override
  String get dtNeedPlan => 'Clients waiting for a plan';

  @override
  String get dtNobodyWaiting => 'Nobody is waiting for a plan.';

  @override
  String get dtYourPlans => 'Your plans';

  @override
  String get dtNoPlans => 'No plans yet.';

  @override
  String get dtPortion => 'Portion';

  @override
  String get dtTargets => 'Targets';

  @override
  String get dtEnergy => 'Energy (kcal)';

  @override
  String get dtProtein => 'Protein (g)';

  @override
  String get dtCarbs => 'Carbs (g)';

  @override
  String get dtFat => 'Fat (g)';

  @override
  String get dtFibre => 'Fibre (g)';

  @override
  String get dtMin => 'From';

  @override
  String get dtMax => 'To';

  @override
  String get dtCopyDay => 'Copy this day';

  @override
  String dtCopyDayTo(int day) {
    return 'Copy day $day to';
  }

  @override
  String dtDayN(int day) {
    return 'Day $day';
  }

  @override
  String get dtCopy => 'Copy';

  @override
  String get dtCopied => 'Copied';

  @override
  String get dtStartsOn => 'Plan starts on';

  @override
  String get dtCarePlanTitle => 'Her care plan: nutrition';

  @override
  String get dtCarePlanNoNutrition =>
      'Her signed care plan has no nutrition section.';

  @override
  String get dtCarePlanRead => 'I have read it';

  @override
  String get dtPublished => 'Published. She\'ll see it from the start date.';

  @override
  String dtPlanDates(String start, String end) {
    return '$start to $end';
  }

  @override
  String get dtSuppressedPreview =>
      'Calorie and weight content is hidden for this member. She will see the plan without energy figures or energy targets.';

  @override
  String get dtDayTotals => 'Day totals, from the food table';

  @override
  String get dtWithin => 'within';

  @override
  String get dtBelow => 'below';

  @override
  String get dtAbove => 'above';

  @override
  String get dtSlotEarly => 'Early morning';

  @override
  String get dtSlotMidMorning => 'Mid-morning';

  @override
  String get dtSlotEvening => 'Evening snack';

  @override
  String get dtSlotBedtime => 'Bedtime';

  @override
  String get dtSlotNote => 'Note';

  @override
  String get dtSlotNoteHint => 'For example \"soak overnight\"';

  @override
  String get dtPreferenceWarning =>
      'Doesn\'t match her food choice or is a food she avoids';

  @override
  String dtConflict(String what) {
    return 'Check before publishing: $what';
  }

  @override
  String get dtPregnancy => 'not tagged pregnancy-safe';

  @override
  String get dtConfirmConflict => 'I\'ve checked this, keep it';

  @override
  String get dtAddDish => 'Add a dish';

  @override
  String dtRepeats(String names) {
    return 'Repeated often this week: $names';
  }

  @override
  String get dtSaveTemplate => 'Save as template';

  @override
  String get dtTemplateHint => 'Template name';

  @override
  String get dtTemplateSaved => 'Template saved';

  @override
  String get dtPublish => 'Publish plan';

  @override
  String get dtConfirmFirst => 'Confirm the marked items to publish';

  @override
  String get dtDiscard => 'Discard draft';

  @override
  String get dtAdjust => 'Adjust from tomorrow';

  @override
  String get dtAdjustStarted => 'A copy from tomorrow is ready to change';

  @override
  String get dtEnd => 'End this plan';

  @override
  String get dtEnded => 'Plan ended';

  @override
  String get dtSearchDish => 'Search dishes and foods';

  @override
  String get dtSearchHint => 'Type at least two letters and search';

  @override
  String dtRequestFood(String name) {
    return 'Not in the list? Request \"$name\"';
  }

  @override
  String get dtRequested =>
      'Requested. You can add it once the nutrition team adds it to the food table.';

  @override
  String get dtNoLogs => 'No food logs are waiting for you.';

  @override
  String dtLogs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '1 meal',
    );
    return '$_temp0';
  }

  @override
  String get dtComment => 'Comment';

  @override
  String get dtCommentHint => 'Up to 280 characters, kind and specific';

  @override
  String get dtCommented => 'Comment sent';

  @override
  String get dtCorrect => 'Correct this dish';

  @override
  String dtCorrectTo(String name) {
    return 'Change to $name';
  }

  @override
  String get dtCorrected => 'Corrected. She has been told.';

  @override
  String get dtCorrectedMark => 'corrected';

  @override
  String get dtHasTargets => 'Her plan\'s targets apply to this day.';

  @override
  String get dtTakeDay => 'Take this day';

  @override
  String get dtPhoto => 'photo';

  @override
  String get dtApprove => 'Approve';

  @override
  String get dtApproved => 'Approved';

  @override
  String get dtApproveDay => 'Approve all for this day';

  @override
  String get dtDayApproved => 'Day approved';

  @override
  String get dtNewRecipe => 'New recipe';

  @override
  String get dtSearchRecipes => 'Search recipes';

  @override
  String get dtMine => 'Mine';

  @override
  String get dtNoRecipes => 'No recipes yet.';

  @override
  String get dtPublishedLabel => 'Published';

  @override
  String get dtGrams => 'Grams';

  @override
  String get dtRecipeIncomplete =>
      'A recipe needs a title, at least one ingredient and servings.';

  @override
  String get dtRecipePublished => 'Recipe published';

  @override
  String dtVersion(int n) {
    return 'version $n';
  }

  @override
  String get dtVersionNote =>
      'Changing ingredients or servings makes a new version; plans already published keep this one.';

  @override
  String get dtRecipeTitle => 'Title';

  @override
  String get dtIngredients => 'Ingredients';

  @override
  String get dtRequestedFood => 'Requested from the nutrition team';

  @override
  String get dtAddIngredient => 'Add an ingredient';

  @override
  String get dtPerServing => 'Per serving, from the food table';

  @override
  String get dtServings => 'Servings';

  @override
  String get dtMinutes => 'Minutes';

  @override
  String get dtSteps => 'Steps';

  @override
  String get dtStepsHelp => 'One step per line';

  @override
  String get dtTags => 'Tags';

  @override
  String dtComputedTags(String tags) {
    return 'Set from the numbers: $tags';
  }

  @override
  String get dtPublishRecipe => 'Publish recipe';

  @override
  String get inSessions => 'Sessions';

  @override
  String get inStudents => 'Students';

  @override
  String get inLibrary => 'Library';

  @override
  String get inAwaitingApproval => 'Waiting for approval';

  @override
  String get inLive => 'Live';

  @override
  String inNextSoon(String title, String when) {
    return '$title starts $when';
  }

  @override
  String get inNoToday => 'No classes today.';

  @override
  String inBooked(int booked, int capacity) {
    return '$booked of $capacity booked';
  }

  @override
  String get inRequests => 'Student requests waiting';

  @override
  String get inAttendanceToConfirm => 'Attendance to confirm';

  @override
  String get inContentReturned => 'Sessions returned by a reviewer';

  @override
  String get inNoBookings => 'Classes this week with no bookings';

  @override
  String get inNewClass => 'New class';

  @override
  String get inNoClasses => 'No classes yet. Schedule one to get started.';

  @override
  String inWaiting(int count) {
    return '$count waiting';
  }

  @override
  String inNewRequests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new requests',
      one: '1 new request',
    );
    return '$_temp0';
  }

  @override
  String get inClass => 'Class';

  @override
  String get inCancelWhy => 'Why are you cancelling?';

  @override
  String get inReasonUnwell => 'I\'m unwell';

  @override
  String get inReasonEmergency => 'A personal emergency';

  @override
  String get inReasonTechnical => 'A technical problem';

  @override
  String get inReasonOther => 'Something else';

  @override
  String get inCancelled =>
      'Cancelled. Everyone booked has been told and their place returned.';

  @override
  String get inLateCancellation =>
      'Cancelled at short notice; this is recorded.';

  @override
  String get inBookings => 'Bookings';

  @override
  String get inNoBookingsYet => 'No bookings yet.';

  @override
  String get inOnWaitingList => 'on the waiting list';

  @override
  String get inAttended => 'attended';

  @override
  String get inNotAttended => 'did not attend';

  @override
  String inRequest(String choice, String text) {
    return 'Request: $choice $text';
  }

  @override
  String get inMarkSeen => 'Mark the request as seen';

  @override
  String get inSeen => 'She\'ll see it was seen';

  @override
  String get inCorrected => 'Attendance corrected';

  @override
  String get inPublish => 'Publish';

  @override
  String get inPublished => 'Done';

  @override
  String get inChange => 'Change class';

  @override
  String get inDeleteDraft => 'Delete draft';

  @override
  String get inCancelClass => 'Cancel class';

  @override
  String get inConfirmAttendance => 'Confirm attendance';

  @override
  String get inAttendanceConfirmed => 'Attendance confirmed';

  @override
  String get inReqFirst => 'First class';

  @override
  String get inReqCamera => 'Camera optional';

  @override
  String get inReqLate => 'Arriving late';

  @override
  String get inReqEarly => 'Leaving early';

  @override
  String get inReqOther => 'Other';

  @override
  String get inIncomplete =>
      'A class needs a title, a start, a length and a capacity.';

  @override
  String get inTitle => 'Title';

  @override
  String get inDescription => 'Description';

  @override
  String get inNoMedicalClaims =>
      'Say what the practice is and who it suits. No claims to treat a condition.';

  @override
  String get inPickStart => 'Choose the start';

  @override
  String get inCapacity => 'Capacity';

  @override
  String get inLevel => 'Level';

  @override
  String get inPhaseTags => 'Suits these cycle phases';

  @override
  String get inWeekly => 'Repeat weekly';

  @override
  String get inUntil => 'Repeat until';

  @override
  String inUntilDate(String date) {
    return 'Until $date';
  }

  @override
  String get inFeeNote => 'The class fee is set by Niraah.';

  @override
  String get inRecommend => 'Suggest a recorded session';

  @override
  String get inNoPublished => 'You have no published sessions yet.';

  @override
  String get inRecommended => 'Suggestion sent';

  @override
  String get inNoStudents => 'Students who book your classes will appear here.';

  @override
  String inAttendedOf(int attended, int booked) {
    return 'attended $attended of $booked';
  }

  @override
  String inPhase(String phase) {
    return '$phase phase';
  }

  @override
  String inProgress(int sessions, int minutes) {
    return '$sessions sessions, $minutes min this month';
  }

  @override
  String get inInReview => 'In review';

  @override
  String get inReturned => 'Returned';

  @override
  String get inWithdrawn => 'Withdrawn';

  @override
  String get inNewSession => 'New session';

  @override
  String get inNoContent => 'Recorded sessions you create will appear here.';

  @override
  String inStats(int plays, int completions) {
    return '$plays plays, $completions completed';
  }

  @override
  String inStatsLong(int plays, int completions) {
    return '$plays plays and $completions completions. Counts only; no member is named.';
  }

  @override
  String get inIntensity => 'Intensity';

  @override
  String get inProposePregnancy => 'I propose this is pregnancy-safe';

  @override
  String get inReviewerDecides => 'The reviewer decides the tag.';

  @override
  String get inRights => 'I own this content and any music in it';

  @override
  String get inVideoNotInApp =>
      'Uploading the video isn\'t in the app yet, so this can\'t be sent for review from here.';

  @override
  String get inSubmit => 'Send for review';

  @override
  String get inSubmitted => 'Sent for review';

  @override
  String get inWithdraw => 'Withdraw from the library';

  @override
  String get inPracticeTypes => 'Practice types';

  @override
  String get pvApplyLink =>
      'Doctor, dietitian or yoga instructor? Apply to join';

  @override
  String get paStatus => 'Status';

  @override
  String get paAsked => 'The team asked for';

  @override
  String get paReason => 'Reason';

  @override
  String get paDetails => 'Your details';

  @override
  String get paName => 'Full name';

  @override
  String get paPhone => 'Contact number';

  @override
  String get paBio => 'Short bio';

  @override
  String get paSpecialities => 'Specialities';

  @override
  String get paLanguages => 'Languages';

  @override
  String get paCommaHint => 'Separate with commas';

  @override
  String get paYears => 'Years of experience';

  @override
  String get paRegNumber => 'Registration number';

  @override
  String get paRegCouncil => 'Registration council';

  @override
  String get paRegHint => 'Needed for doctors; give it if you have one.';

  @override
  String get paReferences => 'Professional references';

  @override
  String get paReferencesHint => 'Two references for doctors and dietitians.';

  @override
  String get paRefName => 'Name';

  @override
  String get paRefRole => 'Role';

  @override
  String get paRefContact => 'Email or phone';

  @override
  String get paSave => 'Save';

  @override
  String get paSaved => 'Saved.';

  @override
  String get paDocuments => 'Documents';

  @override
  String get paDocumentsHint =>
      'Photos of your documents, JPEG or PNG, up to 3 MB each. PDFs can be uploaded on the website.';

  @override
  String get paKindPhoto => 'Photo';

  @override
  String get paKindIdentity => 'Government photo identity';

  @override
  String get paKindQualification => 'Qualification certificate';

  @override
  String get paKindRegistration => 'Registration certificate';

  @override
  String get paUpload => 'Upload';

  @override
  String get paRemove => 'Remove';

  @override
  String get paTooBig => 'Files can be up to 3 MB.';

  @override
  String paTerms(String version) {
    return 'I accept the provider terms and code of conduct (version $version).';
  }

  @override
  String get paSubmit => 'Submit for review';

  @override
  String get paResubmit => 'Send again';

  @override
  String get paSubmitInactive => 'Add what is still needed first';

  @override
  String get paSubmitted => 'Sent. We will email you when there is a decision.';

  @override
  String get paReapply => 'Apply again';

  @override
  String paReapplyFrom(String date) {
    return 'You can apply again from $date.';
  }

  @override
  String get paReadOnly =>
      'Your application is with the team. You can change it if they ask for more information.';

  @override
  String get paMissing => 'Still needed';

  @override
  String get signInAs => 'Sign in as';

  @override
  String get signInAsMember => 'Member';

  @override
  String get signInAsDoctor => 'Doctor';

  @override
  String get signInAsDietitian => 'Dietitian';

  @override
  String get signInAsTrainer => 'Trainer';

  @override
  String get signInNumberLabel => 'Mobile number';

  @override
  String get signInEmailLabel => 'Email';

  @override
  String get signInStaffBody =>
      'Enter your work email. Then your password and authenticator code.';

  @override
  String get signInNeedNumber => 'Members sign in with a mobile number.';

  @override
  String get signInNeedEmail => 'Enter your email address.';

  @override
  String get signInEnterNumber => 'Enter your mobile number';

  @override
  String get signInEnterEmail => 'Enter your email';

  @override
  String get csTypeDoctor => 'Doctor';

  @override
  String get csTypeDietitian => 'Dietitian';

  @override
  String get csStatusHeld => 'Being booked';

  @override
  String get csStatusConfirmed => 'Booked';

  @override
  String get csStatusInProgress => 'In progress';

  @override
  String get csStatusCompleted => 'Done';

  @override
  String get csStatusCancelled => 'Cancelled';

  @override
  String get csStatusNoShow => 'Didn\'t take place';

  @override
  String get csStatusExpired => 'Not completed';

  @override
  String get csCatHealth => 'My health information';

  @override
  String get csCatAssessment => 'My assessment and pre-score';

  @override
  String get csCatCycle => 'My cycle and symptoms';

  @override
  String get csCatMeals => 'My meals';

  @override
  String get csCatLabs => 'My lab reports';

  @override
  String get csCatMessages => 'My messages';

  @override
  String get csEarlier => 'Earlier';

  @override
  String get csLater => 'Later';

  @override
  String get csNoTimesThisWeek => 'No free times in these days.';

  @override
  String csChooseTime(String time) {
    return 'Choose $time';
  }

  @override
  String get csWellness =>
      'A consult is how you reach a doctor or dietitian through Niraah. Niraah supports your wellbeing and does not replace your own doctor. For anything urgent, seek care near you.';

  @override
  String get csFindTitle => 'Find a specialist';

  @override
  String get csAppointmentsTitle => 'Appointments';

  @override
  String get csNoneBookable =>
      'No specialist has free time right now. Please look again later.';

  @override
  String get csNoneFound => 'No specialist matches these filters.';

  @override
  String get csClearFilters => 'Clear filters';

  @override
  String get csGuideTitle => 'Not sure who to see?';

  @override
  String get csGuideBody =>
      'Tell us what\'s on your mind and we\'ll suggest a kind of specialist.';

  @override
  String csIncludedUnlimited(String type) {
    return '$type consults are included in your plan';
  }

  @override
  String csIncludedLeft(String type, int count) {
    return '$type consults included: $count left';
  }

  @override
  String csIncludedPooled(String type) {
    return 'Choose a time and you\'ll see an available $type.';
  }

  @override
  String get csChooseATime => 'Choose a time';

  @override
  String get csIncludedUsedUp =>
      'You\'ve used this period\'s included consults. You can still book a consult with a fee.';

  @override
  String csIncludedRefills(String date) {
    return 'You\'ve used this period\'s included consults. They refill on $date.';
  }

  @override
  String get csFilterAll => 'All';

  @override
  String get csFilterDoctors => 'Doctors';

  @override
  String get csFilterDietitians => 'Dietitians';

  @override
  String get csMoreFilters => 'More filters';

  @override
  String csMoreFiltersOn(int count) {
    return 'More filters ($count)';
  }

  @override
  String get csFilterSpeciality => 'Speciality';

  @override
  String get csFilterLanguage => 'Language';

  @override
  String get csFilterDay => 'Any day';

  @override
  String csFilterDayOn(String date) {
    return 'Free on $date';
  }

  @override
  String get csApplyFilters => 'Show specialists';

  @override
  String csYears(int years) {
    return '$years years\' experience';
  }

  @override
  String csSpeaks(String languages) {
    return 'Speaks $languages';
  }

  @override
  String csNextFree(String time) {
    return 'Next free: $time';
  }

  @override
  String csFee(String amount) {
    return '$amount incl. GST';
  }

  @override
  String csRating(String average, int count) {
    return 'Rated $average by $count members';
  }

  @override
  String get csGuideIntro =>
      'Describe your concern in a few words. We suggest a kind of specialist; we never name a person or a diagnosis.';

  @override
  String get csGuideConcern => 'What would you like help with?';

  @override
  String get csGuideAsk => 'Suggest a specialist';

  @override
  String get csGuideAnswer => 'You could see';

  @override
  String get csGuideNone =>
      'We couldn\'t suggest a kind of specialist for this. A doctor is a good place to start.';

  @override
  String get csGuideByAi =>
      'Suggested by AI. AI insights do not replace medical advice.';

  @override
  String get csProfileTitle => 'Specialist';

  @override
  String get csTimes => 'Free times';

  @override
  String get csNoTimes => 'No times available right now.';

  @override
  String get csIncludedThis => 'Included in your plan';

  @override
  String get csSeeOtherClinicians => 'See other times';

  @override
  String csRegistration(String number, String council) {
    return 'Registration $number, $council';
  }

  @override
  String csPooledTitle(String type) {
    return '$type consult';
  }

  @override
  String csPooledNote(String type) {
    return 'Choose a time. You\'ll see which $type you\'re seeing as soon as you confirm.';
  }

  @override
  String get csIncludedNone =>
      'This consult isn\'t included in your plan right now.';

  @override
  String get csBooked => 'Your consult is booked.';

  @override
  String csAssignedOnConfirm(String type) {
    return 'An available $type, named when you confirm';
  }

  @override
  String get csYourClinician => 'Your clinician';

  @override
  String get csConfirmTitle => 'Confirm your consult';

  @override
  String get csHoldExpired => 'Your hold has ended. Choose a time again.';

  @override
  String csHoldLeft(String time) {
    return 'This time is held for you for $time.';
  }

  @override
  String get csConsentTitle => 'What may your clinician see?';

  @override
  String get csConsentBody =>
      'Choose what this clinician may see for this consult. You can change it until the consult starts.';

  @override
  String get csConsentNone =>
      'If you share nothing, your clinician has only what you tell them in the call.';

  @override
  String get csReasonTitle => 'Reason for the visit';

  @override
  String get csReasonLabel => 'In a few words (optional)';

  @override
  String get csReasonHelp => 'Only your clinician sees this.';

  @override
  String get csChooseAnotherTime => 'Choose another time';

  @override
  String get csConfirm => 'Confirm consult';

  @override
  String get csRelease => 'Give this time back';

  @override
  String get csBookAction => 'Book a consult';

  @override
  String get csUpcoming => 'Upcoming';

  @override
  String get csNoUpcoming =>
      'No consults coming up. When you book one, it appears here.';

  @override
  String get csPast => 'Past';

  @override
  String get csAppointmentTitle => 'Consult';

  @override
  String get csOutcomeReleased => 'The time is free again.';

  @override
  String get csOutcomeRefunded =>
      'Cancelled. Your payment is being refunded in full.';

  @override
  String get csOutcomeUnitReturned =>
      'Cancelled. The consult is back in your plan.';

  @override
  String get csOutcomeKept =>
      'Cancelled. As it was close to the start, the fee or included consult is used.';

  @override
  String get csOutcomeMoved => 'Your consult has a new time.';

  @override
  String get csOutcomeRated => 'Thank you for your rating.';

  @override
  String get csOutcomeDone => 'Done.';

  @override
  String get csFailureWaiting =>
      'Thank you. Our team will look at what happened and let you know.';

  @override
  String get csFailureChoice =>
      'The call didn\'t work. You can take another time or get your money or consult back.';

  @override
  String get csKeep => 'Keep it';

  @override
  String get csRescheduleTitle => 'Move your consult';

  @override
  String csRescheduleNote(int count) {
    return 'No charge. You can move it $count more times.';
  }

  @override
  String get csRebookTitle => 'Choose another time';

  @override
  String get csRebookNote =>
      'What you paid or used carries over to the new time.';

  @override
  String get csReleaseBody => 'This time will be free for others again.';

  @override
  String get csCancelBodyIncluded =>
      'If you cancel well ahead, the consult goes back to your plan; close to the start it counts as used. You\'ll see which straight away.';

  @override
  String get csCancelBodyPaid =>
      'If you cancel well ahead, you get a full refund; close to the start there\'s no refund. You\'ll see which straight away.';

  @override
  String get csCancelTitle => 'Cancel this consult?';

  @override
  String get csCancelAction => 'Cancel consult';

  @override
  String get csProposalTitle => 'Accept the new time?';

  @override
  String get csProposalBody =>
      'Your consult moves to the time your clinician suggested.';

  @override
  String get csProposalAccept => 'Accept';

  @override
  String get csProposalLink => 'My clinician suggested another time';

  @override
  String get csDeclineTitle => 'Get your money or consult back?';

  @override
  String get csDeclineBody =>
      'We\'ll refund what you paid, or return the consult to your plan.';

  @override
  String get csDeclineAction => 'Get my money or consult back';

  @override
  String get csReportTitle => 'The call didn\'t work?';

  @override
  String get csReportBody =>
      'Tell us and we\'ll look at what happened in the room.';

  @override
  String get csReportAction => 'The call didn\'t work';

  @override
  String get csPaidIncluded => 'Included in your plan';

  @override
  String csPaidFee(String amount) {
    return 'Fee $amount incl. GST';
  }

  @override
  String get csRecordingOn => 'This consult is recorded, as you agreed.';

  @override
  String get csFinishBooking => 'Finish booking';

  @override
  String csRoomOpensAt(String time) {
    return 'The room opens at $time.';
  }

  @override
  String get csJoin => 'Join the consult';

  @override
  String get csReschedule => 'Move to another time';

  @override
  String get csNoShowOffer =>
      'Your clinician didn\'t join. Take another time, or get your money or consult back.';

  @override
  String get csRebook => 'Choose another time';

  @override
  String get csRate => 'Rate this consult';

  @override
  String get csBookAgain => 'Book again';

  @override
  String get csRateTitle => 'Rate your consult';

  @override
  String get csRateBody =>
      'How was your consult? Your name is never shown with your rating.';

  @override
  String csRateStars(int count) {
    return '$count out of 5';
  }

  @override
  String get csRateComment => 'Anything you\'d like to add (optional)';

  @override
  String get csRateSend => 'Send rating';

  @override
  String get csRateChoose => 'Choose a rating to continue';

  @override
  String get csRecordingStopped =>
      'Recording stopped. What was recorded is kept as partial.';

  @override
  String get csRoomTitle => 'Consult room';

  @override
  String get csRecordingMark => 'Recording';

  @override
  String get csRecordingBody =>
      'This consult is being recorded as you agreed. You can stop it at any time.';

  @override
  String get csRecordingStop => 'Stop recording';

  @override
  String get csRoomNotOpen => 'The room isn\'t open yet';

  @override
  String get csRoomCheckAgain => 'Check again';

  @override
  String get billTitle => 'Manage plan';

  @override
  String get billStatusTrial => 'Free trial';

  @override
  String get billStatusActive => 'Active';

  @override
  String get billStatusPastDue => 'Payment didn\'t go through';

  @override
  String get billStatusPending => 'Waiting for payment';

  @override
  String get billCancelTitle => 'Cancel your plan?';

  @override
  String billCancelBody(String plan, String date) {
    return 'You keep $plan until $date. No further charge is made, and there\'s no refund for the current period. You can undo this until then.';
  }

  @override
  String billCancelBodyNoDate(String plan) {
    return 'You keep $plan until the end of the current period. No further charge is made, and there\'s no refund for the current period.';
  }

  @override
  String get billKeep => 'Keep my plan';

  @override
  String get billCancelAction => 'Cancel plan';

  @override
  String billCancelled(String date) {
    return 'Your plan ends on $date. No further charge will be made.';
  }

  @override
  String get billUndone => 'Your plan continues.';

  @override
  String billChangeLater(String date) {
    return 'Your new plan starts on $date. Until then you keep your current plan.';
  }

  @override
  String get billChangeDone => 'Your new plan is in force.';

  @override
  String billEndsOn(String date) {
    return 'Ends on $date';
  }

  @override
  String billRenewsOn(String date) {
    return 'Renews on $date';
  }

  @override
  String billValidUntil(String date) {
    return 'Valid until $date';
  }

  @override
  String get billNoSubscription => 'You don\'t have a paid plan.';

  @override
  String get billChange => 'Change plan';

  @override
  String get billUndo => 'Keep my plan after all';

  @override
  String get billInvoices => 'Invoices';

  @override
  String get billInvoicesOpen => 'Invoices and credit notes';

  @override
  String get billChangeNote =>
      'A plan that costs more starts when its payment goes through. One that costs less starts when your current period ends.';

  @override
  String get billNoOtherPlans => 'There are no other plans to move to.';

  @override
  String billPriceLine(String amount) {
    return '$amount incl. GST';
  }

  @override
  String get billNoInvoices =>
      'No invoices yet. Each payment\'s invoice appears here.';

  @override
  String get billCreditNote => 'Credit note';

  @override
  String get billInvoice => 'Invoice';

  @override
  String get billFrom => 'From';

  @override
  String billGstin(String number) {
    return 'GSTIN $number';
  }

  @override
  String get billTo => 'To';

  @override
  String get billLines => 'Details';

  @override
  String get billBeforeTax => 'Before tax';

  @override
  String billTax(String rate) {
    return 'GST at $rate%';
  }

  @override
  String get billLineTotal => 'Total';

  @override
  String get billTotalTax => 'Total GST';

  @override
  String get billTotal => 'Amount paid';

  @override
  String get waTitle => 'Wellness advice from your doctor';

  @override
  String get waEmpty =>
      'Wellness advice from a doctor after a consult appears here.';

  @override
  String get waReplaced => 'A newer advice replaces this one.';

  @override
  String get waAssessment => 'Assessment';

  @override
  String get waSupplements => 'Supplements';

  @override
  String get waAdvice => 'Advice';

  @override
  String get waSeeDoctor => 'See a doctor in person';

  @override
  String get waFollowUp => 'Follow-up';

  @override
  String get waTests => 'Tests advised';

  @override
  String waCode(String code) {
    return 'Verification code $code';
  }

  @override
  String get waOpenDocument => 'Open the document';

  @override
  String get acctDevicesTitle => 'Signed-in devices';

  @override
  String get acctDevicesBody =>
      'Where your account is signed in. End any you don\'t recognise.';

  @override
  String get acctDevicesOpen => 'See signed-in devices';

  @override
  String get acctThisDevice => 'This device';

  @override
  String acctLastActive(String time) {
    return 'Last active $time';
  }

  @override
  String get acctEnd => 'Sign out';

  @override
  String get acctEnded => 'That device is signed out.';

  @override
  String get acctEndAll => 'Sign out everywhere';

  @override
  String get acctEndAllTitle => 'Sign out everywhere?';

  @override
  String get acctEndAllBody =>
      'Every device, this one included, is signed out. You\'ll sign in again with a code.';

  @override
  String get acctChangeNumber => 'Change mobile number';

  @override
  String get acctNumberTitle => 'Mobile number';

  @override
  String get acctNumberBody =>
      'First we check it\'s you with a code to your current number. Then enter your new number and the code we send to it.';

  @override
  String get acctNewNumber => 'New mobile number';

  @override
  String get acctSendCode => 'Send a code to the new number';

  @override
  String get acctCodeSent => 'Enter the code we sent to your new number.';

  @override
  String get acctConfirmNumber => 'Change number';

  @override
  String get acctNumberChanged =>
      'Your number is changed. Other devices are signed out.';

  @override
  String acctPendingChange(String ending, String date) {
    return 'A change to a number ending $ending takes effect on $date.';
  }

  @override
  String get acctCancelChange => 'This wasn\'t me: cancel it';

  @override
  String get acctChangeCancelled => 'The change is cancelled.';

  @override
  String get acctEmailBody =>
      'A recovery email helps you get back into your account if you lose your number. It counts once you open the link we send to it. It can\'t be used to sign in.';

  @override
  String acctEmailNow(String email) {
    return 'Now: $email';
  }

  @override
  String get acctEmailAdd => 'Add a recovery email';

  @override
  String get acctEmailNew => 'New recovery email';

  @override
  String get acctEmailChange => 'Change recovery email';

  @override
  String get acctEmailSave => 'Send the link';

  @override
  String get acctEmailSent => 'We sent a link. Open it to finish.';

  @override
  String get acctEmailRemove => 'Remove recovery email';

  @override
  String get acctEmailRemoved => 'Recovery email removed.';

  @override
  String get mealsHistoryTitle => 'Meal history';

  @override
  String get mealsHistoryEmpty => 'The days you log meals appear here.';

  @override
  String mealsHistoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '1 meal',
    );
    return '$_temp0';
  }

  @override
  String get mealPlanTitle => 'My meal plan';

  @override
  String get mealPlanNone =>
      'When your dietitian shares a meal plan with you, it appears here.';

  @override
  String mealPlanBy(String name) {
    return 'From $name';
  }

  @override
  String get mealPlanPrevDay => 'Previous day';

  @override
  String get mealPlanNextDay => 'Next day';

  @override
  String mealPlanDay(int day, String date) {
    return 'Day $day · $date';
  }

  @override
  String mealPlanOr(String options) {
    return 'Or: $options';
  }

  @override
  String get mealPlanSlotEarly => 'Early morning';

  @override
  String get mealPlanSlotMidMorning => 'Mid-morning';

  @override
  String get mealPlanSlotEvening => 'Evening snack';

  @override
  String get mealPlanSlotBedtime => 'Bedtime';

  @override
  String get rmPermissionTitle => 'Camera and microphone';

  @override
  String get rmPermissionWhy =>
      'To see and hear each other, the app will ask to use your camera and microphone. They\'re used only during this call, and you can turn either off at any time.';

  @override
  String get rmAllow => 'Allow camera and microphone';

  @override
  String get rmAudioOnlyPermission =>
      'We could use your microphone but not your camera. You can still join by voice.';

  @override
  String get rmDenied =>
      'The camera and microphone are blocked for Niraah. Allow them in your phone\'s settings, then try again.';

  @override
  String get rmOpenSettings => 'Open settings';

  @override
  String get rmCameraOff => 'Camera off';

  @override
  String get rmJoinNow => 'Join now';

  @override
  String get rmJoining => 'Joining…';

  @override
  String rmWithClinician(String name) {
    return 'Your consult with $name';
  }

  @override
  String get rmYourClinician => 'your clinician';

  @override
  String rmWaitingFor(String name) {
    return 'Waiting for $name…';
  }

  @override
  String get rmWaitingNote =>
      'They know you\'re here. You can stay on this screen.';

  @override
  String rmStartsAt(String time) {
    return 'Starts at $time';
  }

  @override
  String get rmReconnecting => 'Reconnecting…';

  @override
  String get rmReconnectingNote =>
      'Your connection dropped. We\'re getting you back in; you don\'t need to do anything.';

  @override
  String get rmDropped => 'You\'re no longer connected.';

  @override
  String get rmRejoin => 'Rejoin';

  @override
  String get rmWeak =>
      'Your connection is weak. Switching to audio only can keep the call clear.';

  @override
  String get rmSwitchAudioOnly => 'Switch to audio only';

  @override
  String get rmAudioOnlyOn =>
      'Audio only is on: your camera is off and incoming video is paused.';

  @override
  String get rmVideoBack => 'Turn video back on';

  @override
  String get rmMicMute => 'Mute microphone';

  @override
  String get rmMicUnmute => 'Unmute microphone';

  @override
  String get rmCameraTurnOff => 'Turn camera off';

  @override
  String get rmCameraTurnOn => 'Turn camera on';

  @override
  String get rmSwitchCamera => 'Switch camera';

  @override
  String get rmLeave => 'Leave';

  @override
  String get rmLeaveConfirm =>
      'Leave the room? You can come back while the room is open.';

  @override
  String get rmStay => 'Stay';

  @override
  String get rmLeft => 'You\'ve left the room.';

  @override
  String get rmClosed => 'The room has closed.';

  @override
  String get rmGoBackIn => 'Go back in';

  @override
  String rmRemaining(String time) {
    return '$time left';
  }

  @override
  String rmTimeUp(String time) {
    return 'Time is up · room closes in $time';
  }

  @override
  String get rmJoinFailed =>
      'We couldn\'t connect you to the room. Check your connection and try again.';

  @override
  String get rmLoadError =>
      'We couldn\'t open this room. Try again in a moment.';

  @override
  String get rmYou => 'You';

  @override
  String get dcLink => 'Check camera and microphone';

  @override
  String get dcTitle => 'Device check';

  @override
  String get dcBody =>
      'Check that your camera, microphone and connection work before your consult.';

  @override
  String get dcStart => 'Start the check';

  @override
  String get dcCamera => 'Camera';

  @override
  String get dcCameraOk => 'Your camera works if you can see yourself above.';

  @override
  String get dcBlocked =>
      'Not allowed. You can allow it in your phone\'s settings.';

  @override
  String get dcMicrophone => 'Microphone';

  @override
  String get dcMicSpeak =>
      'Say something: the bar moves when your microphone hears you.';

  @override
  String get dcConnection => 'Connection';

  @override
  String get dcTesting => 'Testing…';

  @override
  String get dcGood => 'Good for video';

  @override
  String get dcPoor => 'Weak: video may look soft, but voice should work';

  @override
  String get dcDown => 'Not connected';

  @override
  String get dcAllowedOnly =>
      'Your camera and microphone are allowed. The preview and connection test run in the room before you join.';

  @override
  String get dcFailed => 'The check couldn\'t start. Try again in a moment.';

  @override
  String get clRoomTitle => 'Live class';

  @override
  String get clPrivacy =>
      'You join with your camera and microphone off. Other members can\'t see or hear you, or see your name.';

  @override
  String get clWaitingInstructor => 'Waiting for your instructor…';

  @override
  String get clCameraOn => 'Show my camera to the instructor';

  @override
  String get clCameraOff => 'Turn my camera off';

  @override
  String get clCameraNote =>
      'Only your instructor sees your camera, so she can help with your posture.';

  @override
  String get clCameraSharing => 'Your instructor can see your camera.';

  @override
  String get clYourClasses => 'Your classes';

  @override
  String get clJoin => 'Join class';

  @override
  String get icOpenRoom => 'Open class room';

  @override
  String get icCheckBody =>
      'Check your camera and microphone, then start the class when the room opens.';

  @override
  String get icStart => 'Start class';

  @override
  String get icEnd => 'End class';

  @override
  String get icEndConfirm => 'End the class for everyone?';

  @override
  String get icEnded => 'Class ended.';

  @override
  String icPresent(int count) {
    return '$count present';
  }

  @override
  String icJoined(String names) {
    return 'Joined: $names';
  }

  @override
  String get icNoneJoined => 'No one has joined yet.';

  @override
  String icPhaseCount(String phase, int count) {
    return '$phase: $count';
  }

  @override
  String get icStudentCameras => 'Students\' cameras';

  @override
  String get payConfirming => 'Confirming your payment…';

  @override
  String get payConfirmingNote => 'This can take a few seconds.';

  @override
  String get payPending =>
      'Your payment is being confirmed. We\'ll let you know as soon as it is.';

  @override
  String get payCancelled => 'Payment not completed.';

  @override
  String get payFailed => 'The payment didn\'t go through. You can try again.';

  @override
  String get payLapsed =>
      'Your held time ran out before the payment arrived. It will be refunded to you in full.';

  @override
  String get payDescConsult => 'Consult';

  @override
  String get payDescClass => 'Live class';

  @override
  String csPayAndConfirm(String amount) {
    return 'Confirm and pay $amount';
  }

  @override
  String get csPayHoldNote =>
      'Your time stays held while you pay. The fee shown is the fee charged.';

  @override
  String get csPaidBooked => 'Paid. Your consult is booked.';

  @override
  String get practicePayTitle => 'Pay for this class?';

  @override
  String practicePayBody(String amount) {
    return 'This class is $amount incl. GST. Your place is held while you pay.';
  }

  @override
  String practicePay(String amount) {
    return 'Pay $amount';
  }

  @override
  String get practiceNotNow => 'Not now';

  @override
  String get practicePaidBooked => 'Paid. Your place is booked.';

  @override
  String get billPayTitle => 'Pay for the change?';

  @override
  String billPayBody(String amount) {
    return 'Your new plan costs $amount now, after credit for the unused days of your current plan. It starts when the payment is confirmed. A paid period isn\'t refunded once it has started.';
  }

  @override
  String billPay(String amount) {
    return 'Pay $amount';
  }

  @override
  String plansActive(String plan) {
    return '$plan is now your plan.';
  }

  @override
  String plansTrialStarted(String plan) {
    return 'Your free trial of $plan has started. Doctor, dietitian and live-class features begin with your first payment.';
  }

  @override
  String get plansNoRefund =>
      'A paid period isn\'t refunded once it has started.';

  @override
  String get csTranscriptConsentTitle => 'A written transcript of this consult';

  @override
  String get csTranscriptDraft => 'Draft wording, pending legal review';

  @override
  String get csTranscriptConsentBody =>
      'If you agree, the audio of this consult is sent to Sarvam AI to be written up as text, and the audio is then deleted. You, this specialist, your doctor or dietitian caring for you now, and a Niraah super admin (only for a complaint, dispute or legal request) can read the transcript. It is kept for up to 3 years. You can still have your consult if you say no.';

  @override
  String get csTranscriptConsentYes => 'Yes, make a transcript of this consult';

  @override
  String get csTranscriptTitle => 'Consult transcript';

  @override
  String get csTranscriptRead => 'Read the transcript';

  @override
  String get csTranscriptPending =>
      'The transcript is being written up. Check back a little later.';

  @override
  String get csTranscriptFailed =>
      'We could not make a transcript of this consult.';

  @override
  String get csTranscriptNone => 'There is no transcript for this consult.';

  @override
  String get csTranscriptUnverified =>
      'Machine-made transcript, not checked by a person. It may contain errors, especially in mixed-language speech.';

  @override
  String get csTranscriptPartial =>
      'The recording was stopped part-way, so this covers only the start of the consult.';

  @override
  String get csTranscriptWhoReads =>
      'You, this specialist and your doctor or dietitian caring for you now can read it.';

  @override
  String get csTranscriptYou => 'You';

  @override
  String get csTranscriptMember => 'Member';

  @override
  String get csTranscriptDoctor => 'Doctor';

  @override
  String get csTranscriptDietitian => 'Dietitian';

  @override
  String csTranscriptMissing(String who) {
    return 'The $who\'s voice could not be transcribed.';
  }
}
