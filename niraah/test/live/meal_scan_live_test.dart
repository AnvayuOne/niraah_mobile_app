// Live check of the meal scan client against a running niraah-platform with AI on:
// LIVE_API=<base> LIVE_TOKEN=<access token> LIVE_PHOTO=<jpeg> flutter test test/live/meal_scan_live_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/auth/session_store.dart';
import 'package:niraah/core/network/niraah_api.dart';
import 'package:niraah/features/meals/data/api_meals_repository.dart';
import 'package:niraah/features/meals/domain/meals.dart';

final String? _base = Platform.environment['LIVE_API'];
final String? _token = Platform.environment['LIVE_TOKEN'];
final String? _photo = Platform.environment['LIVE_PHOTO'];

void main() {
  test('meal scan: photo → dishes with nutrients → saved meal', () async {
    final MemorySessionStore store = MemorySessionStore()..tokens = SessionTokens(accessToken: _token!, refreshToken: 'unused');
    final ApiMealsRepository repo = ApiMealsRepository(NiraahApi(dio: Dio(BaseOptions(baseUrl: _base!, receiveTimeout: const Duration(seconds: 120))), store: store));
    final ScanResult r = await repo.scan(base64Encode(File(_photo!).readAsBytesSync()));
    expect(r, isA<ScanOk>(), reason: r.toString());
    final ScanOk ok = r as ScanOk;
    final List<MatchedItem> matched = ok.items.whereType<MatchedItem>().toList();
    // ignore: avoid_print
    print('dishes: ${ok.items.map((ScanItem i) => i is MatchedItem ? '${i.food.name} ${i.count} ${i.unit} ${i.nutrients.energyKcal} kcal' : '${(i as NotSureItem).label} (not sure)').join('; ')}');
    expect(matched, isNotEmpty);
    final Meal meal = await repo.save(
      eatenAt: DateTime.now(),
      slot: MealSlot.lunch,
      fromScan: true,
      items: <MealItemInput>[for (final MatchedItem m in matched) MealItemInput(foodId: m.food.id, count: m.count, unit: m.unit)],
    );
    expect(meal.items, hasLength(matched.length));
    // ignore: avoid_print
    print('saved: ${meal.totals.energyKcal} kcal, suggestion: ${meal.suggestion}');
  }, timeout: const Timeout(Duration(minutes: 3)), skip: _base == null || _token == null || _photo == null ? 'set LIVE_API, LIVE_TOKEN and LIVE_PHOTO' : false);
}
