import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/features/dietitian/dietitian_pages.dart';
import 'package:niraah/features/dietitian/dietitian_repository.dart';
import 'package:niraah/features/dietitian/meal_plan_pages.dart';
import 'package:niraah/features/provider_work/domain/provider_work.dart';

import '../helpers/fake_api.dart';
import '../helpers/pump_app.dart';

Json nutrients() => <String, dynamic>{'energyKcal': 297, 'proteinG': 9.6, 'carbohydrateG': 52, 'fatG': 6.6, 'fibreG': 9.2};

Json planJson({bool conflict = false}) => <String, dynamic>{
      'id': 'p1',
      'member': 'Asha',
      'status': 'draft',
      'startDate': '2026-11-16',
      'endDate': null,
      'weeks': 1,
      'targets': <String, dynamic>{},
      'suppressed': true,
      'carePlan': null,
      'warnings': <String, dynamic>{'daysOutsideTargets': <int>[], 'preferenceConflicts': <Object>[], 'repeats': <Object>[]},
      'needsConfirmation': conflict
          ? <Object>[
              <String, dynamic>{'itemId': 'i1', 'conflicts': <String>['allergy:peanut']},
            ]
          : <Object>[],
      'days': <Object>[
        <String, dynamic>{
          'dayIndex': 0,
          'date': '2026-11-16',
          'note': null,
          'totals': nutrients(),
          'againstTargets': <String, dynamic>{},
          'slots': <Object>[
            <String, dynamic>{
              'slot': 'lunch',
              'totals': nutrients(),
              'items': <Object>[
                <String, dynamic>{'id': 'i1', 'kind': 'food', 'name': 'Chikki', 'portion': <String, dynamic>{'count': 1, 'unit': 'piece'}, 'nutrients': nutrients(), 'warnings': <String>[]},
              ],
            },
          ],
        },
      ],
    };

class FakeDietitian implements DietitianRepository {
  FakeDietitian(this.current);

  Json current;
  final List<String> calls = <String>[];

  @override
  Future<Json> plan(String id) async => current;

  @override
  Future<Json> confirmItem(String planId, String itemId) async {
    calls.add('confirm:$itemId');
    return current = planJson();
  }

  @override
  Future<Json> dashboard() async => <String, dynamic>{
        'dietitian': <String, dynamic>{'name': 'Meera'},
        'needsMe': <String, dynamic>{'foodLogs': 3, 'oldestFoodLogDueAt': null, 'mealPlansToBuild': 1, 'mealPlansEnding': 0, 'checkIns': 2, 'alerts': 0, 'messages': 0},
        'today': <Object>[],
      };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> settle(WidgetTester tester) async {
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late FakeAdapter adapter;
  setUp(() => adapter = FakeAdapter());

  test('a dish is added by id with a household portion, never as free text (spec 012 AC7)', () async {
    final ApiDietitianRepository repo = ApiDietitianRepository(fakeApi(adapter));
    adapter.reply(planJson());
    await repo.addItem('p1', <String, dynamic>{'dayIndex': 0, 'slot': 'lunch', 'foodId': 'f1', 'count': 2, 'unit': 'piece'});
    expect(adapter.last.path, '/dietitian/meal-plans/p1/items');
    expect(adapter.lastBody, <String, dynamic>{'dayIndex': 0, 'slot': 'lunch', 'foodId': 'f1', 'count': 2, 'unit': 'piece'});
  });

  test('publishing sends the start date, and the care plan confirmation only when given (spec 012 §4 "Publishing" 7)', () async {
    final ApiDietitianRepository repo = ApiDietitianRepository(fakeApi(adapter));
    adapter
      ..reply(planJson())
      ..reply(planJson());
    await repo.publish('p1', '2026-11-16');
    expect(adapter.lastBody, <String, dynamic>{'startDate': '2026-11-16'});
    await repo.publish('p1', '2026-11-16', confirmCarePlanRead: true);
    expect(adapter.lastBody, <String, dynamic>{'startDate': '2026-11-16', 'confirmCarePlanRead': true});
  });

  test('a day is claimed by member and day; a comment is sent as a comment (spec 012 AC21, AC24)', () async {
    final ApiDietitianRepository repo = ApiDietitianRepository(fakeApi(adapter));
    adapter
      ..reply(<String, dynamic>{'logs': <Object>[]})
      ..reply(<String, dynamic>{'remaining': 0});
    await repo.claimDay('m1', '2026-11-15');
    expect(adapter.lastBody, <String, dynamic>{'memberId': 'm1', 'day': '2026-11-15'});
    await repo.review('l1', approve: false, comment: 'Lovely plate.');
    expect(adapter.last.path, '/dietitian/food-logs/l1/review');
    expect(adapter.lastBody, <String, dynamic>{'decision': 'comment', 'comment': 'Lovely plate.'});
  });

  testWidgets('a conflict is confirmed before the plan can be published; the flagged member preview is stated (spec 012 AC10, AC16)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final FakeDietitian repo = FakeDietitian(planJson(conflict: true));
    await tester.pumpWidget(wrapApp(MealPlanBuilderPage(planId: 'p1', repository: repo), size: const Size(390, 2400)));
    await settle(tester);
    expect(find.text('Confirm the marked items to publish'), findsOneWidget);
    expect(find.textContaining('Calorie and weight content is hidden'), findsOneWidget);
    await tester.tap(find.text("I've checked this, keep it"));
    await settle(tester);
    expect(repo.calls, <String>['confirm:i1']);
    expect(find.text('Publish plan'), findsOneWidget);
  });

  testWidgets('the dashboard shows each count that opens its list (spec 012 §1)', (WidgetTester tester) async {
    await tester.pumpApp(DietitianDashboardPage(repository: FakeDietitian(planJson())));
    await settle(tester);
    expect(find.bySemanticsLabel(RegExp('^Food logs to review: 3')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^Check-ins to read: 2')), findsOneWidget);
  });
}
