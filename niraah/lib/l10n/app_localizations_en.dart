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
  String get processingTitle => 'Working out your pre-score';

  @override
  String get processingBody =>
      'Niraah AI is looking across your answers. This takes a few seconds.';

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
  String get practicePayOnWeb =>
      'This class needs a payment, which the app can\'t take yet.';

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
  String get drAPatientsEyebrow => 'Your care list';

  @override
  String drAPatientsCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n patients',
      one: '1 patient',
    );
    return '$_temp0';
  }

  @override
  String drAPatientsAlerts(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n with an open alert',
      one: '1 with an open alert',
      zero: 'No open alerts',
    );
    return '$_temp0';
  }

  @override
  String get drALockedBody =>
      'She decides what she shares. Nothing from this section is shown until she gives consent.';

  @override
  String get drACycleLengths => 'Cycle lengths';

  @override
  String drACycleAvg(int n) {
    return 'Average $n days';
  }

  @override
  String drADays(int n) {
    return '$n d';
  }

  @override
  String get drASymptoms => 'Symptoms';

  @override
  String get drADimensions => 'By dimension';

  @override
  String get drACareTeam => 'Care team';

  @override
  String get drADetails => 'Details';

  @override
  String get drAQueueWaiting => 'Waiting';

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
  String get dtShellTitle => 'Dietitian';

  @override
  String get dtDashShortcuts => 'Plans and recipes';

  @override
  String get dtRecipesSubtitle => 'Your recipes and the shared library';

  @override
  String get dtClientsEyebrow => 'Your clients';

  @override
  String get dtCareTeam => 'Care team';

  @override
  String get dtRelationship => 'Relationship';

  @override
  String get dtPlanLabel => 'Plan';

  @override
  String get dtDoctorLabel => 'Her doctor';

  @override
  String get dtMealsLogged => 'Meals logged by day';

  @override
  String get dtUnread => 'Unread';

  @override
  String get dtTrendEnergy => 'Energy';

  @override
  String get dtTrendCravings => 'Cravings';

  @override
  String get dtCheckInsSubtitle =>
      'Read each one and reply with a short, kind note.';

  @override
  String get dtMoreSubtitle => 'Plans, recipes, check-ins and your account';

  @override
  String get dtMoreWork => 'Your work';

  @override
  String get dtAboutYou => 'About you';

  @override
  String get dtQueueSubtitle =>
      'Oldest first. Your dedicated clients\' days are yours.';

  @override
  String get dtMealsLabel => 'Meals logged';

  @override
  String get schedNothingThisDay => 'Nothing booked this day.';

  @override
  String dtDashWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things are waiting for you',
      one: '1 thing is waiting for you',
      zero: 'Nothing is waiting for you',
    );
    return '$_temp0';
  }

  @override
  String dtClientsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clients',
      one: '1 client',
      zero: 'No clients',
    );
    return '$_temp0';
  }

  @override
  String dtUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread check-ins',
      one: '1 unread check-in',
      zero: 'No unread check-ins',
    );
    return '$_temp0';
  }

  @override
  String dtPlansCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meal plans',
      one: '1 meal plan',
      zero: 'No meal plans yet',
    );
    return '$_temp0';
  }

  @override
  String dtWaitingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clients waiting for a plan',
      one: '1 client waiting for a plan',
      zero: 'Nobody is waiting for a plan',
    );
    return '$_temp0';
  }

  @override
  String dtQueueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days to review',
      one: '1 day to review',
      zero: 'Nothing to review',
    );
    return '$_temp0';
  }

  @override
  String schedAppointmentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appointments',
      one: '1 appointment',
      zero: 'No appointments',
    );
    return '$_temp0';
  }

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
  String get inStartOnWeb =>
      'Starting and running a class isn\'t in the app yet.';

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
  String get welcomeChipDoctors => 'Doctor-reviewed';

  @override
  String get welcomeChipPrivate => 'Private by design';

  @override
  String get landingNavProfessionals => 'For care professionals';

  @override
  String get landingNavSignIn => 'Sign in';

  @override
  String get landingHeroEyebrow => 'Women\'s health, made personal';

  @override
  String get landingHeroTitle => 'Care for your cycle, hormones and whole self';

  @override
  String get landingHeroBody =>
      'Niraah brings verified doctors, dietitians and yoga trainers together with an AI companion, for PCOS, fertility, metabolic health and pregnancy.';

  @override
  String get landingHeroCta => 'Start your free assessment';

  @override
  String get landingHeroSecondary => 'I\'m a care professional';

  @override
  String get landingTick1 => 'Free to start';

  @override
  String get landingTick2 => 'Doctor-reviewed plans';

  @override
  String get landingTick3 => 'Indian diets';

  @override
  String get landingChipDoctors => 'Verified doctors';

  @override
  String get landingChipAi => 'AI companion';

  @override
  String get landingChipYoga => 'Yoga for your phase';

  @override
  String get landingTrust1 => 'Registered doctors and dietitians';

  @override
  String get landingTrust2 => 'Plans built on Indian food';

  @override
  String get landingTrust3 => 'Your data stays private';

  @override
  String get landingTrust4 => 'Prices in rupees, including GST';

  @override
  String get landingProgramsEyebrow => 'Programs';

  @override
  String get landingProgramsTitle => 'Support shaped around you';

  @override
  String get landingProgramPcos => 'PCOS & hormones';

  @override
  String get landingProgramPcosBody =>
      'Understand symptoms and build steady habits with your care team.';

  @override
  String get landingProgramFertility => 'Fertility journey';

  @override
  String get landingProgramFertilityBody =>
      'Know your cycle and prepare with expert guidance.';

  @override
  String get landingProgramMetabolic => 'Metabolic balance';

  @override
  String get landingProgramMetabolicBody =>
      'Food, movement and rest for steadier energy.';

  @override
  String get landingProgramPregnancy => 'Pregnancy care';

  @override
  String get landingProgramPregnancyBody =>
      'Gentle support for each trimester.';

  @override
  String get landingStepsEyebrow => 'How it works';

  @override
  String get landingStepsTitle => 'Four calm steps';

  @override
  String get landingStep1 => 'Take the assessment';

  @override
  String get landingStep1Body =>
      'A few minutes of questions about your cycle, health and habits.';

  @override
  String get landingStep2 => 'See your insights';

  @override
  String get landingStep2Body =>
      'A wellness pre-score and the areas that need care.';

  @override
  String get landingStep3 => 'Meet your care team';

  @override
  String get landingStep3Body =>
      'Doctors, dietitians and trainers who are verified by Niraah.';

  @override
  String get landingStep4 => 'Follow your plan';

  @override
  String get landingStep4Body =>
      'Daily tasks, meals and practice, adjusted as you go.';

  @override
  String get landingTeamEyebrow => 'Your care team';

  @override
  String get landingTeamTitle => 'Real experts, with AI by your side';

  @override
  String get landingTeamDoctor => 'Doctors';

  @override
  String get landingTeamDoctorBody =>
      'Video consults and care plans from registered doctors.';

  @override
  String get landingTeamDietitian => 'Dietitians';

  @override
  String get landingTeamDietitianBody =>
      'Indian meal plans checked by a dietitian before you see them.';

  @override
  String get landingTeamYoga => 'Yoga & fitness trainers';

  @override
  String get landingTeamYogaBody =>
      'Classes and sessions matched to your cycle phase.';

  @override
  String get landingTeamAi => 'AI companion';

  @override
  String get landingTeamAiBody =>
      'Answers any time, with sources, and never medicine doses.';

  @override
  String get landingSafetyTitle => 'Wellness support, not emergency care';

  @override
  String get landingSafetyBody =>
      'Niraah supports and does not replace your own doctor. In an emergency, call 112. For mental health support, call Tele-MANAS on 14416.';

  @override
  String get landingCtaTitle => 'Begin with a free assessment';

  @override
  String get landingCtaBody =>
      'It takes about five minutes. You can stop any time.';

  @override
  String get landingFooter => '© Niraah by Anvayuone';

  @override
  String get landingEmergency => 'Emergency: 112 · Tele-MANAS: 14416';

  @override
  String get landingMobileHeroBody =>
      'Doctors, dietitians, yoga trainers and an AI companion, for PCOS, fertility, metabolic health and pregnancy.';

  @override
  String get landingMobileGetTitle => 'What you get';

  @override
  String get landingMobileBenefit1 => 'Cycle and symptom tracking';

  @override
  String get landingMobileBenefit1Body =>
      'Predictions and patterns, in one calm place.';

  @override
  String get landingMobileBenefit2 => 'Indian meal plans';

  @override
  String get landingMobileBenefit2Body => 'Built on foods you already eat.';

  @override
  String get landingMobileBenefit3 => 'Yoga for your phase';

  @override
  String get landingMobileBenefit3Body => 'Classes matched to your cycle.';

  @override
  String get landingMobileBenefit4 => 'AI Care, any time';

  @override
  String get landingMobileBenefit4Body =>
      'Answers with sources, never medicine doses.';

  @override
  String get landingMobileTeamYoga => 'Yoga';

  @override
  String get landingMobileTeamAi => 'AI Care';

  @override
  String get landingMobileHaveAccount => 'I already have an account';

  @override
  String get landingMobileProgramsBody =>
      'Programs for PCOS, fertility, metabolic health and pregnancy.';

  @override
  String get landingMobileDailyTitle => 'Small steps, every day';

  @override
  String get landingMobileDailyBody =>
      'Track your cycle, eat Indian meals that suit you and move for your phase.';

  @override
  String get landingMobileTeamBody =>
      'Doctors, dietitians and yoga trainers verified by Niraah, with AI Care any time.';

  @override
  String get landingMobileTeamYou => 'You';

  @override
  String get dietTitle => 'Your diet plan';

  @override
  String get dietMaking => 'Cooking your plan…';

  @override
  String get dietEditPreferences => 'Food preferences';

  @override
  String get dietLockedTitle => 'Diet plans are part of some plans';

  @override
  String get dietLockedBody => 'Choose a plan that includes the AI diet plan.';

  @override
  String dietLockedPlans(String plans) {
    return 'Included in: $plans';
  }

  @override
  String get dietSeePlans => 'See plans';

  @override
  String get dietNeedsDietitianTitle => 'A dietitian is the right fit';

  @override
  String get dietDietitianPlanTitle => 'Your dietitian\'s plan';

  @override
  String get dietDietitianPlanBody =>
      'Your dietitian has made a meal plan for you. You\'ll find it in Care.';

  @override
  String get dietUnavailableTitle => 'No plan just yet';

  @override
  String get dietMadeByAi => 'Made by AI · not reviewed by a dietitian';

  @override
  String get dietMadeByRules =>
      'Made from your food choices · not reviewed by a dietitian';

  @override
  String get dietSwap => 'Swap';

  @override
  String dietSwapTitle(String dish) {
    return 'Swap $dish';
  }

  @override
  String get dietSwapBody =>
      'Your choice replaces this dish for the rest of the week.';

  @override
  String get dietDayTotals => 'This day';

  @override
  String get dietKcal => 'kcal';

  @override
  String get dietProtein => 'protein';

  @override
  String get dietFibre => 'fibre';

  @override
  String get dietCarbs => 'carbs';

  @override
  String get dietNewWeek => 'Make a new week';

  @override
  String get dietNewWeekTomorrow => 'New week available tomorrow';

  @override
  String get dietSlotBreakfast => 'Breakfast';

  @override
  String get dietSlotMidMorning => 'Mid-morning';

  @override
  String get dietSlotLunch => 'Lunch';

  @override
  String get dietSlotEveningSnack => 'Evening snack';

  @override
  String get dietSlotDinner => 'Dinner';

  @override
  String get dietProfileTitle => 'Tell us how you eat';

  @override
  String get dietProfileBody =>
      'We\'ll plan Indian meals around your choices. You can change these any time.';

  @override
  String get dietFoodChoice => 'Food choice';

  @override
  String get dietAllergies => 'Allergies';

  @override
  String get dietNoAllergies => 'No allergies';

  @override
  String get dietCuisine => 'Regional cuisine';

  @override
  String get dietFastingDays => 'Fasting days (optional)';

  @override
  String get dietAvoided => 'Foods you avoid (optional)';

  @override
  String get dietAvoidedNone => 'Choose foods';

  @override
  String dietAvoidedCount(int count) {
    return '$count chosen';
  }

  @override
  String get dietSaveAndMake => 'Save and make my plan';

  @override
  String get dietProfileHint => 'Choose your food choice and allergies';

  @override
  String get dietDone => 'Done';

  @override
  String get dietVegetarian => 'Vegetarian';

  @override
  String get dietEggetarian => 'Eggetarian';

  @override
  String get dietNonVegetarian => 'Non-vegetarian';

  @override
  String get dietVegan => 'Vegan';

  @override
  String get dietJain => 'Jain';

  @override
  String get dietPanIndian => 'Pan-Indian';

  @override
  String get dietNorthIndian => 'North Indian';

  @override
  String get dietSouthIndian => 'South Indian';

  @override
  String get dietEastIndian => 'East Indian';

  @override
  String get dietWestIndian => 'West Indian';

  @override
  String get dietPeanut => 'Peanut';

  @override
  String get dietTreeNut => 'Tree nuts';

  @override
  String get dietGluten => 'Gluten';

  @override
  String get dietMilk => 'Milk';

  @override
  String get dietEgg => 'Egg';

  @override
  String get dietSoy => 'Soy';

  @override
  String get dietSesame => 'Sesame';

  @override
  String get dietMustard => 'Mustard';

  @override
  String get dietFish => 'Fish';

  @override
  String get dietShellfish => 'Shellfish';

  @override
  String get dietSun => 'Sun';

  @override
  String get dietMon => 'Mon';

  @override
  String get dietTue => 'Tue';

  @override
  String get dietWed => 'Wed';

  @override
  String get dietThu => 'Thu';

  @override
  String get dietFri => 'Fri';

  @override
  String get dietSat => 'Sat';

  @override
  String get dietEntryTitle => 'Your AI diet plan';

  @override
  String get dietEntryBody =>
      'A week of Indian meals made for you, with swaps.';

  @override
  String get mealsScanStepDishes => 'Finding each dish on your plate…';

  @override
  String get mealsScanStepPortions => 'Estimating portions…';

  @override
  String get mealsScanStepNutrients =>
      'Matching the Indian food table for nutrients…';

  @override
  String get dietOpenCta => 'See this week\'s meals';

  @override
  String get dietMakingHint =>
      'This can take up to a minute. Please keep the app open.';

  @override
  String get cycleFertileLegend => 'Fertile window, estimated';

  @override
  String get cycleTodayLegend => 'Today';

  @override
  String get cyclePhaseShortPeriod => 'Period';

  @override
  String get cyclePhaseShortFollicular => 'Follicular';

  @override
  String get cyclePhaseShortOvulation => 'Ovulation';

  @override
  String get cyclePhaseShortLuteal => 'Luteal';

  @override
  String get dietCook1 => 'Reading your food choice and allergies…';

  @override
  String get dietCook2 => 'Picking dishes from your cuisine…';

  @override
  String get dietCook3 => 'Balancing protein, fibre and energy…';

  @override
  String get dietCook4 => 'Adding swaps you might like…';

  @override
  String get dietCook5 => 'Plating your week…';

  @override
  String get dietCooking => 'Cooking your plan…';

  @override
  String get dietPreparing => 'Getting your kitchen ready…';

  @override
  String get loadPlans => 'Laying out your plans';

  @override
  String get loadCare => 'Getting your care desk ready';

  @override
  String get loadSecure => 'Keeping your account safe';

  @override
  String get loadAssessment => 'Getting your check-in ready';

  @override
  String get loadMeals => 'Setting out today\'s meals';

  @override
  String get loadChat => 'Opening AI Care';

  @override
  String get loadSymptoms => 'Checking in with your body';

  @override
  String get loadHome => 'Bringing your day together';

  @override
  String get loadCycle => 'Reading your cycle';

  @override
  String get scoreAreaCycle => 'Cycle';

  @override
  String get scoreAreaMetabolic => 'Metabolic';

  @override
  String get scoreAreaMind => 'Mind';

  @override
  String get scoreAreaRest => 'Rest';

  @override
  String get scoreStep1 => 'Reading your answers';

  @override
  String get scoreStep2 => 'Looking at your cycle pattern';

  @override
  String get scoreStep3 => 'Weighing symptoms and energy';

  @override
  String get scoreStep4 => 'Checking stress and sleep';

  @override
  String get scoreStep5 => 'Building your pre-score';

  @override
  String drDashWaiting(int count, int consults) {
    return '$count things need you today · $consults consults booked';
  }

  @override
  String drDashAllClear(int consults) {
    return 'You\'re all caught up · $consults consults booked';
  }

  @override
  String get drOnCallShort => 'On call';

  @override
  String get drOffCallShort => 'Off call';

  @override
  String drDashBooked(int count) {
    return '$count booked';
  }

  @override
  String get drQueueClear => 'The queue is clear';

  @override
  String get drNextUp => 'Next';

  @override
  String get drMoreWork => 'Clinical work';

  @override
  String get drMoreYou => 'You and your account';

  @override
  String get drMoreSubtitle => 'Alerts, care plans, results and your profile';

  @override
  String get drRatingLabel => 'Average rating';

  @override
  String drRatingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'from $count reviews',
      one: 'from 1 review',
    );
    return '$_temp0';
  }

  @override
  String get drOnCallNote => 'While this is on, urgent alerts reach you first.';

  @override
  String drDecidedCount(int done, int total) {
    return '$done of $total sections decided';
  }

  @override
  String drFlaggedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flagged',
      one: '1 flagged',
    );
    return '$_temp0';
  }

  @override
  String get drRegistrationTitle => 'Registration';

  @override
  String get drAboutYou => 'About you';

  @override
  String get drInRange => 'In range';

  @override
  String get drMedicinesTitle => 'Her medicines';

  @override
  String get inWorkspace => 'Instructor studio';

  @override
  String get inHomeTitle => 'Today\'s practice';

  @override
  String inTodayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count classes on your mat today',
      one: '1 class on your mat today',
      zero: 'No classes on your mat today',
    );
    return '$_temp0';
  }

  @override
  String get inNextUp => 'Next up';

  @override
  String get inAgendaTitle => 'Your agenda';

  @override
  String inUpcomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count classes ahead',
      one: '1 class ahead',
      zero: 'Nothing scheduled ahead',
    );
    return '$_temp0';
  }

  @override
  String get inPastWeek => 'Past week';

  @override
  String get inComingUp => 'Coming up';

  @override
  String get inClassDetails => 'Class details';

  @override
  String get inTimeAndSize => 'Time and size';

  @override
  String get inRepeatSection => 'Repeat';

  @override
  String get inStudentsTitle => 'The people who practise with you';

  @override
  String inStudentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students',
      one: '1 student',
    );
    return '$_temp0';
  }

  @override
  String get inLibraryTitle => 'Your recorded sessions';

  @override
  String inRatingLine(String rating, int count) {
    return '$rating from $count ratings';
  }

  @override
  String get inMoreTitle => 'Your studio';

  @override
  String get inClassActions => 'What you can do';
}
