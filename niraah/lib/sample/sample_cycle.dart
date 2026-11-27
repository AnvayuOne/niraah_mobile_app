// SAMPLE ONLY. Implements niraah-platform/design/sample/cycle-rules.md
// exactly, line for line with apps/web/src/sample/cycle.ts; the real rules run
// on the server (spec 010 §3 rule 7). Shared cases: design/sample/cycle-cases.json
// (copied to test/fixtures/cycle-cases.json).

import 'dart:math' as math;

import '../features/cycle/domain/cycle.dart';

/// Rule 5: at least two cycle lengths (platform setting, default two).
const int minCycles = 2;

/// Rules 15 and 16 thresholds (platform settings in the real product).
const int noPeriodDays = 90;
const int longBleedingDays = 10;

const String adviceNoPeriod90 = 'cycle.no_period_90';
const String adviceLongBleeding = 'cycle.long_bleeding';

class CycleHistoryResult {
  const CycleHistoryResult({required this.history, required this.advice, this.average, this.range, this.pattern});

  final List<CycleHistoryRow> history;
  final int? average;
  final (int, int)? range;
  final CyclePattern? pattern;

  /// Content keys of the advice cards that apply.
  final List<String> advice;
}

/// Rules 12 to 16: history, average and range, pattern, advice keys. Line for
/// line with `cycleHistory` in apps/web/src/sample/cycle.ts. Shared cases:
/// design/sample/cycle-history-cases.json.
CycleHistoryResult cycleHistory({
  required IsoDate today,
  required List<Period> periods,
  required List<CycleMarker> markers,
  required Map<IsoDate, String> dailyFlow,
  String? regularity,
}) {
  final List<Period> sorted = <Period>[...periods]..sort((Period a, Period b) => a.start.compareTo(b.start));
  // Rule 12.
  final List<CycleHistoryRow> history = <CycleHistoryRow>[
    for (int i = 0; i < sorted.length - 1; i++)
      CycleHistoryRow(
        start: sorted[i].start,
        cycleLength: IsoDates.daysBetween(sorted[i].start, sorted[i + 1].start),
        periodLength: sorted[i].end == null ? null : IsoDates.daysBetween(sorted[i].start, sorted[i].end!) + 1,
      ),
  ];
  final List<int> all = history.map((CycleHistoryRow h) => h.cycleLength).toList();
  final List<int> lengths = all.length > 6 ? all.sublist(all.length - 6) : all;

  // Rules 13 and 14.
  final bool enough = lengths.length >= minCycles;
  final int? average = enough ? (lengths.fold<int>(0, (int s, int l) => s + l) / lengths.length).round() : null;
  final (int, int)? range = enough ? (lengths.reduce(math.min), lengths.reduce(math.max)) : null;
  final CyclePattern? pattern =
      lengths.length >= 3 ? CyclePattern(count: lengths.length, min: lengths.reduce(math.min), max: lengths.reduce(math.max)) : null;

  // Rule 15.
  final List<String> advice = <String>[];
  final bool off = summariseCycle(today: today, periods: periods, markers: markers, regularity: regularity) is CycleOff;
  if (sorted.isNotEmpty && !off && IsoDates.daysBetween(sorted.last.start, today) >= noPeriodDays) advice.add(adviceNoPeriod90);

  // Rule 16: consecutive days with flow, ending today or yesterday.
  bool bleeding(IsoDate d) {
    final String? f = dailyFlow[d];
    return f != null && f != 'none';
  }

  IsoDate? end = bleeding(today) ? today : (bleeding(IsoDates.addDays(today, -1)) ? IsoDates.addDays(today, -1) : null);
  int run = 0;
  while (end != null && bleeding(end)) {
    run += 1;
    end = IsoDates.addDays(end, -1);
  }
  if (run >= longBleedingDays) advice.add(adviceLongBleeding);

  return CycleHistoryResult(history: history, average: average, range: range, pattern: pattern, advice: advice);
}

/// Rule 7: wide window from the assessment answer, in days from the latest start.
const Map<String, (int, int)> _assessmentRanges = <String, (int, int)>{
  'regular': (21, 35),
  'sometimes_off': (21, 40),
  'irregular': (21, 45),
};

CycleSummary summariseCycle({
  required IsoDate today,
  required List<Period> periods,
  required List<CycleMarker> markers,
  String? regularity,
}) {
  // Rule 1: predictions off.
  final CycleMarker? off = markers.where((CycleMarker m) => m != CycleMarker.breastfeeding).firstOrNull;
  if (off != null) return CycleOff(off);
  if (regularity == 'pregnant') return const CycleOff(CycleMarker.pregnant);

  // Rule 2: no period logged.
  final List<Period> sorted = <Period>[...periods]..sort((Period a, Period b) => a.start.compareTo(b.start));
  if (sorted.isEmpty) return const CycleNoData();
  final Period latest = sorted.last;

  // Rule 3.
  final int dayOfCycle = IsoDates.daysBetween(latest.start, today) + 1;

  // Rule 4: gaps between consecutive starts, last six.
  final List<int> all = <int>[for (int i = 1; i < sorted.length; i++) IsoDates.daysBetween(sorted[i - 1].start, sorted[i].start)];
  final List<int> lengths = all.length > 6 ? all.sublist(all.length - 6) : all;

  // Rule 9: period length from ended periods, or 5.
  final List<Period> ended = sorted.where((Period p) => p.end != null).toList();
  final int periodLength = ended.isEmpty
      ? 5
      : (ended.fold<int>(0, (int s, Period p) => s + IsoDates.daysBetween(p.start, p.end!) + 1) / ended.length).round();

  int? meanLength;
  int? halfWidth;
  IsoDate? windowStart;
  IsoDate? windowEnd;
  int? fertileStart;
  int? ovulationDay;
  PredictionBasis basis = PredictionBasis.assessment;

  if (lengths.length >= minCycles) {
    // Rule 6: weighted mean 1..n oldest to newest; population spread.
    basis = PredictionBasis.logs;
    final int n = lengths.length;
    final double weightSum = n * (n + 1) / 2;
    double weighted = 0;
    for (int i = 0; i < n; i++) {
      weighted += lengths[i] * (i + 1);
    }
    weighted /= weightSum;
    final double mean = lengths.fold<int>(0, (int s, int l) => s + l) / n;
    final double spread = math.sqrt(lengths.fold<double>(0, (double s, int l) => s + (l - mean) * (l - mean)) / n);
    meanLength = weighted.round();
    halfWidth = math.max(2, (1.5 * spread - 1e-9).ceil());
    windowStart = IsoDates.addDays(latest.start, meanLength - halfWidth);
    windowEnd = IsoDates.addDays(latest.start, meanLength + halfWidth);
    // Rule 8: fertile window only when cycles are steady.
    if (spread <= 3) {
      ovulationDay = meanLength - 14;
      fertileStart = ovulationDay - 5;
    }
  } else {
    // Rule 7.
    final (int, int)? range = regularity == null ? null : _assessmentRanges[regularity];
    if (range != null) {
      windowStart = IsoDates.addDays(latest.start, range.$1);
      windowEnd = IsoDates.addDays(latest.start, range.$2);
    }
  }

  // Rule 9: phase, estimated.
  Phase? phase;
  if (dayOfCycle <= periodLength) {
    phase = Phase.menstrual;
  } else if (fertileStart != null && ovulationDay != null) {
    if (dayOfCycle < fertileStart) {
      phase = Phase.follicular;
    } else if (dayOfCycle <= ovulationDay + 1) {
      phase = Phase.ovulatory;
    } else {
      phase = Phase.luteal;
    }
  }

  // Rules 10 and 11.
  final bool late = windowEnd != null && today.compareTo(windowEnd) > 0;
  final (int, int)? daysToNext = windowStart != null && windowEnd != null
      ? (math.max(0, IsoDates.daysBetween(today, windowStart)), math.max(0, IsoDates.daysBetween(today, windowEnd)))
      : null;

  return CycleEstimate(
    basis: basis,
    dayOfCycle: dayOfCycle,
    ringLength: meanLength ?? 28,
    meanLength: meanLength,
    halfWidth: halfWidth,
    windowStart: windowStart,
    windowEnd: windowEnd,
    daysToNext: daysToNext,
    periodLength: periodLength,
    fertileStart: fertileStart,
    ovulationDay: ovulationDay,
    phase: phase,
    late: late,
  );
}
