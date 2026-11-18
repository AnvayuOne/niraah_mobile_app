import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/features/cycle/domain/cycle.dart';
import 'package:niraah/sample/sample_cycle.dart';

/// Spec 010 AC10: the same logs give the same prediction on web and mobile.
/// test/fixtures/cycle-cases.json is a copy of
/// niraah-platform/design/sample/cycle-cases.json, which web runs too.
void main() {
  final Map<String, dynamic> file = jsonDecode(File('test/fixtures/cycle-cases.json').readAsStringSync()) as Map<String, dynamic>;

  Map<String, Object?> asMap(CycleSummary s) => switch (s) {
        CycleNoData() => <String, Object?>{'state': 'noData'},
        CycleOff(:final CycleMarker reason) => <String, Object?>{
            'state': 'off',
            'reason': switch (reason) {
              CycleMarker.pregnant => 'pregnant',
              CycleMarker.breastfeeding => 'breastfeeding',
              CycleMarker.hormonalContraception => 'hormonal_contraception',
              CycleMarker.noPeriods => 'no_periods',
            },
          },
        final CycleEstimate e => <String, Object?>{
            'state': 'estimate',
            'basis': e.basis.name,
            'dayOfCycle': e.dayOfCycle,
            'ringLength': e.ringLength,
            'meanLength': e.meanLength,
            'halfWidth': e.halfWidth,
            'windowStart': e.windowStart,
            'windowEnd': e.windowEnd,
            'daysToNext': e.daysToNext == null ? null : <int>[e.daysToNext!.$1, e.daysToNext!.$2],
            'periodLength': e.periodLength,
            'fertileStart': e.fertileStart,
            'ovulationDay': e.ovulationDay,
            'phase': e.phase?.name,
            'late': e.late,
          },
      };

  for (final dynamic raw in file['cases'] as List<dynamic>) {
    final Map<String, dynamic> c = raw as Map<String, dynamic>;
    test(c['name'] as String, () {
      final CycleSummary result = summariseCycle(
        today: c['today'] as String,
        periods: <Period>[
          for (final dynamic p in c['periods'] as List<dynamic>)
            Period(start: (p as Map<String, dynamic>)['start'] as String, end: p['end'] as String?),
        ],
        regularity: c['regularity'] as String?,
        markers: <CycleMarker>[for (final dynamic m in c['markers'] as List<dynamic>) cycleMarkerFrom(m as String)!],
      );
      final Map<String, Object?> got = asMap(result);
      (c['expect'] as Map<String, dynamic>).forEach((String key, dynamic want) {
        expect(got[key], want, reason: '$key in "${c['name']}"');
      });
    });
  }
}
