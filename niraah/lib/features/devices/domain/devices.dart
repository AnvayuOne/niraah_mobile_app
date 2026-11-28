import 'package:equatable/equatable.dart';

/// Connected devices (spec 016). Health Connect on Android and Apple Health on iPhone are read on the phone and
/// sent to `/api/v1/me/health-devices`; the server keeps one value per kind per day.

/// Kinds a member can share (spec 016 §1.2). `periods` go to her cycle log (§4).
abstract final class HealthKinds {
  static const String steps = 'steps';
  static const String activeMinutes = 'active_minutes';
  static const String sleep = 'sleep';
  static const String restingHeartRate = 'resting_heart_rate';
  static const String hrv = 'hrv';
  static const String weight = 'weight';
  static const String basalBodyTemperature = 'basal_body_temperature';
  static const String periods = 'periods';

  static const List<String> all = <String>[steps, activeMinutes, sleep, restingHeartRate, hrv, weight, basalBodyTemperature, periods];
}

enum HealthPlatformKind {
  healthConnect('health_connect'),
  appleHealth('apple_health');

  const HealthPlatformKind(this.wire);
  final String wire;

  static HealthPlatformKind? fromWire(String? v) {
    for (final HealthPlatformKind p in values) {
      if (p.wire == v) return p;
    }
    return null;
  }
}

class HealthSource extends Equatable {
  const HealthSource({
    required this.id,
    required this.platform,
    required this.platformName,
    required this.deviceName,
    required this.kinds,
    required this.connected,
    required this.connectedAt,
    required this.lastSyncedAt,
  });

  final String id;
  final HealthPlatformKind? platform;
  final String platformName;
  final String? deviceName;
  final List<String> kinds;
  final bool connected;
  final DateTime connectedAt;
  final DateTime? lastSyncedAt;

  @override
  List<Object?> get props => <Object?>[id, platform, deviceName, kinds, connected, connectedAt, lastSyncedAt];
}

class ReadingDay extends Equatable {
  const ReadingDay(this.date, this.value);

  final String date;
  final double value;

  @override
  List<Object?> get props => <Object?>[date, value];
}

class ReadingSeries extends Equatable {
  const ReadingSeries({required this.kind, required this.name, required this.unit, required this.latest, required this.average7, required this.days});

  final String kind;
  final String name;
  final String unit;
  final ReadingDay latest;
  final double? average7;
  final List<ReadingDay> days;

  @override
  List<Object?> get props => <Object?>[kind, latest, average7, days];
}

class SyncLimits extends Equatable {
  const SyncLimits({this.readings = 400, this.periods = 24, this.daysBack = 90, this.firstSyncDays = 30});

  final int readings;
  final int periods;
  final int daysBack;
  final int firstSyncDays;

  @override
  List<Object?> get props => <Object?>[readings, periods, daysBack, firstSyncDays];
}

class DevicesDocument extends Equatable {
  const DevicesDocument({required this.note, required this.sources, required this.readings, required this.offered, this.limits = const SyncLimits()});

  final String note;
  final List<HealthSource> sources;
  final List<ReadingSeries> readings;

  /// What may be offered when she connects; no weight on a teen account (spec 016 §1.5).
  final List<String> offered;
  final SyncLimits limits;

  HealthSource? connectedOn(HealthPlatformKind platform) {
    for (final HealthSource s in sources) {
      if (s.connected && s.platform == platform) return s;
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[note, sources, readings, offered, limits];
}

/// One value for one kind on one day, as the server stores it (spec 016 §2.2).
class DailyReading extends Equatable {
  const DailyReading({required this.kind, required this.date, required this.value, this.detail});

  final String kind;
  final String date;
  final double value;
  final Map<String, dynamic>? detail;

  Map<String, dynamic> toJson() => <String, dynamic>{'kind': kind, 'date': date, 'value': value, if (detail != null) 'detail': detail};

  @override
  List<Object?> get props => <Object?>[kind, date, value, detail];
}

class DevicePeriod extends Equatable {
  const DevicePeriod(this.start, [this.end]);

  final String start;
  final String? end;

  Map<String, dynamic> toJson() => <String, dynamic>{'start': start, if (end != null) 'end': end};

  @override
  List<Object?> get props => <Object?>[start, end];
}

class SyncResult extends Equatable {
  const SyncResult({required this.saved, required this.skipped, required this.periodsAdded, required this.lastSyncedAt});

  final int saved;
  final int skipped;
  final int periodsAdded;
  final DateTime? lastSyncedAt;

  SyncResult operator +(SyncResult o) => SyncResult(
        saved: saved + o.saved,
        skipped: skipped + o.skipped,
        periodsAdded: periodsAdded + o.periodsAdded,
        lastSyncedAt: o.lastSyncedAt ?? lastSyncedAt,
      );

  static const SyncResult none = SyncResult(saved: 0, skipped: 0, periodsAdded: 0, lastSyncedAt: null);

  @override
  List<Object?> get props => <Object?>[saved, skipped, periodsAdded, lastSyncedAt];
}

abstract class DevicesRepository {
  Future<DevicesDocument> load();
  Future<HealthSource> connect({required HealthPlatformKind platform, String? deviceName, required List<String> kinds});
  Future<SyncResult> sync(String sourceId, {required List<DailyReading> readings, required List<DevicePeriod> periods});
  Future<void> disconnect(String sourceId, {required bool deleteReadings});
}

/// Whether the phone's health platform can be used (Health Connect may need installing on Android 13 and lower).
enum HealthAvailability { available, needsInstall, unavailable }

/// One sample read from the phone, before it is turned into daily values. Steps arrive already totalled per day,
/// because the platform removes duplicates between the phone and a watch.
class RawSample extends Equatable {
  const RawSample({required this.kind, required this.from, required this.to, required this.value, this.stage, this.method});

  final String kind;
  final DateTime from;
  final DateTime to;
  final double value;

  /// For sleep: `light`, `deep`, `rem`, `awake` or `asleep` (no stage recorded).
  final String? stage;

  /// For HRV: `rmssd` (Health Connect) or `sdnn` (Apple Health).
  final String? method;

  @override
  List<Object?> get props => <Object?>[kind, from, to, value, stage, method];
}

class HealthRead {
  const HealthRead({this.samples = const <RawSample>[], this.flowDays = const <DateTime>[]});

  final List<RawSample> samples;

  /// Days with menstrual flow (not "none"), in local time.
  final List<DateTime> flowDays;
}

/// The phone's health platform, behind an interface so the sync can be tested without one (spec 016 AC20).
abstract class HealthReader {
  HealthPlatformKind get platform;

  /// Kinds this platform can give. Health Connect has no basal body temperature.
  Set<String> get supportedKinds;

  Future<HealthAvailability> availability();
  Future<void> install();

  /// Asks the platform's own permission dialog for exactly these kinds (spec 016 §1.3).
  Future<bool> requestAccess(Set<String> kinds);
  Future<HealthRead> read(Set<String> kinds, DateTime from, DateTime to);
}
