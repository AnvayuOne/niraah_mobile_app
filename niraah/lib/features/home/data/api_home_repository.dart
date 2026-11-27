import '../../../core/network/niraah_api.dart';
import '../../cycle/data/cycle_parser.dart';
import '../../cycle/domain/cycle.dart';
import '../domain/home.dart';
import 'home_parser.dart';

/// Home on `/api/v1` (spec 010 §2), matching apps/web/src/api/member-repositories.ts. The server
/// decides what appears; failures throw an ApiException with the server's message.
class ApiHomeRepository implements HomeRepository {
  ApiHomeRepository(this._api, {IsoDate Function()? today}) : _localToday = today ?? IsoDates.localToday;

  final NiraahApi _api;
  final IsoDate Function() _localToday;

  /// The pre-score and day Home last showed, for "hide this card" and "log today".
  String? _shownPreScoreId;
  IsoDate? _shownToday;

  @override
  Future<HomeDocument> getHome() async {
    // Before the assessment Home is the gate (AC2); `/me/workspace` answers during onboarding, `/me/home` does not.
    final HomeGate? gate = HomeParser.gate((await _api.get('/me/workspace')).orThrow());
    if (gate != null) return gate;
    final Map<String, dynamic> h = (await _api.get('/me/home')).orThrow();
    final Map<dynamic, dynamic>? prescore = h['prescore'] as Map?;
    _shownPreScoreId = prescore == null ? null : '${prescore['id']}';
    _shownToday = '${h['today']}';
    return HomeParser.content(h);
  }

  @override
  Future<void> logPeriodStart(IsoDate date) async => (await _api.post('/me/cycle/periods', <String, dynamic>{'start': date})).orThrow();

  /// Merges into the day Home showed (AC9).
  @override
  Future<DailyLog> saveTodayLog(DailyLogPatch patch) async =>
      CycleParser.dailyLog((await _api.put('/me/cycle/logs/${_shownToday ?? _localToday()}', CycleParser.patchBody(patch))).orThrow());

  /// Hides the card until her next pre-score; nothing to do when none was shown.
  @override
  Future<void> hidePreScoreCard() async {
    final String? id = _shownPreScoreId;
    if (id == null) return;
    (await _api.post('/me/home/prescore-card/dismiss', <String, dynamic>{'prescoreId': id})).orThrow();
  }
}
