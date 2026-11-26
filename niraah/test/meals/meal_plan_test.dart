import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/features/meals/data/api_meals_repository.dart';
import 'package:niraah/features/meals/domain/meals.dart';

import '../helpers/fake_api.dart';

Map<String, dynamic> n({bool kcal = true}) => <String, dynamic>{
      if (kcal) 'energyKcal': 320,
      'proteinG': 12,
      'carbohydrateG': 40,
      'fatG': 9,
      'fibreG': 6,
      'glycaemicIndex': null,
    };

void main() {
  late FakeAdapter adapter;
  late ApiMealsRepository repo;

  setUp(() {
    adapter = FakeAdapter();
    repo = ApiMealsRepository(fakeApi(adapter));
  });

  test('history lists the days she logged meals (spec 010 §6 rule 5)', () async {
    adapter.reply(<String, dynamic>{'days': <Object>[<String, dynamic>{'day': '2026-11-18', 'meals': 2}, <String, dynamic>{'day': '2026-11-16', 'meals': 1}]});
    final List<MealHistoryDay> days = await repo.history();
    expect(adapter.last.path, '/me/meals/history');
    expect(days, const <MealHistoryDay>[MealHistoryDay(day: '2026-11-18', meals: 2), MealHistoryDay(day: '2026-11-16', meals: 1)]);
  });

  test('no active meal plan reads as null (spec 012 AC12)', () async {
    adapter.reply(<String, dynamic>{'plan': null});
    expect(await repo.mealPlan(), isNull);
    expect(adapter.last.path, '/me/meal-plan');
  });

  test('the meal plan reads days, slots, portions, notes and alternatives; energy is absent when suppressed (spec 012 AC16)', () async {
    adapter.reply(<String, dynamic>{
      'plan': <String, dynamic>{
        'id': 'mp1',
        'status': 'active',
        'title': 'Gentle start',
        'startDate': '2026-11-17',
        'endDate': null,
        'weeks': 1,
        'targets': <String, dynamic>{},
        'dietitian': 'Priya',
        'days': <Object>[
          <String, dynamic>{
            'dayIndex': 0,
            'date': '2026-11-17',
            'note': 'Soak the dal overnight.',
            'totals': n(kcal: false),
            'slots': <Object>[
              <String, dynamic>{
                'slot': 'breakfast',
                'totals': n(kcal: false),
                'items': <Object>[
                  <String, dynamic>{
                    'id': 'i1',
                    'kind': 'food',
                    'refId': 'f1',
                    'name': 'Poha',
                    'portion': <String, dynamic>{'count': 1, 'unit': 'katori'},
                    'nutrients': n(kcal: false),
                    'notes': 'Add peanuts.',
                    'alternatives': <Object>[<String, dynamic>{'name': 'Upma'}, 'Idli'],
                  },
                ],
              },
            ],
          },
        ],
      },
    });
    final MealPlan p = (await repo.mealPlan())!;
    expect(p.dietitian, 'Priya');
    final MealPlanItem i = p.days.single.slots.single.items.single;
    expect((i.name, i.count, i.unit, i.notes), ('Poha', 1.0, 'katori', 'Add peanuts.'));
    expect(i.alternatives, <String>['Upma', 'Idli']);
    expect(i.nutrients.energyKcal, isNull);
    expect(p.days.single.totals.proteinG, 12);
  });
}
