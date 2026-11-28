import 'package:intl/intl.dart';

import '../domain/devices.dart';

final NumberFormat _whole = NumberFormat.decimalPattern('en_IN')..maximumFractionDigits = 0;
final NumberFormat _one = NumberFormat.decimalPattern('en_IN')..maximumFractionDigits = 1;

/// A reading as words she reads (spec 016 §3.4): stated, never graded. Matches apps/web/src/features/devices/format.ts.
String formatReading(String kind, double value) => switch (kind) {
      HealthKinds.steps => '${_whole.format(value)} steps',
      HealthKinds.activeMinutes => '${_whole.format(value)} min',
      HealthKinds.sleep => _sleep(value),
      HealthKinds.restingHeartRate => '${_whole.format(value)} bpm',
      HealthKinds.hrv => '${_whole.format(value)} ms',
      HealthKinds.weight => '${_one.format(value)} kg',
      HealthKinds.basalBodyTemperature => '${_one.format(value)} °C',
      _ => _one.format(value),
    };

String _sleep(double minutes) {
  final int m = minutes.round();
  final int h = m ~/ 60;
  return h > 0 ? '$h h ${m % 60} min' : '$m min';
}
