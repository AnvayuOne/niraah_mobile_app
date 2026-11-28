import '../../home/data/unavailable_home_repository.dart';
import '../domain/meals.dart';

/// Used by the sample build: the meal scanner needs the real API and AI (spec 009), so it fails plainly.
class UnavailableMealsRepository implements MealsRepository {
  const UnavailableMealsRepository();

  @override
  Future<ScanResult> scan(String photoBase64) async => const ScanUnavailable();

  @override
  Future<List<FoodOption>> searchFoods(String query) async => throw const HomeNotConnected();

  @override
  Future<Meal> save({required DateTime eatenAt, required MealSlot slot, required bool fromScan, required List<MealItemInput> items, PlanMealRef? planMeal}) async =>
      throw const HomeNotConnected();

  @override
  Future<MealDay> today() async => throw const HomeNotConnected();

  @override
  Future<List<MealHistoryDay>> history() async => throw const HomeNotConnected();

  @override
  Future<MealPlan?> mealPlan() async => throw const HomeNotConnected();

  @override
  Future<MealTimes> mealTimes() async => throw const HomeNotConnected();

  @override
  Future<MealTimes> setMealTime(String slot, {String? time, bool? enabled}) async => throw const HomeNotConnected();

  @override
  Future<PlanMealToday> planMealToday(String slot) async => throw const HomeNotConnected();
}
