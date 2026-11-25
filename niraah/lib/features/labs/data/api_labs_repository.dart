import '../../../core/network/niraah_api.dart';
import '../../../shared/area/area_access.dart';
import '../domain/labs.dart';

/// Labs on `/api/v1` (spec 010 §9): reports, results, home collection and orders.
class ApiLabsRepository implements LabsRepository {
  ApiLabsRepository(this._api);

  final NiraahApi _api;

  @override
  Future<List<LabReport>> reports() async =>
      <LabReport>[for (final dynamic r in (await _api.get('/me/labs/reports')).orArea()['items'] as List<dynamic>) _report(r as Map<String, dynamic>)];

  @override
  Future<LabReport> addReport({required String testDate, required List<ResultInput> results}) async => _report((await _api.post('/me/labs/reports', <String, dynamic>{
        'testDate': testDate,
        'results': <Map<String, dynamic>>[
          for (ResultInput r in results) <String, dynamic>{'name': r.name, 'value': r.value, 'unit': r.unit, 'referenceLow': r.low, 'referenceHigh': r.high},
        ],
      }))
          .orArea());

  @override
  Future<LabCollection> collection() async {
    final Map<String, dynamic> r = (await _api.get('/me/labs/collection')).orArea();
    return LabCollection(
      access: r['access'] as String,
      tests: <LabTest>[
        for (final dynamic t in r['tests'] as List<dynamic>) LabTest(id: (t as Map<String, dynamic>)['id'] as String, name: t['name'] as String, fasting: t['fasting'] as bool),
      ],
      partners: <({String id, String name})>[
        for (final dynamic p in r['partners'] as List<dynamic>) (id: (p as Map<String, dynamic>)['id'] as String, name: p['name'] as String),
      ],
    );
  }

  @override
  Future<List<LabOrder>> orders() async =>
      <LabOrder>[for (final dynamic o in (await _api.get('/me/labs/orders')).orArea()['items'] as List<dynamic>) _order(o as Map<String, dynamic>)];

  @override
  Future<LabOrder> order({required String partnerId, required List<String> testIds, required Map<String, String> address, required DateTime start, required DateTime end}) async =>
      _order((await _api.post('/me/labs/orders', <String, dynamic>{
        'partnerId': partnerId,
        'testIds': testIds,
        'address': address,
        'slot': <String, String>{'start': start.toUtc().toIso8601String(), 'end': end.toUtc().toIso8601String()},
      }))
          .orArea());

  static LabOrder _order(Map<String, dynamic> o) =>
      LabOrder(id: o['id'] as String, statusText: o['statusText'] as String, partner: o['partner'] as String?, slotStart: o['slotStart'] as String?);

  static LabReport _report(Map<String, dynamic> r) => LabReport(
        id: r['id'] as String,
        testDate: r['testDate'] as String?,
        hasFile: r['hasFile'] as bool,
        clinicianComment: r['clinicianComment'] as String?,
        note: r['note'] as String,
        results: <LabResult>[
          for (final dynamic x in r['results'] as List<dynamic>)
            LabResult(
              name: (x as Map<String, dynamic>)['name'] as String,
              value: (x['value'] as num).toDouble(),
              unit: x['unit'] as String,
              low: ((x['range'] as Map<String, dynamic>?)?['low'] as num?)?.toDouble(),
              high: ((x['range'] as Map<String, dynamic>?)?['high'] as num?)?.toDouble(),
              outsideRange: x['outsideRange'] as bool,
              label: x['label'] as String?,
            ),
        ],
      );
}
