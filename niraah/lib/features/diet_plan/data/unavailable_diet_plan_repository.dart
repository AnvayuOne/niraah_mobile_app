import '../../../core/errors/api_exception.dart';
import '../domain/diet_plan.dart';

/// Sample builds: the diet plan needs the Niraah API (it is made by the server).
class UnavailableDietPlanRepository implements DietPlanRepository {
  const UnavailableDietPlanRepository();

  Never _no() => throw ApiException(message: "This screen isn't connected to Niraah's servers yet.");

  @override
  Future<DietPlanState> open() async => _no();
  @override
  Future<DietPlanState> newWeek() async => _no();
  @override
  Future<DietPlanState> swap(String itemId, String? foodId) async => _no();
  @override
  Future<FoodProfile?> profile() async => _no();
  @override
  Future<FoodProfile> saveProfile(FoodProfile profile) async => _no();
  @override
  Future<List<DietOption>> foods() async => _no();
}
