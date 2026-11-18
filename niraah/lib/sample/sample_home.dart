// SAMPLE ONLY (constitution §2 rule 6). Stands in for the server's Home
// document (spec 010 §2), mirroring apps/web/src/sample/home-repository.ts:
// cycle rules from design/sample/cycle-rules.md, and the daily suggestion
// chosen by rules from the sample library (no model in the sample, so it is
// the library text as written: spec 009 fallback).

import 'dart:convert';

import '../features/assessment/domain/prescore.dart';
import '../features/cycle/domain/cycle.dart';
import '../features/home/domain/home.dart';
import 'sample_backend.dart';
import 'sample_content.dart';
import 'sample_cycle.dart';
import 'sample_store.dart';

/// Rules shortlist by phase ('any' items after the phase's own); the day of
/// the year rotates the list so the pick is stable all day.
DailySuggestion pickSuggestion(Phase? phase, IsoDate today) {
  final List<Map<String, dynamic>> items =
      ((jsonDecode(sampleDailyContentJson) as Map<String, dynamic>)['items'] as List<dynamic>).cast<Map<String, dynamic>>();
  bool has(Map<String, dynamic> i, String p) => (i['phases'] as List<dynamic>).contains(p);
  final List<Map<String, dynamic>> shortlist = <Map<String, dynamic>>[
    if (phase != null) ...items.where((Map<String, dynamic> i) => has(i, phase.name)),
    ...items.where((Map<String, dynamic> i) => has(i, 'any')),
  ];
  final int dayOfYear = IsoDates.daysBetween('${today.substring(0, 4)}-01-01', today);
  final Map<String, dynamic> pick = shortlist[dayOfYear % shortlist.length];
  return DailySuggestion(title: pick['title'] as String, text: pick['text'] as String, writtenBy: SuggestionAuthor.rules);
}

class SampleHomeRepository implements HomeRepository {
  SampleHomeRepository(this._backend, {SampleStore? store, String? Function()? name, IsoDate Function()? today})
      : store = store ?? SampleStore(),
        _name = name ?? (() => null),
        _today = today ?? IsoDates.localToday;

  final SampleBackend _backend;
  final String? Function() _name;
  final IsoDate Function() _today;

  /// Shared with the sample Cycle and Symptoms repositories.
  final SampleStore store;
  List<Period> get periods => store.periods;
  Map<IsoDate, DailyLog> get _logs => store.dailyLogs;
  bool _preScoreHidden = false;

  /// Seeds logged periods, for screenshots and tests.
  void seedPeriods(Iterable<Period> p) => periods
    ..clear()
    ..addAll(p);

  @override
  Future<HomeDocument> getHome() async {
    final PreScore? result = _backend.latestPreScore;
    if (result == null) return HomeGate(estimatedMinutes: _backend.document.estimatedMinutes);

    final IsoDate today = _today();
    // The free plan includes `cycle_tracking.access` (design/sample/plans.json).
    final CycleSummary cycle = summariseCycle(
      today: today,
      periods: periods,
      regularity: _backend.answerValue('cycle_regularity'),
      markers: store.markers,
    );
    final Phase? phase = cycle is CycleEstimate ? cycle.phase : null;
    return HomeContent(
      name: _name(),
      today: today,
      areas: Area.values,
      cycle: cycle,
      todayLog: _logs[today] ?? DailyLog(date: today),
      suggestion: pickSuggestion(phase, today),
      preScore: _preScoreHidden
          ? null
          : HomePreScore(
              total: result.total,
              maximum: result.maximum,
              band: result.band.label,
              reviewTarget: result.reviewState == ReviewState.awaitingReview ? result.reviewTarget : null,
            ),
    );
  }

  @override
  Future<void> logPeriodStart(IsoDate date) async {
    periods
      ..removeWhere((Period p) => p.start == date)
      ..add(Period(start: date));
  }

  @override
  Future<DailyLog> saveTodayLog(DailyLogPatch patch) async {
    final IsoDate today = _today();
    final DailyLog next = (_logs[today] ?? DailyLog(date: today)).merge(patch);
    _logs[today] = next;
    return next;
  }

  @override
  Future<void> hidePreScoreCard() async => _preScoreHidden = true;

  /// Number of stored daily logs, for tests (one per date).
  int get logCount => _logs.length;
}
