import '../../../core/network/niraah_api.dart';
import '../../../shared/area/area_access.dart';
import '../domain/wellness_advice.dart';

/// Wellness advice on `/api/v1`: `GET /me/wellness-advice`, `GET /me/wellness-advice/{id}`, `GET /me/wellness-advice/{id}/document`.
class ApiWellnessAdviceRepository implements WellnessAdviceRepository {
  ApiWellnessAdviceRepository(this._api);

  final NiraahApi _api;

  @override
  Future<List<WellnessAdvice>> list() async =>
      <WellnessAdvice>[for (final dynamic a in (await _api.get('/me/wellness-advice')).orArea()['items'] as List<dynamic>) parse(a as Map<String, dynamic>)];

  @override
  Future<WellnessAdvice> get(String id) async => parse((await _api.get('/me/wellness-advice/${Uri.encodeComponent(id)}')).orArea());

  @override
  Future<String> documentUrl(String id) async => '${(await _api.get('/me/wellness-advice/${Uri.encodeComponent(id)}/document')).orArea()['url']}';

  static String? _s(Object? v) => v == null ? null : '$v';

  static WellnessAdvice parse(Map<String, dynamic> a) {
    final Map<String, dynamic> d = (a['doctor'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    return WellnessAdvice(
      id: '${a['id']}',
      title: '${a['title']}',
      current: a['state'] != 'replaced',
      stateLabel: '${a['stateLabel'] ?? ''}',
      replacedBy: _s(a['replacedBy']),
      doctorName: _s(d['name']),
      doctorQualification: _s(d['qualification']),
      registrationNumber: _s(d['registrationNumber']),
      council: _s(d['council']),
      issuedAt: _s(a['issuedAt']),
      assessment: _s(a['assessment']),
      supplements: <AdviceSupplement>[
        for (final dynamic x in (a['supplements'] as List<dynamic>?) ?? const <dynamic>[])
          AdviceSupplement(
            name: '${(x as Map<String, dynamic>)['name']}',
            form: _s(x['form']),
            strength: _s(x['strength']),
            dosePattern: _s(x['dosePattern']),
            timing: _s(x['timing']),
            duration: _s(x['duration']),
            instructions: _s(x['instructions']),
          ),
      ],
      advice: _s(a['advice']),
      seeDoctorLine: _s(a['seeDoctorLine']),
      followUpOn: _s(a['followUpOn']),
      testsAdvised: ((a['testsAdvised'] as List<dynamic>?) ?? const <dynamic>[]).map((dynamic t) => '$t').toList(),
      wellnessStatement: '${a['wellnessStatement'] ?? ''}',
      verificationCode: _s(a['verificationCode']),
    );
  }
}
