import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/features/meals/data/api_meals_repository.dart';
import 'package:niraah/features/meals/domain/meals.dart';
import 'package:niraah/features/meals/presentation/meal_times_card.dart';
import 'package:niraah/features/meals/presentation/today_plan_page.dart';

import '../helpers/fake_api.dart';
import '../helpers/pump_app.dart';

// Meal-time reminders on the phone (spec 010 §6b; AC69, AC73): her meal times, today's plan meals, and "I ate this"
// recorded against the plan meal.

const Nutrients _n = Nutrients(proteinG: 1, carbohydrateG: 1, fatG: 1, fibreG: 1);

class _Saved {
  _Saved(this.slot, this.fromScan, this.items, this.planMeal);
  final MealSlot slot;
  final bool fromScan;
  final List<MealItemInput> items;
  final PlanMealRef? planMeal;
}

class _FakeMeals implements MealsRepository {
  _FakeMeals({this.hasPlan = true, Map<String, List<PlanDish>>? meals, this.source = 'dietitian'}) : meals = meals ?? <String, List<PlanDish>>{};

  final bool hasPlan;
  final String source;
  final Map<String, List<PlanDish>> meals;
  final List<_Saved> saved = <_Saved>[];
  final List<(String, String?, bool?)> changes = <(String, String?, bool?)>[];
  final Map<String, MealTime> times = <String, MealTime>{
    for (final (String slot, String name, String time) in <(String, String, String)>[
      ('early_morning', 'Early morning', '06:30'),
      ('breakfast', 'Breakfast', '08:30'),
      ('mid_morning', 'Mid-morning', '11:00'),
      ('lunch', 'Lunch', '13:30'),
      ('evening_snack', 'Evening snack', '17:00'),
      ('dinner', 'Dinner', '20:00'),
      ('bedtime', 'Bedtime', '21:30'),
    ])
      slot: MealTime(slot: slot, name: name, time: time, enabled: true),
  };

  MealTimes get _times => MealTimes(hasPlan: hasPlan, planSource: hasPlan ? source : null, slots: <MealTime>[for (final String s in planMealSlots) times[s]!]);

  @override
  Future<MealTimes> mealTimes() async => _times;

  @override
  Future<MealTimes> setMealTime(String slot, {String? time, bool? enabled}) async {
    changes.add((slot, time, enabled));
    final MealTime m = times[slot]!;
    times[slot] = MealTime(slot: slot, name: m.name, time: time ?? m.time, enabled: enabled ?? m.enabled);
    return _times;
  }

  @override
  Future<PlanMealToday> planMealToday(String slot) async => PlanMealToday(
        date: '2026-11-27',
        slot: slot,
        name: times[slot]!.name,
        planSource: hasPlan ? source : null,
        caution: source == 'ai' ? 'AI-made · not reviewed · check allergens' : null,
        logSlot: slot == 'lunch' ? MealSlot.lunch : slot == 'breakfast' ? MealSlot.breakfast : slot == 'dinner' ? MealSlot.dinner : MealSlot.snack,
        dishes: meals[slot] ?? const <PlanDish>[],
      );

  @override
  Future<Meal> save({required DateTime eatenAt, required MealSlot slot, required bool fromScan, required List<MealItemInput> items, PlanMealRef? planMeal}) async {
    saved.add(_Saved(slot, fromScan, items, planMeal));
    return Meal(id: 'm1', eatenAt: eatenAt, slot: slot, source: fromScan ? 'scan' : 'manual', items: const <LoggedItem>[], totals: _n, tags: const <String>[]);
  }

  @override
  Future<ScanResult> scan(String photoBase64) async => const ScanUnavailable();
  @override
  Future<List<FoodOption>> searchFoods(String query) async => const <FoodOption>[];
  @override
  Future<MealDay> today() async => throw UnimplementedError();
  @override
  Future<List<MealHistoryDay>> history() async => const <MealHistoryDay>[];
  @override
  Future<MealPlan?> mealPlan() async => null;
}

void main() {
  group('repository (spec 010 §6b)', () {
    late FakeAdapter adapter;
    late ApiMealsRepository repo;
    setUp(() {
      adapter = FakeAdapter();
      repo = ApiMealsRepository(fakeApi(adapter));
    });

    test('AC69: reads her meal times and changes one by slot', () async {
      final Map<String, dynamic> body = <String, dynamic>{
        'hasPlan': true,
        'planSource': 'ai',
        'slots': <Object>[<String, dynamic>{'slot': 'lunch', 'name': 'Lunch', 'time': '13:30', 'enabled': true}],
      };
      adapter.reply(body);
      final MealTimes t = await repo.mealTimes();
      expect(adapter.last.path, '/me/meal-times');
      expect(t.slots.single, const MealTime(slot: 'lunch', name: 'Lunch', time: '13:30', enabled: true));
      adapter.reply(body);
      await repo.setMealTime('lunch', time: '13:00');
      expect(adapter.last.method, 'PUT');
      expect(adapter.last.path, '/me/meal-times/lunch');
      expect(adapter.lastBody, <String, dynamic>{'time': '13:00'});
    });

    test("AC73: today's plan meal reads dishes and the AI caution; a save carries the plan meal", () async {
      adapter.reply(<String, dynamic>{
        'date': '2026-11-27',
        'slot': 'lunch',
        'name': 'Lunch',
        'planSource': 'ai',
        'caution': 'AI-made · not reviewed · check allergens',
        'logSlot': 'lunch',
        'dishes': <Object>[<String, dynamic>{'name': 'Roti', 'count': 2, 'unit': 'piece', 'foodId': 'f1', 'recipeId': null}],
      });
      final PlanMealToday m = await repo.planMealToday('lunch');
      expect(adapter.last.path, '/me/meal-times/lunch/today');
      expect(m.logSlot, MealSlot.lunch);
      expect(m.caution, 'AI-made · not reviewed · check allergens');
      expect(m.canLogAsPlanned, isTrue);
      adapter.reply(<String, dynamic>{
        'id': 'm1',
        'eatenAt': '2026-11-27T13:40:00+05:30',
        'slot': 'lunch',
        'source': 'manual',
        'hasPhoto': false,
        'items': <Object>[],
        'totals': <String, dynamic>{'energyKcal': null, 'proteinG': 0, 'carbohydrateG': 0, 'fatG': 0, 'fibreG': 0, 'glycaemicIndex': null},
        'tags': <Object>[],
        'suggestion': null,
        'review': <String, dynamic>{'state': 'private'},
      });
      await repo.save(eatenAt: DateTime(2026, 11, 27, 13, 40), slot: MealSlot.lunch, fromScan: false, items: const <MealItemInput>[MealItemInput(foodId: 'f1', count: 2, unit: 'piece')], planMeal: const PlanMealRef(slot: 'lunch', fromPlan: true));
      expect(adapter.lastBody['planMeal'], <String, dynamic>{'slot': 'lunch', 'fromPlan': true});
    });
  });

  group("today's plan (spec 010 §6b rule 4)", () {
    testWidgets('AC73: "I ate this" logs the dishes against the plan meal after she confirms', (WidgetTester tester) async {
      final _FakeMeals repo = _FakeMeals(meals: <String, List<PlanDish>>{
        'lunch': const <PlanDish>[PlanDish(name: 'Dal', count: 1, unit: 'katori', foodId: 'dal'), PlanDish(name: 'Roti', count: 2, unit: 'piece', foodId: 'roti')],
      });
      await tester.pumpApp(TodayPlanPage(repository: repo, focusSlot: 'lunch'));
      await tester.pumpAndSettle();
      expect(find.text('Lunch · 13:30'), findsOneWidget);
      expect(find.text('Dal · 1 katori'), findsOneWidget);
      expect(find.text("From your dietitian's meal plan"), findsOneWidget);
      await tester.tap(find.text('I ate this'));
      await tester.pumpAndSettle();
      expect(find.text('Log Lunch as planned?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'I ate this'));
      await tester.pumpAndSettle();
      expect(repo.saved, hasLength(1));
      expect(repo.saved.single.slot, MealSlot.lunch);
      expect(repo.saved.single.fromScan, isFalse);
      expect(repo.saved.single.planMeal, const PlanMealRef(slot: 'lunch', fromPlan: true));
      expect(repo.saved.single.items.map((MealItemInput i) => i.foodId), <String>['dal', 'roti']);
      expect(find.text('I ate this'), findsNothing);
    });

    testWidgets('a recipe dish is logged by scan; an AI plan shows its caution; no streak or missed words', (WidgetTester tester) async {
      final _FakeMeals repo = _FakeMeals(source: 'ai', meals: <String, List<PlanDish>>{
        'breakfast': const <PlanDish>[PlanDish(name: 'Millet porridge', count: 1, unit: 'bowl')],
      });
      await tester.pumpApp(TodayPlanPage(repository: repo));
      await tester.pumpAndSettle();
      expect(find.text('AI-made · not reviewed · check allergens'), findsOneWidget);
      expect(find.text('I ate this'), findsNothing);
      expect(find.text('Scan my meal'), findsOneWidget);
      expect(find.textContaining(RegExp('streak|missed', caseSensitive: false)), findsNothing);
    });

    testWidgets('without a plan it says when meals will appear', (WidgetTester tester) async {
      await tester.pumpApp(TodayPlanPage(repository: _FakeMeals(hasPlan: false)));
      await tester.pumpAndSettle();
      expect(find.text("When you have a diet plan, today's meals appear here."), findsOneWidget);
    });
  });

  group('meal times in notification settings (spec 010 §6b rule 2)', () {
    testWidgets('AC69: each meal has its time and its own switch', (WidgetTester tester) async {
      final _FakeMeals repo = _FakeMeals();
      await tester.pumpApp(Scaffold(body: SingleChildScrollView(child: MealTimesCard(repository: repo))));
      await tester.pumpAndSettle();
      expect(find.text('Your meal times'), findsOneWidget);
      expect(find.text('08:30'), findsOneWidget);
      await tester.tap(find.descendant(of: find.byKey(const ValueKey<String>('meal-time-dinner')), matching: find.byType(Switch)));
      await tester.pumpAndSettle();
      expect(repo.changes, <(String, String?, bool?)>[('dinner', null, false)]);
    });
  });
}
