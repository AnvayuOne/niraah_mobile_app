import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Niraah'**
  String get appName;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @comingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'This part of Niraah is still being built.'**
  String get comingSoonBody;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go to home'**
  String get goHome;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this just now. Your answers are safe.'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @notConnectedYet.
  ///
  /// In en, this message translates to:
  /// **'This screen isn\'t connected to Niraah\'s servers yet.'**
  String get notConnectedYet;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get navCycle;

  /// No description provided for @navAiCare.
  ///
  /// In en, this message translates to:
  /// **'AI Care'**
  String get navAiCare;

  /// No description provided for @navPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get navPractice;

  /// No description provided for @navMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navMe;

  /// No description provided for @splashLabel.
  ///
  /// In en, this message translates to:
  /// **'Niraah, women\'s wellness'**
  String get splashLabel;

  /// No description provided for @introTitle1.
  ///
  /// In en, this message translates to:
  /// **'Know your cycle, know yourself'**
  String get introTitle1;

  /// No description provided for @introBody1.
  ///
  /// In en, this message translates to:
  /// **'Track your period, ovulation and symptoms, all in one calm place.'**
  String get introBody1;

  /// No description provided for @introTitle2.
  ///
  /// In en, this message translates to:
  /// **'Care for PCOS, fertility and more'**
  String get introTitle2;

  /// No description provided for @introBody2.
  ///
  /// In en, this message translates to:
  /// **'Guidance for hormones, nutrition and movement, shaped around you.'**
  String get introBody2;

  /// No description provided for @introTitle3.
  ///
  /// In en, this message translates to:
  /// **'Checked by real doctors'**
  String get introTitle3;

  /// No description provided for @introBody3.
  ///
  /// In en, this message translates to:
  /// **'On plans that include it, a Niraah doctor reviews your care.'**
  String get introBody3;

  /// No description provided for @introSlideLabel.
  ///
  /// In en, this message translates to:
  /// **'Slide {current} of {total}'**
  String introSlideLabel(int current, int total);

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your holistic wellness journey'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Niraah helps you understand your cycle, hormones and daily habits, with AI guidance and care from doctors and dietitians.'**
  String get welcomeBody;

  /// No description provided for @welcomeWellness.
  ///
  /// In en, this message translates to:
  /// **'Niraah is a wellness service. It does not replace your own doctor and is not for emergencies.'**
  String get welcomeWellness;

  /// No description provided for @welcomeContinue.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get welcomeContinue;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Niraah'**
  String get signInTitle;

  /// No description provided for @signInBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number and we\'ll send you a code.'**
  String get signInBody;

  /// No description provided for @signInFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number or email'**
  String get signInFieldLabel;

  /// No description provided for @signInCountryCode.
  ///
  /// In en, this message translates to:
  /// **'+91'**
  String get signInCountryCode;

  /// No description provided for @signInContinueHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a mobile number or an email'**
  String get signInContinueHint;

  /// No description provided for @signInUnrecognised.
  ///
  /// In en, this message translates to:
  /// **'Enter a mobile number or an email'**
  String get signInUnrecognised;

  /// No description provided for @signInPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Check the number: an Indian mobile number has 10 digits.'**
  String get signInPhoneInvalid;

  /// No description provided for @signInNumberHint.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a 6-digit code by SMS.'**
  String get signInNumberHint;

  /// No description provided for @signInEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Doctors, dietitians, instructors and staff sign in with email.'**
  String get signInEmailHint;

  /// No description provided for @passwordTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordTitle;

  /// No description provided for @passwordFor.
  ///
  /// In en, this message translates to:
  /// **'Signing in as {email}'**
  String passwordFor(String email);

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordContinueHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to continue'**
  String get passwordContinueHint;

  /// No description provided for @passwordRejected.
  ///
  /// In en, this message translates to:
  /// **'That email or password is not right.'**
  String get passwordRejected;

  /// No description provided for @passwordForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get passwordForgot;

  /// No description provided for @passwordChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Use a different email'**
  String get passwordChangeEmail;

  /// No description provided for @codeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your code'**
  String get codeTitle;

  /// No description provided for @codeBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {masked}.'**
  String codeBody(String masked);

  /// No description provided for @codeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get codeFieldLabel;

  /// No description provided for @codeContinueHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6 digits to continue'**
  String get codeContinueHint;

  /// No description provided for @codeVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get codeVerify;

  /// No description provided for @codeResendIn.
  ///
  /// In en, this message translates to:
  /// **'Send a new code in {seconds}s'**
  String codeResendIn(int seconds);

  /// No description provided for @codeResend.
  ///
  /// In en, this message translates to:
  /// **'Send a new code'**
  String get codeResend;

  /// No description provided for @codeExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Code expires in {minutes}:{seconds}'**
  String codeExpiresIn(String minutes, String seconds);

  /// No description provided for @codeExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired. Send a new one.'**
  String get codeExpired;

  /// No description provided for @codeChangeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get codeChangeNumber;

  /// No description provided for @codeNotAccepted.
  ///
  /// In en, this message translates to:
  /// **'That code didn\'t work. Check it and try again.'**
  String get codeNotAccepted;

  /// No description provided for @detailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your account'**
  String get detailsTitle;

  /// No description provided for @detailsBody.
  ///
  /// In en, this message translates to:
  /// **'Just a couple of things before we begin.'**
  String get detailsBody;

  /// No description provided for @detailsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get detailsNameLabel;

  /// No description provided for @detailsNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your first name'**
  String get detailsNameHint;

  /// No description provided for @detailsEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Recovery email (optional)'**
  String get detailsEmailLabel;

  /// No description provided for @detailsEmailHelp.
  ///
  /// In en, this message translates to:
  /// **'Only used to help you get back into your account. You can\'t sign in with it.'**
  String get detailsEmailHelp;

  /// No description provided for @detailsEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Check the email address, or leave it empty.'**
  String get detailsEmailInvalid;

  /// No description provided for @detailsAgree.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and the Privacy Notice.'**
  String get detailsAgree;

  /// No description provided for @detailsTermsLink.
  ///
  /// In en, this message translates to:
  /// **'Read the Terms of Service'**
  String get detailsTermsLink;

  /// No description provided for @detailsPrivacyLink.
  ///
  /// In en, this message translates to:
  /// **'Read the Privacy Notice'**
  String get detailsPrivacyLink;

  /// No description provided for @detailsContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get detailsContinue;

  /// No description provided for @detailsContinueHint.
  ///
  /// In en, this message translates to:
  /// **'Add your name and agree to continue'**
  String get detailsContinueHint;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Before we begin'**
  String get consentTitle;

  /// No description provided for @consentBody.
  ///
  /// In en, this message translates to:
  /// **'A few gentle questions about your cycle, mood and daily life help us understand where you are today.'**
  String get consentBody;

  /// No description provided for @consentDuration.
  ///
  /// In en, this message translates to:
  /// **'About {minutes} minutes'**
  String consentDuration(int minutes);

  /// No description provided for @consentResume.
  ///
  /// In en, this message translates to:
  /// **'You can stop at any time and pick up where you left off.'**
  String get consentResume;

  /// No description provided for @consentReviewByPlan.
  ///
  /// In en, this message translates to:
  /// **'On plans that include it, a Niraah doctor reviews your result. On the free plan, your result comes from our doctor-built rules and AI.'**
  String get consentReviewByPlan;

  /// No description provided for @consentHealthData.
  ///
  /// In en, this message translates to:
  /// **'I agree that Niraah may store and use my health answers to personalise my care.'**
  String get consentHealthData;

  /// No description provided for @consentDoctorReview.
  ///
  /// In en, this message translates to:
  /// **'When my plan includes it, let a Niraah doctor review my result.'**
  String get consentDoctorReview;

  /// No description provided for @consentStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get consentStart;

  /// No description provided for @consentStartHint.
  ///
  /// In en, this message translates to:
  /// **'Tick the first box to continue'**
  String get consentStartHint;

  /// No description provided for @consentTextVersion.
  ///
  /// In en, this message translates to:
  /// **'Consent text version {version}'**
  String consentTextVersion(String version);

  /// No description provided for @assessmentSection.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get assessmentSection;

  /// No description provided for @assessmentStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String assessmentStep(int current, int total);

  /// No description provided for @assessmentChooseToContinue.
  ///
  /// In en, this message translates to:
  /// **'Choose an answer to continue'**
  String get assessmentChooseToContinue;

  /// No description provided for @assessmentSeeResult.
  ///
  /// In en, this message translates to:
  /// **'See my result'**
  String get assessmentSeeResult;

  /// No description provided for @assessmentChooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose your date of birth'**
  String get assessmentChooseDate;

  /// No description provided for @assessmentDateChosen.
  ///
  /// In en, this message translates to:
  /// **'Born {date}'**
  String assessmentDateChosen(String date);

  /// No description provided for @assessmentScaleSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected: {label}'**
  String assessmentScaleSelected(String label);

  /// No description provided for @assessmentTextHint.
  ///
  /// In en, this message translates to:
  /// **'Type here'**
  String get assessmentTextHint;

  /// No description provided for @assessmentSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save that answer. Check your connection and try again.'**
  String get assessmentSaveFailed;

  /// No description provided for @assessmentUpdateApp.
  ///
  /// In en, this message translates to:
  /// **'This question needs a newer version of the app. Please update Niraah to continue.'**
  String get assessmentUpdateApp;

  /// No description provided for @minimumAgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Niraah is for adults for now'**
  String get minimumAgeTitle;

  /// No description provided for @minimumAgeBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your interest. Niraah\'s care is designed for women aged 18 and over, so we\'ve paused this account. Nothing you shared about your health has been stored.'**
  String get minimumAgeBody;

  /// No description provided for @minimumAgeWrongDate.
  ///
  /// In en, this message translates to:
  /// **'If you entered your date of birth by mistake, our support team can correct it.'**
  String get minimumAgeWrongDate;

  /// No description provided for @minimumAgeContact.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get minimumAgeContact;

  /// No description provided for @processingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading your answers'**
  String get processingTitle;

  /// No description provided for @processingBody.
  ///
  /// In en, this message translates to:
  /// **'This takes a few seconds.'**
  String get processingBody;

  /// No description provided for @prescoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Your wellness pre-score'**
  String get prescoreTitle;

  /// No description provided for @prescoreOutOf.
  ///
  /// In en, this message translates to:
  /// **'out of {maximum}'**
  String prescoreOutOf(int maximum);

  /// No description provided for @prescoreScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Your pre-score is {total} out of {maximum}. {band}.'**
  String prescoreScoreLabel(int total, int maximum, String band);

  /// No description provided for @prescoreNotDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'This is not a diagnosis. It\'s a starting point for your care.'**
  String get prescoreNotDiagnosis;

  /// No description provided for @prescoreNoticed.
  ///
  /// In en, this message translates to:
  /// **'What we noticed'**
  String get prescoreNoticed;

  /// No description provided for @prescoreAreas.
  ///
  /// In en, this message translates to:
  /// **'Your areas'**
  String get prescoreAreas;

  /// No description provided for @prescoreProgram.
  ///
  /// In en, this message translates to:
  /// **'Suggested for you'**
  String get prescoreProgram;

  /// No description provided for @prescoreFreeNoDoctor.
  ///
  /// In en, this message translates to:
  /// **'Niraah has not passed this to a doctor. Please see a doctor yourself soon.'**
  String get prescoreFreeNoDoctor;

  /// No description provided for @nextBookDoctor.
  ///
  /// In en, this message translates to:
  /// **'Book a doctor'**
  String get nextBookDoctor;

  /// No description provided for @nextSeePlans.
  ///
  /// In en, this message translates to:
  /// **'See plans'**
  String get nextSeePlans;

  /// No description provided for @nextGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go to home'**
  String get nextGoHome;

  /// No description provided for @clinicianNotRequired.
  ///
  /// In en, this message translates to:
  /// **'Built on guidance from our doctors.'**
  String get clinicianNotRequired;

  /// No description provided for @clinicianIncludedIn.
  ///
  /// In en, this message translates to:
  /// **'A doctor\'s review is included with {plans}.'**
  String clinicianIncludedIn(String plans);

  /// No description provided for @clinicianAwaiting.
  ///
  /// In en, this message translates to:
  /// **'A doctor will review this within {target}.'**
  String clinicianAwaiting(String target);

  /// No description provided for @clinicianVerified.
  ///
  /// In en, this message translates to:
  /// **'Clinician Verified'**
  String get clinicianVerified;

  /// No description provided for @clinicianVerifiedBy.
  ///
  /// In en, this message translates to:
  /// **'{name} · {speciality}'**
  String clinicianVerifiedBy(String name, String speciality);

  /// No description provided for @clinicianFollowUp.
  ///
  /// In en, this message translates to:
  /// **'{name} would like to talk with you'**
  String clinicianFollowUp(String name);

  /// No description provided for @clinicianBook.
  ///
  /// In en, this message translates to:
  /// **'Book a consult'**
  String get clinicianBook;

  /// No description provided for @plansTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get plansTitle;

  /// No description provided for @plansBody.
  ///
  /// In en, this message translates to:
  /// **'Every plan includes AI Care chat. You can change or cancel any time.'**
  String get plansBody;

  /// No description provided for @plansRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get plansRecommended;

  /// No description provided for @plansCurrent.
  ///
  /// In en, this message translates to:
  /// **'Your plan'**
  String get plansCurrent;

  /// No description provided for @plansFreePrice.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get plansFreePrice;

  /// No description provided for @plansFreeNote.
  ///
  /// In en, this message translates to:
  /// **'No payment needed'**
  String get plansFreeNote;

  /// No description provided for @plansEvery.
  ///
  /// In en, this message translates to:
  /// **'every {count} {unit}'**
  String plansEvery(int count, String unit);

  /// No description provided for @plansFor.
  ///
  /// In en, this message translates to:
  /// **'for {count} {unit}'**
  String plansFor(int count, String unit);

  /// No description provided for @plansIncludesGst.
  ///
  /// In en, this message translates to:
  /// **'{validity}, including GST'**
  String plansIncludesGst(String validity);

  /// No description provided for @plansUnitDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{day} other{days}}'**
  String plansUnitDays(int count);

  /// No description provided for @plansUnitWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{week} other{weeks}}'**
  String plansUnitWeeks(int count);

  /// No description provided for @plansUnitMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{month} other{months}}'**
  String plansUnitMonths(int count);

  /// No description provided for @plansUnitYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{year} other{years}}'**
  String plansUnitYears(int count);

  /// No description provided for @plansStartTrial.
  ///
  /// In en, this message translates to:
  /// **'Start {days}-day free trial'**
  String plansStartTrial(int days);

  /// No description provided for @plansChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose {name}'**
  String plansChoose(String name);

  /// No description provided for @plansContinueFree.
  ///
  /// In en, this message translates to:
  /// **'Continue free'**
  String get plansContinueFree;

  /// No description provided for @plansUnlimited.
  ///
  /// In en, this message translates to:
  /// **'{name}: unlimited'**
  String plansUnlimited(String name);

  /// No description provided for @plansLimit.
  ///
  /// In en, this message translates to:
  /// **'{name}: {amount} a {period}'**
  String plansLimit(String name, int amount, String period);

  /// No description provided for @plansQuantity.
  ///
  /// In en, this message translates to:
  /// **'{name}: {amount} a {period}'**
  String plansQuantity(String name, int amount, String period);

  /// No description provided for @plansPaymentLater.
  ///
  /// In en, this message translates to:
  /// **'Payment in the app opens soon. You can keep using the free plan until then.'**
  String get plansPaymentLater;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good {part}, {name}'**
  String homeGreeting(String part, String name);

  /// No description provided for @homeGreetingNoName.
  ///
  /// In en, this message translates to:
  /// **'Good {part}'**
  String homeGreetingNoName(String part);

  /// No description provided for @homePartMorning.
  ///
  /// In en, this message translates to:
  /// **'morning'**
  String get homePartMorning;

  /// No description provided for @homePartAfternoon.
  ///
  /// In en, this message translates to:
  /// **'afternoon'**
  String get homePartAfternoon;

  /// No description provided for @homePartEvening.
  ///
  /// In en, this message translates to:
  /// **'evening'**
  String get homePartEvening;

  /// No description provided for @homeRingLabel.
  ///
  /// In en, this message translates to:
  /// **'Your cycle'**
  String get homeRingLabel;

  /// No description provided for @homeDay.
  ///
  /// In en, this message translates to:
  /// **'Day {n}'**
  String homeDay(int n);

  /// No description provided for @homePhaseMenstrual.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get homePhaseMenstrual;

  /// No description provided for @homePhaseFollicular.
  ///
  /// In en, this message translates to:
  /// **'Follicular phase'**
  String get homePhaseFollicular;

  /// No description provided for @homePhaseOvulatory.
  ///
  /// In en, this message translates to:
  /// **'Ovulatory phase'**
  String get homePhaseOvulatory;

  /// No description provided for @homePhaseLuteal.
  ///
  /// In en, this message translates to:
  /// **'Luteal phase'**
  String get homePhaseLuteal;

  /// No description provided for @homeEstimatedSuffix.
  ///
  /// In en, this message translates to:
  /// **'estimated'**
  String get homeEstimatedSuffix;

  /// No description provided for @homeNextInSame.
  ///
  /// In en, this message translates to:
  /// **'Next period estimated in {a} {a, plural, =1{day} other{days}}'**
  String homeNextInSame(int a);

  /// No description provided for @homeNextIn.
  ///
  /// In en, this message translates to:
  /// **'Next period estimated in {a} to {b} days'**
  String homeNextIn(int a, int b);

  /// No description provided for @homeNextBetween.
  ///
  /// In en, this message translates to:
  /// **'Estimated between {from} and {to}'**
  String homeNextBetween(String from, String to);

  /// No description provided for @homeLate.
  ///
  /// In en, this message translates to:
  /// **'Your period is later than estimated.'**
  String get homeLate;

  /// No description provided for @homeFromAssessment.
  ///
  /// In en, this message translates to:
  /// **'This estimate is based on your health check-in. Log two cycles for a closer one.'**
  String get homeFromAssessment;

  /// No description provided for @homeNoWindow.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet to estimate your next period.'**
  String get homeNoWindow;

  /// No description provided for @homeInvitation.
  ///
  /// In en, this message translates to:
  /// **'Tell us when your last period started.'**
  String get homeInvitation;

  /// No description provided for @homeInvitationLabel.
  ///
  /// In en, this message translates to:
  /// **'First day of your last period'**
  String get homeInvitationLabel;

  /// No description provided for @homeSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get homeSave;

  /// No description provided for @homeSaveInactive.
  ///
  /// In en, this message translates to:
  /// **'Choose a date to save'**
  String get homeSaveInactive;

  /// No description provided for @homeOffPregnant.
  ///
  /// In en, this message translates to:
  /// **'Predictions are paused because you\'ve told us you\'re pregnant.'**
  String get homeOffPregnant;

  /// No description provided for @homeOffHormonalContraception.
  ///
  /// In en, this message translates to:
  /// **'Predictions are paused because you\'ve told us you use hormonal contraception.'**
  String get homeOffHormonalContraception;

  /// No description provided for @homeOffNoPeriods.
  ///
  /// In en, this message translates to:
  /// **'Predictions are paused because you\'ve told us you\'re not having periods.'**
  String get homeOffNoPeriods;

  /// No description provided for @homeOffBreastfeeding.
  ///
  /// In en, this message translates to:
  /// **'Predictions are paused while you\'re breastfeeding.'**
  String get homeOffBreastfeeding;

  /// No description provided for @homeLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeLogTitle;

  /// No description provided for @homeLogFlow.
  ///
  /// In en, this message translates to:
  /// **'Flow'**
  String get homeLogFlow;

  /// No description provided for @homeLogMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get homeLogMood;

  /// No description provided for @homeLogEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get homeLogEnergy;

  /// No description provided for @homeLogSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get homeLogSymptoms;

  /// No description provided for @homeNotLogged.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get homeNotLogged;

  /// No description provided for @homeFlowNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get homeFlowNone;

  /// No description provided for @homeFlowSpotting.
  ///
  /// In en, this message translates to:
  /// **'Spotting'**
  String get homeFlowSpotting;

  /// No description provided for @homeFlowLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get homeFlowLight;

  /// No description provided for @homeFlowMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get homeFlowMedium;

  /// No description provided for @homeFlowHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get homeFlowHeavy;

  /// No description provided for @homeMoodCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get homeMoodCalm;

  /// No description provided for @homeMoodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get homeMoodHappy;

  /// No description provided for @homeMoodLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get homeMoodLow;

  /// No description provided for @homeMoodAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get homeMoodAnxious;

  /// No description provided for @homeMoodIrritable.
  ///
  /// In en, this message translates to:
  /// **'Irritable'**
  String get homeMoodIrritable;

  /// No description provided for @homeEnergyLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get homeEnergyLow;

  /// No description provided for @homeEnergyOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get homeEnergyOkay;

  /// No description provided for @homeEnergyHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get homeEnergyHigh;

  /// No description provided for @homePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'{field} today'**
  String homePickerTitle(String field);

  /// No description provided for @homeClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get homeClose;

  /// No description provided for @homeSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get homeSaved;

  /// No description provided for @homeSuggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'For today'**
  String get homeSuggestionTitle;

  /// No description provided for @homeAiMark.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get homeAiMark;

  /// No description provided for @homeFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'From Niraah\'s wellness library'**
  String get homeFromLibrary;

  /// No description provided for @homePrescoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Your wellness pre-score'**
  String get homePrescoreTitle;

  /// No description provided for @homePrescoreLine.
  ///
  /// In en, this message translates to:
  /// **'{total} out of {max} · {band}'**
  String homePrescoreLine(int total, int max, String band);

  /// No description provided for @homeViewResult.
  ///
  /// In en, this message translates to:
  /// **'View result'**
  String get homeViewResult;

  /// No description provided for @homeHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get homeHide;

  /// No description provided for @homeHidePrescore.
  ///
  /// In en, this message translates to:
  /// **'Hide pre-score card'**
  String get homeHidePrescore;

  /// No description provided for @homeReviewNotRequired.
  ///
  /// In en, this message translates to:
  /// **'Built on guidance from our doctors.'**
  String get homeReviewNotRequired;

  /// No description provided for @homeReviewAwaiting.
  ///
  /// In en, this message translates to:
  /// **'A doctor will review this within {target}.'**
  String homeReviewAwaiting(String target);

  /// No description provided for @homeGateTitle.
  ///
  /// In en, this message translates to:
  /// **'Your health check-in comes first'**
  String get homeGateTitle;

  /// No description provided for @homeGateBody.
  ///
  /// In en, this message translates to:
  /// **'It takes about {min} {min, plural, =1{minute} other{minutes}}. Everything else opens when you\'ve finished.'**
  String homeGateBody(int min);

  /// No description provided for @homeGateBodyNoTime.
  ///
  /// In en, this message translates to:
  /// **'Everything else opens when you\'ve finished.'**
  String get homeGateBodyNoTime;

  /// No description provided for @homeGateAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get homeGateAction;

  /// No description provided for @navLabel.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get navLabel;

  /// No description provided for @navComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{area} arrives in a later phase of the build.'**
  String navComingSoon(String area);

  /// No description provided for @cycleTitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get cycleTitle;

  /// No description provided for @cycleLogPeriod.
  ///
  /// In en, this message translates to:
  /// **'Log a period'**
  String get cycleLogPeriod;

  /// No description provided for @cycleLogSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Log symptoms'**
  String get cycleLogSymptoms;

  /// No description provided for @cycleCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get cycleCalendarTitle;

  /// No description provided for @cyclePrevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get cyclePrevMonth;

  /// No description provided for @cycleNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get cycleNextMonth;

  /// No description provided for @cycleLegendLogged.
  ///
  /// In en, this message translates to:
  /// **'Period, logged'**
  String get cycleLegendLogged;

  /// No description provided for @cycleLegendPredicted.
  ///
  /// In en, this message translates to:
  /// **'Next period, estimated'**
  String get cycleLegendPredicted;

  /// No description provided for @cycleLegendToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get cycleLegendToday;

  /// No description provided for @cycleDayLogged.
  ///
  /// In en, this message translates to:
  /// **'period, logged'**
  String get cycleDayLogged;

  /// No description provided for @cycleDayPredicted.
  ///
  /// In en, this message translates to:
  /// **'next period estimated'**
  String get cycleDayPredicted;

  /// No description provided for @cycleDayToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get cycleDayToday;

  /// No description provided for @cycleDayHasLog.
  ///
  /// In en, this message translates to:
  /// **'has a log'**
  String get cycleDayHasLog;

  /// No description provided for @cycleHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cycles'**
  String get cycleHistoryTitle;

  /// No description provided for @cycleHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cycle history appears here once you\'ve logged two periods.'**
  String get cycleHistoryEmpty;

  /// No description provided for @cycleHistoryRow.
  ///
  /// In en, this message translates to:
  /// **'{cycle}-day cycle'**
  String cycleHistoryRow(int cycle);

  /// No description provided for @cyclePeriodDays.
  ///
  /// In en, this message translates to:
  /// **'period {n} {n, plural, =1{day} other{days}}'**
  String cyclePeriodDays(int n);

  /// No description provided for @cycleCurrentCycle.
  ///
  /// In en, this message translates to:
  /// **'Current cycle'**
  String get cycleCurrentCycle;

  /// No description provided for @cycleAverage.
  ///
  /// In en, this message translates to:
  /// **'Average {n} days'**
  String cycleAverage(int n);

  /// No description provided for @cycleRangeSame.
  ///
  /// In en, this message translates to:
  /// **'Each {a} days'**
  String cycleRangeSame(int a);

  /// No description provided for @cycleRange.
  ///
  /// In en, this message translates to:
  /// **'Range {a} to {b} days'**
  String cycleRange(int a, int b);

  /// No description provided for @cyclePatternSame.
  ///
  /// In en, this message translates to:
  /// **'Your last {count} cycles were each {min} days.'**
  String cyclePatternSame(int count, int min);

  /// No description provided for @cyclePattern.
  ///
  /// In en, this message translates to:
  /// **'Your last {count} cycles ranged from {min} to {max} days.'**
  String cyclePattern(int count, int min, int max);

  /// No description provided for @cycleSituationTitle.
  ///
  /// In en, this message translates to:
  /// **'Your situation'**
  String get cycleSituationTitle;

  /// No description provided for @cycleSituationHint.
  ///
  /// In en, this message translates to:
  /// **'These change what we estimate. You can change them at any time.'**
  String get cycleSituationHint;

  /// No description provided for @cycleSituationNone.
  ///
  /// In en, this message translates to:
  /// **'None of these'**
  String get cycleSituationNone;

  /// No description provided for @cycleMarkerPregnant.
  ///
  /// In en, this message translates to:
  /// **'I\'m pregnant'**
  String get cycleMarkerPregnant;

  /// No description provided for @cycleMarkerBreastfeeding.
  ///
  /// In en, this message translates to:
  /// **'I\'m breastfeeding'**
  String get cycleMarkerBreastfeeding;

  /// No description provided for @cycleMarkerHormonalContraception.
  ///
  /// In en, this message translates to:
  /// **'I use hormonal contraception'**
  String get cycleMarkerHormonalContraception;

  /// No description provided for @cycleMarkerNoPeriods.
  ///
  /// In en, this message translates to:
  /// **'I\'m not currently having periods'**
  String get cycleMarkerNoPeriods;

  /// No description provided for @cycleEdit.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get cycleEdit;

  /// No description provided for @cyclePeriodStartedHere.
  ///
  /// In en, this message translates to:
  /// **'My period started this day'**
  String get cyclePeriodStartedHere;

  /// No description provided for @cyclePeriodEndedHere.
  ///
  /// In en, this message translates to:
  /// **'My period ended this day'**
  String get cyclePeriodEndedHere;

  /// No description provided for @cycleRemovePeriod.
  ///
  /// In en, this message translates to:
  /// **'Remove this period'**
  String get cycleRemovePeriod;

  /// No description provided for @cycleNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get cycleNote;

  /// No description provided for @cycleSaveNote.
  ///
  /// In en, this message translates to:
  /// **'Save note'**
  String get cycleSaveNote;

  /// No description provided for @cycleSaveNoteInactive.
  ///
  /// In en, this message translates to:
  /// **'Write a note to save'**
  String get cycleSaveNoteInactive;

  /// No description provided for @cycleErrorEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'The end day is before the start day. Choose a later day.'**
  String get cycleErrorEndBeforeStart;

  /// No description provided for @cycleErrorFuture.
  ///
  /// In en, this message translates to:
  /// **'Choose today or an earlier day.'**
  String get cycleErrorFuture;

  /// No description provided for @cycleErrorOverlaps.
  ///
  /// In en, this message translates to:
  /// **'This overlaps a period you\'ve already logged. Change that one instead.'**
  String get cycleErrorOverlaps;

  /// No description provided for @cyclePeriodSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Log a period'**
  String get cyclePeriodSheetTitle;

  /// No description provided for @cycleStartLabel.
  ///
  /// In en, this message translates to:
  /// **'First day'**
  String get cycleStartLabel;

  /// No description provided for @cycleEndLabel.
  ///
  /// In en, this message translates to:
  /// **'Last day (if it has ended)'**
  String get cycleEndLabel;

  /// No description provided for @cycleSavePeriod.
  ///
  /// In en, this message translates to:
  /// **'Save period'**
  String get cycleSavePeriod;

  /// No description provided for @cycleSavePeriodInactive.
  ///
  /// In en, this message translates to:
  /// **'Choose the first day to save'**
  String get cycleSavePeriodInactive;

  /// No description provided for @symptomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptomsTitle;

  /// No description provided for @symptomsBack.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get symptomsBack;

  /// No description provided for @symptomsFrequent.
  ///
  /// In en, this message translates to:
  /// **'You log these often'**
  String get symptomsFrequent;

  /// No description provided for @symptomsPick.
  ///
  /// In en, this message translates to:
  /// **'Choose a symptom to log it'**
  String get symptomsPick;

  /// No description provided for @symptomsSeverityLabel.
  ///
  /// In en, this message translates to:
  /// **'How strong is it?'**
  String get symptomsSeverityLabel;

  /// No description provided for @symptomsSeverityValue.
  ///
  /// In en, this message translates to:
  /// **'{n} out of 10'**
  String symptomsSeverityValue(int n);

  /// No description provided for @symptomsNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get symptomsNoteLabel;

  /// No description provided for @symptomsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get symptomsSave;

  /// No description provided for @symptomsSaved.
  ///
  /// In en, this message translates to:
  /// **'{name} saved'**
  String symptomsSaved(String name);

  /// No description provided for @symptomsDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get symptomsDone;

  /// No description provided for @symptomsHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get symptomsHistoryTitle;

  /// No description provided for @symptomsHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Symptoms you log appear here, with where you were in your cycle.'**
  String get symptomsHistoryEmpty;

  /// No description provided for @symptomsHistoryRow.
  ///
  /// In en, this message translates to:
  /// **'{name} · {severity} out of 10'**
  String symptomsHistoryRow(String name, int severity);

  /// No description provided for @symptomsPhaseOnDay.
  ///
  /// In en, this message translates to:
  /// **'{phase}, estimated'**
  String symptomsPhaseOnDay(String phase);

  /// No description provided for @symptomsSeverityRefused.
  ///
  /// In en, this message translates to:
  /// **'Choose a number from 1 to 10.'**
  String get symptomsSeverityRefused;

  /// No description provided for @commonLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this screen. Your data is safe.'**
  String get commonLoadError;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Care'**
  String get chatTitle;

  /// No description provided for @chatNewChat.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get chatNewChat;

  /// No description provided for @chatConversations.
  ///
  /// In en, this message translates to:
  /// **'Your conversations'**
  String get chatConversations;

  /// No description provided for @chatNoConversations.
  ///
  /// In en, this message translates to:
  /// **'Your conversations appear here.'**
  String get chatNoConversations;

  /// No description provided for @chatStarterTitle.
  ///
  /// In en, this message translates to:
  /// **'You could ask'**
  String get chatStarterTitle;

  /// No description provided for @chatInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Message AI Care'**
  String get chatInputLabel;

  /// No description provided for @chatInputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ask about your cycle, food, sleep…'**
  String get chatInputPlaceholder;

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// No description provided for @chatSendInactive.
  ///
  /// In en, this message translates to:
  /// **'Type a message to send'**
  String get chatSendInactive;

  /// No description provided for @chatSources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get chatSources;

  /// No description provided for @chatSourceSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get chatSourceSheetTitle;

  /// No description provided for @chatIncomplete.
  ///
  /// In en, this message translates to:
  /// **'This answer stopped before it finished.'**
  String get chatIncomplete;

  /// No description provided for @chatTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get chatTryAgain;

  /// No description provided for @chatPersonalisedOn.
  ///
  /// In en, this message translates to:
  /// **'Using your cycle and logs'**
  String get chatPersonalisedOn;

  /// No description provided for @chatPersonalisedOff.
  ///
  /// In en, this message translates to:
  /// **'General answers: personalisation is off'**
  String get chatPersonalisedOff;

  /// No description provided for @chatPersonalisedSettings.
  ///
  /// In en, this message translates to:
  /// **'Change in privacy settings'**
  String get chatPersonalisedSettings;

  /// No description provided for @chatRemaining.
  ///
  /// In en, this message translates to:
  /// **'{n} {n, plural, =1{message} other{messages}} left today'**
  String chatRemaining(int n);

  /// No description provided for @chatLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used today\'s messages'**
  String get chatLimitTitle;

  /// No description provided for @chatLimitText.
  ///
  /// In en, this message translates to:
  /// **'Your plan includes {limit} AI Care messages a day. They refill on {resets}.'**
  String chatLimitText(int limit, String resets);

  /// No description provided for @chatLimitPlans.
  ///
  /// In en, this message translates to:
  /// **'{plans} include more messages.'**
  String chatLimitPlans(String plans);

  /// No description provided for @chatSeePlans.
  ///
  /// In en, this message translates to:
  /// **'See plans'**
  String get chatSeePlans;

  /// No description provided for @chatRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get chatRename;

  /// No description provided for @chatRenameLabel.
  ///
  /// In en, this message translates to:
  /// **'Conversation name'**
  String get chatRenameLabel;

  /// No description provided for @chatSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get chatSave;

  /// No description provided for @chatDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get chatDelete;

  /// No description provided for @chatDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this conversation? This can\'t be undone.'**
  String get chatDeleteConfirm;

  /// No description provided for @chatDeleteYes.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation'**
  String get chatDeleteYes;

  /// No description provided for @chatCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get chatCancel;

  /// No description provided for @chatBack.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get chatBack;

  /// No description provided for @chatYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get chatYou;

  /// No description provided for @chatAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Care'**
  String get chatAssistant;

  /// No description provided for @chatThinking.
  ///
  /// In en, this message translates to:
  /// **'AI Care is writing'**
  String get chatThinking;

  /// No description provided for @pvPasswordForgotSent.
  ///
  /// In en, this message translates to:
  /// **'If that email has an account, we have sent a link.'**
  String get pvPasswordForgotSent;

  /// No description provided for @pvPasswordLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in 15 minutes.'**
  String get pvPasswordLocked;

  /// No description provided for @pvPasswordSampleHint.
  ///
  /// In en, this message translates to:
  /// **'Sample mode: use a sample account with the password niraah-sample-pass.'**
  String get pvPasswordSampleHint;

  /// No description provided for @pvAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your authenticator code'**
  String get pvAuthTitle;

  /// No description provided for @pvAuthBody.
  ///
  /// In en, this message translates to:
  /// **'Open your authenticator app and enter the 6-digit code for Niraah.'**
  String get pvAuthBody;

  /// No description provided for @pvAuthLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get pvAuthLabel;

  /// No description provided for @pvAuthVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get pvAuthVerify;

  /// No description provided for @pvAuthInactive.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6 digits to continue'**
  String get pvAuthInactive;

  /// No description provided for @pvAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'That code is not right. Try the current code.'**
  String get pvAuthFailed;

  /// No description provided for @pvAuthUseRecovery.
  ///
  /// In en, this message translates to:
  /// **'Use a recovery code instead'**
  String get pvAuthUseRecovery;

  /// No description provided for @pvAuthRecoveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Recovery code'**
  String get pvAuthRecoveryLabel;

  /// No description provided for @pvAuthRecoveryHint.
  ///
  /// In en, this message translates to:
  /// **'Each recovery code works once.'**
  String get pvAuthRecoveryHint;

  /// No description provided for @pvAuthUseAuthenticator.
  ///
  /// In en, this message translates to:
  /// **'Use my authenticator app'**
  String get pvAuthUseAuthenticator;

  /// No description provided for @pvAuthSampleHint.
  ///
  /// In en, this message translates to:
  /// **'Sample mode: any 6 digits will work.'**
  String get pvAuthSampleHint;

  /// No description provided for @pvSetupInvalidTitle.
  ///
  /// In en, this message translates to:
  /// **'This link is no longer valid'**
  String get pvSetupInvalidTitle;

  /// No description provided for @pvSetupInvalidBody.
  ///
  /// In en, this message translates to:
  /// **'Ask the person who invited you for a new one.'**
  String get pvSetupInvalidBody;

  /// No description provided for @pvSetupWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String pvSetupWelcome(String name);

  /// No description provided for @pvSetupStep1.
  ///
  /// In en, this message translates to:
  /// **'Set a password'**
  String get pvSetupStep1;

  /// No description provided for @pvSetupStep2.
  ///
  /// In en, this message translates to:
  /// **'Add an authenticator'**
  String get pvSetupStep2;

  /// No description provided for @pvSetupStep3.
  ///
  /// In en, this message translates to:
  /// **'Save recovery codes'**
  String get pvSetupStep3;

  /// No description provided for @pvSetupStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {n} of {total}'**
  String pvSetupStepOf(int n, int total);

  /// No description provided for @pvSetupPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get pvSetupPasswordLabel;

  /// No description provided for @pvSetupPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 12 characters. Longer is stronger; no other rules.'**
  String get pvSetupPasswordHint;

  /// No description provided for @pvSetupPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 12 characters.'**
  String get pvSetupPasswordTooShort;

  /// No description provided for @pvSetupPasswordBreached.
  ///
  /// In en, this message translates to:
  /// **'This password has appeared in a data breach. Choose a different one.'**
  String get pvSetupPasswordBreached;

  /// No description provided for @pvSetupNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get pvSetupNext;

  /// No description provided for @pvSetupPasswordInactive.
  ///
  /// In en, this message translates to:
  /// **'Enter a password to continue'**
  String get pvSetupPasswordInactive;

  /// No description provided for @pvSetupAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Add an authenticator app'**
  String get pvSetupAuthTitle;

  /// No description provided for @pvSetupAuthBody.
  ///
  /// In en, this message translates to:
  /// **'Scan this in your authenticator app, then enter the 6-digit code it shows.'**
  String get pvSetupAuthBody;

  /// No description provided for @pvSetupAuthKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Setup key'**
  String get pvSetupAuthKeyLabel;

  /// No description provided for @pvSetupAuthSampleKey.
  ///
  /// In en, this message translates to:
  /// **'SAMPLE KEY NOT FOR USE'**
  String get pvSetupAuthSampleKey;

  /// No description provided for @pvSetupCodesTitle.
  ///
  /// In en, this message translates to:
  /// **'Save your recovery codes'**
  String get pvSetupCodesTitle;

  /// No description provided for @pvSetupCodesBody.
  ///
  /// In en, this message translates to:
  /// **'If you lose your phone, each code lets you in once. Keep them somewhere safe and private.'**
  String get pvSetupCodesBody;

  /// No description provided for @pvSetupCodesConfirm.
  ///
  /// In en, this message translates to:
  /// **'I have saved these codes'**
  String get pvSetupCodesConfirm;

  /// No description provided for @pvSetupFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish set-up'**
  String get pvSetupFinish;

  /// No description provided for @pvSetupFinishInactive.
  ///
  /// In en, this message translates to:
  /// **'Confirm you\'ve saved the codes'**
  String get pvSetupFinishInactive;

  /// No description provided for @pvStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Your application'**
  String get pvStatusTitle;

  /// No description provided for @pvStatusBody.
  ///
  /// In en, this message translates to:
  /// **'Complete your details and send them for review. An admin checks them, and you can see members once you\'re approved.'**
  String get pvStatusBody;

  /// No description provided for @pvStatusMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Still needed'**
  String get pvStatusMissingTitle;

  /// No description provided for @pvStatusNothingMissing.
  ///
  /// In en, this message translates to:
  /// **'Nothing more is needed from you right now.'**
  String get pvStatusNothingMissing;

  /// No description provided for @pvSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get pvSignOut;

  /// No description provided for @pvShellNav.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get pvShellNav;

  /// No description provided for @pvShellHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get pvShellHome;

  /// No description provided for @pvShellPatients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get pvShellPatients;

  /// No description provided for @pvShellQueue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get pvShellQueue;

  /// No description provided for @pvShellSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get pvShellSchedule;

  /// No description provided for @pvShellMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get pvShellMore;

  /// No description provided for @pvShellComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{area} arrives in a later step of Phase 4.'**
  String pvShellComingSoon(String area);

  /// No description provided for @pvShellRoleSoon.
  ///
  /// In en, this message translates to:
  /// **'The {role} workspace arrives in a later phase.'**
  String pvShellRoleSoon(String role);

  /// No description provided for @pvRoleDietitian.
  ///
  /// In en, this message translates to:
  /// **'dietitian'**
  String get pvRoleDietitian;

  /// No description provided for @pvRoleInstructor.
  ///
  /// In en, this message translates to:
  /// **'instructor'**
  String get pvRoleInstructor;

  /// No description provided for @pvDashGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good day, {name}'**
  String pvDashGreeting(String name);

  /// No description provided for @pvDashNeedsMe.
  ///
  /// In en, this message translates to:
  /// **'Needs you'**
  String get pvDashNeedsMe;

  /// No description provided for @pvDashUrgentAlerts.
  ///
  /// In en, this message translates to:
  /// **'Urgent alerts'**
  String get pvDashUrgentAlerts;

  /// No description provided for @pvDashReviews.
  ///
  /// In en, this message translates to:
  /// **'Pre-score reviews'**
  String get pvDashReviews;

  /// No description provided for @pvDashOldestOverdue.
  ///
  /// In en, this message translates to:
  /// **'Oldest is overdue'**
  String get pvDashOldestOverdue;

  /// No description provided for @pvDashOldestUnderHour.
  ///
  /// In en, this message translates to:
  /// **'Oldest due in under an hour'**
  String get pvDashOldestUnderHour;

  /// No description provided for @pvDashOldestDue.
  ///
  /// In en, this message translates to:
  /// **'Oldest due in {h} h'**
  String pvDashOldestDue(int h);

  /// No description provided for @pvDashCarePlans.
  ///
  /// In en, this message translates to:
  /// **'Care plans to sign'**
  String get pvDashCarePlans;

  /// No description provided for @pvDashLabResults.
  ///
  /// In en, this message translates to:
  /// **'Lab results to review'**
  String get pvDashLabResults;

  /// No description provided for @pvDashMessages.
  ///
  /// In en, this message translates to:
  /// **'Unread messages'**
  String get pvDashMessages;

  /// No description provided for @pvDashDrafts.
  ///
  /// In en, this message translates to:
  /// **'Prescriptions in draft'**
  String get pvDashDrafts;

  /// No description provided for @pvDashToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get pvDashToday;

  /// No description provided for @pvDashNoAppointments.
  ///
  /// In en, this message translates to:
  /// **'No appointments today.'**
  String get pvDashNoAppointments;

  /// No description provided for @pvDashJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get pvDashJoin;

  /// No description provided for @pvDashJoinSoon.
  ///
  /// In en, this message translates to:
  /// **'Join opens 10 minutes before'**
  String get pvDashJoinSoon;

  /// No description provided for @pvDashOnCallNow.
  ///
  /// In en, this message translates to:
  /// **'You\'re on call until {to}.'**
  String pvDashOnCallNow(String to);

  /// No description provided for @pvDashOnCallLater.
  ///
  /// In en, this message translates to:
  /// **'Not on call now. Next on call {from}–{to}.'**
  String pvDashOnCallLater(String from, String to);

  /// No description provided for @pvDashOpenQueue.
  ///
  /// In en, this message translates to:
  /// **'Open queue'**
  String get pvDashOpenQueue;

  /// No description provided for @pvDashOnCall.
  ///
  /// In en, this message translates to:
  /// **'You\'re on call now.'**
  String get pvDashOnCall;

  /// No description provided for @pvDashNotOnCall.
  ///
  /// In en, this message translates to:
  /// **'Not on call now.'**
  String get pvDashNotOnCall;

  /// No description provided for @pvDashJoinOnWeb.
  ///
  /// In en, this message translates to:
  /// **'Join from the web app for now'**
  String get pvDashJoinOnWeb;

  /// No description provided for @pvDashClinicalReview.
  ///
  /// In en, this message translates to:
  /// **'Clinical review'**
  String get pvDashClinicalReview;

  /// No description provided for @pvQueueFlags.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 flag} other{{n} flags}}'**
  String pvQueueFlags(int n);

  /// No description provided for @pvQueueOpenedByMe.
  ///
  /// In en, this message translates to:
  /// **'Opened by you'**
  String get pvQueueOpenedByMe;

  /// No description provided for @pvReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Pre-score review'**
  String get pvReviewTitle;

  /// No description provided for @pvQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Pre-score reviews'**
  String get pvQueueTitle;

  /// No description provided for @pvQueueEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reviews waiting. Well done.'**
  String get pvQueueEmpty;

  /// No description provided for @pvQueueOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get pvQueueOverdue;

  /// No description provided for @pvQueueDueUnderHour.
  ///
  /// In en, this message translates to:
  /// **'Due in under an hour'**
  String get pvQueueDueUnderHour;

  /// No description provided for @pvQueueDue.
  ///
  /// In en, this message translates to:
  /// **'Due in {h} h'**
  String pvQueueDue(int h);

  /// No description provided for @pvQueueDedicated.
  ///
  /// In en, this message translates to:
  /// **'Your patient'**
  String get pvQueueDedicated;

  /// No description provided for @pvQueueNoFlags.
  ///
  /// In en, this message translates to:
  /// **'No flags'**
  String get pvQueueNoFlags;

  /// No description provided for @pvQueueUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get pvQueueUrgent;

  /// No description provided for @pvQueueAttention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get pvQueueAttention;

  /// No description provided for @pvQueueInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get pvQueueInfo;

  /// No description provided for @pvQueueHoldingAnother.
  ///
  /// In en, this message translates to:
  /// **'Finish or release your current review first.'**
  String get pvQueueHoldingAnother;

  /// No description provided for @pvQueueGone.
  ///
  /// In en, this message translates to:
  /// **'This review has already been completed.'**
  String get pvQueueGone;

  /// No description provided for @pvQueuePick.
  ///
  /// In en, this message translates to:
  /// **'Choose a review to open it.'**
  String get pvQueuePick;

  /// No description provided for @pvReviewBack.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get pvReviewBack;

  /// No description provided for @pvReviewSummary.
  ///
  /// In en, this message translates to:
  /// **'AI clinician summary'**
  String get pvReviewSummary;

  /// No description provided for @pvReviewSummaryNote.
  ///
  /// In en, this message translates to:
  /// **'Drafted by AI from her answers. Check it against the answers.'**
  String get pvReviewSummaryNote;

  /// No description provided for @pvReviewFlags.
  ///
  /// In en, this message translates to:
  /// **'Flags'**
  String get pvReviewFlags;

  /// No description provided for @pvReviewScores.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get pvReviewScores;

  /// No description provided for @pvReviewTotal.
  ///
  /// In en, this message translates to:
  /// **'{t} out of {m} · {band}'**
  String pvReviewTotal(int t, int m, String band);

  /// No description provided for @pvReviewScoreLocked.
  ///
  /// In en, this message translates to:
  /// **'Score, band and flags come from the questionnaire\'s rules and can\'t be changed here.'**
  String get pvReviewScoreLocked;

  /// No description provided for @pvReviewObservations.
  ///
  /// In en, this message translates to:
  /// **'What she will see'**
  String get pvReviewObservations;

  /// No description provided for @pvReviewEdited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get pvReviewEdited;

  /// No description provided for @pvReviewOriginalAi.
  ///
  /// In en, this message translates to:
  /// **'Original AI text'**
  String get pvReviewOriginalAi;

  /// No description provided for @pvReviewEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get pvReviewEdit;

  /// No description provided for @pvReviewRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get pvReviewRemove;

  /// No description provided for @pvReviewRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get pvReviewRestore;

  /// No description provided for @pvReviewSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get pvReviewSave;

  /// No description provided for @pvReviewCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get pvReviewCancel;

  /// No description provided for @pvReviewAnswers.
  ///
  /// In en, this message translates to:
  /// **'Her answers'**
  String get pvReviewAnswers;

  /// No description provided for @pvReviewConsent.
  ///
  /// In en, this message translates to:
  /// **'Consent'**
  String get pvReviewConsent;

  /// No description provided for @pvReviewConsentView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get pvReviewConsentView;

  /// No description provided for @pvReviewConsentNone.
  ///
  /// In en, this message translates to:
  /// **'No consent'**
  String get pvReviewConsentNone;

  /// No description provided for @pvReviewAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept as is'**
  String get pvReviewAccept;

  /// No description provided for @pvReviewVerifyNext.
  ///
  /// In en, this message translates to:
  /// **'Verify and next'**
  String get pvReviewVerifyNext;

  /// No description provided for @pvReviewFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Request follow-up'**
  String get pvReviewFollowUp;

  /// No description provided for @pvReviewFollowUpLabel.
  ///
  /// In en, this message translates to:
  /// **'Note to her (required)'**
  String get pvReviewFollowUpLabel;

  /// No description provided for @pvReviewFollowUpSend.
  ///
  /// In en, this message translates to:
  /// **'Send follow-up request'**
  String get pvReviewFollowUpSend;

  /// No description provided for @pvReviewFollowUpInactive.
  ///
  /// In en, this message translates to:
  /// **'Write a note to send'**
  String get pvReviewFollowUpInactive;

  /// No description provided for @pvReviewNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Short note to her (optional)'**
  String get pvReviewNoteLabel;

  /// No description provided for @pvReviewConcern.
  ///
  /// In en, this message translates to:
  /// **'Scoring concern'**
  String get pvReviewConcern;

  /// No description provided for @pvReviewConcernLabel.
  ///
  /// In en, this message translates to:
  /// **'What looks wrong with the scoring?'**
  String get pvReviewConcernLabel;

  /// No description provided for @pvReviewConcernSend.
  ///
  /// In en, this message translates to:
  /// **'Send to clinical reviewer'**
  String get pvReviewConcernSend;

  /// No description provided for @pvReviewConcernInactive.
  ///
  /// In en, this message translates to:
  /// **'Describe the concern to send'**
  String get pvReviewConcernInactive;

  /// No description provided for @pvReviewConcernSent.
  ///
  /// In en, this message translates to:
  /// **'Sent to the clinical reviewer. The result is unchanged.'**
  String get pvReviewConcernSent;

  /// No description provided for @pvReviewClaimNote.
  ///
  /// In en, this message translates to:
  /// **'This review is yours for {min} minutes.'**
  String pvReviewClaimNote(int min);

  /// No description provided for @pvReviewRelease.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get pvReviewRelease;

  /// No description provided for @pvReviewDone.
  ///
  /// In en, this message translates to:
  /// **'Review completed.'**
  String get pvReviewDone;

  /// No description provided for @pvRoleAdminWebOnly.
  ///
  /// In en, this message translates to:
  /// **'The admin workspace is on the web. Sign in on a computer to use it.'**
  String get pvRoleAdminWebOnly;

  /// No description provided for @scTitle.
  ///
  /// In en, this message translates to:
  /// **'Is this your account?'**
  String get scTitle;

  /// No description provided for @scBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s been a while, or this is a new device. Before we open the account, show us it\'s you.'**
  String get scBody;

  /// No description provided for @scDobLabel.
  ///
  /// In en, this message translates to:
  /// **'Your date of birth'**
  String get scDobLabel;

  /// No description provided for @scDobPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Choose your date of birth'**
  String get scDobPlaceholder;

  /// No description provided for @scDobChosen.
  ///
  /// In en, this message translates to:
  /// **'Date of birth: {date}'**
  String scDobChosen(String date);

  /// No description provided for @scEmailOption.
  ///
  /// In en, this message translates to:
  /// **'Send a code to my recovery email'**
  String get scEmailOption;

  /// No description provided for @scEmailSent.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a code to your recovery email.'**
  String get scEmailSent;

  /// No description provided for @scEmailCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code from the email'**
  String get scEmailCodeLabel;

  /// No description provided for @scDeviceOption.
  ///
  /// In en, this message translates to:
  /// **'Use this device'**
  String get scDeviceOption;

  /// No description provided for @scDeviceBody.
  ///
  /// In en, this message translates to:
  /// **'This device has been used with this account before.'**
  String get scDeviceBody;

  /// No description provided for @scCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get scCheck;

  /// No description provided for @scInactive.
  ///
  /// In en, this message translates to:
  /// **'Fill this in to continue'**
  String get scInactive;

  /// No description provided for @scNotMine.
  ///
  /// In en, this message translates to:
  /// **'This is not my account'**
  String get scNotMine;

  /// No description provided for @scNotMineTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new account?'**
  String get scNotMineTitle;

  /// No description provided for @scNotMineBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll give this number a new, empty account. The old account is not opened or shown to you.'**
  String get scNotMineBody;

  /// No description provided for @scNotMineConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, start a new account'**
  String get scNotMineConfirm;

  /// No description provided for @scCancel.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get scCancel;

  /// No description provided for @scSupport.
  ///
  /// In en, this message translates to:
  /// **'We can\'t confirm it\'s you here. Contact support and we\'ll help you get back in.'**
  String get scSupport;

  /// No description provided for @stSuspendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account is not available'**
  String get stSuspendedTitle;

  /// No description provided for @stSuspendedBody.
  ///
  /// In en, this message translates to:
  /// **'Contact support.'**
  String get stSuspendedBody;

  /// No description provided for @stPausedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account is paused'**
  String get stPausedTitle;

  /// No description provided for @stPausedBody.
  ///
  /// In en, this message translates to:
  /// **'Contact support, or delete your account.'**
  String get stPausedBody;

  /// No description provided for @stDeletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account is being deleted'**
  String get stDeletionTitle;

  /// No description provided for @stDeletionBody.
  ///
  /// In en, this message translates to:
  /// **'You can cancel the deletion here within the grace period, or sign out.'**
  String get stDeletionBody;

  /// No description provided for @reauthTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a new authenticator'**
  String get reauthTitle;

  /// No description provided for @reauthBody.
  ///
  /// In en, this message translates to:
  /// **'Your recovery code worked. Add your authenticator app again before you continue.'**
  String get reauthBody;

  /// No description provided for @setupKeyLoading.
  ///
  /// In en, this message translates to:
  /// **'Getting your setup key…'**
  String get setupKeyLoading;

  /// No description provided for @mealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get mealsTitle;

  /// No description provided for @mealsHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your meals today'**
  String get mealsHomeTitle;

  /// No description provided for @mealsHomeBody.
  ///
  /// In en, this message translates to:
  /// **'Snap your plate and we will work out what is on it.'**
  String get mealsHomeBody;

  /// No description provided for @mealsHomeNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet today.'**
  String get mealsHomeNone;

  /// No description provided for @mealsHomeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 meal logged today} other{{count} meals logged today}}'**
  String mealsHomeCount(int count);

  /// No description provided for @mealsScanAction.
  ///
  /// In en, this message translates to:
  /// **'Scan a meal'**
  String get mealsScanAction;

  /// No description provided for @mealsTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get mealsTakePhoto;

  /// No description provided for @mealsChoosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get mealsChoosePhoto;

  /// No description provided for @mealsScanIntro.
  ///
  /// In en, this message translates to:
  /// **'Take a clear photo from above, with the whole plate in view.'**
  String get mealsScanIntro;

  /// No description provided for @mealsReading.
  ///
  /// In en, this message translates to:
  /// **'Reading your meal…'**
  String get mealsReading;

  /// No description provided for @mealsResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Here is what we found'**
  String get mealsResultTitle;

  /// No description provided for @mealsResultHint.
  ///
  /// In en, this message translates to:
  /// **'Check each dish and its portion. Nothing is saved until you tap Save.'**
  String get mealsResultHint;

  /// No description provided for @mealsNotSureHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose the dish'**
  String get mealsNotSureHint;

  /// No description provided for @mealsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get mealsRemove;

  /// No description provided for @mealsSlot.
  ///
  /// In en, this message translates to:
  /// **'Which meal is this?'**
  String get mealsSlot;

  /// No description provided for @mealsSlotBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealsSlotBreakfast;

  /// No description provided for @mealsSlotLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealsSlotLunch;

  /// No description provided for @mealsSlotDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealsSlotDinner;

  /// No description provided for @mealsSlotSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get mealsSlotSnack;

  /// No description provided for @mealsSave.
  ///
  /// In en, this message translates to:
  /// **'Save meal'**
  String get mealsSave;

  /// No description provided for @mealsSaveInactive.
  ///
  /// In en, this message translates to:
  /// **'Choose every dish to save'**
  String get mealsSaveInactive;

  /// No description provided for @mealsSaved.
  ///
  /// In en, this message translates to:
  /// **'Meal saved'**
  String get mealsSaved;

  /// No description provided for @mealsDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get mealsDone;

  /// No description provided for @mealsScanAnother.
  ///
  /// In en, this message translates to:
  /// **'Scan another meal'**
  String get mealsScanAnother;

  /// No description provided for @mealsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The meal scanner isn’t available right now. Please try again in a little while.'**
  String get mealsUnavailable;

  /// No description provided for @mealsLimit.
  ///
  /// In en, this message translates to:
  /// **'You have used today’s meal scans.'**
  String get mealsLimit;

  /// No description provided for @mealsSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Which dish is this?'**
  String get mealsSearchTitle;

  /// No description provided for @mealsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search, e.g. dal, idli, roti'**
  String get mealsSearchHint;

  /// No description provided for @mealsSearchNone.
  ///
  /// In en, this message translates to:
  /// **'No dish found. Try another name.'**
  String get mealsSearchNone;

  /// No description provided for @mealsTotals.
  ///
  /// In en, this message translates to:
  /// **'This meal'**
  String get mealsTotals;

  /// No description provided for @mealsDayTotals.
  ///
  /// In en, this message translates to:
  /// **'Today so far'**
  String get mealsDayTotals;

  /// No description provided for @mealsKcal.
  ///
  /// In en, this message translates to:
  /// **'{value} kcal'**
  String mealsKcal(String value);

  /// No description provided for @mealsProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein {value} g'**
  String mealsProtein(String value);

  /// No description provided for @mealsCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs {value} g'**
  String mealsCarbs(String value);

  /// No description provided for @mealsFat.
  ///
  /// In en, this message translates to:
  /// **'Fat {value} g'**
  String mealsFat(String value);

  /// No description provided for @mealsFibre.
  ///
  /// In en, this message translates to:
  /// **'Fibre {value} g'**
  String mealsFibre(String value);

  /// No description provided for @mealsAiMark.
  ///
  /// In en, this message translates to:
  /// **'Identified by AI · nutrients from the Indian food table'**
  String get mealsAiMark;

  /// No description provided for @mealsTodayEmpty.
  ///
  /// In en, this message translates to:
  /// **'No meals logged today yet.'**
  String get mealsTodayEmpty;

  /// No description provided for @mealsTagLowGi.
  ///
  /// In en, this message translates to:
  /// **'Low GI'**
  String get mealsTagLowGi;

  /// No description provided for @mealsTagHighProtein.
  ///
  /// In en, this message translates to:
  /// **'High protein'**
  String get mealsTagHighProtein;

  /// No description provided for @mealsTagHighFibre.
  ///
  /// In en, this message translates to:
  /// **'High fibre'**
  String get mealsTagHighFibre;

  /// No description provided for @mealsTagPcosFriendly.
  ///
  /// In en, this message translates to:
  /// **'PCOS-friendly'**
  String get mealsTagPcosFriendly;

  /// No description provided for @mealsTagUnder400.
  ///
  /// In en, this message translates to:
  /// **'Under 400 kcal'**
  String get mealsTagUnder400;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @stCancelDeletion.
  ///
  /// In en, this message translates to:
  /// **'Cancel deletion'**
  String get stCancelDeletion;

  /// No description provided for @areaStartsOn.
  ///
  /// In en, this message translates to:
  /// **'This starts when your trial ends and your first payment goes through, on {date}.'**
  String areaStartsOn(String date);

  /// No description provided for @areaIncludedIn.
  ///
  /// In en, this message translates to:
  /// **'Included in: {plans}'**
  String areaIncludedIn(String plans);

  /// No description provided for @areaSeePlans.
  ///
  /// In en, this message translates to:
  /// **'See plans'**
  String get areaSeePlans;

  /// No description provided for @areaNotOnPlan.
  ///
  /// In en, this message translates to:
  /// **'{area} isn\'t on your plan.'**
  String areaNotOnPlan(String area);

  /// No description provided for @practiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceTitle;

  /// No description provided for @practiceForToday.
  ///
  /// In en, this message translates to:
  /// **'For today'**
  String get practiceForToday;

  /// No description provided for @practiceForPhase.
  ///
  /// In en, this message translates to:
  /// **'Chosen for your {phase} phase.'**
  String practiceForPhase(String phase);

  /// No description provided for @practiceNoPhase.
  ///
  /// In en, this message translates to:
  /// **'Yoga and breathwork, at your own pace.'**
  String get practiceNoPhase;

  /// No description provided for @practiceTodayEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing picked for today yet. The library has sessions for any day.'**
  String get practiceTodayEmpty;

  /// No description provided for @practiceBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse the library'**
  String get practiceBrowse;

  /// No description provided for @practiceMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get practiceMore;

  /// No description provided for @practiceMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String practiceMinutes(int minutes);

  /// No description provided for @practiceLevel.
  ///
  /// In en, this message translates to:
  /// **'Level: {level}'**
  String practiceLevel(String level);

  /// No description provided for @practiceCaptions.
  ///
  /// In en, this message translates to:
  /// **'Captions'**
  String get practiceCaptions;

  /// No description provided for @practicePlay.
  ///
  /// In en, this message translates to:
  /// **'Play the session'**
  String get practicePlay;

  /// No description provided for @practiceNoVideo.
  ///
  /// In en, this message translates to:
  /// **'The video for this session is not available yet.'**
  String get practiceNoVideo;

  /// No description provided for @practiceFinished.
  ///
  /// In en, this message translates to:
  /// **'I\'ve finished this session'**
  String get practiceFinished;

  /// No description provided for @practiceLogged.
  ///
  /// In en, this message translates to:
  /// **'Saved to what you did'**
  String get practiceLogged;

  /// No description provided for @practiceLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get practiceLibraryTitle;

  /// No description provided for @practiceLibraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sessions match these filters. Try fewer filters.'**
  String get practiceLibraryEmpty;

  /// No description provided for @practiceUpTo.
  ///
  /// In en, this message translates to:
  /// **'Up to {minutes} min'**
  String practiceUpTo(int minutes);

  /// No description provided for @practiceHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'What you did'**
  String get practiceHistoryTitle;

  /// No description provided for @practiceHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Sessions you finish will show here, week by week.'**
  String get practiceHistoryEmpty;

  /// No description provided for @practiceWeekOf.
  ///
  /// In en, this message translates to:
  /// **'Week of {date}'**
  String practiceWeekOf(String date);

  /// No description provided for @practiceWeekSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session} other{{count} sessions}}, {minutes} min'**
  String practiceWeekSummary(int count, int minutes);

  /// No description provided for @practiceLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Live classes'**
  String get practiceLiveTitle;

  /// No description provided for @practiceClassesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No live classes in the next two weeks.'**
  String get practiceClassesEmpty;

  /// No description provided for @practiceClassesAfterTrial.
  ///
  /// In en, this message translates to:
  /// **'Live classes start with your first payment.'**
  String get practiceClassesAfterTrial;

  /// No description provided for @practicePlacesLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 place left} other{{count} places left}}'**
  String practicePlacesLeft(int count);

  /// No description provided for @practiceClassFull.
  ///
  /// In en, this message translates to:
  /// **'This class is full'**
  String get practiceClassFull;

  /// No description provided for @practiceBook.
  ///
  /// In en, this message translates to:
  /// **'Book a place'**
  String get practiceBook;

  /// No description provided for @practiceBooked.
  ///
  /// In en, this message translates to:
  /// **'Your place is booked'**
  String get practiceBooked;

  /// No description provided for @meYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Your plan'**
  String get meYourPlan;

  /// No description provided for @meNoPlan.
  ///
  /// In en, this message translates to:
  /// **'No plan yet'**
  String get meNoPlan;

  /// No description provided for @mePlanRenews.
  ///
  /// In en, this message translates to:
  /// **'Renews on {date}'**
  String mePlanRenews(String date);

  /// No description provided for @mePlanEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends on {date}'**
  String mePlanEnds(String date);

  /// No description provided for @mePlanRetired.
  ///
  /// In en, this message translates to:
  /// **'This plan is no longer offered. You keep it until {date}.'**
  String mePlanRetired(String date);

  /// No description provided for @meSeePlans.
  ///
  /// In en, this message translates to:
  /// **'See plans'**
  String get meSeePlans;

  /// No description provided for @meAreas.
  ///
  /// In en, this message translates to:
  /// **'More for you'**
  String get meAreas;

  /// No description provided for @meLocked.
  ///
  /// In en, this message translates to:
  /// **'not on your plan'**
  String get meLocked;

  /// No description provided for @meSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get meSettings;

  /// No description provided for @meWellness.
  ///
  /// In en, this message translates to:
  /// **'Niraah supports your wellbeing. It does not replace your own doctor and is not an emergency service.'**
  String get meWellness;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Name you\'d like us to use'**
  String get profileName;

  /// No description provided for @profileHeight.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get profileHeight;

  /// No description provided for @profileHeightRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a height between 50 and 250 cm.'**
  String get profileHeightRange;

  /// No description provided for @profileGoals.
  ///
  /// In en, this message translates to:
  /// **'Your goals'**
  String get profileGoals;

  /// No description provided for @profileAddGoal.
  ///
  /// In en, this message translates to:
  /// **'Add a goal'**
  String get profileAddGoal;

  /// No description provided for @profileRemoveGoal.
  ///
  /// In en, this message translates to:
  /// **'Remove {goal}'**
  String profileRemoveGoal(String goal);

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get profilePhone;

  /// No description provided for @profileRecoveryEmail.
  ///
  /// In en, this message translates to:
  /// **'Recovery email'**
  String get profileRecoveryEmail;

  /// No description provided for @profileDob.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get profileDob;

  /// No description provided for @profileDobNote.
  ///
  /// In en, this message translates to:
  /// **'To correct this, contact support.'**
  String get profileDobNote;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileTimeZone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get profileTimeZone;

  /// No description provided for @profileNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get profileNotSet;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyTitle;

  /// No description provided for @privacyWhoCanSee.
  ///
  /// In en, this message translates to:
  /// **'Who can see my data'**
  String get privacyWhoCanSee;

  /// No description provided for @privacyNoConsents.
  ///
  /// In en, this message translates to:
  /// **'No one else can see your health data.'**
  String get privacyNoConsents;

  /// No description provided for @privacyGivenOn.
  ///
  /// In en, this message translates to:
  /// **'Given on {date}'**
  String privacyGivenOn(String date);

  /// No description provided for @privacyWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get privacyWithdraw;

  /// No description provided for @privacyWithdrawTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw access?'**
  String get privacyWithdrawTitle;

  /// No description provided for @privacyWithdrawBody.
  ///
  /// In en, this message translates to:
  /// **'{who} will no longer see your {category} data. This takes effect at once.'**
  String privacyWithdrawBody(String who, String category);

  /// No description provided for @privacyWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Access withdrawn'**
  String get privacyWithdrawn;

  /// No description provided for @privacyStaffAccess.
  ///
  /// In en, this message translates to:
  /// **'When Niraah staff opened your data'**
  String get privacyStaffAccess;

  /// No description provided for @privacyNoStaffAccess.
  ///
  /// In en, this message translates to:
  /// **'Niraah staff have not opened your health data.'**
  String get privacyNoStaffAccess;

  /// No description provided for @privacyAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Personalised AI'**
  String get privacyAiTitle;

  /// No description provided for @privacyAiSwitch.
  ///
  /// In en, this message translates to:
  /// **'Use my data to personalise AI answers'**
  String get privacyAiSwitch;

  /// No description provided for @privacyAiOn.
  ///
  /// In en, this message translates to:
  /// **'On: AI features use your logs and answers.'**
  String get privacyAiOn;

  /// No description provided for @privacyAiOff.
  ///
  /// In en, this message translates to:
  /// **'Off: AI features use only what you type.'**
  String get privacyAiOff;

  /// No description provided for @privacyChatTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Care chat history'**
  String get privacyChatTitle;

  /// No description provided for @privacyChatBody.
  ///
  /// In en, this message translates to:
  /// **'All your AI Care conversations will be deleted. This cannot be undone.'**
  String get privacyChatBody;

  /// No description provided for @privacyChatDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete all conversations'**
  String get privacyChatDelete;

  /// No description provided for @privacyChatDeleted.
  ///
  /// In en, this message translates to:
  /// **'Conversations deleted'**
  String get privacyChatDeleted;

  /// No description provided for @privacyExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get privacyExportTitle;

  /// No description provided for @privacyExportBody.
  ///
  /// In en, this message translates to:
  /// **'We prepare a copy of everything you\'ve given us and let you know when it\'s ready. Opening it needs a quick sign-in check.'**
  String get privacyExportBody;

  /// No description provided for @privacyExportRequest.
  ///
  /// In en, this message translates to:
  /// **'Request an export'**
  String get privacyExportRequest;

  /// No description provided for @privacyExportRequested.
  ///
  /// In en, this message translates to:
  /// **'We\'re preparing your export'**
  String get privacyExportRequested;

  /// No description provided for @privacyExportRequestedOn.
  ///
  /// In en, this message translates to:
  /// **'Requested {date}'**
  String privacyExportRequestedOn(String date);

  /// No description provided for @privacyExportPreparing.
  ///
  /// In en, this message translates to:
  /// **'Being prepared'**
  String get privacyExportPreparing;

  /// No description provided for @privacyExportReadyUntil.
  ///
  /// In en, this message translates to:
  /// **'Ready until {date}'**
  String privacyExportReadyUntil(String date);

  /// No description provided for @privacyExportExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get privacyExportExpired;

  /// No description provided for @privacyExportFailed.
  ///
  /// In en, this message translates to:
  /// **'This export didn\'t finish. Please request a new one.'**
  String get privacyExportFailed;

  /// No description provided for @privacyExportOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get privacyExportOpen;

  /// No description provided for @privacyExportCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get privacyExportCopy;

  /// No description provided for @privacyExportCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get privacyExportCopied;

  /// No description provided for @privacyDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get privacyDeleteTitle;

  /// No description provided for @privacyDeleteSummary.
  ///
  /// In en, this message translates to:
  /// **'Your account and data are deleted after a grace period, in which you can sign in and cancel. Records the law requires us to keep, such as invoices, are kept. An active plan is cancelled.'**
  String get privacyDeleteSummary;

  /// No description provided for @privacyDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'After the grace period your account and data are deleted and cannot be recovered. Records the law requires, such as invoices, are kept. Your plan is cancelled now. Next, we\'ll check it\'s you.'**
  String get privacyDeleteBody;

  /// No description provided for @privacyDeleteContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get privacyDeleteContinue;

  /// No description provided for @privacyDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get privacyDeleteAction;

  /// No description provided for @privacyDeleteStarted.
  ///
  /// In en, this message translates to:
  /// **'Your account will be deleted on {date}.'**
  String privacyDeleteStarted(String date);

  /// No description provided for @freshTitle.
  ///
  /// In en, this message translates to:
  /// **'Check it\'s you'**
  String get freshTitle;

  /// No description provided for @freshBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to your mobile number.'**
  String get freshBody;

  /// No description provided for @freshConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get freshConfirm;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifTitle;

  /// No description provided for @notifPush.
  ///
  /// In en, this message translates to:
  /// **'App notifications'**
  String get notifPush;

  /// No description provided for @notifSms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get notifSms;

  /// No description provided for @notifEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get notifEmail;

  /// No description provided for @notifAlwaysOn.
  ///
  /// In en, this message translates to:
  /// **'Always on. {reason}'**
  String notifAlwaysOn(String reason);

  /// No description provided for @programsTitle.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get programsTitle;

  /// No description provided for @programsAll.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get programsAll;

  /// No description provided for @programsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No programs are open right now.'**
  String get programsEmpty;

  /// No description provided for @programsSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested for you'**
  String get programsSuggested;

  /// No description provided for @programsLength.
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, =1{1 week} other{{weeks} weeks}}'**
  String programsLength(int weeks);

  /// No description provided for @programsJoin.
  ///
  /// In en, this message translates to:
  /// **'Join this program'**
  String get programsJoin;

  /// No description provided for @programsStartOn.
  ///
  /// In en, this message translates to:
  /// **'Choose a start day'**
  String get programsStartOn;

  /// No description provided for @programsJoined.
  ///
  /// In en, this message translates to:
  /// **'You\'ve joined {name}'**
  String programsJoined(String name);

  /// No description provided for @programsWeek.
  ///
  /// In en, this message translates to:
  /// **'Week {week}'**
  String programsWeek(int week);

  /// No description provided for @programsWeekOf.
  ///
  /// In en, this message translates to:
  /// **'Week {week} of {weeks}'**
  String programsWeekOf(int week, int weeks);

  /// No description provided for @programsStarted.
  ///
  /// In en, this message translates to:
  /// **'Started {date}'**
  String programsStarted(String date);

  /// No description provided for @programsPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused. Your progress is kept.'**
  String get programsPaused;

  /// No description provided for @programsPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get programsPause;

  /// No description provided for @programsResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get programsResume;

  /// No description provided for @programsPausedNote.
  ///
  /// In en, this message translates to:
  /// **'Program paused'**
  String get programsPausedNote;

  /// No description provided for @programsResumed.
  ///
  /// In en, this message translates to:
  /// **'Program resumed'**
  String get programsResumed;

  /// No description provided for @programsLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave program'**
  String get programsLeave;

  /// No description provided for @programsLeft.
  ///
  /// In en, this message translates to:
  /// **'You\'ve left the program'**
  String get programsLeft;

  /// No description provided for @careTitle.
  ///
  /// In en, this message translates to:
  /// **'Care plan'**
  String get careTitle;

  /// No description provided for @careNone.
  ///
  /// In en, this message translates to:
  /// **'When your doctor signs a care plan for you, it will appear here.'**
  String get careNone;

  /// No description provided for @careSignedBy.
  ///
  /// In en, this message translates to:
  /// **'Signed by {doctor} on {date}'**
  String careSignedBy(String doctor, String date);

  /// No description provided for @careYourDoctor.
  ///
  /// In en, this message translates to:
  /// **'your doctor'**
  String get careYourDoctor;

  /// No description provided for @careNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get careNutrition;

  /// No description provided for @careMovement.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get careMovement;

  /// No description provided for @careSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get careSleep;

  /// No description provided for @careSupplements.
  ///
  /// In en, this message translates to:
  /// **'Supplements'**
  String get careSupplements;

  /// No description provided for @careTodayTasks.
  ///
  /// In en, this message translates to:
  /// **'Today\'s tasks'**
  String get careTodayTasks;

  /// No description provided for @careNoTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks for today.'**
  String get careNoTasks;

  /// No description provided for @careWeek.
  ///
  /// In en, this message translates to:
  /// **'Your week'**
  String get careWeek;

  /// No description provided for @careWeekDay.
  ///
  /// In en, this message translates to:
  /// **'{date}: {count, plural, =1{1 task done} other{{count} tasks done}}'**
  String careWeekDay(String date, int count);

  /// No description provided for @careHistory.
  ///
  /// In en, this message translates to:
  /// **'Earlier plans'**
  String get careHistory;

  /// No description provided for @checkInsTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly check-in'**
  String get checkInsTitle;

  /// No description provided for @checkInsNoneDue.
  ///
  /// In en, this message translates to:
  /// **'No check-in this week. Your trend is below.'**
  String get checkInsNoneDue;

  /// No description provided for @checkInsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Week of {date}'**
  String checkInsThisWeek(String date);

  /// No description provided for @checkInsWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight in kg (optional)'**
  String get checkInsWeight;

  /// No description provided for @checkInsWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist in cm (optional)'**
  String get checkInsWaist;

  /// No description provided for @checkInsEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy this week'**
  String get checkInsEnergy;

  /// No description provided for @checkInsCravings.
  ///
  /// In en, this message translates to:
  /// **'Cravings this week'**
  String get checkInsCravings;

  /// No description provided for @checkInsScale.
  ///
  /// In en, this message translates to:
  /// **'{value} of 5'**
  String checkInsScale(int value);

  /// No description provided for @checkInsScaleEnds.
  ///
  /// In en, this message translates to:
  /// **'1 is low, 5 is high'**
  String get checkInsScaleEnds;

  /// No description provided for @checkInsNote.
  ///
  /// In en, this message translates to:
  /// **'Anything else (optional)'**
  String get checkInsNote;

  /// No description provided for @checkInsSubmit.
  ///
  /// In en, this message translates to:
  /// **'Save check-in'**
  String get checkInsSubmit;

  /// No description provided for @checkInsSaved.
  ///
  /// In en, this message translates to:
  /// **'Check-in saved'**
  String get checkInsSaved;

  /// No description provided for @checkInsTrend.
  ///
  /// In en, this message translates to:
  /// **'Your trend'**
  String get checkInsTrend;

  /// No description provided for @checkInsTrendEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your check-ins will show here over time.'**
  String get checkInsTrendEmpty;

  /// No description provided for @checkInsEnergyValue.
  ///
  /// In en, this message translates to:
  /// **'energy {value}'**
  String checkInsEnergyValue(int value);

  /// No description provided for @checkInsCravingsValue.
  ///
  /// In en, this message translates to:
  /// **'cravings {value}'**
  String checkInsCravingsValue(int value);

  /// No description provided for @checkInsWeightValue.
  ///
  /// In en, this message translates to:
  /// **'{value} kg'**
  String checkInsWeightValue(String value);

  /// No description provided for @checkInsWaistValue.
  ///
  /// In en, this message translates to:
  /// **'waist {value} cm'**
  String checkInsWaistValue(String value);

  /// No description provided for @labsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lab tests'**
  String get labsTitle;

  /// No description provided for @labsReports.
  ///
  /// In en, this message translates to:
  /// **'Your reports'**
  String get labsReports;

  /// No description provided for @labsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add a lab report to keep your results in one place.'**
  String get labsEmpty;

  /// No description provided for @labsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a report'**
  String get labsAdd;

  /// No description provided for @labsReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get labsReport;

  /// No description provided for @labsTestedOn.
  ///
  /// In en, this message translates to:
  /// **'Tested on {date}'**
  String labsTestedOn(String date);

  /// No description provided for @labsRange.
  ///
  /// In en, this message translates to:
  /// **'Lab\'s range {low} to {high}'**
  String labsRange(String low, String high);

  /// No description provided for @labsOutside.
  ///
  /// In en, this message translates to:
  /// **'Outside the lab\'s range'**
  String get labsOutside;

  /// No description provided for @labsCollection.
  ///
  /// In en, this message translates to:
  /// **'Home collection'**
  String get labsCollection;

  /// No description provided for @labsOrder.
  ///
  /// In en, this message translates to:
  /// **'Book home collection'**
  String get labsOrder;

  /// No description provided for @labsAfterTrial.
  ///
  /// In en, this message translates to:
  /// **'Home collection starts when your trial ends and your first payment goes through.'**
  String get labsAfterTrial;

  /// No description provided for @labsNotIncluded.
  ///
  /// In en, this message translates to:
  /// **'Home collection isn\'t on your plan. You can still add your own reports.'**
  String get labsNotIncluded;

  /// No description provided for @labsCollectionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Home collection isn\'t available right now.'**
  String get labsCollectionUnavailable;

  /// No description provided for @labsPickDate.
  ///
  /// In en, this message translates to:
  /// **'Choose the test date'**
  String get labsPickDate;

  /// No description provided for @labsPickDateFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose the test date to save'**
  String get labsPickDateFirst;

  /// No description provided for @labsResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get labsResults;

  /// No description provided for @labsResultsHelp.
  ///
  /// In en, this message translates to:
  /// **'Copy each result and the range printed on your report. Leave this empty to save the report only.'**
  String get labsResultsHelp;

  /// No description provided for @labsMarker.
  ///
  /// In en, this message translates to:
  /// **'Test name'**
  String get labsMarker;

  /// No description provided for @labsValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get labsValue;

  /// No description provided for @labsUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get labsUnit;

  /// No description provided for @labsLow.
  ///
  /// In en, this message translates to:
  /// **'Range from'**
  String get labsLow;

  /// No description provided for @labsHigh.
  ///
  /// In en, this message translates to:
  /// **'Range to'**
  String get labsHigh;

  /// No description provided for @labsAddResult.
  ///
  /// In en, this message translates to:
  /// **'Add another result'**
  String get labsAddResult;

  /// No description provided for @labsResultIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Each result needs a name and a number.'**
  String get labsResultIncomplete;

  /// No description provided for @labsSave.
  ///
  /// In en, this message translates to:
  /// **'Save report'**
  String get labsSave;

  /// No description provided for @labsChooseTests.
  ///
  /// In en, this message translates to:
  /// **'Choose tests'**
  String get labsChooseTests;

  /// No description provided for @labsFasting.
  ///
  /// In en, this message translates to:
  /// **'Needs fasting'**
  String get labsFasting;

  /// No description provided for @labsPartner.
  ///
  /// In en, this message translates to:
  /// **'Lab'**
  String get labsPartner;

  /// No description provided for @labsAddress.
  ///
  /// In en, this message translates to:
  /// **'Address for collection'**
  String get labsAddress;

  /// No description provided for @labsAddressLine.
  ///
  /// In en, this message translates to:
  /// **'House, street and area'**
  String get labsAddressLine;

  /// No description provided for @labsCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get labsCity;

  /// No description provided for @labsPincode.
  ///
  /// In en, this message translates to:
  /// **'PIN code'**
  String get labsPincode;

  /// No description provided for @labsTime.
  ///
  /// In en, this message translates to:
  /// **'Collection time'**
  String get labsTime;

  /// No description provided for @labsPickTime.
  ///
  /// In en, this message translates to:
  /// **'Choose a day and time'**
  String get labsPickTime;

  /// No description provided for @labsTimeNote.
  ///
  /// In en, this message translates to:
  /// **'The lab confirms the exact time with you.'**
  String get labsTimeNote;

  /// No description provided for @labsOrderSubmit.
  ///
  /// In en, this message translates to:
  /// **'Request collection'**
  String get labsOrderSubmit;

  /// No description provided for @labsOrderIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Choose tests, an address and a time'**
  String get labsOrderIncomplete;

  /// No description provided for @communityTitle.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get communityTitle;

  /// No description provided for @communityRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Community rules'**
  String get communityRulesTitle;

  /// No description provided for @communityAcceptRules.
  ///
  /// In en, this message translates to:
  /// **'I agree to the rules'**
  String get communityAcceptRules;

  /// No description provided for @communityAcceptFirst.
  ///
  /// In en, this message translates to:
  /// **'Agree to the community rules to post.'**
  String get communityAcceptFirst;

  /// No description provided for @communityCircles.
  ///
  /// In en, this message translates to:
  /// **'Circles'**
  String get communityCircles;

  /// No description provided for @communityNoCircles.
  ///
  /// In en, this message translates to:
  /// **'No circles are open yet.'**
  String get communityNoCircles;

  /// No description provided for @communityJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get communityJoin;

  /// No description provided for @communityLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get communityLeave;

  /// No description provided for @communityFeedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No posts here yet. You could start the conversation.'**
  String get communityFeedEmpty;

  /// No description provided for @communityNewPost.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get communityNewPost;

  /// No description provided for @communityWrite.
  ///
  /// In en, this message translates to:
  /// **'Write your post'**
  String get communityWrite;

  /// No description provided for @communityPostAnonymously.
  ///
  /// In en, this message translates to:
  /// **'Post anonymously'**
  String get communityPostAnonymously;

  /// No description provided for @communityAnonymousNote.
  ///
  /// In en, this message translates to:
  /// **'Other members won\'t see your name or photo.'**
  String get communityAnonymousNote;

  /// No description provided for @communitySend.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get communitySend;

  /// No description provided for @communityPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get communityPosted;

  /// No description provided for @communityReplied.
  ///
  /// In en, this message translates to:
  /// **'Reply posted'**
  String get communityReplied;

  /// No description provided for @communityThread.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get communityThread;

  /// No description provided for @communityReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get communityReply;

  /// No description provided for @communityReplies.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No replies} =1{1 reply} other{{count} replies}}'**
  String communityReplies(int count);

  /// No description provided for @communityEdited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get communityEdited;

  /// No description provided for @communityEditedNote.
  ///
  /// In en, this message translates to:
  /// **'Post updated'**
  String get communityEditedNote;

  /// No description provided for @communityBeingReviewed.
  ///
  /// In en, this message translates to:
  /// **'Your post is being reviewed'**
  String get communityBeingReviewed;

  /// No description provided for @communityYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get communityYou;

  /// No description provided for @communityYouAnonymous.
  ///
  /// In en, this message translates to:
  /// **'You, anonymously'**
  String get communityYouAnonymous;

  /// No description provided for @communityAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous member'**
  String get communityAnonymous;

  /// No description provided for @communityMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get communityMember;

  /// No description provided for @communityMore.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get communityMore;

  /// No description provided for @communityEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get communityEdit;

  /// No description provided for @communityDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get communityDelete;

  /// No description provided for @communityDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get communityDeleted;

  /// No description provided for @communityReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get communityReport;

  /// No description provided for @communityReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Why are you reporting this?'**
  String get communityReportTitle;

  /// No description provided for @communityReported.
  ///
  /// In en, this message translates to:
  /// **'Thank you. Our moderators will look at it.'**
  String get communityReported;

  /// No description provided for @communityMute.
  ///
  /// In en, this message translates to:
  /// **'Mute this author'**
  String get communityMute;

  /// No description provided for @communityMuted.
  ///
  /// In en, this message translates to:
  /// **'You won\'t see posts from this author'**
  String get communityMuted;

  /// No description provided for @communityReasonHarmful.
  ///
  /// In en, this message translates to:
  /// **'Harmful health advice'**
  String get communityReasonHarmful;

  /// No description provided for @communityReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get communityReasonHarassment;

  /// No description provided for @communityReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get communityReasonSpam;

  /// No description provided for @communityReasonPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get communityReasonPersonal;

  /// No description provided for @communityReasonSelfHarm.
  ///
  /// In en, this message translates to:
  /// **'Someone may be at risk'**
  String get communityReasonSelfHarm;

  /// No description provided for @communityReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get communityReasonOther;

  /// No description provided for @homeManagePlan.
  ///
  /// In en, this message translates to:
  /// **'Manage plan'**
  String get homeManagePlan;

  /// No description provided for @homeOpenCarePlan.
  ///
  /// In en, this message translates to:
  /// **'Open care plan'**
  String get homeOpenCarePlan;

  /// No description provided for @homeNextTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get homeNextTitle;

  /// No description provided for @homeNextClass.
  ///
  /// In en, this message translates to:
  /// **'Live class'**
  String get homeNextClass;

  /// No description provided for @homeNextConsult.
  ///
  /// In en, this message translates to:
  /// **'Consult'**
  String get homeNextConsult;

  /// No description provided for @homeNextConsultWith.
  ///
  /// In en, this message translates to:
  /// **'Consult with {name}'**
  String homeNextConsultWith(String name);

  /// No description provided for @homeCheckInTitle.
  ///
  /// In en, this message translates to:
  /// **'Your weekly check-in'**
  String get homeCheckInTitle;

  /// No description provided for @homeCheckInBody.
  ///
  /// In en, this message translates to:
  /// **'A few quick questions about your week, whenever suits you.'**
  String get homeCheckInBody;

  /// No description provided for @homeCheckInAction.
  ///
  /// In en, this message translates to:
  /// **'Start check-in'**
  String get homeCheckInAction;

  /// No description provided for @drUnnamed.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get drUnnamed;

  /// No description provided for @drSearchName.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get drSearchName;

  /// No description provided for @drPast.
  ///
  /// In en, this message translates to:
  /// **'Past patients'**
  String get drPast;

  /// No description provided for @drRelDedicated.
  ///
  /// In en, this message translates to:
  /// **'Dedicated'**
  String get drRelDedicated;

  /// No description provided for @drRelConsult.
  ///
  /// In en, this message translates to:
  /// **'Consult'**
  String get drRelConsult;

  /// No description provided for @drRelReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get drRelReview;

  /// No description provided for @drOpenAlert.
  ///
  /// In en, this message translates to:
  /// **'Open alert'**
  String get drOpenAlert;

  /// No description provided for @drPlanAwaiting.
  ///
  /// In en, this message translates to:
  /// **'Care plan awaiting'**
  String get drPlanAwaiting;

  /// No description provided for @drNoPatients.
  ///
  /// In en, this message translates to:
  /// **'No members have a care relationship with you right now.'**
  String get drNoPatients;

  /// No description provided for @drNoPastPatients.
  ///
  /// In en, this message translates to:
  /// **'No past patients.'**
  String get drNoPastPatients;

  /// No description provided for @drNext.
  ///
  /// In en, this message translates to:
  /// **'Next {date}'**
  String drNext(String date);

  /// No description provided for @drPastPatient.
  ///
  /// In en, this message translates to:
  /// **'Past patient'**
  String get drPastPatient;

  /// No description provided for @drDietitian.
  ///
  /// In en, this message translates to:
  /// **'Dietitian: {name}'**
  String drDietitian(String name);

  /// No description provided for @drConsent.
  ///
  /// In en, this message translates to:
  /// **'Consent'**
  String get drConsent;

  /// No description provided for @drConsentView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get drConsentView;

  /// No description provided for @drConsentNone.
  ///
  /// In en, this message translates to:
  /// **'No consent'**
  String get drConsentNone;

  /// No description provided for @drFlags.
  ///
  /// In en, this message translates to:
  /// **'Flags'**
  String get drFlags;

  /// No description provided for @drMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get drMessages;

  /// No description provided for @drBrief.
  ///
  /// In en, this message translates to:
  /// **'Clinician brief'**
  String get drBrief;

  /// No description provided for @drBriefOpen.
  ///
  /// In en, this message translates to:
  /// **'Show the brief'**
  String get drBriefOpen;

  /// No description provided for @drNotShared.
  ///
  /// In en, this message translates to:
  /// **'She has not shared: {categories}'**
  String drNotShared(String categories);

  /// No description provided for @drNotSharedSection.
  ///
  /// In en, this message translates to:
  /// **'She has not shared this.'**
  String get drNotSharedSection;

  /// No description provided for @drSecSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get drSecSummary;

  /// No description provided for @drSecAssessment.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get drSecAssessment;

  /// No description provided for @drSecCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle and symptoms'**
  String get drSecCycle;

  /// No description provided for @drSecCarePlan.
  ///
  /// In en, this message translates to:
  /// **'Care plan'**
  String get drSecCarePlan;

  /// No description provided for @drSecAdvice.
  ///
  /// In en, this message translates to:
  /// **'Wellness advice'**
  String get drSecAdvice;

  /// No description provided for @drSecLabs.
  ///
  /// In en, this message translates to:
  /// **'Labs'**
  String get drSecLabs;

  /// No description provided for @drSecMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get drSecMeals;

  /// No description provided for @drSecShared.
  ///
  /// In en, this message translates to:
  /// **'Shared from AI chat'**
  String get drSecShared;

  /// No description provided for @drSecNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get drSecNotes;

  /// No description provided for @drSecTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get drSecTimeline;

  /// No description provided for @drAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get drAddNote;

  /// No description provided for @drNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Visible to clinicians caring for her, never to her'**
  String get drNoteHint;

  /// No description provided for @drSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get drSave;

  /// No description provided for @drSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get drSaved;

  /// No description provided for @drRecommendTests.
  ///
  /// In en, this message translates to:
  /// **'Recommend tests'**
  String get drRecommendTests;

  /// No description provided for @drRecommendNote.
  ///
  /// In en, this message translates to:
  /// **'Note for her (optional), for example \"fasting\"'**
  String get drRecommendNote;

  /// No description provided for @drRecommend.
  ///
  /// In en, this message translates to:
  /// **'Recommend'**
  String get drRecommend;

  /// No description provided for @drRecommended.
  ///
  /// In en, this message translates to:
  /// **'Tests recommended'**
  String get drRecommended;

  /// No description provided for @drOpenDraft.
  ///
  /// In en, this message translates to:
  /// **'Open the care plan draft'**
  String get drOpenDraft;

  /// No description provided for @drCarePlans.
  ///
  /// In en, this message translates to:
  /// **'Care plans to sign'**
  String get drCarePlans;

  /// No description provided for @drCarePlan.
  ///
  /// In en, this message translates to:
  /// **'Care plan'**
  String get drCarePlan;

  /// No description provided for @drNoCarePlans.
  ///
  /// In en, this message translates to:
  /// **'No care plans are waiting for you.'**
  String get drNoCarePlans;

  /// No description provided for @drDue.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String drDue(String date);

  /// No description provided for @drClaimedByMe.
  ///
  /// In en, this message translates to:
  /// **'Yours'**
  String get drClaimedByMe;

  /// No description provided for @drOfferedToMe.
  ///
  /// In en, this message translates to:
  /// **'Offered to you'**
  String get drOfferedToMe;

  /// No description provided for @drSharedQueue.
  ///
  /// In en, this message translates to:
  /// **'Shared queue'**
  String get drSharedQueue;

  /// No description provided for @drRevision.
  ///
  /// In en, this message translates to:
  /// **'Revision'**
  String get drRevision;

  /// No description provided for @drEmptyPlan.
  ///
  /// In en, this message translates to:
  /// **'No AI draft: write it yourself'**
  String get drEmptyPlan;

  /// No description provided for @drReturnNoteWas.
  ///
  /// In en, this message translates to:
  /// **'Returned with: {note}'**
  String drReturnNoteWas(String note);

  /// No description provided for @drAiSuggestion.
  ///
  /// In en, this message translates to:
  /// **'AI suggestion'**
  String get drAiSuggestion;

  /// No description provided for @drNoSuggestion.
  ///
  /// In en, this message translates to:
  /// **'No suggestion for this section.'**
  String get drNoSuggestion;

  /// No description provided for @drYourVersion.
  ///
  /// In en, this message translates to:
  /// **'Your version'**
  String get drYourVersion;

  /// No description provided for @drClearedBecause.
  ///
  /// In en, this message translates to:
  /// **'Left out: {reason}'**
  String drClearedBecause(String reason);

  /// No description provided for @drAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get drAccepted;

  /// No description provided for @drEdited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get drEdited;

  /// No description provided for @drCleared.
  ///
  /// In en, this message translates to:
  /// **'Left out'**
  String get drCleared;

  /// No description provided for @drUndecided.
  ///
  /// In en, this message translates to:
  /// **'Not decided yet'**
  String get drUndecided;

  /// No description provided for @drAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get drAccept;

  /// No description provided for @drEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get drEdit;

  /// No description provided for @drClear.
  ///
  /// In en, this message translates to:
  /// **'Leave out'**
  String get drClear;

  /// No description provided for @drClearSection.
  ///
  /// In en, this message translates to:
  /// **'Leave this section out'**
  String get drClearSection;

  /// No description provided for @drClearReason.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get drClearReason;

  /// No description provided for @drDoseWarning.
  ///
  /// In en, this message translates to:
  /// **'This text reads as a dose or a medicine. Confirm it is yours to give, or that it only refers to a medicine she already takes from her own doctor.'**
  String get drDoseWarning;

  /// No description provided for @drDoseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get drDoseConfirm;

  /// No description provided for @drTasks.
  ///
  /// In en, this message translates to:
  /// **'Daily tasks'**
  String get drTasks;

  /// No description provided for @drNoTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet.'**
  String get drNoTasks;

  /// No description provided for @drAddTask.
  ///
  /// In en, this message translates to:
  /// **'Add a task'**
  String get drAddTask;

  /// No description provided for @drTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get drTaskTitle;

  /// No description provided for @drRemoveTask.
  ///
  /// In en, this message translates to:
  /// **'Remove task'**
  String get drRemoveTask;

  /// No description provided for @drDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get drDaily;

  /// No description provided for @drWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get drWeekdays;

  /// No description provided for @drWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get drWeekly;

  /// No description provided for @drProposedByAi.
  ///
  /// In en, this message translates to:
  /// **'proposed by AI'**
  String get drProposedByAi;

  /// No description provided for @drSign.
  ///
  /// In en, this message translates to:
  /// **'Sign the care plan'**
  String get drSign;

  /// No description provided for @drSignTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign this care plan?'**
  String get drSignTitle;

  /// No description provided for @drSigned.
  ///
  /// In en, this message translates to:
  /// **'Signed. She can see it now.'**
  String get drSigned;

  /// No description provided for @drDecideAll.
  ///
  /// In en, this message translates to:
  /// **'Decide every section to sign'**
  String get drDecideAll;

  /// No description provided for @drKeepOne.
  ///
  /// In en, this message translates to:
  /// **'Keep at least one section to sign'**
  String get drKeepOne;

  /// No description provided for @drConfirmDoses.
  ///
  /// In en, this message translates to:
  /// **'Confirm the dose-like text to sign'**
  String get drConfirmDoses;

  /// No description provided for @drReturn.
  ///
  /// In en, this message translates to:
  /// **'Return for a new draft'**
  String get drReturn;

  /// No description provided for @drReturnHint.
  ///
  /// In en, this message translates to:
  /// **'What should change? The AI is given this note.'**
  String get drReturnHint;

  /// No description provided for @drReturned.
  ///
  /// In en, this message translates to:
  /// **'A new draft has been made with your note'**
  String get drReturned;

  /// No description provided for @drRevise.
  ///
  /// In en, this message translates to:
  /// **'Revise this plan'**
  String get drRevise;

  /// No description provided for @drRevisionStarted.
  ///
  /// In en, this message translates to:
  /// **'A revision has been started'**
  String get drRevisionStarted;

  /// No description provided for @drAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get drAlerts;

  /// No description provided for @drAlertsOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get drAlertsOpen;

  /// No description provided for @drAlertsResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get drAlertsResolved;

  /// No description provided for @drNoAlerts.
  ///
  /// In en, this message translates to:
  /// **'No alerts.'**
  String get drNoAlerts;

  /// No description provided for @drUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get drUrgent;

  /// No description provided for @drAge.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String drAge(int minutes);

  /// No description provided for @drOnCallAlert.
  ///
  /// In en, this message translates to:
  /// **'On call'**
  String get drOnCallAlert;

  /// No description provided for @drNotOpened.
  ///
  /// In en, this message translates to:
  /// **'Not opened'**
  String get drNotOpened;

  /// No description provided for @drAlertOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get drAlertOpen;

  /// No description provided for @drAlertAcknowledged.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged'**
  String get drAlertAcknowledged;

  /// No description provided for @drAlertResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get drAlertResolved;

  /// No description provided for @drOpenProfile.
  ///
  /// In en, this message translates to:
  /// **'Open her profile'**
  String get drOpenProfile;

  /// No description provided for @drAcknowledge.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge'**
  String get drAcknowledge;

  /// No description provided for @drAcknowledged.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged'**
  String get drAcknowledged;

  /// No description provided for @drAskToBook.
  ///
  /// In en, this message translates to:
  /// **'Ask her to book'**
  String get drAskToBook;

  /// No description provided for @drAskedToBook.
  ///
  /// In en, this message translates to:
  /// **'She has been asked to book'**
  String get drAskedToBook;

  /// No description provided for @drResolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get drResolve;

  /// No description provided for @drResolveHint.
  ///
  /// In en, this message translates to:
  /// **'What was done (required)'**
  String get drResolveHint;

  /// No description provided for @drResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get drResolved;

  /// No description provided for @drLabResults.
  ///
  /// In en, this message translates to:
  /// **'Lab results to review'**
  String get drLabResults;

  /// No description provided for @drNoLabResults.
  ///
  /// In en, this message translates to:
  /// **'No lab results are waiting for you.'**
  String get drNoLabResults;

  /// No description provided for @drFlagged.
  ///
  /// In en, this message translates to:
  /// **'Flagged'**
  String get drFlagged;

  /// No description provided for @drTypedByMember.
  ///
  /// In en, this message translates to:
  /// **'Typed in by her'**
  String get drTypedByMember;

  /// No description provided for @drTypedByMemberLong.
  ///
  /// In en, this message translates to:
  /// **'These values were typed in by her from her report.'**
  String get drTypedByMemberLong;

  /// No description provided for @drLabReport.
  ///
  /// In en, this message translates to:
  /// **'Lab report'**
  String get drLabReport;

  /// No description provided for @drReview.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get drReview;

  /// No description provided for @drReviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get drReviewed;

  /// No description provided for @drCommentForHer.
  ///
  /// In en, this message translates to:
  /// **'Comment for her, in plain words (optional)'**
  String get drCommentForHer;

  /// No description provided for @drMarkReviewed.
  ///
  /// In en, this message translates to:
  /// **'Mark reviewed'**
  String get drMarkReviewed;

  /// No description provided for @drConfirmOwnDoctor.
  ///
  /// In en, this message translates to:
  /// **'It refers to a medicine from her own doctor'**
  String get drConfirmOwnDoctor;

  /// No description provided for @drAdviceDrafts.
  ///
  /// In en, this message translates to:
  /// **'Wellness advice drafts'**
  String get drAdviceDrafts;

  /// No description provided for @drNoDrafts.
  ///
  /// In en, this message translates to:
  /// **'No drafts.'**
  String get drNoDrafts;

  /// No description provided for @drUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String drUpdated(String date);

  /// No description provided for @drCorrection.
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get drCorrection;

  /// No description provided for @drWellnessAdvice.
  ///
  /// In en, this message translates to:
  /// **'Wellness advice'**
  String get drWellnessAdvice;

  /// No description provided for @drWriteAdvice.
  ///
  /// In en, this message translates to:
  /// **'Write wellness advice'**
  String get drWriteAdvice;

  /// No description provided for @drAssessment.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get drAssessment;

  /// No description provided for @drAssessmentHelp.
  ///
  /// In en, this message translates to:
  /// **'In plain words. Do not name a disease as diagnosed.'**
  String get drAssessmentHelp;

  /// No description provided for @drSupplements.
  ///
  /// In en, this message translates to:
  /// **'Supplements'**
  String get drSupplements;

  /// No description provided for @drAddSupplement.
  ///
  /// In en, this message translates to:
  /// **'Add a supplement'**
  String get drAddSupplement;

  /// No description provided for @drChooseSupplement.
  ///
  /// In en, this message translates to:
  /// **'Choose from the catalogue'**
  String get drChooseSupplement;

  /// No description provided for @drNoSupplements.
  ///
  /// In en, this message translates to:
  /// **'The catalogue has no approved supplements yet.'**
  String get drNoSupplements;

  /// No description provided for @drRemoveLine.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get drRemoveLine;

  /// No description provided for @drSupplementsOnly.
  ///
  /// In en, this message translates to:
  /// **'Health supplements from the catalogue only. No prescription medicine and no hormonal product.'**
  String get drSupplementsOnly;

  /// No description provided for @drDosePattern.
  ///
  /// In en, this message translates to:
  /// **'Dose pattern'**
  String get drDosePattern;

  /// No description provided for @drTiming.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get drTiming;

  /// No description provided for @drBeforeFood.
  ///
  /// In en, this message translates to:
  /// **'Before food'**
  String get drBeforeFood;

  /// No description provided for @drAfterFood.
  ///
  /// In en, this message translates to:
  /// **'After food'**
  String get drAfterFood;

  /// No description provided for @drWithFood.
  ///
  /// In en, this message translates to:
  /// **'With food'**
  String get drWithFood;

  /// No description provided for @drAnyTime.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get drAnyTime;

  /// No description provided for @drDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get drDuration;

  /// No description provided for @drInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get drInstructions;

  /// No description provided for @drAdvice.
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get drAdvice;

  /// No description provided for @drSeeDoctorLine.
  ///
  /// In en, this message translates to:
  /// **'See a doctor in person'**
  String get drSeeDoctorLine;

  /// No description provided for @drTestsAdvised.
  ///
  /// In en, this message translates to:
  /// **'Tests advised'**
  String get drTestsAdvised;

  /// No description provided for @drCommaSeparated.
  ///
  /// In en, this message translates to:
  /// **'Separate with commas'**
  String get drCommaSeparated;

  /// No description provided for @drNoFollowUp.
  ///
  /// In en, this message translates to:
  /// **'No follow-up date'**
  String get drNoFollowUp;

  /// No description provided for @drFollowUpOn.
  ///
  /// In en, this message translates to:
  /// **'Follow up on {date}'**
  String drFollowUpOn(String date);

  /// No description provided for @drSetFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Set follow-up'**
  String get drSetFollowUp;

  /// No description provided for @drWordingCheck.
  ///
  /// In en, this message translates to:
  /// **'{field} names a medicine or a dose. Remove it, or confirm it only refers to a medicine she already takes from her own doctor.'**
  String drWordingCheck(String field);

  /// No description provided for @drSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get drSaveDraft;

  /// No description provided for @drSignAdvice.
  ///
  /// In en, this message translates to:
  /// **'Sign and send'**
  String get drSignAdvice;

  /// No description provided for @drAdviceSigned.
  ///
  /// In en, this message translates to:
  /// **'Signed. She has been told there is something new in her app.'**
  String get drAdviceSigned;

  /// No description provided for @drAdviceSignedOn.
  ///
  /// In en, this message translates to:
  /// **'Signed {date}'**
  String drAdviceSignedOn(String date);

  /// No description provided for @drVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code: {code}'**
  String drVerificationCode(String code);

  /// No description provided for @drDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard draft'**
  String get drDiscard;

  /// No description provided for @drDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Draft discarded'**
  String get drDiscarded;

  /// No description provided for @drMedicinesNotShared.
  ///
  /// In en, this message translates to:
  /// **'She has not shared her assessment, so reported medicines and allergies are not shown.'**
  String get drMedicinesNotShared;

  /// No description provided for @drMedicinesNotRecorded.
  ///
  /// In en, this message translates to:
  /// **'Medicines and allergies: not recorded.'**
  String get drMedicinesNotRecorded;

  /// No description provided for @drOnMedicationFlag.
  ///
  /// In en, this message translates to:
  /// **'She said she takes medicine. Details are not recorded.'**
  String get drOnMedicationFlag;

  /// No description provided for @drMedicinesReported.
  ///
  /// In en, this message translates to:
  /// **'Reported medicines: {medicines}. Allergies: {allergies}.'**
  String drMedicinesReported(String medicines, String allergies);

  /// No description provided for @drApproval.
  ///
  /// In en, this message translates to:
  /// **'Approval: {status}'**
  String drApproval(String status);

  /// No description provided for @drReverify.
  ///
  /// In en, this message translates to:
  /// **'Re-verification by {date}'**
  String drReverify(String date);

  /// No description provided for @drRegistration.
  ///
  /// In en, this message translates to:
  /// **'Registration {number}, {council}'**
  String drRegistration(String number, String council);

  /// No description provided for @drNoRegistration.
  ///
  /// In en, this message translates to:
  /// **'No registration number on file. You can\'t sign until it is added.'**
  String get drNoRegistration;

  /// No description provided for @drRating.
  ///
  /// In en, this message translates to:
  /// **'Rating {average} from {count} reviews'**
  String drRating(String average, int count);

  /// No description provided for @drOnCallSwitch.
  ///
  /// In en, this message translates to:
  /// **'I\'m on call now'**
  String get drOnCallSwitch;

  /// No description provided for @drBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get drBio;

  /// No description provided for @drLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get drLanguages;

  /// No description provided for @drSpecialities.
  ///
  /// In en, this message translates to:
  /// **'Consult specialities'**
  String get drSpecialities;

  /// No description provided for @drRegistrationNote.
  ///
  /// In en, this message translates to:
  /// **'To change your registration or qualifications, send a new document to Niraah for review.'**
  String get drRegistrationNote;

  /// No description provided for @drReviewerTasks.
  ///
  /// In en, this message translates to:
  /// **'Clinical review'**
  String get drReviewerTasks;

  /// No description provided for @drReviewerOnWeb.
  ///
  /// In en, this message translates to:
  /// **'Approving these tasks isn\'t in the app yet.'**
  String get drReviewerOnWeb;

  /// No description provided for @earnTitle.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnTitle;

  /// No description provided for @earnAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get earnAvailable;

  /// No description provided for @earnPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get earnPending;

  /// No description provided for @earnPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get earnPaid;

  /// No description provided for @earnReversed.
  ///
  /// In en, this message translates to:
  /// **'Reversed'**
  String get earnReversed;

  /// No description provided for @earnAvailableOn.
  ///
  /// In en, this message translates to:
  /// **'available {date}'**
  String earnAvailableOn(String date);

  /// No description provided for @earnCashOut.
  ///
  /// In en, this message translates to:
  /// **'Cash out'**
  String get earnCashOut;

  /// No description provided for @earnNothingAvailable.
  ///
  /// In en, this message translates to:
  /// **'Nothing available to cash out yet'**
  String get earnNothingAvailable;

  /// No description provided for @earnPayoutRequested.
  ///
  /// In en, this message translates to:
  /// **'Cash-out requested'**
  String get earnPayoutRequested;

  /// No description provided for @earnLines.
  ///
  /// In en, this message translates to:
  /// **'Earning lines'**
  String get earnLines;

  /// No description provided for @earnNoLines.
  ///
  /// In en, this message translates to:
  /// **'No earnings yet.'**
  String get earnNoLines;

  /// No description provided for @earnRules.
  ///
  /// In en, this message translates to:
  /// **'What each kind of work pays'**
  String get earnRules;

  /// No description provided for @earnRuleAmount.
  ///
  /// In en, this message translates to:
  /// **'{kind}: {amount}'**
  String earnRuleAmount(String kind, String amount);

  /// No description provided for @earnRuleShare.
  ///
  /// In en, this message translates to:
  /// **'{kind}: {percent}% of the fee'**
  String earnRuleShare(String kind, String percent);

  /// No description provided for @earnPayouts.
  ///
  /// In en, this message translates to:
  /// **'Payouts'**
  String get earnPayouts;

  /// No description provided for @earnNoPayouts.
  ///
  /// In en, this message translates to:
  /// **'No payouts yet.'**
  String get earnNoPayouts;

  /// No description provided for @earnTaxWithheld.
  ///
  /// In en, this message translates to:
  /// **'Tax withheld {amount}'**
  String earnTaxWithheld(String amount);

  /// No description provided for @earnRequestedOn.
  ///
  /// In en, this message translates to:
  /// **'Requested {date}'**
  String earnRequestedOn(String date);

  /// No description provided for @schedTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedTitle;

  /// No description provided for @schedTimeZone.
  ///
  /// In en, this message translates to:
  /// **'Times in {zone}'**
  String schedTimeZone(String zone);

  /// No description provided for @schedNoHours.
  ///
  /// In en, this message translates to:
  /// **'You have no consult hours set, so members can\'t book you.'**
  String get schedNoHours;

  /// No description provided for @schedNextTwoWeeks.
  ///
  /// In en, this message translates to:
  /// **'Next two weeks'**
  String get schedNextTwoWeeks;

  /// No description provided for @schedNoAppointments.
  ///
  /// In en, this message translates to:
  /// **'No appointments in the next two weeks.'**
  String get schedNoAppointments;

  /// No description provided for @schedHold.
  ///
  /// In en, this message translates to:
  /// **'Being booked'**
  String get schedHold;

  /// No description provided for @schedBeingBooked.
  ///
  /// In en, this message translates to:
  /// **'Being booked'**
  String get schedBeingBooked;

  /// No description provided for @schedConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get schedConfirmed;

  /// No description provided for @schedInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get schedInProgress;

  /// No description provided for @schedCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get schedCompleted;

  /// No description provided for @schedCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get schedCancelled;

  /// No description provided for @schedNoShow.
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get schedNoShow;

  /// No description provided for @schedWeeklyHours.
  ///
  /// In en, this message translates to:
  /// **'Weekly hours'**
  String get schedWeeklyHours;

  /// No description provided for @schedNoWeeklyHours.
  ///
  /// In en, this message translates to:
  /// **'No weekly hours set.'**
  String get schedNoWeeklyHours;

  /// No description provided for @schedConsults.
  ///
  /// In en, this message translates to:
  /// **'Consults'**
  String get schedConsults;

  /// No description provided for @schedReviewsOnCall.
  ///
  /// In en, this message translates to:
  /// **'Reviews and on call'**
  String get schedReviewsOnCall;

  /// No description provided for @schedHoursOnWeb.
  ///
  /// In en, this message translates to:
  /// **'Changing weekly hours isn\'t in the app yet.'**
  String get schedHoursOnWeb;

  /// No description provided for @schedExceptions.
  ///
  /// In en, this message translates to:
  /// **'Blocked time and extra hours'**
  String get schedExceptions;

  /// No description provided for @schedAddException.
  ///
  /// In en, this message translates to:
  /// **'Block time or add hours'**
  String get schedAddException;

  /// No description provided for @schedExceptionKind.
  ///
  /// In en, this message translates to:
  /// **'What is this time?'**
  String get schedExceptionKind;

  /// No description provided for @schedBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get schedBlocked;

  /// No description provided for @schedExtra.
  ///
  /// In en, this message translates to:
  /// **'Extra consult hours'**
  String get schedExtra;

  /// No description provided for @schedFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get schedFrom;

  /// No description provided for @schedTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get schedTo;

  /// No description provided for @schedSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get schedSaved;

  /// No description provided for @schedRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get schedRemove;

  /// No description provided for @staffCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Check it\'s you'**
  String get staffCheckTitle;

  /// No description provided for @staffCheckBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your password and the code from your authenticator app to sign.'**
  String get staffCheckBody;

  /// No description provided for @staffCheckPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get staffCheckPassword;

  /// No description provided for @staffCheckCode.
  ///
  /// In en, this message translates to:
  /// **'Authenticator code'**
  String get staffCheckCode;

  /// No description provided for @msgTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get msgTitle;

  /// No description provided for @msgNoThreads.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet.'**
  String get msgNoThreads;

  /// No description provided for @msgNotOnPlan.
  ///
  /// In en, this message translates to:
  /// **'Messaging your care team isn\'t on your plan.'**
  String get msgNotOnPlan;

  /// No description provided for @msgUnread.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String msgUnread(int count);

  /// No description provided for @msgReadOnly.
  ///
  /// In en, this message translates to:
  /// **'You can read this conversation but not reply.'**
  String get msgReadOnly;

  /// No description provided for @msgStart.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get msgStart;

  /// No description provided for @msgConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your messages?'**
  String get msgConsentTitle;

  /// No description provided for @msgConsentBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will be able to read what you send in this conversation.'**
  String msgConsentBody(String name);

  /// No description provided for @msgConsentAgree.
  ///
  /// In en, this message translates to:
  /// **'Agree and continue'**
  String get msgConsentAgree;

  /// No description provided for @msgWrite.
  ///
  /// In en, this message translates to:
  /// **'Write a message'**
  String get msgWrite;

  /// No description provided for @msgSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get msgSend;

  /// No description provided for @msgDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get msgDeleted;

  /// No description provided for @msgSharedFromChat.
  ///
  /// In en, this message translates to:
  /// **'Shared from AI Care'**
  String get msgSharedFromChat;

  /// No description provided for @msgEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get msgEdit;

  /// No description provided for @msgSendAnyway.
  ///
  /// In en, this message translates to:
  /// **'It refers to her own doctor\'s medicine: send'**
  String get msgSendAnyway;

  /// No description provided for @msgAway.
  ///
  /// In en, this message translates to:
  /// **'Away until {date}. {note}'**
  String msgAway(String date, String note);

  /// No description provided for @msgSetAway.
  ///
  /// In en, this message translates to:
  /// **'Set away'**
  String get msgSetAway;

  /// No description provided for @msgAwayTitle.
  ///
  /// In en, this message translates to:
  /// **'Away note'**
  String get msgAwayTitle;

  /// No description provided for @msgAwayNote.
  ///
  /// In en, this message translates to:
  /// **'A line members will see'**
  String get msgAwayNote;

  /// No description provided for @msgAwayUntil.
  ///
  /// In en, this message translates to:
  /// **'Back on'**
  String get msgAwayUntil;

  /// No description provided for @msgAwaySet.
  ///
  /// In en, this message translates to:
  /// **'Away until {date}'**
  String msgAwaySet(String date);

  /// No description provided for @dtClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get dtClients;

  /// No description provided for @dtReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get dtReview;

  /// No description provided for @dtFoodLogs.
  ///
  /// In en, this message translates to:
  /// **'Food logs to review'**
  String get dtFoodLogs;

  /// No description provided for @dtPlansToBuild.
  ///
  /// In en, this message translates to:
  /// **'Meal plans to build'**
  String get dtPlansToBuild;

  /// No description provided for @dtEndingSoon.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{None ending this week} =1{1 ending within 7 days} other{{count} ending within 7 days}}'**
  String dtEndingSoon(int count);

  /// No description provided for @dtCheckIns.
  ///
  /// In en, this message translates to:
  /// **'Check-ins to read'**
  String get dtCheckIns;

  /// No description provided for @dtPastClients.
  ///
  /// In en, this message translates to:
  /// **'Past clients'**
  String get dtPastClients;

  /// No description provided for @dtNoClients.
  ///
  /// In en, this message translates to:
  /// **'No clients with a care relationship right now.'**
  String get dtNoClients;

  /// No description provided for @dtPlanNone.
  ///
  /// In en, this message translates to:
  /// **'No plan'**
  String get dtPlanNone;

  /// No description provided for @dtPlanDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get dtPlanDraft;

  /// No description provided for @dtPlanScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get dtPlanScheduled;

  /// No description provided for @dtPlanActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get dtPlanActive;

  /// No description provided for @dtPlanEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get dtPlanEnded;

  /// No description provided for @dtPlanUntil.
  ///
  /// In en, this message translates to:
  /// **'until {date}'**
  String dtPlanUntil(String date);

  /// No description provided for @dtLastCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Last check-in {date}'**
  String dtLastCheckIn(String date);

  /// No description provided for @dtUnreviewedLogs.
  ///
  /// In en, this message translates to:
  /// **'Food logs to review'**
  String get dtUnreviewedLogs;

  /// No description provided for @dtSecMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Meal plan'**
  String get dtSecMealPlan;

  /// No description provided for @dtSecProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get dtSecProgress;

  /// No description provided for @dtDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor: {name}'**
  String dtDoctor(String name);

  /// No description provided for @dtNewPlan.
  ///
  /// In en, this message translates to:
  /// **'New meal plan'**
  String get dtNewPlan;

  /// No description provided for @dtMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Meal plan'**
  String get dtMealPlan;

  /// No description provided for @dtMealPlans.
  ///
  /// In en, this message translates to:
  /// **'Meal plans'**
  String get dtMealPlans;

  /// No description provided for @dtRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get dtRecipes;

  /// No description provided for @dtRecipe.
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get dtRecipe;

  /// No description provided for @dtSpecialities.
  ///
  /// In en, this message translates to:
  /// **'Specialities'**
  String get dtSpecialities;

  /// No description provided for @dtPlanPeriods.
  ///
  /// In en, this message translates to:
  /// **'Plan periods: {periods}'**
  String dtPlanPeriods(String periods);

  /// No description provided for @dtNoCheckIns.
  ///
  /// In en, this message translates to:
  /// **'No check-ins yet.'**
  String get dtNoCheckIns;

  /// No description provided for @dtYourReply.
  ///
  /// In en, this message translates to:
  /// **'Your reply: {text}'**
  String dtYourReply(String text);

  /// No description provided for @dtMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Mark read'**
  String get dtMarkRead;

  /// No description provided for @dtMarkedRead.
  ///
  /// In en, this message translates to:
  /// **'Marked read'**
  String get dtMarkedRead;

  /// No description provided for @dtReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get dtReply;

  /// No description provided for @dtReplyHint.
  ///
  /// In en, this message translates to:
  /// **'A short, kind note'**
  String get dtReplyHint;

  /// No description provided for @dtReplied.
  ///
  /// In en, this message translates to:
  /// **'Reply sent'**
  String get dtReplied;

  /// No description provided for @dtMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed weeks'**
  String get dtMissed;

  /// No description provided for @dtNudge.
  ///
  /// In en, this message translates to:
  /// **'Send a gentle nudge'**
  String get dtNudge;

  /// No description provided for @dtNudged.
  ///
  /// In en, this message translates to:
  /// **'Nudge sent'**
  String get dtNudged;

  /// No description provided for @dtNudgeSent.
  ///
  /// In en, this message translates to:
  /// **'Nudge sent'**
  String get dtNudgeSent;

  /// No description provided for @dtAssign.
  ///
  /// In en, this message translates to:
  /// **'Assign a check-in questionnaire'**
  String get dtAssign;

  /// No description provided for @dtAssigned.
  ///
  /// In en, this message translates to:
  /// **'Questionnaire assigned'**
  String get dtAssigned;

  /// No description provided for @dtNoQuestionnaires.
  ///
  /// In en, this message translates to:
  /// **'No check-in questionnaires are published yet.'**
  String get dtNoQuestionnaires;

  /// No description provided for @dtSchedule.
  ///
  /// In en, this message translates to:
  /// **'How often?'**
  String get dtSchedule;

  /// No description provided for @dtFortnightly.
  ///
  /// In en, this message translates to:
  /// **'Fortnightly'**
  String get dtFortnightly;

  /// No description provided for @dtMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get dtMonthly;

  /// No description provided for @dtEndsOn.
  ///
  /// In en, this message translates to:
  /// **'Ends on'**
  String get dtEndsOn;

  /// No description provided for @dtNoUnreadCheckIns.
  ///
  /// In en, this message translates to:
  /// **'All check-ins are read.'**
  String get dtNoUnreadCheckIns;

  /// No description provided for @dtRefer.
  ///
  /// In en, this message translates to:
  /// **'Refer to her doctor'**
  String get dtRefer;

  /// No description provided for @dtReferHint.
  ///
  /// In en, this message translates to:
  /// **'Your note for her doctor'**
  String get dtReferHint;

  /// No description provided for @dtReferred.
  ///
  /// In en, this message translates to:
  /// **'Referred to her doctor'**
  String get dtReferred;

  /// No description provided for @dtNeedPlan.
  ///
  /// In en, this message translates to:
  /// **'Clients waiting for a plan'**
  String get dtNeedPlan;

  /// No description provided for @dtNobodyWaiting.
  ///
  /// In en, this message translates to:
  /// **'Nobody is waiting for a plan.'**
  String get dtNobodyWaiting;

  /// No description provided for @dtYourPlans.
  ///
  /// In en, this message translates to:
  /// **'Your plans'**
  String get dtYourPlans;

  /// No description provided for @dtNoPlans.
  ///
  /// In en, this message translates to:
  /// **'No plans yet.'**
  String get dtNoPlans;

  /// No description provided for @dtPortion.
  ///
  /// In en, this message translates to:
  /// **'Portion'**
  String get dtPortion;

  /// No description provided for @dtTargets.
  ///
  /// In en, this message translates to:
  /// **'Targets'**
  String get dtTargets;

  /// No description provided for @dtEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy (kcal)'**
  String get dtEnergy;

  /// No description provided for @dtProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get dtProtein;

  /// No description provided for @dtCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get dtCarbs;

  /// No description provided for @dtFat.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get dtFat;

  /// No description provided for @dtFibre.
  ///
  /// In en, this message translates to:
  /// **'Fibre (g)'**
  String get dtFibre;

  /// No description provided for @dtMin.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get dtMin;

  /// No description provided for @dtMax.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get dtMax;

  /// No description provided for @dtCopyDay.
  ///
  /// In en, this message translates to:
  /// **'Copy this day'**
  String get dtCopyDay;

  /// No description provided for @dtCopyDayTo.
  ///
  /// In en, this message translates to:
  /// **'Copy day {day} to'**
  String dtCopyDayTo(int day);

  /// No description provided for @dtDayN.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String dtDayN(int day);

  /// No description provided for @dtCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get dtCopy;

  /// No description provided for @dtCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get dtCopied;

  /// No description provided for @dtStartsOn.
  ///
  /// In en, this message translates to:
  /// **'Plan starts on'**
  String get dtStartsOn;

  /// No description provided for @dtCarePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Her care plan: nutrition'**
  String get dtCarePlanTitle;

  /// No description provided for @dtCarePlanNoNutrition.
  ///
  /// In en, this message translates to:
  /// **'Her signed care plan has no nutrition section.'**
  String get dtCarePlanNoNutrition;

  /// No description provided for @dtCarePlanRead.
  ///
  /// In en, this message translates to:
  /// **'I have read it'**
  String get dtCarePlanRead;

  /// No description provided for @dtPublished.
  ///
  /// In en, this message translates to:
  /// **'Published. She\'ll see it from the start date.'**
  String get dtPublished;

  /// No description provided for @dtPlanDates.
  ///
  /// In en, this message translates to:
  /// **'{start} to {end}'**
  String dtPlanDates(String start, String end);

  /// No description provided for @dtSuppressedPreview.
  ///
  /// In en, this message translates to:
  /// **'Calorie and weight content is hidden for this member. She will see the plan without energy figures or energy targets.'**
  String get dtSuppressedPreview;

  /// No description provided for @dtDayTotals.
  ///
  /// In en, this message translates to:
  /// **'Day totals, from the food table'**
  String get dtDayTotals;

  /// No description provided for @dtWithin.
  ///
  /// In en, this message translates to:
  /// **'within'**
  String get dtWithin;

  /// No description provided for @dtBelow.
  ///
  /// In en, this message translates to:
  /// **'below'**
  String get dtBelow;

  /// No description provided for @dtAbove.
  ///
  /// In en, this message translates to:
  /// **'above'**
  String get dtAbove;

  /// No description provided for @dtSlotEarly.
  ///
  /// In en, this message translates to:
  /// **'Early morning'**
  String get dtSlotEarly;

  /// No description provided for @dtSlotMidMorning.
  ///
  /// In en, this message translates to:
  /// **'Mid-morning'**
  String get dtSlotMidMorning;

  /// No description provided for @dtSlotEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening snack'**
  String get dtSlotEvening;

  /// No description provided for @dtSlotBedtime.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get dtSlotBedtime;

  /// No description provided for @dtSlotNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get dtSlotNote;

  /// No description provided for @dtSlotNoteHint.
  ///
  /// In en, this message translates to:
  /// **'For example \"soak overnight\"'**
  String get dtSlotNoteHint;

  /// No description provided for @dtPreferenceWarning.
  ///
  /// In en, this message translates to:
  /// **'Doesn\'t match her food choice or is a food she avoids'**
  String get dtPreferenceWarning;

  /// No description provided for @dtConflict.
  ///
  /// In en, this message translates to:
  /// **'Check before publishing: {what}'**
  String dtConflict(String what);

  /// No description provided for @dtPregnancy.
  ///
  /// In en, this message translates to:
  /// **'not tagged pregnancy-safe'**
  String get dtPregnancy;

  /// No description provided for @dtConfirmConflict.
  ///
  /// In en, this message translates to:
  /// **'I\'ve checked this, keep it'**
  String get dtConfirmConflict;

  /// No description provided for @dtAddDish.
  ///
  /// In en, this message translates to:
  /// **'Add a dish'**
  String get dtAddDish;

  /// No description provided for @dtRepeats.
  ///
  /// In en, this message translates to:
  /// **'Repeated often this week: {names}'**
  String dtRepeats(String names);

  /// No description provided for @dtSaveTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save as template'**
  String get dtSaveTemplate;

  /// No description provided for @dtTemplateHint.
  ///
  /// In en, this message translates to:
  /// **'Template name'**
  String get dtTemplateHint;

  /// No description provided for @dtTemplateSaved.
  ///
  /// In en, this message translates to:
  /// **'Template saved'**
  String get dtTemplateSaved;

  /// No description provided for @dtPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish plan'**
  String get dtPublish;

  /// No description provided for @dtConfirmFirst.
  ///
  /// In en, this message translates to:
  /// **'Confirm the marked items to publish'**
  String get dtConfirmFirst;

  /// No description provided for @dtDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard draft'**
  String get dtDiscard;

  /// No description provided for @dtAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust from tomorrow'**
  String get dtAdjust;

  /// No description provided for @dtAdjustStarted.
  ///
  /// In en, this message translates to:
  /// **'A copy from tomorrow is ready to change'**
  String get dtAdjustStarted;

  /// No description provided for @dtEnd.
  ///
  /// In en, this message translates to:
  /// **'End this plan'**
  String get dtEnd;

  /// No description provided for @dtEnded.
  ///
  /// In en, this message translates to:
  /// **'Plan ended'**
  String get dtEnded;

  /// No description provided for @dtSearchDish.
  ///
  /// In en, this message translates to:
  /// **'Search dishes and foods'**
  String get dtSearchDish;

  /// No description provided for @dtSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Type at least two letters and search'**
  String get dtSearchHint;

  /// No description provided for @dtRequestFood.
  ///
  /// In en, this message translates to:
  /// **'Not in the list? Request \"{name}\"'**
  String dtRequestFood(String name);

  /// No description provided for @dtRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested. You can add it once the nutrition team adds it to the food table.'**
  String get dtRequested;

  /// No description provided for @dtNoLogs.
  ///
  /// In en, this message translates to:
  /// **'No food logs are waiting for you.'**
  String get dtNoLogs;

  /// No description provided for @dtLogs.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 meal} other{{count} meals}}'**
  String dtLogs(int count);

  /// No description provided for @dtComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get dtComment;

  /// No description provided for @dtCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Up to 280 characters, kind and specific'**
  String get dtCommentHint;

  /// No description provided for @dtCommented.
  ///
  /// In en, this message translates to:
  /// **'Comment sent'**
  String get dtCommented;

  /// No description provided for @dtCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct this dish'**
  String get dtCorrect;

  /// No description provided for @dtCorrectTo.
  ///
  /// In en, this message translates to:
  /// **'Change to {name}'**
  String dtCorrectTo(String name);

  /// No description provided for @dtCorrected.
  ///
  /// In en, this message translates to:
  /// **'Corrected. She has been told.'**
  String get dtCorrected;

  /// No description provided for @dtCorrectedMark.
  ///
  /// In en, this message translates to:
  /// **'corrected'**
  String get dtCorrectedMark;

  /// No description provided for @dtHasTargets.
  ///
  /// In en, this message translates to:
  /// **'Her plan\'s targets apply to this day.'**
  String get dtHasTargets;

  /// No description provided for @dtTakeDay.
  ///
  /// In en, this message translates to:
  /// **'Take this day'**
  String get dtTakeDay;

  /// No description provided for @dtPhoto.
  ///
  /// In en, this message translates to:
  /// **'photo'**
  String get dtPhoto;

  /// No description provided for @dtApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get dtApprove;

  /// No description provided for @dtApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get dtApproved;

  /// No description provided for @dtApproveDay.
  ///
  /// In en, this message translates to:
  /// **'Approve all for this day'**
  String get dtApproveDay;

  /// No description provided for @dtDayApproved.
  ///
  /// In en, this message translates to:
  /// **'Day approved'**
  String get dtDayApproved;

  /// No description provided for @dtNewRecipe.
  ///
  /// In en, this message translates to:
  /// **'New recipe'**
  String get dtNewRecipe;

  /// No description provided for @dtSearchRecipes.
  ///
  /// In en, this message translates to:
  /// **'Search recipes'**
  String get dtSearchRecipes;

  /// No description provided for @dtMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get dtMine;

  /// No description provided for @dtNoRecipes.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet.'**
  String get dtNoRecipes;

  /// No description provided for @dtPublishedLabel.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get dtPublishedLabel;

  /// No description provided for @dtGrams.
  ///
  /// In en, this message translates to:
  /// **'Grams'**
  String get dtGrams;

  /// No description provided for @dtRecipeIncomplete.
  ///
  /// In en, this message translates to:
  /// **'A recipe needs a title, at least one ingredient and servings.'**
  String get dtRecipeIncomplete;

  /// No description provided for @dtRecipePublished.
  ///
  /// In en, this message translates to:
  /// **'Recipe published'**
  String get dtRecipePublished;

  /// No description provided for @dtVersion.
  ///
  /// In en, this message translates to:
  /// **'version {n}'**
  String dtVersion(int n);

  /// No description provided for @dtVersionNote.
  ///
  /// In en, this message translates to:
  /// **'Changing ingredients or servings makes a new version; plans already published keep this one.'**
  String get dtVersionNote;

  /// No description provided for @dtRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get dtRecipeTitle;

  /// No description provided for @dtIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get dtIngredients;

  /// No description provided for @dtRequestedFood.
  ///
  /// In en, this message translates to:
  /// **'Requested from the nutrition team'**
  String get dtRequestedFood;

  /// No description provided for @dtAddIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add an ingredient'**
  String get dtAddIngredient;

  /// No description provided for @dtPerServing.
  ///
  /// In en, this message translates to:
  /// **'Per serving, from the food table'**
  String get dtPerServing;

  /// No description provided for @dtServings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get dtServings;

  /// No description provided for @dtMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get dtMinutes;

  /// No description provided for @dtSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get dtSteps;

  /// No description provided for @dtStepsHelp.
  ///
  /// In en, this message translates to:
  /// **'One step per line'**
  String get dtStepsHelp;

  /// No description provided for @dtTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get dtTags;

  /// No description provided for @dtComputedTags.
  ///
  /// In en, this message translates to:
  /// **'Set from the numbers: {tags}'**
  String dtComputedTags(String tags);

  /// No description provided for @dtPublishRecipe.
  ///
  /// In en, this message translates to:
  /// **'Publish recipe'**
  String get dtPublishRecipe;

  /// No description provided for @inSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get inSessions;

  /// No description provided for @inStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get inStudents;

  /// No description provided for @inLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get inLibrary;

  /// No description provided for @inAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get inAwaitingApproval;

  /// No description provided for @inLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get inLive;

  /// No description provided for @inNextSoon.
  ///
  /// In en, this message translates to:
  /// **'{title} starts {when}'**
  String inNextSoon(String title, String when);

  /// No description provided for @inNoToday.
  ///
  /// In en, this message translates to:
  /// **'No classes today.'**
  String get inNoToday;

  /// No description provided for @inBooked.
  ///
  /// In en, this message translates to:
  /// **'{booked} of {capacity} booked'**
  String inBooked(int booked, int capacity);

  /// No description provided for @inRequests.
  ///
  /// In en, this message translates to:
  /// **'Student requests waiting'**
  String get inRequests;

  /// No description provided for @inAttendanceToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Attendance to confirm'**
  String get inAttendanceToConfirm;

  /// No description provided for @inContentReturned.
  ///
  /// In en, this message translates to:
  /// **'Sessions returned by a reviewer'**
  String get inContentReturned;

  /// No description provided for @inNoBookings.
  ///
  /// In en, this message translates to:
  /// **'Classes this week with no bookings'**
  String get inNoBookings;

  /// No description provided for @inNewClass.
  ///
  /// In en, this message translates to:
  /// **'New class'**
  String get inNewClass;

  /// No description provided for @inNoClasses.
  ///
  /// In en, this message translates to:
  /// **'No classes yet. Schedule one to get started.'**
  String get inNoClasses;

  /// No description provided for @inWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count} waiting'**
  String inWaiting(int count);

  /// No description provided for @inNewRequests.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new request} other{{count} new requests}}'**
  String inNewRequests(int count);

  /// No description provided for @inClass.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get inClass;

  /// No description provided for @inCancelWhy.
  ///
  /// In en, this message translates to:
  /// **'Why are you cancelling?'**
  String get inCancelWhy;

  /// No description provided for @inReasonUnwell.
  ///
  /// In en, this message translates to:
  /// **'I\'m unwell'**
  String get inReasonUnwell;

  /// No description provided for @inReasonEmergency.
  ///
  /// In en, this message translates to:
  /// **'A personal emergency'**
  String get inReasonEmergency;

  /// No description provided for @inReasonTechnical.
  ///
  /// In en, this message translates to:
  /// **'A technical problem'**
  String get inReasonTechnical;

  /// No description provided for @inReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get inReasonOther;

  /// No description provided for @inCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled. Everyone booked has been told and their place returned.'**
  String get inCancelled;

  /// No description provided for @inLateCancellation.
  ///
  /// In en, this message translates to:
  /// **'Cancelled at short notice; this is recorded.'**
  String get inLateCancellation;

  /// No description provided for @inBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get inBookings;

  /// No description provided for @inNoBookingsYet.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet.'**
  String get inNoBookingsYet;

  /// No description provided for @inOnWaitingList.
  ///
  /// In en, this message translates to:
  /// **'on the waiting list'**
  String get inOnWaitingList;

  /// No description provided for @inAttended.
  ///
  /// In en, this message translates to:
  /// **'attended'**
  String get inAttended;

  /// No description provided for @inNotAttended.
  ///
  /// In en, this message translates to:
  /// **'did not attend'**
  String get inNotAttended;

  /// No description provided for @inRequest.
  ///
  /// In en, this message translates to:
  /// **'Request: {choice} {text}'**
  String inRequest(String choice, String text);

  /// No description provided for @inMarkSeen.
  ///
  /// In en, this message translates to:
  /// **'Mark the request as seen'**
  String get inMarkSeen;

  /// No description provided for @inSeen.
  ///
  /// In en, this message translates to:
  /// **'She\'ll see it was seen'**
  String get inSeen;

  /// No description provided for @inCorrected.
  ///
  /// In en, this message translates to:
  /// **'Attendance corrected'**
  String get inCorrected;

  /// No description provided for @inPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get inPublish;

  /// No description provided for @inPublished.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get inPublished;

  /// No description provided for @inChange.
  ///
  /// In en, this message translates to:
  /// **'Change class'**
  String get inChange;

  /// No description provided for @inDeleteDraft.
  ///
  /// In en, this message translates to:
  /// **'Delete draft'**
  String get inDeleteDraft;

  /// No description provided for @inCancelClass.
  ///
  /// In en, this message translates to:
  /// **'Cancel class'**
  String get inCancelClass;

  /// No description provided for @inConfirmAttendance.
  ///
  /// In en, this message translates to:
  /// **'Confirm attendance'**
  String get inConfirmAttendance;

  /// No description provided for @inAttendanceConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Attendance confirmed'**
  String get inAttendanceConfirmed;

  /// No description provided for @inReqFirst.
  ///
  /// In en, this message translates to:
  /// **'First class'**
  String get inReqFirst;

  /// No description provided for @inReqCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera optional'**
  String get inReqCamera;

  /// No description provided for @inReqLate.
  ///
  /// In en, this message translates to:
  /// **'Arriving late'**
  String get inReqLate;

  /// No description provided for @inReqEarly.
  ///
  /// In en, this message translates to:
  /// **'Leaving early'**
  String get inReqEarly;

  /// No description provided for @inReqOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get inReqOther;

  /// No description provided for @inIncomplete.
  ///
  /// In en, this message translates to:
  /// **'A class needs a title, a start, a length and a capacity.'**
  String get inIncomplete;

  /// No description provided for @inTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get inTitle;

  /// No description provided for @inDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get inDescription;

  /// No description provided for @inNoMedicalClaims.
  ///
  /// In en, this message translates to:
  /// **'Say what the practice is and who it suits. No claims to treat a condition.'**
  String get inNoMedicalClaims;

  /// No description provided for @inPickStart.
  ///
  /// In en, this message translates to:
  /// **'Choose the start'**
  String get inPickStart;

  /// No description provided for @inCapacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get inCapacity;

  /// No description provided for @inLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get inLevel;

  /// No description provided for @inPhaseTags.
  ///
  /// In en, this message translates to:
  /// **'Suits these cycle phases'**
  String get inPhaseTags;

  /// No description provided for @inWeekly.
  ///
  /// In en, this message translates to:
  /// **'Repeat weekly'**
  String get inWeekly;

  /// No description provided for @inUntil.
  ///
  /// In en, this message translates to:
  /// **'Repeat until'**
  String get inUntil;

  /// No description provided for @inUntilDate.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String inUntilDate(String date);

  /// No description provided for @inFeeNote.
  ///
  /// In en, this message translates to:
  /// **'The class fee is set by Niraah.'**
  String get inFeeNote;

  /// No description provided for @inRecommend.
  ///
  /// In en, this message translates to:
  /// **'Suggest a recorded session'**
  String get inRecommend;

  /// No description provided for @inNoPublished.
  ///
  /// In en, this message translates to:
  /// **'You have no published sessions yet.'**
  String get inNoPublished;

  /// No description provided for @inRecommended.
  ///
  /// In en, this message translates to:
  /// **'Suggestion sent'**
  String get inRecommended;

  /// No description provided for @inNoStudents.
  ///
  /// In en, this message translates to:
  /// **'Students who book your classes will appear here.'**
  String get inNoStudents;

  /// No description provided for @inAttendedOf.
  ///
  /// In en, this message translates to:
  /// **'attended {attended} of {booked}'**
  String inAttendedOf(int attended, int booked);

  /// No description provided for @inPhase.
  ///
  /// In en, this message translates to:
  /// **'{phase} phase'**
  String inPhase(String phase);

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'{sessions} sessions, {minutes} min this month'**
  String inProgress(int sessions, int minutes);

  /// No description provided for @inInReview.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get inInReview;

  /// No description provided for @inReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get inReturned;

  /// No description provided for @inWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get inWithdrawn;

  /// No description provided for @inNewSession.
  ///
  /// In en, this message translates to:
  /// **'New session'**
  String get inNewSession;

  /// No description provided for @inNoContent.
  ///
  /// In en, this message translates to:
  /// **'Recorded sessions you create will appear here.'**
  String get inNoContent;

  /// No description provided for @inStats.
  ///
  /// In en, this message translates to:
  /// **'{plays} plays, {completions} completed'**
  String inStats(int plays, int completions);

  /// No description provided for @inStatsLong.
  ///
  /// In en, this message translates to:
  /// **'{plays} plays and {completions} completions. Counts only; no member is named.'**
  String inStatsLong(int plays, int completions);

  /// No description provided for @inIntensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get inIntensity;

  /// No description provided for @inProposePregnancy.
  ///
  /// In en, this message translates to:
  /// **'I propose this is pregnancy-safe'**
  String get inProposePregnancy;

  /// No description provided for @inReviewerDecides.
  ///
  /// In en, this message translates to:
  /// **'The reviewer decides the tag.'**
  String get inReviewerDecides;

  /// No description provided for @inRights.
  ///
  /// In en, this message translates to:
  /// **'I own this content and any music in it'**
  String get inRights;

  /// No description provided for @inVideoNotInApp.
  ///
  /// In en, this message translates to:
  /// **'Uploading the video isn\'t in the app yet, so this can\'t be sent for review from here.'**
  String get inVideoNotInApp;

  /// No description provided for @inSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send for review'**
  String get inSubmit;

  /// No description provided for @inSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Sent for review'**
  String get inSubmitted;

  /// No description provided for @inWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw from the library'**
  String get inWithdraw;

  /// No description provided for @inPracticeTypes.
  ///
  /// In en, this message translates to:
  /// **'Practice types'**
  String get inPracticeTypes;

  /// No description provided for @pvApplyLink.
  ///
  /// In en, this message translates to:
  /// **'Doctor, dietitian or yoga instructor? Apply to join'**
  String get pvApplyLink;

  /// No description provided for @paStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get paStatus;

  /// No description provided for @paAsked.
  ///
  /// In en, this message translates to:
  /// **'The team asked for'**
  String get paAsked;

  /// No description provided for @paReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get paReason;

  /// No description provided for @paDetails.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get paDetails;

  /// No description provided for @paName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get paName;

  /// No description provided for @paPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact number'**
  String get paPhone;

  /// No description provided for @paBio.
  ///
  /// In en, this message translates to:
  /// **'Short bio'**
  String get paBio;

  /// No description provided for @paSpecialities.
  ///
  /// In en, this message translates to:
  /// **'Specialities'**
  String get paSpecialities;

  /// No description provided for @paLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get paLanguages;

  /// No description provided for @paCommaHint.
  ///
  /// In en, this message translates to:
  /// **'Separate with commas'**
  String get paCommaHint;

  /// No description provided for @paYears.
  ///
  /// In en, this message translates to:
  /// **'Years of experience'**
  String get paYears;

  /// No description provided for @paRegNumber.
  ///
  /// In en, this message translates to:
  /// **'Registration number'**
  String get paRegNumber;

  /// No description provided for @paRegCouncil.
  ///
  /// In en, this message translates to:
  /// **'Registration council'**
  String get paRegCouncil;

  /// No description provided for @paRegHint.
  ///
  /// In en, this message translates to:
  /// **'Needed for doctors; give it if you have one.'**
  String get paRegHint;

  /// No description provided for @paReferences.
  ///
  /// In en, this message translates to:
  /// **'Professional references'**
  String get paReferences;

  /// No description provided for @paReferencesHint.
  ///
  /// In en, this message translates to:
  /// **'Two references for doctors and dietitians.'**
  String get paReferencesHint;

  /// No description provided for @paRefName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get paRefName;

  /// No description provided for @paRefRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get paRefRole;

  /// No description provided for @paRefContact.
  ///
  /// In en, this message translates to:
  /// **'Email or phone'**
  String get paRefContact;

  /// No description provided for @paSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get paSave;

  /// No description provided for @paSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved.'**
  String get paSaved;

  /// No description provided for @paDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get paDocuments;

  /// No description provided for @paDocumentsHint.
  ///
  /// In en, this message translates to:
  /// **'Photos of your documents, JPEG or PNG, up to 3 MB each. PDFs can be uploaded on the website.'**
  String get paDocumentsHint;

  /// No description provided for @paKindPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get paKindPhoto;

  /// No description provided for @paKindIdentity.
  ///
  /// In en, this message translates to:
  /// **'Government photo identity'**
  String get paKindIdentity;

  /// No description provided for @paKindQualification.
  ///
  /// In en, this message translates to:
  /// **'Qualification certificate'**
  String get paKindQualification;

  /// No description provided for @paKindRegistration.
  ///
  /// In en, this message translates to:
  /// **'Registration certificate'**
  String get paKindRegistration;

  /// No description provided for @paUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get paUpload;

  /// No description provided for @paRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get paRemove;

  /// No description provided for @paTooBig.
  ///
  /// In en, this message translates to:
  /// **'Files can be up to 3 MB.'**
  String get paTooBig;

  /// No description provided for @paTerms.
  ///
  /// In en, this message translates to:
  /// **'I accept the provider terms and code of conduct (version {version}).'**
  String paTerms(String version);

  /// No description provided for @paSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get paSubmit;

  /// No description provided for @paResubmit.
  ///
  /// In en, this message translates to:
  /// **'Send again'**
  String get paResubmit;

  /// No description provided for @paSubmitInactive.
  ///
  /// In en, this message translates to:
  /// **'Add what is still needed first'**
  String get paSubmitInactive;

  /// No description provided for @paSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Sent. We will email you when there is a decision.'**
  String get paSubmitted;

  /// No description provided for @paReapply.
  ///
  /// In en, this message translates to:
  /// **'Apply again'**
  String get paReapply;

  /// No description provided for @paReapplyFrom.
  ///
  /// In en, this message translates to:
  /// **'You can apply again from {date}.'**
  String paReapplyFrom(String date);

  /// No description provided for @paReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Your application is with the team. You can change it if they ask for more information.'**
  String get paReadOnly;

  /// No description provided for @paMissing.
  ///
  /// In en, this message translates to:
  /// **'Still needed'**
  String get paMissing;

  /// No description provided for @signInAs.
  ///
  /// In en, this message translates to:
  /// **'Sign in as'**
  String get signInAs;

  /// No description provided for @signInAsMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get signInAsMember;

  /// No description provided for @signInAsDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get signInAsDoctor;

  /// No description provided for @signInAsDietitian.
  ///
  /// In en, this message translates to:
  /// **'Dietitian'**
  String get signInAsDietitian;

  /// No description provided for @signInAsTrainer.
  ///
  /// In en, this message translates to:
  /// **'Trainer'**
  String get signInAsTrainer;

  /// No description provided for @signInNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get signInNumberLabel;

  /// No description provided for @signInEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signInEmailLabel;

  /// No description provided for @signInStaffBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your work email. Then your password and authenticator code.'**
  String get signInStaffBody;

  /// No description provided for @signInNeedNumber.
  ///
  /// In en, this message translates to:
  /// **'Members sign in with a mobile number.'**
  String get signInNeedNumber;

  /// No description provided for @signInNeedEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get signInNeedEmail;

  /// No description provided for @signInEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number'**
  String get signInEnterNumber;

  /// No description provided for @signInEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get signInEnterEmail;

  /// No description provided for @csTypeDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get csTypeDoctor;

  /// No description provided for @csTypeDietitian.
  ///
  /// In en, this message translates to:
  /// **'Dietitian'**
  String get csTypeDietitian;

  /// No description provided for @csStatusHeld.
  ///
  /// In en, this message translates to:
  /// **'Being booked'**
  String get csStatusHeld;

  /// No description provided for @csStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get csStatusConfirmed;

  /// No description provided for @csStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get csStatusInProgress;

  /// No description provided for @csStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get csStatusCompleted;

  /// No description provided for @csStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get csStatusCancelled;

  /// No description provided for @csStatusNoShow.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t take place'**
  String get csStatusNoShow;

  /// No description provided for @csStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Not completed'**
  String get csStatusExpired;

  /// No description provided for @csCatHealth.
  ///
  /// In en, this message translates to:
  /// **'My health information'**
  String get csCatHealth;

  /// No description provided for @csCatAssessment.
  ///
  /// In en, this message translates to:
  /// **'My assessment and pre-score'**
  String get csCatAssessment;

  /// No description provided for @csCatCycle.
  ///
  /// In en, this message translates to:
  /// **'My cycle and symptoms'**
  String get csCatCycle;

  /// No description provided for @csCatMeals.
  ///
  /// In en, this message translates to:
  /// **'My meals'**
  String get csCatMeals;

  /// No description provided for @csCatLabs.
  ///
  /// In en, this message translates to:
  /// **'My lab reports'**
  String get csCatLabs;

  /// No description provided for @csCatMessages.
  ///
  /// In en, this message translates to:
  /// **'My messages'**
  String get csCatMessages;

  /// No description provided for @csEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get csEarlier;

  /// No description provided for @csLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get csLater;

  /// No description provided for @csNoTimesThisWeek.
  ///
  /// In en, this message translates to:
  /// **'No free times in these days.'**
  String get csNoTimesThisWeek;

  /// No description provided for @csChooseTime.
  ///
  /// In en, this message translates to:
  /// **'Choose {time}'**
  String csChooseTime(String time);

  /// No description provided for @csWellness.
  ///
  /// In en, this message translates to:
  /// **'A consult is how you reach a doctor or dietitian through Niraah. Niraah supports your wellbeing and does not replace your own doctor. For anything urgent, seek care near you.'**
  String get csWellness;

  /// No description provided for @csFindTitle.
  ///
  /// In en, this message translates to:
  /// **'Find a specialist'**
  String get csFindTitle;

  /// No description provided for @csAppointmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get csAppointmentsTitle;

  /// No description provided for @csNoneBookable.
  ///
  /// In en, this message translates to:
  /// **'No specialist has free time right now. Please look again later.'**
  String get csNoneBookable;

  /// No description provided for @csNoneFound.
  ///
  /// In en, this message translates to:
  /// **'No specialist matches these filters.'**
  String get csNoneFound;

  /// No description provided for @csClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get csClearFilters;

  /// No description provided for @csGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Not sure who to see?'**
  String get csGuideTitle;

  /// No description provided for @csGuideBody.
  ///
  /// In en, this message translates to:
  /// **'Tell us what\'s on your mind and we\'ll suggest a kind of specialist.'**
  String get csGuideBody;

  /// No description provided for @csIncludedUnlimited.
  ///
  /// In en, this message translates to:
  /// **'{type} consults are included in your plan'**
  String csIncludedUnlimited(String type);

  /// No description provided for @csIncludedLeft.
  ///
  /// In en, this message translates to:
  /// **'{type} consults included: {count} left'**
  String csIncludedLeft(String type, int count);

  /// No description provided for @csIncludedPooled.
  ///
  /// In en, this message translates to:
  /// **'Choose a time and you\'ll see an available {type}.'**
  String csIncludedPooled(String type);

  /// No description provided for @csChooseATime.
  ///
  /// In en, this message translates to:
  /// **'Choose a time'**
  String get csChooseATime;

  /// No description provided for @csIncludedUsedUp.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used this period\'s included consults. You can still book a consult with a fee.'**
  String get csIncludedUsedUp;

  /// No description provided for @csIncludedRefills.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used this period\'s included consults. They refill on {date}.'**
  String csIncludedRefills(String date);

  /// No description provided for @csFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get csFilterAll;

  /// No description provided for @csFilterDoctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get csFilterDoctors;

  /// No description provided for @csFilterDietitians.
  ///
  /// In en, this message translates to:
  /// **'Dietitians'**
  String get csFilterDietitians;

  /// No description provided for @csMoreFilters.
  ///
  /// In en, this message translates to:
  /// **'More filters'**
  String get csMoreFilters;

  /// No description provided for @csMoreFiltersOn.
  ///
  /// In en, this message translates to:
  /// **'More filters ({count})'**
  String csMoreFiltersOn(int count);

  /// No description provided for @csFilterSpeciality.
  ///
  /// In en, this message translates to:
  /// **'Speciality'**
  String get csFilterSpeciality;

  /// No description provided for @csFilterLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get csFilterLanguage;

  /// No description provided for @csFilterDay.
  ///
  /// In en, this message translates to:
  /// **'Any day'**
  String get csFilterDay;

  /// No description provided for @csFilterDayOn.
  ///
  /// In en, this message translates to:
  /// **'Free on {date}'**
  String csFilterDayOn(String date);

  /// No description provided for @csApplyFilters.
  ///
  /// In en, this message translates to:
  /// **'Show specialists'**
  String get csApplyFilters;

  /// No description provided for @csYears.
  ///
  /// In en, this message translates to:
  /// **'{years} years\' experience'**
  String csYears(int years);

  /// No description provided for @csSpeaks.
  ///
  /// In en, this message translates to:
  /// **'Speaks {languages}'**
  String csSpeaks(String languages);

  /// No description provided for @csNextFree.
  ///
  /// In en, this message translates to:
  /// **'Next free: {time}'**
  String csNextFree(String time);

  /// No description provided for @csFee.
  ///
  /// In en, this message translates to:
  /// **'{amount} incl. GST'**
  String csFee(String amount);

  /// No description provided for @csRating.
  ///
  /// In en, this message translates to:
  /// **'Rated {average} by {count} members'**
  String csRating(String average, int count);

  /// No description provided for @csGuideIntro.
  ///
  /// In en, this message translates to:
  /// **'Describe your concern in a few words. We suggest a kind of specialist; we never name a person or a diagnosis.'**
  String get csGuideIntro;

  /// No description provided for @csGuideConcern.
  ///
  /// In en, this message translates to:
  /// **'What would you like help with?'**
  String get csGuideConcern;

  /// No description provided for @csGuideAsk.
  ///
  /// In en, this message translates to:
  /// **'Suggest a specialist'**
  String get csGuideAsk;

  /// No description provided for @csGuideAnswer.
  ///
  /// In en, this message translates to:
  /// **'You could see'**
  String get csGuideAnswer;

  /// No description provided for @csGuideNone.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t suggest a kind of specialist for this. A doctor is a good place to start.'**
  String get csGuideNone;

  /// No description provided for @csGuideByAi.
  ///
  /// In en, this message translates to:
  /// **'Suggested by AI. AI insights do not replace medical advice.'**
  String get csGuideByAi;

  /// No description provided for @csProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Specialist'**
  String get csProfileTitle;

  /// No description provided for @csTimes.
  ///
  /// In en, this message translates to:
  /// **'Free times'**
  String get csTimes;

  /// No description provided for @csNoTimes.
  ///
  /// In en, this message translates to:
  /// **'No times available right now.'**
  String get csNoTimes;

  /// No description provided for @csIncludedThis.
  ///
  /// In en, this message translates to:
  /// **'Included in your plan'**
  String get csIncludedThis;

  /// No description provided for @csSeeOtherClinicians.
  ///
  /// In en, this message translates to:
  /// **'See other times'**
  String get csSeeOtherClinicians;

  /// No description provided for @csRegistration.
  ///
  /// In en, this message translates to:
  /// **'Registration {number}, {council}'**
  String csRegistration(String number, String council);

  /// No description provided for @csPooledTitle.
  ///
  /// In en, this message translates to:
  /// **'{type} consult'**
  String csPooledTitle(String type);

  /// No description provided for @csPooledNote.
  ///
  /// In en, this message translates to:
  /// **'Choose a time. You\'ll see which {type} you\'re seeing as soon as you confirm.'**
  String csPooledNote(String type);

  /// No description provided for @csIncludedNone.
  ///
  /// In en, this message translates to:
  /// **'This consult isn\'t included in your plan right now.'**
  String get csIncludedNone;

  /// No description provided for @csBooked.
  ///
  /// In en, this message translates to:
  /// **'Your consult is booked.'**
  String get csBooked;

  /// No description provided for @csAssignedOnConfirm.
  ///
  /// In en, this message translates to:
  /// **'An available {type}, named when you confirm'**
  String csAssignedOnConfirm(String type);

  /// No description provided for @csYourClinician.
  ///
  /// In en, this message translates to:
  /// **'Your clinician'**
  String get csYourClinician;

  /// No description provided for @csConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your consult'**
  String get csConfirmTitle;

  /// No description provided for @csHoldExpired.
  ///
  /// In en, this message translates to:
  /// **'Your hold has ended. Choose a time again.'**
  String get csHoldExpired;

  /// No description provided for @csHoldLeft.
  ///
  /// In en, this message translates to:
  /// **'This time is held for you for {time}.'**
  String csHoldLeft(String time);

  /// No description provided for @csConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'What may your clinician see?'**
  String get csConsentTitle;

  /// No description provided for @csConsentBody.
  ///
  /// In en, this message translates to:
  /// **'Choose what this clinician may see for this consult. You can change it until the consult starts.'**
  String get csConsentBody;

  /// No description provided for @csConsentNone.
  ///
  /// In en, this message translates to:
  /// **'If you share nothing, your clinician has only what you tell them in the call.'**
  String get csConsentNone;

  /// No description provided for @csReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Reason for the visit'**
  String get csReasonTitle;

  /// No description provided for @csReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'In a few words (optional)'**
  String get csReasonLabel;

  /// No description provided for @csReasonHelp.
  ///
  /// In en, this message translates to:
  /// **'Only your clinician sees this.'**
  String get csReasonHelp;

  /// No description provided for @csChooseAnotherTime.
  ///
  /// In en, this message translates to:
  /// **'Choose another time'**
  String get csChooseAnotherTime;

  /// No description provided for @csConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm consult'**
  String get csConfirm;

  /// No description provided for @csRelease.
  ///
  /// In en, this message translates to:
  /// **'Give this time back'**
  String get csRelease;

  /// No description provided for @csBookAction.
  ///
  /// In en, this message translates to:
  /// **'Book a consult'**
  String get csBookAction;

  /// No description provided for @csUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get csUpcoming;

  /// No description provided for @csNoUpcoming.
  ///
  /// In en, this message translates to:
  /// **'No consults coming up. When you book one, it appears here.'**
  String get csNoUpcoming;

  /// No description provided for @csPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get csPast;

  /// No description provided for @csAppointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Consult'**
  String get csAppointmentTitle;

  /// No description provided for @csOutcomeReleased.
  ///
  /// In en, this message translates to:
  /// **'The time is free again.'**
  String get csOutcomeReleased;

  /// No description provided for @csOutcomeRefunded.
  ///
  /// In en, this message translates to:
  /// **'Cancelled. Your payment is being refunded in full.'**
  String get csOutcomeRefunded;

  /// No description provided for @csOutcomeUnitReturned.
  ///
  /// In en, this message translates to:
  /// **'Cancelled. The consult is back in your plan.'**
  String get csOutcomeUnitReturned;

  /// No description provided for @csOutcomeKept.
  ///
  /// In en, this message translates to:
  /// **'Cancelled. As it was close to the start, the fee or included consult is used.'**
  String get csOutcomeKept;

  /// No description provided for @csOutcomeMoved.
  ///
  /// In en, this message translates to:
  /// **'Your consult has a new time.'**
  String get csOutcomeMoved;

  /// No description provided for @csOutcomeRated.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your rating.'**
  String get csOutcomeRated;

  /// No description provided for @csOutcomeDone.
  ///
  /// In en, this message translates to:
  /// **'Done.'**
  String get csOutcomeDone;

  /// No description provided for @csFailureWaiting.
  ///
  /// In en, this message translates to:
  /// **'Thank you. Our team will look at what happened and let you know.'**
  String get csFailureWaiting;

  /// No description provided for @csFailureChoice.
  ///
  /// In en, this message translates to:
  /// **'The call didn\'t work. You can take another time or get your money or consult back.'**
  String get csFailureChoice;

  /// No description provided for @csKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get csKeep;

  /// No description provided for @csRescheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Move your consult'**
  String get csRescheduleTitle;

  /// No description provided for @csRescheduleNote.
  ///
  /// In en, this message translates to:
  /// **'No charge. You can move it {count} more times.'**
  String csRescheduleNote(int count);

  /// No description provided for @csRebookTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose another time'**
  String get csRebookTitle;

  /// No description provided for @csRebookNote.
  ///
  /// In en, this message translates to:
  /// **'What you paid or used carries over to the new time.'**
  String get csRebookNote;

  /// No description provided for @csReleaseBody.
  ///
  /// In en, this message translates to:
  /// **'This time will be free for others again.'**
  String get csReleaseBody;

  /// No description provided for @csCancelBodyIncluded.
  ///
  /// In en, this message translates to:
  /// **'If you cancel well ahead, the consult goes back to your plan; close to the start it counts as used. You\'ll see which straight away.'**
  String get csCancelBodyIncluded;

  /// No description provided for @csCancelBodyPaid.
  ///
  /// In en, this message translates to:
  /// **'If you cancel well ahead, you get a full refund; close to the start there\'s no refund. You\'ll see which straight away.'**
  String get csCancelBodyPaid;

  /// No description provided for @csCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this consult?'**
  String get csCancelTitle;

  /// No description provided for @csCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel consult'**
  String get csCancelAction;

  /// No description provided for @csProposalTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept the new time?'**
  String get csProposalTitle;

  /// No description provided for @csProposalBody.
  ///
  /// In en, this message translates to:
  /// **'Your consult moves to the time your clinician suggested.'**
  String get csProposalBody;

  /// No description provided for @csProposalAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get csProposalAccept;

  /// No description provided for @csProposalLink.
  ///
  /// In en, this message translates to:
  /// **'My clinician suggested another time'**
  String get csProposalLink;

  /// No description provided for @csDeclineTitle.
  ///
  /// In en, this message translates to:
  /// **'Get your money or consult back?'**
  String get csDeclineTitle;

  /// No description provided for @csDeclineBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll refund what you paid, or return the consult to your plan.'**
  String get csDeclineBody;

  /// No description provided for @csDeclineAction.
  ///
  /// In en, this message translates to:
  /// **'Get my money or consult back'**
  String get csDeclineAction;

  /// No description provided for @csReportTitle.
  ///
  /// In en, this message translates to:
  /// **'The call didn\'t work?'**
  String get csReportTitle;

  /// No description provided for @csReportBody.
  ///
  /// In en, this message translates to:
  /// **'Tell us and we\'ll look at what happened in the room.'**
  String get csReportBody;

  /// No description provided for @csReportAction.
  ///
  /// In en, this message translates to:
  /// **'The call didn\'t work'**
  String get csReportAction;

  /// No description provided for @csPaidIncluded.
  ///
  /// In en, this message translates to:
  /// **'Included in your plan'**
  String get csPaidIncluded;

  /// No description provided for @csPaidFee.
  ///
  /// In en, this message translates to:
  /// **'Fee {amount} incl. GST'**
  String csPaidFee(String amount);

  /// No description provided for @csRecordingOn.
  ///
  /// In en, this message translates to:
  /// **'This consult is recorded, as you agreed.'**
  String get csRecordingOn;

  /// No description provided for @csFinishBooking.
  ///
  /// In en, this message translates to:
  /// **'Finish booking'**
  String get csFinishBooking;

  /// No description provided for @csRoomOpensAt.
  ///
  /// In en, this message translates to:
  /// **'The room opens at {time}.'**
  String csRoomOpensAt(String time);

  /// No description provided for @csJoin.
  ///
  /// In en, this message translates to:
  /// **'Join the consult'**
  String get csJoin;

  /// No description provided for @csReschedule.
  ///
  /// In en, this message translates to:
  /// **'Move to another time'**
  String get csReschedule;

  /// No description provided for @csNoShowOffer.
  ///
  /// In en, this message translates to:
  /// **'Your clinician didn\'t join. Take another time, or get your money or consult back.'**
  String get csNoShowOffer;

  /// No description provided for @csRebook.
  ///
  /// In en, this message translates to:
  /// **'Choose another time'**
  String get csRebook;

  /// No description provided for @csRate.
  ///
  /// In en, this message translates to:
  /// **'Rate this consult'**
  String get csRate;

  /// No description provided for @csBookAgain.
  ///
  /// In en, this message translates to:
  /// **'Book again'**
  String get csBookAgain;

  /// No description provided for @csRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate your consult'**
  String get csRateTitle;

  /// No description provided for @csRateBody.
  ///
  /// In en, this message translates to:
  /// **'How was your consult? Your name is never shown with your rating.'**
  String get csRateBody;

  /// No description provided for @csRateStars.
  ///
  /// In en, this message translates to:
  /// **'{count} out of 5'**
  String csRateStars(int count);

  /// No description provided for @csRateComment.
  ///
  /// In en, this message translates to:
  /// **'Anything you\'d like to add (optional)'**
  String get csRateComment;

  /// No description provided for @csRateSend.
  ///
  /// In en, this message translates to:
  /// **'Send rating'**
  String get csRateSend;

  /// No description provided for @csRateChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose a rating to continue'**
  String get csRateChoose;

  /// No description provided for @csRecordingStopped.
  ///
  /// In en, this message translates to:
  /// **'Recording stopped. What was recorded is kept as partial.'**
  String get csRecordingStopped;

  /// No description provided for @csRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Consult room'**
  String get csRoomTitle;

  /// No description provided for @csRecordingMark.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get csRecordingMark;

  /// No description provided for @csRecordingBody.
  ///
  /// In en, this message translates to:
  /// **'This consult is being recorded as you agreed. You can stop it at any time.'**
  String get csRecordingBody;

  /// No description provided for @csRecordingStop.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get csRecordingStop;

  /// No description provided for @csRoomNotOpen.
  ///
  /// In en, this message translates to:
  /// **'The room isn\'t open yet'**
  String get csRoomNotOpen;

  /// No description provided for @csRoomCheckAgain.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get csRoomCheckAgain;

  /// No description provided for @billTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage plan'**
  String get billTitle;

  /// No description provided for @billStatusTrial.
  ///
  /// In en, this message translates to:
  /// **'Free trial'**
  String get billStatusTrial;

  /// No description provided for @billStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get billStatusActive;

  /// No description provided for @billStatusPastDue.
  ///
  /// In en, this message translates to:
  /// **'Payment didn\'t go through'**
  String get billStatusPastDue;

  /// No description provided for @billStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment'**
  String get billStatusPending;

  /// No description provided for @billCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel your plan?'**
  String get billCancelTitle;

  /// No description provided for @billCancelBody.
  ///
  /// In en, this message translates to:
  /// **'You keep {plan} until {date}. No further charge is made, and there\'s no refund for the current period. You can undo this until then.'**
  String billCancelBody(String plan, String date);

  /// No description provided for @billCancelBodyNoDate.
  ///
  /// In en, this message translates to:
  /// **'You keep {plan} until the end of the current period. No further charge is made, and there\'s no refund for the current period.'**
  String billCancelBodyNoDate(String plan);

  /// No description provided for @billKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep my plan'**
  String get billKeep;

  /// No description provided for @billCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel plan'**
  String get billCancelAction;

  /// No description provided for @billCancelled.
  ///
  /// In en, this message translates to:
  /// **'Your plan ends on {date}. No further charge will be made.'**
  String billCancelled(String date);

  /// No description provided for @billUndone.
  ///
  /// In en, this message translates to:
  /// **'Your plan continues.'**
  String get billUndone;

  /// No description provided for @billChangeLater.
  ///
  /// In en, this message translates to:
  /// **'Your new plan starts on {date}. Until then you keep your current plan.'**
  String billChangeLater(String date);

  /// No description provided for @billChangeDone.
  ///
  /// In en, this message translates to:
  /// **'Your new plan is in force.'**
  String get billChangeDone;

  /// No description provided for @billEndsOn.
  ///
  /// In en, this message translates to:
  /// **'Ends on {date}'**
  String billEndsOn(String date);

  /// No description provided for @billRenewsOn.
  ///
  /// In en, this message translates to:
  /// **'Renews on {date}'**
  String billRenewsOn(String date);

  /// No description provided for @billValidUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}'**
  String billValidUntil(String date);

  /// No description provided for @billNoSubscription.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have a paid plan.'**
  String get billNoSubscription;

  /// No description provided for @billChange.
  ///
  /// In en, this message translates to:
  /// **'Change plan'**
  String get billChange;

  /// No description provided for @billUndo.
  ///
  /// In en, this message translates to:
  /// **'Keep my plan after all'**
  String get billUndo;

  /// No description provided for @billInvoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get billInvoices;

  /// No description provided for @billInvoicesOpen.
  ///
  /// In en, this message translates to:
  /// **'Invoices and credit notes'**
  String get billInvoicesOpen;

  /// No description provided for @billChangeNote.
  ///
  /// In en, this message translates to:
  /// **'A plan that costs more starts when its payment goes through. One that costs less starts when your current period ends.'**
  String get billChangeNote;

  /// No description provided for @billNoOtherPlans.
  ///
  /// In en, this message translates to:
  /// **'There are no other plans to move to.'**
  String get billNoOtherPlans;

  /// No description provided for @billPriceLine.
  ///
  /// In en, this message translates to:
  /// **'{amount} incl. GST'**
  String billPriceLine(String amount);

  /// No description provided for @billNoInvoices.
  ///
  /// In en, this message translates to:
  /// **'No invoices yet. Each payment\'s invoice appears here.'**
  String get billNoInvoices;

  /// No description provided for @billCreditNote.
  ///
  /// In en, this message translates to:
  /// **'Credit note'**
  String get billCreditNote;

  /// No description provided for @billInvoice.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get billInvoice;

  /// No description provided for @billFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get billFrom;

  /// No description provided for @billGstin.
  ///
  /// In en, this message translates to:
  /// **'GSTIN {number}'**
  String billGstin(String number);

  /// No description provided for @billTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get billTo;

  /// No description provided for @billLines.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get billLines;

  /// No description provided for @billBeforeTax.
  ///
  /// In en, this message translates to:
  /// **'Before tax'**
  String get billBeforeTax;

  /// No description provided for @billTax.
  ///
  /// In en, this message translates to:
  /// **'GST at {rate}%'**
  String billTax(String rate);

  /// No description provided for @billLineTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get billLineTotal;

  /// No description provided for @billTotalTax.
  ///
  /// In en, this message translates to:
  /// **'Total GST'**
  String get billTotalTax;

  /// No description provided for @billTotal.
  ///
  /// In en, this message translates to:
  /// **'Amount paid'**
  String get billTotal;

  /// No description provided for @waTitle.
  ///
  /// In en, this message translates to:
  /// **'Wellness advice from your doctor'**
  String get waTitle;

  /// No description provided for @waEmpty.
  ///
  /// In en, this message translates to:
  /// **'Wellness advice from a doctor after a consult appears here.'**
  String get waEmpty;

  /// No description provided for @waReplaced.
  ///
  /// In en, this message translates to:
  /// **'A newer advice replaces this one.'**
  String get waReplaced;

  /// No description provided for @waAssessment.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get waAssessment;

  /// No description provided for @waSupplements.
  ///
  /// In en, this message translates to:
  /// **'Supplements'**
  String get waSupplements;

  /// No description provided for @waAdvice.
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get waAdvice;

  /// No description provided for @waSeeDoctor.
  ///
  /// In en, this message translates to:
  /// **'See a doctor in person'**
  String get waSeeDoctor;

  /// No description provided for @waFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get waFollowUp;

  /// No description provided for @waTests.
  ///
  /// In en, this message translates to:
  /// **'Tests advised'**
  String get waTests;

  /// No description provided for @waCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code {code}'**
  String waCode(String code);

  /// No description provided for @waOpenDocument.
  ///
  /// In en, this message translates to:
  /// **'Open the document'**
  String get waOpenDocument;

  /// No description provided for @acctDevicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Signed-in devices'**
  String get acctDevicesTitle;

  /// No description provided for @acctDevicesBody.
  ///
  /// In en, this message translates to:
  /// **'Where your account is signed in. End any you don\'t recognise.'**
  String get acctDevicesBody;

  /// No description provided for @acctDevicesOpen.
  ///
  /// In en, this message translates to:
  /// **'See signed-in devices'**
  String get acctDevicesOpen;

  /// No description provided for @acctThisDevice.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get acctThisDevice;

  /// No description provided for @acctLastActive.
  ///
  /// In en, this message translates to:
  /// **'Last active {time}'**
  String acctLastActive(String time);

  /// No description provided for @acctEnd.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get acctEnd;

  /// No description provided for @acctEnded.
  ///
  /// In en, this message translates to:
  /// **'That device is signed out.'**
  String get acctEnded;

  /// No description provided for @acctEndAll.
  ///
  /// In en, this message translates to:
  /// **'Sign out everywhere'**
  String get acctEndAll;

  /// No description provided for @acctEndAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out everywhere?'**
  String get acctEndAllTitle;

  /// No description provided for @acctEndAllBody.
  ///
  /// In en, this message translates to:
  /// **'Every device, this one included, is signed out. You\'ll sign in again with a code.'**
  String get acctEndAllBody;

  /// No description provided for @acctChangeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change mobile number'**
  String get acctChangeNumber;

  /// No description provided for @acctNumberTitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get acctNumberTitle;

  /// No description provided for @acctNumberBody.
  ///
  /// In en, this message translates to:
  /// **'First we check it\'s you with a code to your current number. Then enter your new number and the code we send to it.'**
  String get acctNumberBody;

  /// No description provided for @acctNewNumber.
  ///
  /// In en, this message translates to:
  /// **'New mobile number'**
  String get acctNewNumber;

  /// No description provided for @acctSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send a code to the new number'**
  String get acctSendCode;

  /// No description provided for @acctCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Enter the code we sent to your new number.'**
  String get acctCodeSent;

  /// No description provided for @acctConfirmNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get acctConfirmNumber;

  /// No description provided for @acctNumberChanged.
  ///
  /// In en, this message translates to:
  /// **'Your number is changed. Other devices are signed out.'**
  String get acctNumberChanged;

  /// No description provided for @acctPendingChange.
  ///
  /// In en, this message translates to:
  /// **'A change to a number ending {ending} takes effect on {date}.'**
  String acctPendingChange(String ending, String date);

  /// No description provided for @acctCancelChange.
  ///
  /// In en, this message translates to:
  /// **'This wasn\'t me: cancel it'**
  String get acctCancelChange;

  /// No description provided for @acctChangeCancelled.
  ///
  /// In en, this message translates to:
  /// **'The change is cancelled.'**
  String get acctChangeCancelled;

  /// No description provided for @acctEmailBody.
  ///
  /// In en, this message translates to:
  /// **'A recovery email helps you get back into your account if you lose your number. It counts once you open the link we send to it. It can\'t be used to sign in.'**
  String get acctEmailBody;

  /// No description provided for @acctEmailNow.
  ///
  /// In en, this message translates to:
  /// **'Now: {email}'**
  String acctEmailNow(String email);

  /// No description provided for @acctEmailAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a recovery email'**
  String get acctEmailAdd;

  /// No description provided for @acctEmailNew.
  ///
  /// In en, this message translates to:
  /// **'New recovery email'**
  String get acctEmailNew;

  /// No description provided for @acctEmailChange.
  ///
  /// In en, this message translates to:
  /// **'Change recovery email'**
  String get acctEmailChange;

  /// No description provided for @acctEmailSave.
  ///
  /// In en, this message translates to:
  /// **'Send the link'**
  String get acctEmailSave;

  /// No description provided for @acctEmailSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a link. Open it to finish.'**
  String get acctEmailSent;

  /// No description provided for @acctEmailRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove recovery email'**
  String get acctEmailRemove;

  /// No description provided for @acctEmailRemoved.
  ///
  /// In en, this message translates to:
  /// **'Recovery email removed.'**
  String get acctEmailRemoved;

  /// No description provided for @mealsHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal history'**
  String get mealsHistoryTitle;

  /// No description provided for @mealsHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'The days you log meals appear here.'**
  String get mealsHistoryEmpty;

  /// No description provided for @mealsHistoryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 meal} other{{count} meals}}'**
  String mealsHistoryCount(int count);

  /// No description provided for @mealPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'My meal plan'**
  String get mealPlanTitle;

  /// No description provided for @mealPlanNone.
  ///
  /// In en, this message translates to:
  /// **'When your dietitian shares a meal plan with you, it appears here.'**
  String get mealPlanNone;

  /// No description provided for @mealPlanBy.
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String mealPlanBy(String name);

  /// No description provided for @mealPlanPrevDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get mealPlanPrevDay;

  /// No description provided for @mealPlanNextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get mealPlanNextDay;

  /// No description provided for @mealPlanDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day} · {date}'**
  String mealPlanDay(int day, String date);

  /// No description provided for @mealPlanOr.
  ///
  /// In en, this message translates to:
  /// **'Or: {options}'**
  String mealPlanOr(String options);

  /// No description provided for @mealPlanSlotEarly.
  ///
  /// In en, this message translates to:
  /// **'Early morning'**
  String get mealPlanSlotEarly;

  /// No description provided for @mealPlanSlotMidMorning.
  ///
  /// In en, this message translates to:
  /// **'Mid-morning'**
  String get mealPlanSlotMidMorning;

  /// No description provided for @mealPlanSlotEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening snack'**
  String get mealPlanSlotEvening;

  /// No description provided for @mealPlanSlotBedtime.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get mealPlanSlotBedtime;

  /// No description provided for @rmPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera and microphone'**
  String get rmPermissionTitle;

  /// No description provided for @rmPermissionWhy.
  ///
  /// In en, this message translates to:
  /// **'To see and hear each other, the app will ask to use your camera and microphone. They\'re used only during this call, and you can turn either off at any time.'**
  String get rmPermissionWhy;

  /// No description provided for @rmAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow camera and microphone'**
  String get rmAllow;

  /// No description provided for @rmAudioOnlyPermission.
  ///
  /// In en, this message translates to:
  /// **'We could use your microphone but not your camera. You can still join by voice.'**
  String get rmAudioOnlyPermission;

  /// No description provided for @rmDenied.
  ///
  /// In en, this message translates to:
  /// **'The camera and microphone are blocked for Niraah. Allow them in your phone\'s settings, then try again.'**
  String get rmDenied;

  /// No description provided for @rmOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get rmOpenSettings;

  /// No description provided for @rmCameraOff.
  ///
  /// In en, this message translates to:
  /// **'Camera off'**
  String get rmCameraOff;

  /// No description provided for @rmJoinNow.
  ///
  /// In en, this message translates to:
  /// **'Join now'**
  String get rmJoinNow;

  /// No description provided for @rmJoining.
  ///
  /// In en, this message translates to:
  /// **'Joining…'**
  String get rmJoining;

  /// No description provided for @rmWithClinician.
  ///
  /// In en, this message translates to:
  /// **'Your consult with {name}'**
  String rmWithClinician(String name);

  /// No description provided for @rmYourClinician.
  ///
  /// In en, this message translates to:
  /// **'your clinician'**
  String get rmYourClinician;

  /// No description provided for @rmWaitingFor.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name}…'**
  String rmWaitingFor(String name);

  /// No description provided for @rmWaitingNote.
  ///
  /// In en, this message translates to:
  /// **'They know you\'re here. You can stay on this screen.'**
  String get rmWaitingNote;

  /// No description provided for @rmStartsAt.
  ///
  /// In en, this message translates to:
  /// **'Starts at {time}'**
  String rmStartsAt(String time);

  /// No description provided for @rmReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get rmReconnecting;

  /// No description provided for @rmReconnectingNote.
  ///
  /// In en, this message translates to:
  /// **'Your connection dropped. We\'re getting you back in; you don\'t need to do anything.'**
  String get rmReconnectingNote;

  /// No description provided for @rmDropped.
  ///
  /// In en, this message translates to:
  /// **'You\'re no longer connected.'**
  String get rmDropped;

  /// No description provided for @rmRejoin.
  ///
  /// In en, this message translates to:
  /// **'Rejoin'**
  String get rmRejoin;

  /// No description provided for @rmWeak.
  ///
  /// In en, this message translates to:
  /// **'Your connection is weak. Switching to audio only can keep the call clear.'**
  String get rmWeak;

  /// No description provided for @rmSwitchAudioOnly.
  ///
  /// In en, this message translates to:
  /// **'Switch to audio only'**
  String get rmSwitchAudioOnly;

  /// No description provided for @rmAudioOnlyOn.
  ///
  /// In en, this message translates to:
  /// **'Audio only is on: your camera is off and incoming video is paused.'**
  String get rmAudioOnlyOn;

  /// No description provided for @rmVideoBack.
  ///
  /// In en, this message translates to:
  /// **'Turn video back on'**
  String get rmVideoBack;

  /// No description provided for @rmMicMute.
  ///
  /// In en, this message translates to:
  /// **'Mute microphone'**
  String get rmMicMute;

  /// No description provided for @rmMicUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute microphone'**
  String get rmMicUnmute;

  /// No description provided for @rmCameraTurnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn camera off'**
  String get rmCameraTurnOff;

  /// No description provided for @rmCameraTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn camera on'**
  String get rmCameraTurnOn;

  /// No description provided for @rmSwitchCamera.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get rmSwitchCamera;

  /// No description provided for @rmLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get rmLeave;

  /// No description provided for @rmLeaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave the room? You can come back while the room is open.'**
  String get rmLeaveConfirm;

  /// No description provided for @rmStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get rmStay;

  /// No description provided for @rmLeft.
  ///
  /// In en, this message translates to:
  /// **'You\'ve left the room.'**
  String get rmLeft;

  /// No description provided for @rmClosed.
  ///
  /// In en, this message translates to:
  /// **'The room has closed.'**
  String get rmClosed;

  /// No description provided for @rmGoBackIn.
  ///
  /// In en, this message translates to:
  /// **'Go back in'**
  String get rmGoBackIn;

  /// No description provided for @rmRemaining.
  ///
  /// In en, this message translates to:
  /// **'{time} left'**
  String rmRemaining(String time);

  /// No description provided for @rmTimeUp.
  ///
  /// In en, this message translates to:
  /// **'Time is up · room closes in {time}'**
  String rmTimeUp(String time);

  /// No description provided for @rmJoinFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t connect you to the room. Check your connection and try again.'**
  String get rmJoinFailed;

  /// No description provided for @rmLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open this room. Try again in a moment.'**
  String get rmLoadError;

  /// No description provided for @rmYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get rmYou;

  /// No description provided for @dcLink.
  ///
  /// In en, this message translates to:
  /// **'Check camera and microphone'**
  String get dcLink;

  /// No description provided for @dcTitle.
  ///
  /// In en, this message translates to:
  /// **'Device check'**
  String get dcTitle;

  /// No description provided for @dcBody.
  ///
  /// In en, this message translates to:
  /// **'Check that your camera, microphone and connection work before your consult.'**
  String get dcBody;

  /// No description provided for @dcStart.
  ///
  /// In en, this message translates to:
  /// **'Start the check'**
  String get dcStart;

  /// No description provided for @dcCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get dcCamera;

  /// No description provided for @dcCameraOk.
  ///
  /// In en, this message translates to:
  /// **'Your camera works if you can see yourself above.'**
  String get dcCameraOk;

  /// No description provided for @dcBlocked.
  ///
  /// In en, this message translates to:
  /// **'Not allowed. You can allow it in your phone\'s settings.'**
  String get dcBlocked;

  /// No description provided for @dcMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get dcMicrophone;

  /// No description provided for @dcMicSpeak.
  ///
  /// In en, this message translates to:
  /// **'Say something: the bar moves when your microphone hears you.'**
  String get dcMicSpeak;

  /// No description provided for @dcConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get dcConnection;

  /// No description provided for @dcTesting.
  ///
  /// In en, this message translates to:
  /// **'Testing…'**
  String get dcTesting;

  /// No description provided for @dcGood.
  ///
  /// In en, this message translates to:
  /// **'Good for video'**
  String get dcGood;

  /// No description provided for @dcPoor.
  ///
  /// In en, this message translates to:
  /// **'Weak: video may look soft, but voice should work'**
  String get dcPoor;

  /// No description provided for @dcDown.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get dcDown;

  /// No description provided for @dcAllowedOnly.
  ///
  /// In en, this message translates to:
  /// **'Your camera and microphone are allowed. The preview and connection test run in the room before you join.'**
  String get dcAllowedOnly;

  /// No description provided for @dcFailed.
  ///
  /// In en, this message translates to:
  /// **'The check couldn\'t start. Try again in a moment.'**
  String get dcFailed;

  /// No description provided for @clRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Live class'**
  String get clRoomTitle;

  /// No description provided for @clPrivacy.
  ///
  /// In en, this message translates to:
  /// **'You join with your camera and microphone off. Other members can\'t see or hear you, or see your name.'**
  String get clPrivacy;

  /// No description provided for @clWaitingInstructor.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your instructor…'**
  String get clWaitingInstructor;

  /// No description provided for @clCameraOn.
  ///
  /// In en, this message translates to:
  /// **'Show my camera to the instructor'**
  String get clCameraOn;

  /// No description provided for @clCameraOff.
  ///
  /// In en, this message translates to:
  /// **'Turn my camera off'**
  String get clCameraOff;

  /// No description provided for @clCameraNote.
  ///
  /// In en, this message translates to:
  /// **'Only your instructor sees your camera, so she can help with your posture.'**
  String get clCameraNote;

  /// No description provided for @clCameraSharing.
  ///
  /// In en, this message translates to:
  /// **'Your instructor can see your camera.'**
  String get clCameraSharing;

  /// No description provided for @clYourClasses.
  ///
  /// In en, this message translates to:
  /// **'Your classes'**
  String get clYourClasses;

  /// No description provided for @clJoin.
  ///
  /// In en, this message translates to:
  /// **'Join class'**
  String get clJoin;

  /// No description provided for @icOpenRoom.
  ///
  /// In en, this message translates to:
  /// **'Open class room'**
  String get icOpenRoom;

  /// No description provided for @icCheckBody.
  ///
  /// In en, this message translates to:
  /// **'Check your camera and microphone, then start the class when the room opens.'**
  String get icCheckBody;

  /// No description provided for @icStart.
  ///
  /// In en, this message translates to:
  /// **'Start class'**
  String get icStart;

  /// No description provided for @icEnd.
  ///
  /// In en, this message translates to:
  /// **'End class'**
  String get icEnd;

  /// No description provided for @icEndConfirm.
  ///
  /// In en, this message translates to:
  /// **'End the class for everyone?'**
  String get icEndConfirm;

  /// No description provided for @icEnded.
  ///
  /// In en, this message translates to:
  /// **'Class ended.'**
  String get icEnded;

  /// No description provided for @icPresent.
  ///
  /// In en, this message translates to:
  /// **'{count} present'**
  String icPresent(int count);

  /// No description provided for @icJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined: {names}'**
  String icJoined(String names);

  /// No description provided for @icNoneJoined.
  ///
  /// In en, this message translates to:
  /// **'No one has joined yet.'**
  String get icNoneJoined;

  /// No description provided for @icPhaseCount.
  ///
  /// In en, this message translates to:
  /// **'{phase}: {count}'**
  String icPhaseCount(String phase, int count);

  /// No description provided for @icStudentCameras.
  ///
  /// In en, this message translates to:
  /// **'Students\' cameras'**
  String get icStudentCameras;

  /// No description provided for @payConfirming.
  ///
  /// In en, this message translates to:
  /// **'Confirming your payment…'**
  String get payConfirming;

  /// No description provided for @payConfirmingNote.
  ///
  /// In en, this message translates to:
  /// **'This can take a few seconds.'**
  String get payConfirmingNote;

  /// No description provided for @payPending.
  ///
  /// In en, this message translates to:
  /// **'Your payment is being confirmed. We\'ll let you know as soon as it is.'**
  String get payPending;

  /// No description provided for @payCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment not completed.'**
  String get payCancelled;

  /// No description provided for @payFailed.
  ///
  /// In en, this message translates to:
  /// **'The payment didn\'t go through. You can try again.'**
  String get payFailed;

  /// No description provided for @payLapsed.
  ///
  /// In en, this message translates to:
  /// **'Your held time ran out before the payment arrived. It will be refunded to you in full.'**
  String get payLapsed;

  /// No description provided for @payDescConsult.
  ///
  /// In en, this message translates to:
  /// **'Consult'**
  String get payDescConsult;

  /// No description provided for @payDescClass.
  ///
  /// In en, this message translates to:
  /// **'Live class'**
  String get payDescClass;

  /// No description provided for @csPayAndConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm and pay {amount}'**
  String csPayAndConfirm(String amount);

  /// No description provided for @csPayHoldNote.
  ///
  /// In en, this message translates to:
  /// **'Your time stays held while you pay. The fee shown is the fee charged.'**
  String get csPayHoldNote;

  /// No description provided for @csPaidBooked.
  ///
  /// In en, this message translates to:
  /// **'Paid. Your consult is booked.'**
  String get csPaidBooked;

  /// No description provided for @practicePayTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay for this class?'**
  String get practicePayTitle;

  /// No description provided for @practicePayBody.
  ///
  /// In en, this message translates to:
  /// **'This class is {amount} incl. GST. Your place is held while you pay.'**
  String practicePayBody(String amount);

  /// No description provided for @practicePay.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String practicePay(String amount);

  /// No description provided for @practiceNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get practiceNotNow;

  /// No description provided for @practicePaidBooked.
  ///
  /// In en, this message translates to:
  /// **'Paid. Your place is booked.'**
  String get practicePaidBooked;

  /// No description provided for @billPayTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay for the change?'**
  String get billPayTitle;

  /// No description provided for @billPayBody.
  ///
  /// In en, this message translates to:
  /// **'Your new plan costs {amount} now, after credit for the unused days of your current plan. It starts when the payment is confirmed. A paid period isn\'t refunded once it has started.'**
  String billPayBody(String amount);

  /// No description provided for @billPay.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String billPay(String amount);

  /// No description provided for @plansActive.
  ///
  /// In en, this message translates to:
  /// **'{plan} is now your plan.'**
  String plansActive(String plan);

  /// No description provided for @plansTrialStarted.
  ///
  /// In en, this message translates to:
  /// **'Your free trial of {plan} has started. Doctor, dietitian and live-class features begin with your first payment.'**
  String plansTrialStarted(String plan);

  /// No description provided for @plansNoRefund.
  ///
  /// In en, this message translates to:
  /// **'A paid period isn\'t refunded once it has started.'**
  String get plansNoRefund;

  /// No description provided for @csTranscriptConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'A written transcript of this consult'**
  String get csTranscriptConsentTitle;

  /// No description provided for @csTranscriptDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft wording, pending legal review'**
  String get csTranscriptDraft;

  /// No description provided for @csTranscriptConsentBody.
  ///
  /// In en, this message translates to:
  /// **'If you agree, the audio of this consult is sent to Sarvam AI to be written up as text, and the audio is then deleted. You, this specialist, your doctor or dietitian caring for you now, and a Niraah super admin (only for a complaint, dispute or legal request) can read the transcript. It is kept for up to 3 years. You can still have your consult if you say no.'**
  String get csTranscriptConsentBody;

  /// No description provided for @csTranscriptConsentYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, make a transcript of this consult'**
  String get csTranscriptConsentYes;

  /// No description provided for @csTranscriptTitle.
  ///
  /// In en, this message translates to:
  /// **'Consult transcript'**
  String get csTranscriptTitle;

  /// No description provided for @csTranscriptRead.
  ///
  /// In en, this message translates to:
  /// **'Read the transcript'**
  String get csTranscriptRead;

  /// No description provided for @csTranscriptPending.
  ///
  /// In en, this message translates to:
  /// **'The transcript is being written up. Check back a little later.'**
  String get csTranscriptPending;

  /// No description provided for @csTranscriptFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not make a transcript of this consult.'**
  String get csTranscriptFailed;

  /// No description provided for @csTranscriptNone.
  ///
  /// In en, this message translates to:
  /// **'There is no transcript for this consult.'**
  String get csTranscriptNone;

  /// No description provided for @csTranscriptUnverified.
  ///
  /// In en, this message translates to:
  /// **'Machine-made transcript, not checked by a person. It may contain errors, especially in mixed-language speech.'**
  String get csTranscriptUnverified;

  /// No description provided for @csTranscriptPartial.
  ///
  /// In en, this message translates to:
  /// **'The recording was stopped part-way, so this covers only the start of the consult.'**
  String get csTranscriptPartial;

  /// No description provided for @csTranscriptWhoReads.
  ///
  /// In en, this message translates to:
  /// **'You, this specialist and your doctor or dietitian caring for you now can read it.'**
  String get csTranscriptWhoReads;

  /// No description provided for @csTranscriptYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get csTranscriptYou;

  /// No description provided for @csTranscriptMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get csTranscriptMember;

  /// No description provided for @csTranscriptDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get csTranscriptDoctor;

  /// No description provided for @csTranscriptDietitian.
  ///
  /// In en, this message translates to:
  /// **'Dietitian'**
  String get csTranscriptDietitian;

  /// No description provided for @csTranscriptMissing.
  ///
  /// In en, this message translates to:
  /// **'The {who}\'s voice could not be transcribed.'**
  String csTranscriptMissing(String who);

  /// No description provided for @todayPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s plan'**
  String get todayPlanTitle;

  /// No description provided for @todayPlanFromDietitian.
  ///
  /// In en, this message translates to:
  /// **'From your dietitian\'s meal plan'**
  String get todayPlanFromDietitian;

  /// No description provided for @todayPlanFromAi.
  ///
  /// In en, this message translates to:
  /// **'From your AI diet plan'**
  String get todayPlanFromAi;

  /// No description provided for @todayPlanAteThis.
  ///
  /// In en, this message translates to:
  /// **'I ate this'**
  String get todayPlanAteThis;

  /// No description provided for @todayPlanScan.
  ///
  /// In en, this message translates to:
  /// **'Scan my meal'**
  String get todayPlanScan;

  /// No description provided for @todayPlanLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged. Nicely done.'**
  String get todayPlanLogged;

  /// No description provided for @todayPlanNone.
  ///
  /// In en, this message translates to:
  /// **'When you have a diet plan, today\'s meals appear here.'**
  String get todayPlanNone;

  /// No description provided for @todayPlanNoMeals.
  ///
  /// In en, this message translates to:
  /// **'Your plan has no meals for today.'**
  String get todayPlanNoMeals;

  /// No description provided for @todayPlanRecipeNote.
  ///
  /// In en, this message translates to:
  /// **'This meal has a recipe in it. Log it with a scan, or by hand from your meal log.'**
  String get todayPlanRecipeNote;

  /// No description provided for @todayPlanConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log {meal} as planned?'**
  String todayPlanConfirmTitle(String meal);

  /// No description provided for @mealTimesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your meal times'**
  String get mealTimesTitle;

  /// No description provided for @mealTimesNote.
  ///
  /// In en, this message translates to:
  /// **'We remind you what your plan has for each meal, at its time. Turn any meal off.'**
  String get mealTimesNote;

  /// No description provided for @mealTimesNoPlan.
  ///
  /// In en, this message translates to:
  /// **'These reminders start when you have a diet plan.'**
  String get mealTimesNoPlan;

  /// No description provided for @mealTimesChange.
  ///
  /// In en, this message translates to:
  /// **'{meal} reminder at {time}. Change time'**
  String mealTimesChange(String meal, String time);

  /// No description provided for @devTitle.
  ///
  /// In en, this message translates to:
  /// **'Connected devices'**
  String get devTitle;

  /// No description provided for @devMeRowSub.
  ///
  /// In en, this message translates to:
  /// **'Health Connect or Apple Health'**
  String get devMeRowSub;

  /// No description provided for @devIntro.
  ///
  /// In en, this message translates to:
  /// **'Steps, sleep, heart rate and more from your watch, ring, band or scale.'**
  String get devIntro;

  /// No description provided for @devConnectWith.
  ///
  /// In en, this message translates to:
  /// **'Connect {platform}'**
  String devConnectWith(String platform);

  /// No description provided for @devChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose what to share'**
  String get devChoose;

  /// No description provided for @devChooseNote.
  ///
  /// In en, this message translates to:
  /// **'Only what you choose is read, and you can stop at any time.'**
  String get devChooseNote;

  /// No description provided for @devConsent.
  ///
  /// In en, this message translates to:
  /// **'Niraah will store the readings you choose from your device. Niraah does not check them, they are not a medical measurement, and AI features do not use them.'**
  String get devConsent;

  /// No description provided for @devConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get devConnect;

  /// No description provided for @devKindSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get devKindSteps;

  /// No description provided for @devKindActive.
  ///
  /// In en, this message translates to:
  /// **'Active minutes'**
  String get devKindActive;

  /// No description provided for @devKindSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get devKindSleep;

  /// No description provided for @devKindRestingHr.
  ///
  /// In en, this message translates to:
  /// **'Resting heart rate'**
  String get devKindRestingHr;

  /// No description provided for @devKindHrv.
  ///
  /// In en, this message translates to:
  /// **'Heart rate variability'**
  String get devKindHrv;

  /// No description provided for @devKindWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get devKindWeight;

  /// No description provided for @devKindTemp.
  ///
  /// In en, this message translates to:
  /// **'Basal body temperature'**
  String get devKindTemp;

  /// No description provided for @devKindPeriods.
  ///
  /// In en, this message translates to:
  /// **'Periods, added to your cycle log'**
  String get devKindPeriods;

  /// No description provided for @devNeedsInstall.
  ///
  /// In en, this message translates to:
  /// **'Health Connect needs to be installed or updated first.'**
  String get devNeedsInstall;

  /// No description provided for @devInstall.
  ///
  /// In en, this message translates to:
  /// **'Get Health Connect'**
  String get devInstall;

  /// No description provided for @devUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Health Connect isn\'t available on this phone.'**
  String get devUnavailable;

  /// No description provided for @devDenied.
  ///
  /// In en, this message translates to:
  /// **'Niraah wasn\'t given access. You can allow it in {platform}.'**
  String devDenied(String platform);

  /// No description provided for @devSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get devSyncNow;

  /// No description provided for @devSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced. {count} readings saved.'**
  String devSynced(String count);

  /// No description provided for @devLastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced {when}'**
  String devLastSynced(String when);

  /// No description provided for @devNeverSynced.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get devNeverSynced;

  /// No description provided for @devDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get devDisconnected;

  /// No description provided for @devDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get devDisconnect;

  /// No description provided for @devDisconnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect this device?'**
  String get devDisconnectTitle;

  /// No description provided for @devDisconnectBody.
  ///
  /// In en, this message translates to:
  /// **'Niraah stops receiving readings from it. Keep the readings already sent, or delete them? You can also remove Niraah\'s access in {platform}.'**
  String devDisconnectBody(String platform);

  /// No description provided for @devKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep the readings'**
  String get devKeep;

  /// No description provided for @devDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete the readings'**
  String get devDelete;

  /// No description provided for @devEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing is connected yet. When you connect, the readings you choose appear here.'**
  String get devEmpty;

  /// No description provided for @devReadings.
  ///
  /// In en, this message translates to:
  /// **'Your readings'**
  String get devReadings;

  /// No description provided for @devNoReadings.
  ///
  /// In en, this message translates to:
  /// **'No readings yet. Pull down to sync.'**
  String get devNoReadings;

  /// No description provided for @devLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest: {value} on {day}'**
  String devLatest(String value, String day);

  /// No description provided for @devAverage.
  ///
  /// In en, this message translates to:
  /// **'7-day average: {value}'**
  String devAverage(String value);

  /// No description provided for @devSharing.
  ///
  /// In en, this message translates to:
  /// **'Sharing: {list}'**
  String devSharing(String list);

  /// No description provided for @devFailed.
  ///
  /// In en, this message translates to:
  /// **'That didn\'t go through. Your readings are safe. Try again.'**
  String get devFailed;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
