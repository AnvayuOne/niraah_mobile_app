import '../../../core/network/niraah_api.dart';
import '../domain/diet_plan.dart';

/// The AI diet plan on `/api/v1` (spec 010 §6a): `GET /me/diet-plan`, `POST /me/diet-plan/new-week`,
/// `POST /me/diet-plan/items/{id}/swap`, `GET|PUT /me/food-profile`, `GET /me/diet-plan/foods`.
class ApiDietPlanRepository implements DietPlanRepository {
  ApiDietPlanRepository(this._api);

  final NiraahApi _api;

  @override
  Future<DietPlanState> open() async => DietPlanState.fromJson((await _api.get('/me/diet-plan')).orThrow());

  @override
  Future<DietPlanState> newWeek() async => DietPlanState.fromJson((await _api.post('/me/diet-plan/new-week')).orThrow());

  @override
  Future<DietPlanState> swap(String itemId, String? foodId) async => DietPlanState.fromJson((await _api.post('/me/diet-plan/items/$itemId/swap', <String, dynamic>{'foodId': foodId})).orThrow());

  @override
  Future<FoodProfile?> profile() async {
    final Map<String, dynamic> r = (await _api.get('/me/food-profile')).orThrow();
    return r['profile'] == null ? null : FoodProfile.fromJson(r['profile'] as Map<String, dynamic>);
  }

  @override
  Future<FoodProfile> saveProfile(FoodProfile profile) async {
    final Map<String, dynamic> r = (await _api.put('/me/food-profile', profile.toJson())).orThrow();
    return FoodProfile.fromJson(r['profile'] as Map<String, dynamic>);
  }

  @override
  Future<List<DietOption>> foods() async {
    final Map<String, dynamic> r = (await _api.get('/me/diet-plan/foods')).orThrow();
    return <DietOption>[for (final dynamic f in r['foods'] as List<dynamic>) DietOption((f as Map<String, dynamic>)['id'] as String, f['name'] as String)];
  }
}
