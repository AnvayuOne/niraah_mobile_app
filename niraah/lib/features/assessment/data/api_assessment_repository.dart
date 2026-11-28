import '../../../core/network/niraah_api.dart';
import '../../../shared/helpers/result.dart';
import '../domain/assessment_repository.dart';
import '../domain/prescore.dart';
import '../domain/questionnaire.dart';
import 'questionnaire_parser.dart';

/// The onboarding assessment on `/api/v1` (spec 007 T9). Scoring happens only on the server; the
/// document carries no weights or flags (spec 005 AC21).
class ApiAssessmentRepository implements AssessmentRepository {
  ApiAssessmentRepository(this._api);

  final NiraahApi _api;
  static const String consentTextVersion = '2026-11-15';

  static bool _isText(QuestionType t) => t == QuestionType.shortText || t == QuestionType.number;

  @override
  Future<Result<AssessmentSession>> startOrResume() async {
    final ApiResult<Map<String, dynamic>> r = await _api.post('/assessment/start', <String, dynamic>{});
    if (r is ApiFail<Map<String, dynamic>>) {
      return FailureResult<AssessmentSession>(r.error.field == 'consent' ? kConsentRequired : r.error.message);
    }
    final Map<String, dynamic> data = (r as ApiOk<Map<String, dynamic>>).data;
    final QuestionnaireDocument doc = QuestionnaireParser.parse(Map<String, dynamic>.from(data['document'] as Map));
    final Map<String, dynamic> raw = Map<String, dynamic>.from((data['answers'] as Map?) ?? <String, dynamic>{});
    final Answers answers = <String, Answer>{};
    for (Question q in doc.questions) {
      final List<String>? v = (raw[q.key] as List<dynamic>?)?.cast<String>();
      if (v == null || v.isEmpty) continue;
      answers[q.key] = _isText(q.type) ? Answer.text(v.first) : Answer.values(v);
    }
    return Success<AssessmentSession>(
      AssessmentSession(assessmentId: '${data['assessmentId']}', document: doc, answers: answers, consentTextVersion: consentTextVersion),
    );
  }

  @override
  Future<Result<void>> recordConsent({required bool healthData, required bool doctorReview, required String textVersion}) async {
    if (!healthData) return const FailureResult<void>('consent_required');
    final ApiResult<Map<String, dynamic>> r = await _api.post('/assessment/consent', <String, dynamic>{'textVersion': textVersion, 'doctorReview': doctorReview});
    return r is ApiOk ? const Success<void>(null) : FailureResult<void>((r as ApiFail<Map<String, dynamic>>).error.message);
  }

  @override
  Future<Result<SaveOutcome>> saveAnswer(String assessmentId, String questionKey, Answer answer) async {
    final List<String> values = answer.text != null ? <String>[answer.text!] : answer.values;
    final ApiResult<Map<String, dynamic>> r = await _api.post('/assessment/$assessmentId/answers', <String, dynamic>{'questionKey': questionKey, 'values': values});
    switch (r) {
      case ApiOk<Map<String, dynamic>>(:Map<String, dynamic> data):
        return Success<SaveOutcome>(data['stopped'] == 'minimum_age' ? SaveOutcome.minimumAgeStop : SaveOutcome.saved);
      case ApiFail<Map<String, dynamic>>(:ApiError error):
        return FailureResult<SaveOutcome>(error.message);
    }
  }

  @override
  Future<Result<PreScore>> submit(String assessmentId, Answers answers) async {
    final ApiResult<Map<String, dynamic>> r = await _api.post('/assessment/$assessmentId/submit');
    switch (r) {
      case ApiOk<Map<String, dynamic>>(:Map<String, dynamic> data):
        if (data['kind'] != 'prescore') return const FailureResult<PreScore>('no_prescore');
        return Success<PreScore>(preScoreFrom(Map<String, dynamic>.from(data['prescore'] as Map)));
      case ApiFail<Map<String, dynamic>>(:ApiError error):
        // A required visible question without an answer names it (spec 007 AC14).
        return FailureResult<PreScore>(error.field != null && error.code == 'invalid_request' ? 'missing:${error.field}' : error.message);
    }
  }

  @override
  Future<Result<List<String>?>> aiObservations(String preScoreId) async {
    final ApiResult<Map<String, dynamic>> r = await _api.get('/prescores/$preScoreId');
    if (r is! ApiOk<Map<String, dynamic>>) return const Success<List<String>?>(null);
    final List<dynamic> obs = (r.data['observations'] as List<dynamic>?) ?? <dynamic>[];
    final List<String> ai = obs.where((dynamic o) => (o as Map)['source'] == 'ai').map((dynamic o) => '${(o as Map)['text']}').toList();
    return Success<List<String>?>(ai.isEmpty ? null : ai);
  }

  /// The member's pre-score view: names and levels, never points (spec 007 AC53).
  static PreScore preScoreFrom(Map<String, dynamic> p) {
    final Map<dynamic, dynamic>? band = p['band'] as Map?;
    final Map<dynamic, dynamic> clinician = (p['clinician'] as Map?) ?? <dynamic, dynamic>{};
    final Map<dynamic, dynamic>? care = p['careMessage'] as Map?;
    final List<dynamic> obs = (p['observations'] as List<dynamic>?) ?? <dynamic>[];
    final ReviewState state = switch (clinician['state']) {
      'awaiting_review' => ReviewState.awaitingReview,
      'verified' => ReviewState.verified,
      'follow_up_requested' => ReviewState.followUpRequested,
      _ => ReviewState.notRequired,
    };
    return PreScore(
      id: '${p['id']}',
      total: p['total'] as int,
      maximum: p['maximum'] as int,
      band: Band(label: '${band?['label'] ?? ''}', message: '${band?['message'] ?? ''}', colorToken: '${band?['color'] ?? 'sage'}'),
      dimensions: ((p['dimensions'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic d) => DimensionLevel(name: '${(d as Map)['name']}', level: '${d['level']}'))
          .toList(growable: false),
      // The member view carries the care message, not flag keys (spec 005 AC21).
      flags: care == null
          ? const <RaisedFlag>[]
          : <RaisedFlag>[
              RaisedFlag(
                key: 'care',
                severity: FlagSeverity.urgent,
                careMessage: care['notPassedOn'] == null ? '${care['message']}' : '${care['message']} ${care['notPassedOn']}',
              ),
            ],
      observations: obs.map((dynamic o) => '${(o as Map)['text']}').take(4).toList(growable: false),
      observationSource: obs.any((dynamic o) => (o as Map)['source'] == 'ai') ? ObservationSource.ai : ObservationSource.rules,
      reviewState: state,
      hasPaidPlan: p['nextStep'] == 'home',
      reviewTarget: clinician['targetHours'] == null ? null : '${clinician['targetHours']} hours',
      reviewer: clinician['doctorName'] == null ? null : Reviewer(name: '${clinician['doctorName']}', speciality: '${clinician['speciality'] ?? ''}'),
      doctorNote: clinician['note'] as String?,
      suggestedProgram: (p['suggestedProgram'] as Map?)?['name'] as String?,
    );
  }
}
