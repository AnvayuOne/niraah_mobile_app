import 'devices.dart';

/// Turns what the phone's health platform holds into the daily values and periods the API takes, and sends them
/// in batches within the server's limits (spec 016 §2, §4, AC20).
class DeviceSync {
  DeviceSync({required this.reader, required this.repository, DateTime Function()? now}) : _now = now ?? DateTime.now;

  final HealthReader reader;
  final DevicesRepository repository;
  final DateTime Function() _now;

  /// First sync: the last 30 days. After that: from the day before the last sync, so a day that was still going
  /// is sent again whole (a resend replaces it on the server, §2.3).
  DateTime windowStart(HealthSource source, SyncLimits limits) {
    final DateTime now = _now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime? last = source.lastSyncedAt?.toLocal();
    if (last == null) return today.subtract(Duration(days: limits.firstSyncDays - 1));
    final DateTime from = DateTime(last.year, last.month, last.day).subtract(const Duration(days: 1));
    final DateTime oldest = today.subtract(Duration(days: limits.daysBack));
    return from.isBefore(oldest) ? oldest : from;
  }

  Future<SyncResult> sync(HealthSource source, {SyncLimits limits = const SyncLimits()}) async {
    final Set<String> kinds = source.kinds.where(reader.supportedKinds.contains).toSet();
    final DateTime from = windowStart(source, limits);
    final HealthRead read = await reader.read(kinds, from, _now());
    final List<DailyReading> readings = dailyReadings(read.samples, platform: reader.platform);
    final List<DevicePeriod> periods = kinds.contains(HealthKinds.periods) ? periodsFromFlow(read.flowDays) : const <DevicePeriod>[];
    SyncResult total = SyncResult.none;
    for (final (List<DailyReading>, List<DevicePeriod>) b in batches(readings, periods, limits)) {
      total = total + await repository.sync(source.id, readings: b.$1, periods: b.$2);
    }
    return total;
  }
}

String isoDay(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

double _round(double v, [int places = 2]) {
  final double f = places == 0 ? 1 : (places == 1 ? 10 : 100);
  return (v * f).round() / f;
}

/// One value per kind per local day (spec 016 §2.2): steps and active minutes totalled, sleep as minutes asleep on
/// the day she woke with its stages, resting heart rate and HRV averaged, weight and temperature the day's last.
List<DailyReading> dailyReadings(List<RawSample> samples, {required HealthPlatformKind platform}) {
  final Map<String, Map<String, List<RawSample>>> byKindDay = <String, Map<String, List<RawSample>>>{};
  for (final RawSample s in samples) {
    // Sleep belongs to the day she woke up (§2.2); everything else to the day it started.
    final DateTime at = (s.kind == HealthKinds.sleep ? s.to : s.from).toLocal();
    byKindDay.putIfAbsent(s.kind, () => <String, List<RawSample>>{}).putIfAbsent(isoDay(at), () => <RawSample>[]).add(s);
  }
  final List<DailyReading> out = <DailyReading>[];
  for (final MapEntry<String, Map<String, List<RawSample>>> k in byKindDay.entries) {
    for (final MapEntry<String, List<RawSample>> d in k.value.entries) {
      final List<RawSample> xs = d.value..sort((RawSample a, RawSample b) => a.from.compareTo(b.from));
      switch (k.key) {
        case HealthKinds.steps:
          out.add(DailyReading(kind: k.key, date: d.key, value: xs.fold<double>(0, (double a, RawSample s) => a + s.value).roundToDouble()));
        case HealthKinds.activeMinutes:
          out.add(DailyReading(kind: k.key, date: d.key, value: xs.fold<double>(0, (double a, RawSample s) => a + s.value).clamp(0, 1440).roundToDouble()));
        case HealthKinds.sleep:
          final Map<String, double> stages = <String, double>{};
          for (final RawSample s in xs) {
            final String stage = s.stage ?? 'asleep';
            stages[stage] = (stages[stage] ?? 0) + s.value;
          }
          final double asleep = (stages['asleep'] ?? 0) + (stages['light'] ?? 0) + (stages['deep'] ?? 0) + (stages['rem'] ?? 0);
          if (asleep <= 0) continue;
          final Map<String, int> detail = <String, int>{
            for (final String st in <String>['light', 'deep', 'rem', 'awake'])
              if (stages[st] != null) st: stages[st]!.round(),
          };
          out.add(DailyReading(kind: k.key, date: d.key, value: asleep.clamp(0, 1440).roundToDouble(), detail: detail.isEmpty ? null : <String, dynamic>{'stages': detail}));
        case HealthKinds.restingHeartRate:
          out.add(DailyReading(kind: k.key, date: d.key, value: _round(xs.fold<double>(0, (double a, RawSample s) => a + s.value) / xs.length, 0)));
        case HealthKinds.hrv:
          final double avg = xs.fold<double>(0, (double a, RawSample s) => a + s.value) / xs.length;
          final String method = xs.first.method ?? (platform == HealthPlatformKind.appleHealth ? 'sdnn' : 'rmssd');
          out.add(DailyReading(kind: k.key, date: d.key, value: _round(avg, 1), detail: <String, dynamic>{'method': method}));
        case HealthKinds.weight:
        case HealthKinds.basalBodyTemperature:
          out.add(DailyReading(kind: k.key, date: d.key, value: _round(xs.last.value)));
      }
    }
  }
  out.sort((DailyReading a, DailyReading b) => a.date == b.date ? a.kind.compareTo(b.kind) : a.date.compareTo(b.date));
  return out;
}

/// Days with flow, joined into periods; a gap of more than one day starts a new period (spec 016 §4).
List<DevicePeriod> periodsFromFlow(List<DateTime> flowDays) {
  final List<DateTime> days = flowDays.map((DateTime d) => DateTime(d.year, d.month, d.day)).toSet().toList()..sort();
  final List<DevicePeriod> out = <DevicePeriod>[];
  DateTime? start;
  DateTime? end;
  for (final DateTime d in days) {
    if (start != null && d.difference(end!).inDays <= 2) {
      end = d;
      continue;
    }
    if (start != null) out.add(DevicePeriod(isoDay(start), isoDay(end!)));
    start = d;
    end = d;
  }
  if (start != null) out.add(DevicePeriod(isoDay(start), isoDay(end!)));
  return out;
}

/// Splits into requests of at most `limits.readings` readings and `limits.periods` periods (spec 016 §2.5).
List<(List<DailyReading>, List<DevicePeriod>)> batches(List<DailyReading> readings, List<DevicePeriod> periods, SyncLimits limits) {
  final List<(List<DailyReading>, List<DevicePeriod>)> out = <(List<DailyReading>, List<DevicePeriod>)>[];
  int r = 0;
  int p = 0;
  while (r < readings.length || p < periods.length) {
    final int rEnd = (r + limits.readings).clamp(0, readings.length);
    final int pEnd = (p + limits.periods).clamp(0, periods.length);
    out.add((readings.sublist(r, rEnd), periods.sublist(p, pEnd)));
    r = rEnd;
    p = pEnd;
  }
  // Nothing new still counts as a sync, so "Last synced" moves on (§2.6).
  if (out.isEmpty) out.add((const <DailyReading>[], const <DevicePeriod>[]));
  return out;
}
