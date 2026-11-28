import '../../../core/network/niraah_api.dart';
import '../domain/devices.dart';

/// Connected devices on `/api/v1/me/health-devices` (spec 016), matching apps/web/src/api/devices-repository.ts.
class ApiDevicesRepository implements DevicesRepository {
  ApiDevicesRepository(this._api);

  final NiraahApi _api;

  @override
  Future<DevicesDocument> load() async => DevicesParser.document((await _api.get('/me/health-devices')).orThrow());

  @override
  Future<HealthSource> connect({required HealthPlatformKind platform, String? deviceName, required List<String> kinds}) async {
    final Map<String, dynamic> r = (await _api.post('/me/health-devices', <String, dynamic>{
      'platform': platform.wire,
      if (deviceName != null && deviceName.trim().isNotEmpty) 'deviceName': deviceName.trim(),
      'kinds': kinds,
    }))
        .orThrow();
    return DevicesParser.source(r);
  }

  @override
  Future<SyncResult> sync(String sourceId, {required List<DailyReading> readings, required List<DevicePeriod> periods}) async {
    final Map<String, dynamic> r = (await _api.post('/me/health-devices/${Uri.encodeComponent(sourceId)}/sync', <String, dynamic>{
      'readings': readings.map((DailyReading x) => x.toJson()).toList(),
      'periods': periods.map((DevicePeriod x) => x.toJson()).toList(),
    }))
        .orThrow();
    return SyncResult(
      saved: (r['saved'] as num?)?.toInt() ?? 0,
      skipped: (r['skipped'] as num?)?.toInt() ?? 0,
      periodsAdded: (r['periodsAdded'] as num?)?.toInt() ?? 0,
      lastSyncedAt: DateTime.tryParse(r['lastSyncedAt'] as String? ?? ''),
    );
  }

  @override
  Future<void> disconnect(String sourceId, {required bool deleteReadings}) async {
    (await _api.post('/me/health-devices/${Uri.encodeComponent(sourceId)}/disconnect', <String, dynamic>{'deleteReadings': deleteReadings})).orThrow();
  }
}

abstract final class DevicesParser {
  static HealthSource source(Map<dynamic, dynamic> j) => HealthSource(
        id: j['id'] as String,
        platform: HealthPlatformKind.fromWire(j['platform'] as String?),
        platformName: j['platformName'] as String? ?? '',
        deviceName: j['deviceName'] as String?,
        kinds: ((j['kinds'] as List<dynamic>?) ?? const <dynamic>[]).cast<String>(),
        connected: j['status'] == 'connected',
        connectedAt: DateTime.parse(j['connectedAt'] as String),
        lastSyncedAt: DateTime.tryParse(j['lastSyncedAt'] as String? ?? ''),
      );

  static ReadingDay _day(Map<dynamic, dynamic> j) => ReadingDay(j['date'] as String, (j['value'] as num).toDouble());

  static DevicesDocument document(Map<dynamic, dynamic> j) {
    final Map<dynamic, dynamic> limits = (j['limits'] as Map<dynamic, dynamic>?) ?? const <dynamic, dynamic>{};
    return DevicesDocument(
      note: j['note'] as String? ?? '',
      sources: ((j['sources'] as List<dynamic>?) ?? const <dynamic>[]).map((dynamic s) => source(s as Map<dynamic, dynamic>)).toList(),
      readings: ((j['readings'] as List<dynamic>?) ?? const <dynamic>[]).map((dynamic r) {
        final Map<dynamic, dynamic> m = r as Map<dynamic, dynamic>;
        return ReadingSeries(
          kind: m['kind'] as String,
          name: m['name'] as String,
          unit: m['unit'] as String,
          latest: _day(m['latest'] as Map<dynamic, dynamic>),
          average7: (m['average7'] as num?)?.toDouble(),
          days: ((m['days'] as List<dynamic>?) ?? const <dynamic>[]).map((dynamic d) => _day(d as Map<dynamic, dynamic>)).toList(),
        );
      }).toList(),
      offered: ((j['offered'] as List<dynamic>?) ?? HealthKinds.all).cast<String>(),
      limits: SyncLimits(
        readings: (limits['readings'] as num?)?.toInt() ?? 400,
        periods: (limits['periods'] as num?)?.toInt() ?? 24,
        daysBack: (limits['daysBack'] as num?)?.toInt() ?? 90,
        firstSyncDays: (limits['firstSyncDays'] as num?)?.toInt() ?? 30,
      ),
    );
  }
}
