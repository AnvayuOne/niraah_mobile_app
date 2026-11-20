import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/features/diet_plan/domain/diet_plan.dart';
import 'package:niraah/features/diet_plan/presentation/diet_plan_page.dart';

import '../helpers/pump_app.dart';

/// The first open needs a profile; after saving, open() is held until the test completes it.
class _SlowRepo implements DietPlanRepository {
  int opens = 0;
  int saves = 0;
  FoodProfile? saved;
  final Completer<DietPlanState> cooked = Completer<DietPlanState>();

  @override
  Future<DietPlanState> open() async => opens++ == 0 ? const DietNeedsProfile() : cooked.future;

  @override
  Future<FoodProfile?> profile() async => null;

  @override
  Future<List<DietOption>> foods() async => const <DietOption>[DietOption('f1', 'Poha')];

  @override
  Future<FoodProfile> saveProfile(FoodProfile p) async {
    saves++;
    saved = p;
    return p;
  }

  @override
  Future<DietPlanState> newWeek() => cooked.future;

  @override
  Future<DietPlanState> swap(String itemId, String? foodId) => cooked.future;
}

void main() {
  test('several food choices save as the widest one', () {
    expect(foodChoiceFor(<String>{'vegetarian', 'eggetarian'}), 'eggetarian');
    expect(foodChoiceFor(<String>{'vegan', 'non_vegetarian'}), 'non_vegetarian');
    expect(foodChoiceFor(<String>{'vegan', 'jain'}), 'vegetarian');
    expect(foodChoiceFor(<String>{'jain'}), 'jain');
  });

  testWidgets('food choice and cuisine take several picks; saving shows cooking until the plan is ready', (WidgetTester t) async {
    final _SlowRepo repo = _SlowRepo();
    await t.pumpWidget(wrapApp(DietPlanPage(repository: repo)));
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));

    // Several food choices and cuisines at once.
    for (final String label in <String>['Vegan', 'Jain', 'North Indian', 'South Indian', 'No allergies']) {
      final Finder f = find.widgetWithText(FilterChip, label);
      await t.scrollUntilVisible(f, 80, scrollable: find.byType(Scrollable).first);
      await t.pump();
      await t.tap(f, warnIfMissed: true);
      await t.pump();
    }
    for (final String label in <String>['North Indian', 'South Indian']) {
      expect(t.widget<FilterChip>(find.widgetWithText(FilterChip, label)).selected, isTrue, reason: label);
    }

    final Finder save = find.text('Save and make my plan');
    await t.scrollUntilVisible(save, 120, scrollable: find.byType(Scrollable).first);
    await t.pump();
    await t.tap(save);
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));

    // The plan is still cooking: the cooking view shows, and there is no form left to tap again.
    expect(find.byType(DietCookingView), findsOneWidget);
    expect(find.byType(FilterChip), findsNothing);
    expect(repo.saves, 1);
    // Single-select would have kept only the last tap (Jain / South Indian).
    expect(repo.saved!.foodChoice, 'vegetarian');
    expect(repo.saved!.cuisine, 'pan_indian');

    await t.pump(const Duration(seconds: 5));
    expect(find.byType(DietCookingView), findsOneWidget);

    repo.cooked.complete(const DietUnavailable('done'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    expect(find.byType(DietCookingView), findsNothing);
    expect(find.text('done'), findsOneWidget);
  });
}
