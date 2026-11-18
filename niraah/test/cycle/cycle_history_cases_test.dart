import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/features/cycle/domain/cycle.dart';
import 'package:niraah/sample/sample_cycle.dart';

/// Rules 12 to 16, shared with web. test/fixtures/cycle-history-cases.json is a
/// copy of niraah-platform/design/sample/cycle-history-cases.json.
void main() {
  final Map<String, dynamic> file =
      jsonDecode(File('test/fixtures/cycle-history-cases.json').readAsStringSync()) as Map<String, dynamic>;

  for (final dynamic raw in file['cases'] as List<dynamic>) {
    final Map<String, dynamic> c = raw as Map<String, dynamic>;
    test(c['name'] as String, () {
      final CycleHistoryResult r = cycleHistory(
        today: c['today'] as String,
        periods: <Period>[
          for (final dynamic p in c['periods'] as List<dynamic>)
            Period(start: (p as Map<String, dynamic>)['start'] as String, end: p['end'] as String?),
        ],
        markers: <CycleMarker>[for (final dynamic m in c['markers'] as List<dynamic>) cycleMarkerFrom(m as String)!],
        dailyFlow: (c['dailyFlow'] as Map<String, dynamic>).cast<String, String>(),
        regularity: c['regularity'] as String?,
      );
      final Map<String, Object?> got = <String, Object?>{
        'history': <Map<String, Object?>>[
          for (final CycleHistoryRow h in r.history) <String, Object?>{'start': h.start, 'cycleLength': h.cycleLength, 'periodLength': h.periodLength},
        ],
        'average': r.average,
        'range': r.range == null ? null : <int>[r.range!.$1, r.range!.$2],
        'pattern': r.pattern == null ? null : <String, int>{'count': r.pattern!.count, 'min': r.pattern!.min, 'max': r.pattern!.max},
        'advice': r.advice,
      };
      (c['expect'] as Map<String, dynamic>).forEach((String key, dynamic want) {
        expect(got[key], want, reason: '$key in "${c['name']}"');
      });
    });
  }
}
