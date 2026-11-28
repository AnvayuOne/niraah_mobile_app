import 'dart:io' show Platform;

import 'package:health/health.dart';

import '../domain/device_sync.dart' show isoDay;
import '../domain/devices.dart';

/// Health Connect (Android) and Apple Health (iPhone) through the `health` package (spec 016 §1, plan 016 "Flutter").
/// Only read permissions are asked; Niraah writes nothing back (spec 016 "Out of scope").
class HealthPackageReader implements HealthReader {
  HealthPackageReader([Health? health]) : _health = health ?? Health();

  final Health _health;
  bool _configured = false;

  Future<void> _ready() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  @override
  HealthPlatformKind get platform => Platform.isIOS ? HealthPlatformKind.appleHealth : HealthPlatformKind.healthConnect;

  /// Health Connect has no basal body temperature type the package reads; active minutes come from workouts there.
  @override
  Set<String> get supportedKinds => platform == HealthPlatformKind.appleHealth
      ? HealthKinds.all.toSet()
      : HealthKinds.all.where((String k) => k != HealthKinds.basalBodyTemperature).toSet();

  List<HealthDataType> _types(Set<String> kinds) {
    final bool ios = platform == HealthPlatformKind.appleHealth;
    return <HealthDataType>{
      for (final String k in kinds)
        ...switch (k) {
          HealthKinds.steps => <HealthDataType>[HealthDataType.STEPS],
          HealthKinds.activeMinutes => <HealthDataType>[ios ? HealthDataType.EXERCISE_TIME : HealthDataType.WORKOUT],
          HealthKinds.sleep => <HealthDataType>[
              HealthDataType.SLEEP_ASLEEP,
              HealthDataType.SLEEP_LIGHT,
              HealthDataType.SLEEP_DEEP,
              HealthDataType.SLEEP_REM,
              HealthDataType.SLEEP_AWAKE,
            ],
          HealthKinds.restingHeartRate => <HealthDataType>[HealthDataType.RESTING_HEART_RATE],
          HealthKinds.hrv => <HealthDataType>[ios ? HealthDataType.HEART_RATE_VARIABILITY_SDNN : HealthDataType.HEART_RATE_VARIABILITY_RMSSD],
          HealthKinds.weight => <HealthDataType>[HealthDataType.WEIGHT],
          HealthKinds.basalBodyTemperature => ios ? <HealthDataType>[HealthDataType.BASAL_BODY_TEMPERATURE] : <HealthDataType>[],
          HealthKinds.periods => <HealthDataType>[HealthDataType.MENSTRUATION_FLOW],
          _ => <HealthDataType>[],
        },
    }.toList();
  }

  @override
  Future<HealthAvailability> availability() async {
    if (platform == HealthPlatformKind.appleHealth) return HealthAvailability.available;
    await _ready();
    final HealthConnectSdkStatus? s = await _health.getHealthConnectSdkStatus();
    return switch (s) {
      HealthConnectSdkStatus.sdkAvailable => HealthAvailability.available,
      HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired => HealthAvailability.needsInstall,
      _ => HealthAvailability.unavailable,
    };
  }

  @override
  Future<void> install() => _health.installHealthConnect();

  @override
  Future<bool> requestAccess(Set<String> kinds) async {
    await _ready();
    final List<HealthDataType> types = _types(kinds);
    if (types.isEmpty) return false;
    return _health.requestAuthorization(types, permissions: types.map((_) => HealthDataAccess.READ).toList());
  }

  @override
  Future<HealthRead> read(Set<String> kinds, DateTime from, DateTime to) async {
    await _ready();
    final List<RawSample> samples = <RawSample>[];
    // Steps per day from the platform's own total, which removes duplicates between a phone and a watch.
    if (kinds.contains(HealthKinds.steps)) {
      for (DateTime d = DateTime(from.year, from.month, from.day); d.isBefore(to); d = d.add(const Duration(days: 1))) {
        final DateTime end = d.add(const Duration(days: 1));
        final int n = await _health.getTotalStepsInInterval(d, end.isAfter(to) ? to : end);
        if (n > 0) samples.add(RawSample(kind: HealthKinds.steps, from: d, to: end, value: n.toDouble()));
      }
    }
    final List<HealthDataType> types = _types(kinds)..remove(HealthDataType.STEPS);
    final List<DateTime> flowDays = <DateTime>[];
    if (types.isEmpty) return HealthRead(samples: samples);
    final List<HealthDataPoint> points = _health.removeDuplicates(await _health.getHealthDataFromTypes(types: types, startTime: from, endTime: to));
    for (final HealthDataPoint p in points) {
      final HealthValue v = p.value;
      final double minutes = p.dateTo.difference(p.dateFrom).inSeconds / 60;
      switch (p.type) {
        case HealthDataType.MENSTRUATION_FLOW:
          if (v is MenstruationFlowHealthValue && v.flow != MenstrualFlow.none) flowDays.add(p.dateFrom.toLocal());
        case HealthDataType.WORKOUT:
          samples.add(RawSample(kind: HealthKinds.activeMinutes, from: p.dateFrom, to: p.dateTo, value: minutes));
        case HealthDataType.SLEEP_ASLEEP || HealthDataType.SLEEP_LIGHT || HealthDataType.SLEEP_DEEP || HealthDataType.SLEEP_REM || HealthDataType.SLEEP_AWAKE:
          final String stage = switch (p.type) {
            HealthDataType.SLEEP_LIGHT => 'light',
            HealthDataType.SLEEP_DEEP => 'deep',
            HealthDataType.SLEEP_REM => 'rem',
            HealthDataType.SLEEP_AWAKE => 'awake',
            _ => 'asleep',
          };
          samples.add(RawSample(kind: HealthKinds.sleep, from: p.dateFrom, to: p.dateTo, value: minutes, stage: stage));
        default:
          if (v is! NumericHealthValue) continue;
          final double n = v.numericValue.toDouble();
          final String? kind = switch (p.type) {
            HealthDataType.EXERCISE_TIME => HealthKinds.activeMinutes,
            HealthDataType.RESTING_HEART_RATE => HealthKinds.restingHeartRate,
            HealthDataType.HEART_RATE_VARIABILITY_RMSSD || HealthDataType.HEART_RATE_VARIABILITY_SDNN => HealthKinds.hrv,
            HealthDataType.WEIGHT => HealthKinds.weight,
            HealthDataType.BASAL_BODY_TEMPERATURE => HealthKinds.basalBodyTemperature,
            _ => null,
          };
          if (kind == null) continue;
          samples.add(RawSample(
            kind: kind,
            from: p.dateFrom,
            to: p.dateTo,
            value: n,
            method: p.type == HealthDataType.HEART_RATE_VARIABILITY_SDNN ? 'sdnn' : (p.type == HealthDataType.HEART_RATE_VARIABILITY_RMSSD ? 'rmssd' : null),
          ));
      }
    }
    return HealthRead(samples: samples, flowDays: flowDays);
  }

  /// A short label for the phone, kept local; used only as the connection's name.
  static String deviceLabel() => Platform.isIOS ? 'iPhone' : 'Android phone';

  /// For tests and logs: the day a sample counts towards.
  static String dayOf(DateTime d) => isoDay(d.toLocal());
}
