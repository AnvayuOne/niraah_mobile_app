import '../../../core/network/niraah_api.dart';
import '../domain/cycle.dart';
import 'cycle_parser.dart';

/// The Cycle screen on `/api/v1` (spec 010 §3), matching apps/web/src/api/member-repositories.ts.
/// Predictions, phases, history and advice come only from the server (AC10); nothing is worked out here.
/// Failures other than a period refusal throw an ApiException with the server's message.
class ApiCycleRepository implements CycleRepository {
  ApiCycleRepository(this._api);

  final NiraahApi _api;

  @override
  Future<CycleDocument> getCycle() async => CycleParser.document((await _api.get('/me/cycle')).orThrow());

  /// Adds a period or replaces the one that started on [replacing]; nothing else she logged changes
  /// (AC15). A refusal names its reason: a future date, an end before the start, or an overlap.
  @override
  Future<PeriodSaveResult> savePeriod(Period period, {IsoDate? replacing}) async {
    final ApiResult<Map<String, dynamic>> r = await _api.post('/me/cycle/periods', <String, dynamic>{
      'start': period.start,
      'end': ?period.end,
      'replacing': ?replacing,
    });
    if (r is ApiFail<Map<String, dynamic>>) {
      final PeriodError? reason = CycleParser.periodError(r.error.details?['reason']);
      if (reason != null) return PeriodSaveResult.refused(reason);
    }
    r.orThrow();
    return const PeriodSaveResult.ok();
  }

  @override
  Future<void> deletePeriod(IsoDate start) async => (await _api.delete('/me/cycle/periods/$start')).orThrow();

  @override
  Future<void> setMarkers(List<CycleMarker> markers) async =>
      (await _api.put('/me/cycle/markers', <String, dynamic>{'markers': markers.map(CycleParser.markerKey).toList(growable: false)})).orThrow();

  /// One log per day; saving again merges into it (AC9).
  @override
  Future<DailyLog> saveDailyLog(IsoDate date, DailyLogPatch patch) async =>
      CycleParser.dailyLog((await _api.put('/me/cycle/logs/$date', CycleParser.patchBody(patch))).orThrow());
}
