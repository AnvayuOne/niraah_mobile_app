// SAMPLE "server": in-memory stand-in for the /api/v1 endpoints, so the
// screens can be built before their specs are approved. Imported only via
// lib/main_sample.dart.

import 'dart:convert';

import '../features/assessment/data/questionnaire_parser.dart';
import '../features/assessment/domain/assessment_repository.dart';
import '../features/assessment/domain/prescore.dart';
import '../features/assessment/domain/questionnaire.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/plans/data/plans_parser.dart';
import '../features/plans/domain/plan.dart';
import '../shared/helpers/result.dart';
import 'sample_content.dart';
import 'sample_scoring.dart';

class SampleBackend {
  SampleBackend({DateTime Function()? clock, this.aiDelay = const Duration(milliseconds: 2500)})
      : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final Duration aiDelay;

  /// Minimum age is a platform setting that cannot go below 18 (spec 007).
  static const int minimumAge = 18;

  /// The profile field collected before the first health question.
  static const String dateOfBirthKey = 'date_of_birth';

  static const String consentTextVersion = 'sample-1';

  final QuestionnaireDocument document =
      QuestionnaireParser.parse(jsonDecode(sampleQuestionnaireJson) as Map<String, dynamic>);
  final Map<String, dynamic> _scoring = jsonDecode(sampleScoringJson) as Map<String, dynamic>;
  final Map<String, dynamic> _plans = jsonDecode(samplePlansJson) as Map<String, dynamic>;

  final Answers _answers = <String, Answer>{};
  PreScore? _preScore;
  DateTime? _aiReadyAt;
  List<String> _aiObservations = const <String>[];
  bool paused = false;

  AssessmentSession session() => AssessmentSession(
        assessmentId: 'sample-assessment',
        document: document,
        answers: Map<String, Answer>.of(_answers),
        consentTextVersion: consentTextVersion,
      );

  SaveOutcome save(String key, Answer answer) {
    if (key == dateOfBirthKey) {
      final DateTime? dob = DateTime.tryParse(answer.text ?? '');
      if (dob != null && _ageOn(dob, _clock()) < minimumAge) {
        _answers.clear();
        paused = true;
        return SaveOutcome.minimumAgeStop;
      }
    }
    _answers[key] = answer;
    return SaveOutcome.saved;
  }

  static int _ageOn(DateTime dob, DateTime today) {
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) age--;
    return age;
  }

  /// Submitting twice has no further effect (spec 007 §3).
  PreScore submit(Answers answers) {
    final PreScore? existing = _preScore;
    if (existing != null) return existing;
    final ScoreResult r = SampleScorer(_scoring).score(document, answers);
    _answers
      ..clear()
      ..addAll(r.keptAnswers);
    _preScore = PreScore(
      id: 'sample-prescore',
      total: r.total,
      maximum: r.totalMaximum,
      band: r.band,
      dimensions: r.dimensions.map((ScoredDimension d) => DimensionLevel(name: d.name, level: d.level)).toList(),
      flags: r.flags,
      observations: r.fallbackObservations,
      observationSource: ObservationSource.rules,
      reviewState: ReviewState.notRequired,
      hasPaidPlan: false,
      plansIncludingReview: _plansIncluding('prescore.doctor_review'),
      suggestedProgram: r.program,
    );
    _aiReadyAt = _clock().add(aiDelay);
    _aiObservations = <String>[
      for (final ScoredDimension d in r.dimensions)
        if (d.percent < 70) 'Your answers about ${d.name.toLowerCase()} suggest some gentle support could help.',
      ...r.flagObservations,
      r.bandFallbackObservation,
    ].take(4).toList(growable: false);
    return _preScore!;
  }

  /// The pre-score once the assessment is submitted.
  PreScore? get latestPreScore => _preScore;

  /// First value of a kept answer, for example her cycle regularity.
  String? answerValue(String key) => _answers[key]?.values.firstOrNull;

  List<String>? aiObservations() {
    final DateTime? at = _aiReadyAt;
    if (at == null || _clock().isBefore(at)) return null;
    return _aiObservations;
  }

  List<String> _plansIncluding(String featureKey) => <String>[
        for (final dynamic p in _plans['plans'] as List<dynamic>)
          if (((p as Map<String, dynamic>)['features'] as List<dynamic>)
              .any((dynamic f) => (f as Map<String, dynamic>)['key'] == featureKey && f['value'] == true))
            p['name'] as String,
      ];

  /// First plan in display order whose rules match her pre-score; otherwise
  /// the highlighted plan (spec 004, "Recommending a plan").
  String? recommendedPlanId() {
    final PreScore? p = _preScore;
    final List<Map<String, dynamic>> plans = (_plans['plans'] as List<dynamic>).cast<Map<String, dynamic>>();
    if (p != null) {
      for (final Map<String, dynamic> plan in plans) {
        final Map<String, dynamic> rules = plan['recommendedFor'] as Map<String, dynamic>;
        final bool band = (rules['bands'] as List<dynamic>).contains(p.band.label);
        final bool flag = (rules['flags'] as List<dynamic>).any((dynamic f) => p.flags.any((RaisedFlag r) => r.key == f));
        if (band || flag) return plan['id'] as String;
      }
    }
    return plans.where((Map<String, dynamic> m) => m['highlighted'] == true).firstOrNull?['id'] as String?;
  }

  /// She has no subscription in the sample, so she holds the free plan.
  PlansOffer plansOffer() {
    final String? freeId = (_plans['plans'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .where((Map<String, dynamic> m) => m['isFree'] == true)
        .firstOrNull?['id'] as String?;
    return PlansParser.parse(_plans, recommendedId: recommendedPlanId(), currentPlanId: freeId);
  }

  bool get assessmentComplete => _preScore != null;
}

class SampleAssessmentRepository implements AssessmentRepository {
  SampleAssessmentRepository(this._backend);

  final SampleBackend _backend;
  static const Duration _latency = Duration(milliseconds: 250);

  @override
  Future<Result<AssessmentSession>> startOrResume() async {
    await Future<void>.delayed(_latency);
    return Success<AssessmentSession>(_backend.session());
  }

  @override
  Future<Result<void>> recordConsent({required bool healthData, required bool doctorReview, required String textVersion}) async {
    if (!healthData) return const FailureResult<void>('consent_required');
    return const Success<void>(null);
  }

  @override
  Future<Result<SaveOutcome>> saveAnswer(String assessmentId, String questionKey, Answer answer) async =>
      Success<SaveOutcome>(_backend.save(questionKey, answer));

  @override
  Future<Result<PreScore>> submit(String assessmentId, Answers answers) async {
    await Future<void>.delayed(_latency);
    return Success<PreScore>(_backend.submit(answers));
  }

  @override
  Future<Result<List<String>?>> aiObservations(String preScoreId) async => Success<List<String>?>(_backend.aiObservations());
}

class SamplePlansRepository implements PlansRepository {
  SamplePlansRepository(this._backend);

  final SampleBackend _backend;

  @override
  Future<Result<PlansOffer>> offer() async {
    if (!_backend.assessmentComplete) return const FailureResult<PlansOffer>('assessment_required');
    return Success<PlansOffer>(_backend.plansOffer());
  }

  /// The sample has no billing: choosing a plan says payment comes later, and nothing is ever shown as paid.
  @override
  Future<Result<PlanChoice>> choose(String priceId) async => const Success<PlanChoice>(PlanPaymentUnavailable());

  @override
  Future<SubscriptionCheck> subscriptionStatus(String subscriptionId) async => const SubscriptionCheck(status: 'pending', confirmed: false);
}

class SampleAuthRepository implements AuthRepository {
  SampleAuthRepository();

  final Set<String> _accounts = <String>{};

  /// Stored as the server would record them (spec 010 §1.3).
  Map<String, String?>? accountDetails;

  @override
  Future<Result<void>> requestCode(String phoneE164) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const Success<void>(null);
  }

  /// SAMPLE ONLY: any six digits are accepted. The first sign-in for a number
  /// creates the account.
  @override
  Future<Result<CodeOutcome>> verifyCode(String phoneE164, String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!RegExp(r'^[0-9]{6}$').hasMatch(code)) return const FailureResult<CodeOutcome>('code_rejected');
    final bool created = _accounts.add(phoneE164);
    return Success<CodeOutcome>(created ? CodeOutcome.newAccount : CodeOutcome.signedIn);
  }

  /// SAMPLE ONLY: the sample has no provider or admin accounts.
  @override
  Future<Result<void>> signInWithPassword(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const FailureResult<void>('password_rejected');
  }

  @override
  Future<Result<void>> saveAccountDetails({
    required String displayName,
    required String termsVersion,
    required String privacyVersion,
    String? recoveryEmail,
  }) async {
    accountDetails = <String, String?>{
      'displayName': displayName,
      'termsVersion': termsVersion,
      'privacyVersion': privacyVersion,
      'recoveryEmail': recoveryEmail,
    };
    return const Success<void>(null);
  }
}
