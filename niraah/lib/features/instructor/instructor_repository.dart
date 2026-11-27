import '../../core/network/niraah_api.dart';
import '../provider_work/domain/provider_work.dart';

/// The instructor workspace (spec 013) on `/api/v1/instructor/*`, plus spec 014's attendance correction. Member
/// facts in every response are the four the spec allows (AC1); the screens read them as [Json].
abstract class InstructorRepository {
  Future<Json> home();
  Future<List<Json>> classes({DateTime? from, DateTime? to});
  Future<Json> classDetail(String id);
  Future<Json> createClass(Json input);
  Future<Json> updateClass(String id, Json patch);
  Future<Json> publish(String id, {bool series = false});
  Future<Json> cancel(String id, String reason);
  Future<Json> confirmAttendance(String id);
  Future<void> correctAttendance(String bookingId, bool attended);
  Future<void> seeRequest(String bookingId);
  Future<List<Json>> students();
  Future<void> recommend(String memberId, {String? contentId});
  Future<List<Json>> content();
  Future<Json> saveContent(String? id, Json input);
  Future<Json> submitContent(String id);
  Future<void> withdrawContent(String id);
  Future<Json> profile();
  Future<Json> updateProfile({String? bio, List<String>? languages, List<String>? practiceTypes});
}

class ApiInstructorRepository implements InstructorRepository {
  ApiInstructorRepository(this._api);

  final NiraahApi _api;

  static String _e(String id) => Uri.encodeComponent(id);

  @override
  Future<Json> home() async => (await _api.get('/instructor/home')).orThrow();

  @override
  Future<List<Json>> classes({DateTime? from, DateTime? to}) async {
    final Map<String, String> q = <String, String>{if (from != null) 'from': from.toUtc().toIso8601String(), if (to != null) 'to': to.toUtc().toIso8601String()};
    return (await _api.get('/instructor/classes${q.isEmpty ? '' : '?${Uri(queryParameters: q).query}'}')).orThrow().objs('items');
  }

  @override
  Future<Json> classDetail(String id) async => (await _api.get('/instructor/classes/${_e(id)}')).orThrow();

  @override
  Future<Json> createClass(Json input) async => (await _api.post('/instructor/classes', input)).orThrow();

  @override
  Future<Json> updateClass(String id, Json patch) async => (await _api.patch('/instructor/classes/${_e(id)}', patch)).orThrow();

  @override
  Future<Json> publish(String id, {bool series = false}) async => (await _api.post('/instructor/classes/${_e(id)}/publish', <String, dynamic>{if (series) 'series': true})).orThrow();

  @override
  Future<Json> cancel(String id, String reason) async => (await _api.post('/instructor/classes/${_e(id)}/cancel-with-reason', <String, dynamic>{'reason': reason})).orThrow();

  @override
  Future<Json> confirmAttendance(String id) async => (await _api.post('/instructor/classes/${_e(id)}/attendance/confirm')).orThrow();

  @override
  Future<void> correctAttendance(String bookingId, bool attended) async => (await _api.put('/class-bookings/${_e(bookingId)}/attendance', <String, dynamic>{'attended': attended})).orThrow();

  @override
  Future<void> seeRequest(String bookingId) async => (await _api.post('/instructor/bookings/${_e(bookingId)}/request-seen')).orThrow();

  @override
  Future<List<Json>> students() async => (await _api.get('/instructor/students')).orThrow().objs('items');

  @override
  Future<void> recommend(String memberId, {String? contentId}) async => (await _api.post('/instructor/students/${_e(memberId)}/recommend', <String, dynamic>{'contentId': contentId})).orThrow();

  @override
  Future<List<Json>> content() async => (await _api.get('/instructor/content')).orThrow().objs('items');

  @override
  Future<Json> saveContent(String? id, Json input) async => (id == null ? await _api.post('/instructor/content', input) : await _api.put('/instructor/content/${_e(id)}', input)).orThrow();

  @override
  Future<Json> submitContent(String id) async => (await _api.post('/instructor/content/${_e(id)}/submit')).orThrow();

  @override
  Future<void> withdrawContent(String id) async => (await _api.post('/instructor/content/${_e(id)}/withdraw')).orThrow();

  @override
  Future<Json> profile() async => (await _api.get('/instructor/profile')).orThrow();

  @override
  Future<Json> updateProfile({String? bio, List<String>? languages, List<String>? practiceTypes}) async =>
      (await _api.patch('/instructor/profile', <String, dynamic>{'bio': ?bio, 'languages': ?languages, 'practiceTypes': ?practiceTypes})).orThrow();
}
