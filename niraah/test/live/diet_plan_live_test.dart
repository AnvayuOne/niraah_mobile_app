// Live check of the AI diet plan client against a running niraah-platform. Needs a member who has
// finished the assessment: LIVE_API=<base> LIVE_TOKEN=<access token> flutter test test/live
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/auth/session_store.dart';
import 'package:niraah/core/network/niraah_api.dart';
import 'package:niraah/features/diet_plan/data/api_diet_plan_repository.dart';
import 'package:niraah/features/diet_plan/domain/diet_plan.dart';

final String? _base = Platform.environment['LIVE_API'];
final String? _token = Platform.environment['LIVE_TOKEN'];

void main() {
  test('diet plan: profile, plan, swap parse from the live API', () async {
    final MemorySessionStore store = MemorySessionStore()..tokens = SessionTokens(accessToken: _token!, refreshToken: 'unused');
    final ApiDietPlanRepository repo = ApiDietPlanRepository(NiraahApi(dio: Dio(BaseOptions(baseUrl: _base!)), store: store));
    final List<DietOption> foods = await repo.foods();
    expect(foods, isNotEmpty);
    await repo.saveProfile(const FoodProfile(foodChoice: 'eggetarian', allergens: <String>[], noAllergies: true, avoidedFoodIds: <String>[], cuisine: 'north_indian', fastingDays: <int>[]));
    final DietPlanState st = await repo.open();
    expect(st, isA<DietReady>());
    final DietReady p = st as DietReady;
    expect(p.days, hasLength(7));
    expect(p.days.first.meals, hasLength(5));
    expect(p.cautions, hasLength(4));
    final DietItem item = p.days.expand((DietDay d) => d.meals).expand((DietMeal m) => m.items).firstWhere((DietItem i) => i.swaps.isNotEmpty);
    final DietPlanState after = await repo.swap(item.id, item.swaps.first.id);
    expect(after, isA<DietReady>());
  }, timeout: const Timeout(Duration(minutes: 4)), skip: _base == null || _token == null ? 'set LIVE_API and LIVE_TOKEN' : false);
}
