import '../../cycle/domain/cycle.dart';
import '../domain/home.dart';

/// Used by `main.dart` until spec 010's endpoints exist. Fails plainly.
class UnavailableHomeRepository implements HomeRepository {
  const UnavailableHomeRepository();

  static Never _no() => throw const HomeNotConnected();

  @override
  Future<HomeDocument> getHome() async => _no();

  @override
  Future<void> logPeriodStart(IsoDate date) async => _no();

  @override
  Future<DailyLog> saveTodayLog(DailyLogPatch patch) async => _no();

  @override
  Future<void> hidePreScoreCard() async => _no();
}

class HomeNotConnected implements Exception {
  const HomeNotConnected();
}
