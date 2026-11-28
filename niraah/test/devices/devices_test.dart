import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/di/service_locator.dart';
import 'package:niraah/features/devices/data/api_devices_repository.dart';
import 'package:niraah/features/devices/domain/device_auto_sync.dart';
import 'package:niraah/features/devices/domain/device_sync.dart';
import 'package:niraah/features/devices/domain/devices.dart';
import 'package:niraah/features/devices/presentation/reading_format.dart';

import '../helpers/fake_api.dart';

// Connected devices on the phone (spec 016 AC20), tested with a fake reader and a fake HTTP adapter. Reading a real
// Health Connect or Apple Health store needs a device and is not covered here.

class _FakeReader implements HealthReader {
  _FakeReader(this.data);

  final HealthRead data;
  @override
  HealthPlatformKind get platform => HealthPlatformKind.healthConnect;
  final List<(Set<String>, DateTime, DateTime)> reads = <(Set<String>, DateTime, DateTime)>[];

  @override
  Set<String> get supportedKinds => HealthKinds.all.toSet();
  @override
  Future<HealthAvailability> availability() async => HealthAvailability.available;
  @override
  Future<void> install() async {}
  @override
  Future<bool> requestAccess(Set<String> kinds) async => true;
  @override
  Future<HealthRead> read(Set<String> kinds, DateTime from, DateTime to) async {
    reads.add((kinds, from, to));
    return data;
  }
}

Map<String, dynamic> sourceJson({String? lastSyncedAt, List<String> kinds = const <String>['steps', 'sleep', 'periods']}) => <String, dynamic>{
      'id': '11111111-1111-1111-1111-111111111111',
      'platform': 'health_connect',
      'platformName': 'Health Connect',
      'deviceName': 'Android phone',
      'kinds': kinds,
      'status': 'connected',
      'connectedAt': '2026-11-01T05:00:00.000Z',
      'disconnectedAt': null,
      'lastSyncedAt': lastSyncedAt,
    };

void main() {
  group('daily values (spec 016 §2.2)', () {
    test('steps are totalled per day, sleep counts on the wake day with stages, HRV is averaged with its method', () {
      final List<DailyReading> out = dailyReadings(<RawSample>[
        RawSample(kind: HealthKinds.steps, from: DateTime(2026, 11, 14), to: DateTime(2026, 11, 15), value: 4210),
        // Night of the 14th, she woke on the 15th.
        RawSample(kind: HealthKinds.sleep, from: DateTime(2026, 11, 14, 23), to: DateTime(2026, 11, 15, 2), value: 180, stage: 'light'),
        RawSample(kind: HealthKinds.sleep, from: DateTime(2026, 11, 15, 2), to: DateTime(2026, 11, 15, 3, 30), value: 90, stage: 'deep'),
        RawSample(kind: HealthKinds.sleep, from: DateTime(2026, 11, 15, 3, 30), to: DateTime(2026, 11, 15, 3, 45), value: 15, stage: 'awake'),
        RawSample(kind: HealthKinds.hrv, from: DateTime(2026, 11, 15, 6), to: DateTime(2026, 11, 15, 6), value: 40),
        RawSample(kind: HealthKinds.hrv, from: DateTime(2026, 11, 15, 7), to: DateTime(2026, 11, 15, 7), value: 45),
        RawSample(kind: HealthKinds.weight, from: DateTime(2026, 11, 15, 7), to: DateTime(2026, 11, 15, 7), value: 61.0),
        RawSample(kind: HealthKinds.weight, from: DateTime(2026, 11, 15, 21), to: DateTime(2026, 11, 15, 21), value: 61.4),
      ], platform: HealthPlatformKind.healthConnect);
      expect(out, containsAll(<DailyReading>[
        const DailyReading(kind: 'steps', date: '2026-11-14', value: 4210),
        const DailyReading(kind: 'sleep', date: '2026-11-15', value: 270, detail: <String, dynamic>{'stages': <String, int>{'light': 180, 'deep': 90, 'awake': 15}}),
        const DailyReading(kind: 'hrv', date: '2026-11-15', value: 42.5, detail: <String, dynamic>{'method': 'rmssd'}),
        const DailyReading(kind: 'weight', date: '2026-11-15', value: 61.4),
      ]));
      expect(out.where((DailyReading r) => r.kind == 'sleep'), hasLength(1));
    });

    test('flow days join into periods; a gap of more than a day starts a new one (§4)', () {
      final List<DevicePeriod> p = periodsFromFlow(<DateTime>[
        DateTime(2026, 10, 1), DateTime(2026, 10, 2), DateTime(2026, 10, 4), // one period, a day without a record inside
        DateTime(2026, 10, 29), DateTime(2026, 10, 30),
      ]);
      expect(p, const <DevicePeriod>[DevicePeriod('2026-10-01', '2026-10-04'), DevicePeriod('2026-10-29', '2026-10-30')]);
    });

    test('batches stay within 400 readings and 24 periods, and an empty sync still sends once (§2.5, §2.6)', () {
      final List<DailyReading> many = List<DailyReading>.generate(850, (int i) => DailyReading(kind: 'steps', date: '2026-11-${(i % 28 + 1).toString().padLeft(2, '0')}', value: 1));
      final List<DevicePeriod> periods = List<DevicePeriod>.generate(30, (int i) => DevicePeriod('2026-01-${(i + 1).toString().padLeft(2, '0')}'));
      final List<(List<DailyReading>, List<DevicePeriod>)> b = batches(many, periods, const SyncLimits());
      expect(b.map((x) => x.$1.length), <int>[400, 400, 50]);
      expect(b.map((x) => x.$2.length), <int>[24, 6, 0]);
      expect(batches(const <DailyReading>[], const <DevicePeriod>[], const SyncLimits()), hasLength(1));
    });
  });

  group('sync over the API (AC20)', () {
    test('first sync reads 30 days; later syncs read from the day before the last sync; requests carry the batch', () async {
      final FakeAdapter adapter = FakeAdapter();
      final ApiDevicesRepository repo = ApiDevicesRepository(fakeApi(adapter));
      final _FakeReader reader = _FakeReader(HealthRead(
        samples: <RawSample>[RawSample(kind: HealthKinds.steps, from: DateTime(2026, 11, 15), to: DateTime(2026, 11, 16), value: 7420)],
        flowDays: <DateTime>[DateTime(2026, 11, 2), DateTime(2026, 11, 3)],
      ));
      final DeviceSync sync = DeviceSync(reader: reader, repository: repo, now: () => DateTime(2026, 11, 15, 10));

      adapter.reply(<String, dynamic>{'saved': 1, 'skipped': 0, 'periodsAdded': 1, 'lastSyncedAt': '2026-11-15T04:30:00.000Z'});
      final SyncResult r = await sync.sync(DevicesParser.source(sourceJson()));
      expect(r.saved, 1);
      expect(r.periodsAdded, 1);
      expect(reader.reads.single.$2, DateTime(2026, 10, 17)); // 30 days including today
      expect(adapter.last.path, '/me/health-devices/11111111-1111-1111-1111-111111111111/sync');
      expect(adapter.lastBody['readings'], <Map<String, dynamic>>[<String, dynamic>{'kind': 'steps', 'date': '2026-11-15', 'value': 7420.0}]);
      expect(adapter.lastBody['periods'], <Map<String, dynamic>>[<String, dynamic>{'start': '2026-11-02', 'end': '2026-11-03'}]);

      adapter.reply(<String, dynamic>{'saved': 1, 'skipped': 0, 'periodsAdded': 0, 'lastSyncedAt': '2026-11-15T04:35:00.000Z'});
      await sync.sync(DevicesParser.source(sourceJson(lastSyncedAt: '2026-11-12T04:30:00.000Z')));
      expect(reader.reads.last.$2, DateTime(2026, 11, 11));
    });

    test('periods are not sent when she did not choose them', () async {
      final FakeAdapter adapter = FakeAdapter();
      final _FakeReader reader = _FakeReader(HealthRead(flowDays: <DateTime>[DateTime(2026, 11, 2)]));
      final DeviceSync sync = DeviceSync(reader: reader, repository: ApiDevicesRepository(fakeApi(adapter)), now: () => DateTime(2026, 11, 15));
      adapter.reply(<String, dynamic>{'saved': 0, 'skipped': 0, 'periodsAdded': 0, 'lastSyncedAt': '2026-11-15T04:30:00.000Z'});
      await sync.sync(DevicesParser.source(sourceJson(kinds: <String>['steps'])));
      expect(adapter.lastBody['periods'], isEmpty);
      expect(reader.reads.single.$1, <String>{'steps'});
    });

    test('connect, document and disconnect requests', () async {
      final FakeAdapter adapter = FakeAdapter();
      final ApiDevicesRepository repo = ApiDevicesRepository(fakeApi(adapter));
      adapter.reply(sourceJson());
      final HealthSource s = await repo.connect(platform: HealthPlatformKind.healthConnect, deviceName: 'Android phone', kinds: <String>['steps']);
      expect(adapter.lastBody, <String, dynamic>{'platform': 'health_connect', 'deviceName': 'Android phone', 'kinds': <String>['steps']});
      expect(s.connected, isTrue);

      adapter.reply(<String, dynamic>{
        'note': 'Readings come from your devices.',
        'sources': <Map<String, dynamic>>[sourceJson()],
        'readings': <Map<String, dynamic>>[
          <String, dynamic>{'kind': 'steps', 'name': 'Steps', 'unit': 'steps', 'latest': <String, dynamic>{'date': '2026-11-15', 'value': 7420}, 'average7': 6100.5, 'days': <Map<String, dynamic>>[<String, dynamic>{'date': '2026-11-15', 'value': 7420}]},
        ],
        'offered': <String>['steps', 'sleep'],
        'limits': <String, dynamic>{'readings': 400, 'periods': 24, 'daysBack': 90, 'firstSyncDays': 30},
      });
      final DevicesDocument doc = await repo.load();
      expect(doc.connectedOn(HealthPlatformKind.healthConnect)?.id, s.id);
      expect(doc.readings.single.average7, 6100.5);
      expect(doc.offered, <String>['steps', 'sleep']);

      adapter.reply(<String, dynamic>{'ok': true});
      await repo.disconnect(s.id, deleteReadings: true);
      expect(adapter.lastBody, <String, dynamic>{'deleteReadings': true});
    });
  });

  test('opening the app syncs a connected source once per run (§2.1)', () async {
    final FakeAdapter adapter = FakeAdapter();
    getIt.registerSingleton<DevicesRepository>(ApiDevicesRepository(fakeApi(adapter)));
    addTearDown(() => getIt.unregister<DevicesRepository>());
    adapter
      ..reply(<String, dynamic>{'note': '', 'sources': <Map<String, dynamic>>[sourceJson(kinds: <String>['steps'])], 'readings': <dynamic>[], 'offered': <String>['steps']})
      ..reply(<String, dynamic>{'saved': 0, 'skipped': 0, 'periodsAdded': 0, 'lastSyncedAt': '2026-11-15T04:30:00.000Z'});
    final _FakeReader reader = _FakeReader(const HealthRead());
    await DeviceAutoSync.once(reader: reader);
    await DeviceAutoSync.once(reader: reader);
    expect(adapter.requests.map((r) => r.path), <String>['/me/health-devices', '/me/health-devices/11111111-1111-1111-1111-111111111111/sync']);
  });

  test('values are stated, never graded (§3.4)', () {
    expect(formatReading('steps', 7420), '7,420 steps');
    expect(formatReading('sleep', 412), '6 h 52 min');
    expect(formatReading('weight', 61.24), '61.2 kg');
  });
}
