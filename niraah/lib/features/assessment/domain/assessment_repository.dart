import '../../../shared/helpers/result.dart';
import 'prescore.dart';
import 'questionnaire.dart';

/// What happened when an answer was saved.
enum SaveOutcome {
  saved,

  /// The date of birth is below the minimum age and teen accounts are off:
  /// the assessment stops and the account is paused (spec 007 §1).
  minimumAgeStop,
}

class AssessmentSession {
  const AssessmentSession({
    required this.assessmentId,
    required this.document,
    required this.answers,
    required this.consentTextVersion,
  });

  final String assessmentId;
  final QuestionnaireDocument document;

  /// Answers kept from an earlier visit, so she resumes where she stopped.
  final Answers answers;
  final String consentTextVersion;
}

/// The onboarding assessment, as the API will offer it (spec 007).
abstract interface class AssessmentRepository {
  /// Returns her assessment in progress, or starts one on the live version.
  Future<Result<AssessmentSession>> startOrResume();

  Future<Result<void>> recordConsent({required bool healthData, required bool doctorReview, required String textVersion});

  Future<Result<SaveOutcome>> saveAnswer(String assessmentId, String questionKey, Answer answer);

  /// Completes the assessment and returns the rule-based pre-score at once.
  Future<Result<PreScore>> submit(String assessmentId, Answers answers);

  /// The AI summary's observations once ready, or null while still pending.
  Future<Result<List<String>?>> aiObservations(String preScoreId);
}
