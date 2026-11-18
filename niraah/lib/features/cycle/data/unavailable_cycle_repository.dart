import '../../home/data/unavailable_home_repository.dart';
import '../domain/cycle.dart';

/// Used by `main.dart` until spec 010's cycle endpoints exist. Fails plainly.
class UnavailableCycleRepository implements CycleRepository {
  const UnavailableCycleRepository();

  @override
  Future<CycleDocument> getCycle() async => throw const HomeNotConnected();

  @override
  Future<PeriodSaveResult> savePeriod(Period period, {IsoDate? replacing}) async => throw const HomeNotConnected();

  @override
  Future<void> deletePeriod(IsoDate start) async => throw const HomeNotConnected();

  @override
  Future<void> setMarkers(List<CycleMarker> markers) async => throw const HomeNotConnected();

  @override
  Future<DailyLog> saveDailyLog(IsoDate date, DailyLogPatch patch) async => throw const HomeNotConnected();
}
