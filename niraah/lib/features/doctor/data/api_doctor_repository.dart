import '../../../core/errors/api_exception.dart';
import '../../../core/network/niraah_api.dart';
import '../domain/doctor.dart';
import 'doctor_parser.dart';

/// The doctor dashboard and pre-score review queue on `/api/v1` (spec 011 §1, §4; spec 007 §7),
/// matching apps/web/src/api/doctor-repository.ts.
class ApiDoctorRepository implements DoctorRepository {
  ApiDoctorRepository(this._api, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final NiraahApi _api;
  final DateTime Function() _clock;

  String _id(String id) => Uri.encodeComponent(id);

  @override
  Future<DoctorDashboard> getDashboard() async => DoctorParser.dashboard((await _api.get('/doctor/dashboard')).orThrow(), _clock());

  @override
  Future<List<QueueItem>> getQueue() async => DoctorParser.queue((await _api.get('/doctor/reviews')).orThrow(), _clock());

  /// The claim answers with the review screen. 409: she holds another (AC47); 410 or 404: taken or done (AC38).
  @override
  Future<ClaimResult> claim(String id) async {
    final ApiResult<Map<String, dynamic>> r = await _api.post('/doctor/reviews/${_id(id)}/claim');
    return switch (r) {
      ApiOk<Map<String, dynamic>>(:final Map<String, dynamic> data) => ClaimResult.ok(DoctorParser.review(data, _clock())),
      ApiFail<Map<String, dynamic>>(status: 409) => const ClaimResult.failed(ClaimFailure.holdingAnother),
      ApiFail<Map<String, dynamic>>(status: 410) || ApiFail<Map<String, dynamic>>(status: 404) => const ClaimResult.failed(ClaimFailure.gone),
      ApiFail<Map<String, dynamic>>(:final ApiError error, :final int status) => throw ApiException(message: error.message, statusCode: status),
    };
  }

  @override
  Future<void> release(String id) async => (await _api.post('/doctor/reviews/${_id(id)}/release')).orThrow();

  @override
  Future<ReviewDetail> editObservation(String id, int index, String? text) async =>
      DoctorParser.review((await _api.post('/doctor/reviews/${_id(id)}/observations', <String, dynamic>{'index': index, 'text': text})).orThrow(), _clock());

  @override
  Future<CompleteResult> complete(String id, ReviewOutcome outcome, String note, {bool next = false}) async {
    final String trimmed = note.trim();
    if (outcome == ReviewOutcome.followUp && trimmed.isEmpty) return const CompleteResult.noteRequired();
    final ApiResult<Map<String, dynamic>> r = await _api.post('/doctor/reviews/${_id(id)}/complete', <String, dynamic>{
      'outcome': outcome == ReviewOutcome.verified ? 'verify' : 'follow_up',
      if (trimmed.isNotEmpty) 'note': trimmed,
      if (next) 'next': true,
    });
    return switch (r) {
      ApiOk<Map<String, dynamic>>(:final Map<String, dynamic> data) => CompleteResult.ok(data['next'] as String?),
      ApiFail<Map<String, dynamic>>(:final ApiError error) when error.field == 'note' => const CompleteResult.noteRequired(),
      ApiFail<Map<String, dynamic>>(:final ApiError error, :final int status) => throw ApiException(message: error.message, statusCode: status),
    };
  }

  @override
  Future<void> scoringConcern(String id, String note) async => (await _api.post('/doctor/reviews/${_id(id)}/concern', <String, dynamic>{'note': note.trim()})).orThrow();
}
