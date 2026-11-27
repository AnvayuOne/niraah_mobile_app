import '../../../core/network/niraah_api.dart';
import '../../provider_work/domain/provider_work.dart';
import '../domain/doctor_work.dart';

/// The doctor workspace beyond the dashboard and review queue, on `/api/v1/doctor/*` (spec 011; plan 011).
class ApiDoctorWorkRepository implements DoctorWorkRepository {
  ApiDoctorWorkRepository(this._api);

  final NiraahApi _api;

  static String _e(String id) => Uri.encodeComponent(id);

  Future<Json> _get(String path) async => (await _api.get(path)).orThrow();
  Future<Json> _post(String path, [Json? body]) async => (await _api.post(path, body)).orThrow();

  @override
  Future<List<Json>> patients(PatientFilters f) async {
    final String q = f.query.isEmpty ? '' : '?${Uri(queryParameters: f.query).query}';
    return (await _get('/doctor/patients$q')).objs('items');
  }

  @override
  Future<Json> patient(String memberId) => _get('/doctor/patients/${_e(memberId)}');

  @override
  Future<Json> section(String memberId, String section) => _get('/doctor/patients/${_e(memberId)}/sections/${_e(section)}');

  @override
  Future<Json> addNote(String memberId, String text) => _post('/doctor/patients/${_e(memberId)}/notes', <String, dynamic>{'text': text});

  @override
  Future<Json> brief(String memberId) => _get('/doctor/patients/${_e(memberId)}/brief');

  @override
  Future<Json> medicines(String memberId) => _get('/doctor/patients/${_e(memberId)}/medicines');

  @override
  Future<List<Json>> carePlanQueue() async => (await _get('/doctor/care-plans')).objs('items');

  @override
  Future<void> claimCarePlan(String id) => _post('/doctor/care-plans/${_e(id)}/claim');

  @override
  Future<Json> carePlan(String id) => _get('/doctor/care-plans/${_e(id)}');

  @override
  Future<Json> decide(String id, String kind, String decision, {String? text, String? reason}) async =>
      (await _api.put('/doctor/care-plans/${_e(id)}/sections/${_e(kind)}', <String, dynamic>{'decision': decision, 'text': ?text, 'reason': ?reason})).orThrow();

  @override
  Future<Json> confirmDose(String id, String kind) => _post('/doctor/care-plans/${_e(id)}/sections/${_e(kind)}/confirm-dose');

  @override
  Future<Json> setTasks(String id, List<Json> tasks) async => (await _api.put('/doctor/care-plans/${_e(id)}/tasks', <String, dynamic>{'tasks': tasks})).orThrow();

  @override
  Future<Json> returnPlan(String id, String note) => _post('/doctor/care-plans/${_e(id)}/return', <String, dynamic>{'note': note});

  @override
  Future<Json> signPlan(String id) => _post('/doctor/care-plans/${_e(id)}/sign');

  @override
  Future<Json> revisePlan(String id) => _post('/doctor/care-plans/${_e(id)}/revise');

  @override
  Future<List<Json>> alerts({String? status}) async => (await _get('/doctor/alerts${status == null ? '' : '?status=${_e(status)}'}')).objs('items');

  @override
  Future<Json> openAlert(String id) => _post('/doctor/alerts/${_e(id)}/open');

  @override
  Future<void> acknowledgeAlert(String id) => _post('/doctor/alerts/${_e(id)}/acknowledge');

  @override
  Future<void> askToBook(String id) => _post('/doctor/alerts/${_e(id)}/ask-to-book');

  @override
  Future<void> resolveAlert(String id, String note) => _post('/doctor/alerts/${_e(id)}/resolve', <String, dynamic>{'note': note});

  @override
  Future<List<Json>> labTests() async => (await _get('/doctor/lab-tests')).objs('items');

  @override
  Future<void> recommendTests(String memberId, List<String> testIds, {String? note}) =>
      _post('/doctor/patients/${_e(memberId)}/lab-recommendations', <String, dynamic>{'testIds': testIds, 'note': ?note});

  @override
  Future<List<Json>> labReportsToReview() async => (await _get('/doctor/lab-reports')).objs('items');

  @override
  Future<Json> labReport(String id) => _get('/doctor/lab-reports/${_e(id)}');

  @override
  Future<Json> reviewLab(String id, {String? comment, bool confirmMedicines = false}) =>
      _post('/doctor/lab-reports/${_e(id)}/review', <String, dynamic>{'comment': ?comment, if (confirmMedicines) 'confirmMedicines': true});

  @override
  Future<List<Json>> prescriptionDrafts() async => (await _get('/doctor/prescriptions')).objs('items');

  @override
  Future<String> createPrescription(String appointmentId) async => (await _post('/doctor/prescriptions', <String, dynamic>{'appointmentId': appointmentId}))['id'] as String;

  @override
  Future<Json> prescription(String id) => _get('/doctor/prescriptions/${_e(id)}');

  @override
  Future<Json> updatePrescription(String id, Json patch) async => (await _api.patch('/doctor/prescriptions/${_e(id)}', patch)).orThrow();

  @override
  Future<Json> confirmWording(String id, String field) => _post('/doctor/prescriptions/${_e(id)}/confirm-wording', <String, dynamic>{'field': field, 'confirm': true});

  @override
  Future<void> discardPrescription(String id) async => (await _api.delete('/doctor/prescriptions/${_e(id)}')).orThrow();

  @override
  Future<Json> signPrescription(String id, String proofId) => _post('/doctor/prescriptions/${_e(id)}/sign', <String, dynamic>{'proofId': proofId});

  @override
  Future<List<Json>> supplements() async => (await _get('/doctor/supplements')).objs('items');

  @override
  Future<Json> profile() => _get('/doctor/profile');

  @override
  Future<Json> updateProfile({String? bio, List<String>? languages, List<String>? specialities, bool? onCall}) async =>
      (await _api.patch('/doctor/profile', <String, dynamic>{'bio': ?bio, 'languages': ?languages, 'specialities': ?specialities, 'onCall': ?onCall})).orThrow();

  @override
  Future<Json> reviewerTasks() => _get('/doctor/reviewer-tasks');
}
