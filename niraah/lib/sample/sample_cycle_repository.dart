// SAMPLE ONLY (constitution §2 rule 6). Stands in for the server's Cycle area
// (spec 010 §3), mirroring apps/web/src/sample/cycle-repository.ts.

import 'dart:convert';

import '../features/cycle/domain/cycle.dart';
import 'sample_backend.dart';
import 'sample_content.dart';
import 'sample_cycle.dart';
import 'sample_store.dart';

final Map<String, dynamic> _messages =
    (jsonDecode(sampleContentMessagesJson) as Map<String, dynamic>)['messages'] as Map<String, dynamic>;

/// Clinician-keyed text by key.
String sampleMessage(String key) => _messages[key] as String;

/// An advice card with its keyed wording. The free plan has no
/// `care_team.urgent_alerts` (design/sample/plans.json), so nothing is passed
/// on and the card says so.
AdviceCard sampleAdviceCard(String key, {bool planHasUrgentAlerts = false}) {
  final Map<String, dynamic> m = _messages[key] as Map<String, dynamic>;
  return AdviceCard(
    key: key,
    title: m['title'] as String,
    text: m['text'] as String,
    notPassedOn: planHasUrgentAlerts ? null : sampleMessage('advice.not_passed_on'),
  );
}

String flowKey(PeriodFlow f) => f.name;

class SampleCycleRepository implements CycleRepository {
  SampleCycleRepository(this._store, this._backend, {IsoDate Function()? today}) : _today = today ?? IsoDates.localToday;

  final SampleStore _store;
  final SampleBackend _backend;
  final IsoDate Function() _today;

  static bool _overlaps(Period a, Period b) {
    final IsoDate aEnd = a.end ?? a.start;
    final IsoDate bEnd = b.end ?? b.start;
    return a.start.compareTo(bEnd) <= 0 && b.start.compareTo(aEnd) <= 0;
  }

  @override
  Future<CycleDocument> getCycle() async {
    final IsoDate today = _today();
    final List<Period> periods = List<Period>.of(_store.periods);
    final List<CycleMarker> markers = List<CycleMarker>.of(_store.markers);
    final String? regularity = _backend.answerValue('cycle_regularity');
    final CycleHistoryResult h = cycleHistory(
      today: today,
      periods: periods,
      markers: markers,
      regularity: regularity,
      dailyFlow: <IsoDate, String>{
        for (DailyLog l in _store.dailyLogs.values)
          if (l.flow != null) l.date: flowKey(l.flow!),
      },
    );
    return CycleDocument(
      today: today,
      summary: summariseCycle(today: today, periods: periods, markers: markers, regularity: regularity),
      periods: periods,
      markers: markers,
      logs: Map<IsoDate, DailyLog>.of(_store.dailyLogs),
      history: h.history,
      average: h.average,
      range: h.range,
      pattern: h.pattern,
      advice: h.advice.map(sampleAdviceCard).toList(),
      disclaimer: sampleMessage('cycle.predictions_disclaimer'),
      wellness: sampleMessage('wellness.cycle'),
    );
  }

  @override
  Future<PeriodSaveResult> savePeriod(Period period, {IsoDate? replacing}) async {
    final IsoDate today = _today();
    if (period.start.compareTo(today) > 0 || (period.end != null && period.end!.compareTo(today) > 0)) {
      return const PeriodSaveResult.refused(PeriodError.future);
    }
    if (period.end != null && period.end!.compareTo(period.start) < 0) return const PeriodSaveResult.refused(PeriodError.endBeforeStart);
    final List<Period> others = _store.periods.where((Period p) => p.start != (replacing ?? period.start)).toList();
    if (others.any((Period p) => _overlaps(p, period))) return const PeriodSaveResult.refused(PeriodError.overlaps);
    // Editing a period never touches daily logs or other periods (AC15).
    _store.periods
      ..clear()
      ..addAll(others)
      ..add(period);
    return const PeriodSaveResult.ok();
  }

  @override
  Future<void> deletePeriod(IsoDate start) async => _store.periods.removeWhere((Period p) => p.start == start);

  @override
  Future<void> setMarkers(List<CycleMarker> markers) async => _store.markers
    ..clear()
    ..addAll(markers.toSet());

  @override
  Future<DailyLog> saveDailyLog(IsoDate date, DailyLogPatch patch) async {
    final DailyLog next = (_store.dailyLogs[date] ?? DailyLog(date: date)).merge(patch);
    _store.dailyLogs[date] = next;
    return next;
  }
}
