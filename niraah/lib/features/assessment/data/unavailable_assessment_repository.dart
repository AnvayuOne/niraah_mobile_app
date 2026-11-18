import '../../../shared/helpers/result.dart';
import '../domain/assessment_repository.dart';
import '../domain/prescore.dart';
import '../domain/questionnaire.dart';

/// Used by `main.dart` until the `/api/v1` assessment endpoints exist and
/// their spec is approved. Every call fails plainly; nothing is faked.
class UnavailableAssessmentRepository implements AssessmentRepository {
  const UnavailableAssessmentRepository();

  static const FailureResult<Never> _no = FailureResult<Never>('not_connected');

  @override
  Future<Result<AssessmentSession>> startOrResume() async => _no;

  @override
  Future<Result<void>> recordConsent({required bool healthData, required bool doctorReview, required String textVersion}) async => _no;

  @override
  Future<Result<SaveOutcome>> saveAnswer(String assessmentId, String questionKey, Answer answer) async => _no;

  @override
  Future<Result<PreScore>> submit(String assessmentId, Answers answers) async => _no;

  @override
  Future<Result<List<String>?>> aiObservations(String preScoreId) async => _no;
}
