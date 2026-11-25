// Renders the dietitian screens, and the shared Schedule and Earnings pages, to PNG for visual review.
// Runs only when SCREENSHOT_DIR is set:
//   SCREENSHOT_DIR=<dir> flutter test test/screenshots/dietitian_screenshot_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/design_system/theme/app_theme.dart';
import 'package:niraah/design_system/tokens/tokens.dart';
import 'package:niraah/design_system/widgets/clinician_ui.dart';
import 'package:niraah/features/dietitian/dietitian_pages.dart';
import 'package:niraah/features/dietitian/dietitian_repository.dart';
import 'package:niraah/features/dietitian/meal_plan_pages.dart';
import 'package:niraah/features/dietitian/review_recipe_pages.dart';
import 'package:niraah/features/provider_work/domain/provider_work.dart';
import 'package:niraah/features/provider_work/presentation/provider_work_pages.dart';
import 'package:niraah/l10n/app_localizations.dart';

final String? _out = Platform.environment['SCREENSHOT_DIR'];
const GlobalObjectKey<State<StatefulWidget>> _boundary = GlobalObjectKey<State<StatefulWidget>>('shot');

Future<void> _loadFonts() async {
  Future<ByteData> font(String file) async => ByteData.sublistView(File('assets/fonts/$file').readAsBytesSync());
  final FontLoader sans = FontLoader('PlusJakartaSans');
  for (String w in <String>['400', '500', '600', '700', '800']) {
    sans.addFont(font('PlusJakartaSans-$w.ttf'));
  }
  await sans.load();
  final FontLoader display = FontLoader('CormorantGaramond');
  for (String w in <String>['500', '600', '700', 'Italic-500']) {
    display.addFont(font('CormorantGaramond-$w.ttf'));
  }
  await display.load();
  final String root = Platform.environment['FLUTTER_ROOT'] ?? '';
  final File icons = File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    final FontLoader m = FontLoader('MaterialIcons')..addFont(Future<ByteData>.value(ByteData.sublistView(icons.readAsBytesSync())));
    await m.load();
  }
}

Widget _frame(Widget child) => RepaintBoundary(
      key: _boundary,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.current,
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        routerConfig: GoRouter(routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => child)]),
      ),
    );

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final RenderRepaintBoundary rb = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image img = await rb.toImage(pixelRatio: 2);
    final ByteData? png = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory(_out!).createSync(recursive: true);
    File('${_out!}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}

Json _n(num kcal, num p, num c, num f, num fi) => <String, dynamic>{'energyKcal': kcal, 'proteinG': p, 'carbohydrateG': c, 'fatG': f, 'fibreG': fi};

Json _item(String id, String name, num count, String unit, Json n, {String? notes, List<String> warnings = const <String>[]}) =>
    <String, dynamic>{'id': id, 'kind': 'food', 'name': name, 'portion': <String, dynamic>{'count': count, 'unit': unit}, 'nutrients': n, 'notes': notes, 'warnings': warnings};

class _FakeDietitian implements DietitianRepository {
  @override
  Future<Json> dashboard() async => <String, dynamic>{
        'dietitian': <String, dynamic>{'name': 'Sunita'},
        'needsMe': <String, dynamic>{'foodLogs': 6, 'oldestFoodLogDueAt': '2026-11-21T10:00:00Z', 'mealPlansToBuild': 2, 'mealPlansEnding': 1, 'checkIns': 3, 'alerts': 1, 'messages': 4},
        'today': <Object>[
          <String, dynamic>{'id': 'a1', 'startsAt': '2026-11-20T05:30:00Z', 'member': 'Asha Verma', 'reason': 'Meal plan review', 'joinable': true},
          <String, dynamic>{'id': 'a2', 'startsAt': '2026-11-20T09:00:00Z', 'member': 'Kavya Nair', 'reason': 'First consult', 'joinable': false},
          <String, dynamic>{'id': 'a3', 'startsAt': '2026-11-20T11:30:00Z', 'member': 'Ritu Sharma', 'joinable': false},
        ],
      };

  @override
  Future<List<Json>> clients({String? search, String? kind, String? mealPlan, bool? openAlert, bool past = false}) async => <Json>[
        <String, dynamic>{'id': 'm1', 'name': 'Asha Verma', 'ageBand': '30–34', 'relationship': 'dedicated', 'plan': 'Niraah Care', 'mealPlan': <String, dynamic>{'state': 'active', 'until': '2026-12-14'}, 'lastCheckIn': '2026-11-17', 'unreviewedLogs': true},
        <String, dynamic>{'id': 'm2', 'name': 'Kavya Nair', 'ageBand': '25–29', 'relationship': 'consult', 'plan': 'Niraah Plus', 'mealPlan': <String, dynamic>{'state': 'draft'}, 'openAlert': true},
        <String, dynamic>{'id': 'm3', 'name': 'Ritu Sharma', 'ageBand': '40–44', 'relationship': 'dedicated', 'plan': 'Niraah Care', 'mealPlan': <String, dynamic>{'state': 'none'}, 'lastCheckIn': '2026-11-03'},
        <String, dynamic>{'id': 'm4', 'name': 'Priya Menon', 'ageBand': '35–39', 'relationship': 'dedicated', 'plan': 'Niraah Care', 'mealPlan': <String, dynamic>{'state': 'active'}, 'lastCheckIn': '2026-11-18'},
      ];

  @override
  Future<Json> client(String memberId) async => <String, dynamic>{
        'id': memberId,
        'name': 'Asha Verma',
        'ageBand': '30–34',
        'plan': 'Niraah Care',
        'relationship': 'dedicated',
        'dedicatedDoctor': 'Dr Meera Iyer',
        'suppressionBanner': 'Calorie and weight content is hidden for this member.',
        'consent': <Object>[
          <String, dynamic>{'category': 'meals', 'shared': true},
          <String, dynamic>{'category': 'cycle_symptoms', 'shared': true},
          <String, dynamic>{'category': 'assessment', 'shared': false},
          <String, dynamic>{'category': 'lab_reports', 'shared': true},
        ],
        'flags': <Object>[<String, dynamic>{'name': 'On medication'}],
        'sections': <String>['meals', 'meal_plan', 'progress', 'assessment', 'labs', 'notes'],
      };

  @override
  Future<Json> section(String memberId, String section) async => switch (section) {
        'meals' => <String, dynamic>{
            'section': 'meals',
            'shared': true,
            'days': <Object>[
              <String, dynamic>{'day': '2026-11-19', 'meals': 4, 'totals': _n(1620, 58, 210, 52, 28)},
              <String, dynamic>{'day': '2026-11-18', 'meals': 3, 'totals': _n(1380, 44, 190, 46, 22)},
              <String, dynamic>{'day': '2026-11-17', 'meals': 2, 'totals': _n(900, 30, 120, 30, 14)},
            ],
            'reviewed': 5,
          },
        'meal_plan' => <String, dynamic>{
            'section': 'meal_plan',
            'shared': true,
            'plans': <Object>[
              <String, dynamic>{'id': 'p1', 'title': 'PCOS-friendly week', 'status': 'active', 'startDate': '2026-11-16', 'mine': true},
            ],
          },
        'assessment' => <String, dynamic>{'section': 'assessment', 'shared': false},
        _ => <String, dynamic>{'section': section, 'shared': true, 'items': <Object>[]},
      };

  @override
  Future<Json> progress(String memberId) async => <String, dynamic>{
        'planPeriods': <Object>[<String, dynamic>{'from': '2026-10-01', 'to': '2026-11-14'}],
        'checkIns': <Object>[
          <String, dynamic>{'id': 'c1', 'week': '2026-11-16', 'energy': 4, 'cravings': 2, 'note': 'Felt steadier after adding protein at breakfast.', 'read': false},
          <String, dynamic>{'id': 'c2', 'week': '2026-11-09', 'energy': 3, 'cravings': 3, 'read': true, 'reply': 'Lovely progress, keep the evening walk.'},
          <String, dynamic>{'id': 'c3', 'week': '2026-11-02', 'energy': 2, 'cravings': 4, 'read': true},
          <String, dynamic>{'id': 'c4', 'week': '2026-10-26', 'energy': 3, 'cravings': 4, 'read': true},
        ],
        'missed': <Object>[
          <String, dynamic>{'week': '2026-10-19', 'nudged': false},
          <String, dynamic>{'week': '2026-10-12', 'nudged': true},
        ],
      };

  @override
  Future<List<Json>> plans() async => <Json>[
        <String, dynamic>{'id': 'p1', 'member': 'Asha Verma', 'title': 'PCOS-friendly week', 'status': 'active', 'endDate': '2026-12-14'},
        <String, dynamic>{'id': 'p2', 'member': 'Kavya Nair', 'title': 'Iron-rich vegetarian', 'status': 'draft'},
        <String, dynamic>{'id': 'p3', 'member': 'Neha Kulkarni', 'title': 'Gentle start', 'status': 'scheduled', 'endDate': '2026-12-30'},
      ];

  @override
  Future<Json> toBuild() async => <String, dynamic>{
        'needPlan': <Object>[
          <String, dynamic>{'memberId': 'm3', 'member': 'Ritu Sharma'},
          <String, dynamic>{'memberId': 'm5', 'member': 'Divya Rao'},
        ],
      };

  @override
  Future<Json> plan(String id) async => <String, dynamic>{
        'id': id,
        'member': 'Kavya Nair',
        'status': 'draft',
        'startDate': '2026-11-23',
        'endDate': '2026-11-29',
        'suppressed': true,
        'warnings': <String, dynamic>{'repeats': <Object>[<String, dynamic>{'name': 'Poha'}]},
        'needsConfirmation': <Object>[<String, dynamic>{'itemId': 'i3', 'conflicts': <String>['allergy:peanut']}],
        'days': <Object>[
          for (int d = 0; d < 7; d++)
            <String, dynamic>{
              'dayIndex': d,
              'totals': _n(1540, 62, 205, 48, 31),
              'againstTargets': <String, dynamic>{'proteinG': 'within', 'fibreG': 'below', 'energyKcal': 'within'},
              'slots': <Object>[
                <String, dynamic>{
                  'slot': 'breakfast',
                  'totals': _n(380, 14, 58, 9, 6),
                  'items': <Object>[
                    _item('i1', 'Vegetable poha', 1, 'katori', _n(250, 6, 45, 5, 3), notes: 'Less oil, add peas'),
                    _item('i2', 'Boiled egg', 1, 'piece', _n(78, 6, 1, 5, 0), warnings: <String>['eggetarian']),
                  ],
                },
                <String, dynamic>{
                  'slot': 'mid_morning',
                  'totals': _n(160, 5, 14, 9, 2),
                  'items': <Object>[_item('i3', 'Peanut chikki', 1, 'piece', _n(160, 5, 14, 9, 2))],
                },
                <String, dynamic>{
                  'slot': 'lunch',
                  'totals': _n(520, 22, 78, 12, 14),
                  'items': <Object>[
                    _item('i4', 'Rajma', 1, 'katori', _n(220, 12, 32, 4, 9)),
                    _item('i5', 'Jeera rice', 1, 'katori', _n(210, 4, 42, 4, 1)),
                    _item('i6', 'Cucumber raita', 1, 'katori', _n(90, 6, 4, 4, 1)),
                  ],
                },
                <String, dynamic>{'slot': 'dinner', 'totals': _n(0, 0, 0, 0, 0), 'items': <Object>[]},
              ],
            },
        ],
      };

  @override
  Future<List<Json>> foodLogQueue() async => <Json>[
        <String, dynamic>{'memberId': 'm1', 'member': 'Asha Verma', 'day': '2026-11-19', 'logIds': <String>['l1', 'l2', 'l3'], 'dueAt': '2026-11-21T10:00:00Z', 'dedicated': true},
        <String, dynamic>{'memberId': 'm2', 'member': 'Kavya Nair', 'day': '2026-11-19', 'logIds': <String>['l4', 'l5'], 'dueAt': '2026-11-21T12:00:00Z', 'dedicated': false, 'claimedByMe': true},
        <String, dynamic>{'memberId': 'm6', 'member': 'Lakshmi Pillai', 'day': '2026-11-18', 'logIds': <String>['l6'], 'dueAt': '2026-11-20T18:00:00Z', 'dedicated': false},
      ];

  @override
  Future<Json> foodLogDay(String memberId, String day) async => <String, dynamic>{
        'member': 'Asha Verma',
        'day': day,
        'dedicated': true,
        'targets': <String, dynamic>{'proteinG': <String, dynamic>{'min': 55}},
        'logs': <Object>[
          <String, dynamic>{
            'id': 'l1',
            'slot': 'breakfast',
            'at': '2026-11-19T03:00:00Z',
            'hasPhoto': true,
            'items': <Object>[
              <String, dynamic>{'id': 'x1', 'name': 'Idli', 'portion': '3 pieces'},
              <String, dynamic>{'id': 'x2', 'name': 'Sambar', 'portion': '1 katori', 'corrected': true},
            ],
            'totals': _n(340, 12, 62, 4, 6),
            'tags': <String>['high fibre', 'low sugar'],
          },
          <String, dynamic>{
            'id': 'l2',
            'slot': 'lunch',
            'at': '2026-11-19T08:00:00Z',
            'items': <Object>[
              <String, dynamic>{'id': 'x3', 'name': 'Chapati', 'portion': '2 pieces'},
              <String, dynamic>{'id': 'x4', 'name': 'Palak paneer', 'grams': 180},
            ],
            'totals': _n(560, 24, 58, 24, 9),
            'tags': <String>[],
          },
        ],
      };

  @override
  Future<List<Json>> recipes({String? search, bool mine = false}) async => <Json>[
        <String, dynamic>{'id': 'r1', 'title': 'Moong dal chilla with mint chutney', 'status': 'published', 'perServing': _n(210, 12, 28, 5, 6)},
        <String, dynamic>{'id': 'r2', 'title': 'Ragi porridge', 'status': 'draft', 'perServing': _n(180, 5, 34, 3, 4)},
        <String, dynamic>{'id': 'r3', 'title': 'Sprouts salad', 'status': 'published', 'perServing': _n(150, 9, 20, 3, 7)},
      ];

  @override
  Future<Json> recipe(String id) async => <String, dynamic>{
        'id': id,
        'title': 'Moong dal chilla with mint chutney',
        'status': 'published',
        'version': 2,
        'mine': true,
        'servings': 2,
        'timeMinutes': 25,
        'steps': <String>['Soak the dal for four hours.', 'Grind with ginger and chilli.', 'Cook thin chillas on a hot tawa.'],
        'ingredients': <Object>[
          <String, dynamic>{'foodId': 'f1', 'name': 'Moong dal', 'grams': 120},
          <String, dynamic>{'foodId': 'f2', 'name': 'Mint leaves', 'grams': 20},
          <String, dynamic>{'requestId': 'q1', 'name': 'Gondhoraj lime', 'grams': 10, 'requested': true},
        ],
        'tags': <String>['breakfast', 'vegetarian', 'north_indian', 'high_protein'],
        'perServing': _n(210, 12, 28, 5, 6),
      };

  @override
  Future<List<Json>> unreadCheckIns() async => <Json>[
        <String, dynamic>{'memberId': 'm1', 'member': 'Asha Verma', 'week': '2026-11-16'},
        <String, dynamic>{'memberId': 'm4', 'member': 'Priya Menon', 'week': '2026-11-16'},
        <String, dynamic>{'memberId': 'm3', 'member': 'Ritu Sharma', 'week': '2026-11-09'},
      ];

  @override
  Future<List<Json>> alerts({String? status}) async => <Json>[
        <String, dynamic>{'id': 'a1', 'member': <String, dynamic>{'id': 'm2', 'name': 'Kavya Nair'}, 'raisedBy': 'Skipped meals on four of the last five days', 'severity': 'urgent', 'status': 'open', 'ageMinutes': 35},
        <String, dynamic>{'id': 'a2', 'member': <String, dynamic>{'id': 'm1', 'name': 'Asha Verma'}, 'raisedBy': 'A food log mentions dizziness after fasting', 'severity': 'attention', 'status': 'acknowledged', 'ageMinutes': 220},
      ];

  @override
  Future<Json> profile() async => <String, dynamic>{
        'name': 'Sunita Balan',
        'approvalStatus': 'approved',
        'bio': 'Registered dietitian focused on PCOS, thyroid and pregnancy nutrition with Indian home food.',
        'languages': <String>['English', 'Malayalam', 'Hindi'],
        'specialities': <String>['PCOS', 'Thyroid', 'Pregnancy'],
        'rating': <String, dynamic>{'average': 4.9, 'count': 84},
      };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWork implements ProviderWorkRepository {
  @override
  Future<Json> earnings() async => <String, dynamic>{
        'availablePaise': 1250000,
        'pendingPaise': 480000,
        'paidPaise': 3640000,
        'lines': <Object>[
          <String, dynamic>{'kind': 'Meal plan', 'date': '2026-11-18', 'status': 'pending', 'availableOn': '2026-11-25', 'amountPaise': 120000},
          <String, dynamic>{'kind': 'Consult', 'date': '2026-11-15', 'status': 'available', 'amountPaise': 80000},
          <String, dynamic>{'kind': 'Food-log reviews', 'date': '2026-11-10', 'status': 'paid', 'amountPaise': 45000},
          <String, dynamic>{'kind': 'Consult', 'date': '2026-11-02', 'status': 'reversed', 'amountPaise': 80000},
        ],
        'rules': <Object>[
          <String, dynamic>{'kind': 'Consult', 'sharePercent': 70},
          <String, dynamic>{'kind': 'Meal plan', 'amountPaise': 120000},
          <String, dynamic>{'kind': 'Food-log review', 'amountPaise': 1500},
        ],
      };

  @override
  Future<List<Json>> payouts() async => <Json>[
        <String, dynamic>{'sentPaise': 1820000, 'status': 'paid', 'taxWithheldPaise': 182000, 'steps': <String, dynamic>{'requested': '2026-11-01'}},
        <String, dynamic>{'sentPaise': 900000, 'status': 'failed', 'failureReason': 'The bank account could not be verified.', 'steps': <String, dynamic>{'requested': '2026-10-15'}},
      ];

  @override
  Future<Json> schedule(DateTime from, DateTime to) async => <String, dynamic>{
        'timeZone': 'Asia/Kolkata',
        'appointments': <Object>[
          <String, dynamic>{'startsAt': '2026-11-20T04:30:00Z', 'endsAt': '2026-11-20T05:00:00Z', 'memberName': 'Asha Verma', 'state': 'completed'},
          <String, dynamic>{'startsAt': '2026-11-20T06:00:00Z', 'endsAt': '2026-11-20T06:30:00Z', 'memberName': 'Kavya Nair', 'state': 'confirmed'},
          <String, dynamic>{'startsAt': '2026-11-20T09:00:00Z', 'endsAt': '2026-11-20T09:30:00Z', 'state': 'being_booked'},
          <String, dynamic>{'startsAt': '2026-11-20T11:30:00Z', 'endsAt': '2026-11-20T12:00:00Z', 'memberName': 'Ritu Sharma', 'state': 'cancelled'},
          <String, dynamic>{'startsAt': '2026-11-23T05:00:00Z', 'endsAt': '2026-11-23T05:30:00Z', 'memberName': 'Priya Menon', 'state': 'confirmed'},
          <String, dynamic>{'startsAt': '2026-11-26T08:00:00Z', 'endsAt': '2026-11-26T08:30:00Z', 'memberName': 'Neha Kulkarni', 'state': 'confirmed'},
        ],
      };

  @override
  Future<Json> availability() async => <String, dynamic>{
        'hours': <Object>[
          <String, dynamic>{'weekday': 1, 'start': '09:00:00', 'end': '13:00:00', 'kind': 'consults'},
          <String, dynamic>{'weekday': 1, 'start': '16:00:00', 'end': '18:00:00', 'kind': 'reviews'},
          <String, dynamic>{'weekday': 3, 'start': '10:00:00', 'end': '14:00:00', 'kind': 'consults'},
          <String, dynamic>{'weekday': 5, 'start': '09:00:00', 'end': '12:00:00', 'kind': 'consults'},
        ],
        'exceptions': <Object>[
          <String, dynamic>{'id': 'e1', 'kind': 'blocked', 'startsAt': '2026-11-27T04:30:00Z', 'endsAt': '2026-11-27T08:30:00Z'},
          <String, dynamic>{'id': 'e2', 'kind': 'extra_consults', 'startsAt': '2026-11-29T04:30:00Z', 'endsAt': '2026-11-29T06:30:00Z'},
        ],
      };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  NColors.dark = Platform.environment['SCREENSHOT_DARK'] == '1';
  setUpAll(_loadFonts);

  void phone(WidgetTester tester, {double height = 844}) {
    tester.view.physicalSize = Size(1170, height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  final _FakeDietitian repo = _FakeDietitian();
  final _FakeWork work = _FakeWork();
  DateTime clock() => DateTime(2026, 11, 20, 8);
  Widget dt(Widget child) => CRole.dietitian(child: child);
  final Map<String, (double, Widget Function())> screens = <String, (double, Widget Function())>{
    'd01-dashboard': (1100, () => DietitianDashboardPage(repository: repo)),
    'd01b-dashboard-phone': (844, () => DietitianDashboardPage(repository: repo)),
    'd02-clients': (1000, () => ClientsPage(repository: repo)),
    'd03-client': (1150, () => dt(ClientPage(memberId: 'm1', repository: repo))),
    'd04-meal-plans': (1000, () => dt(MealPlansPage(repository: repo))),
    'd05-builder': (2100, () => dt(MealPlanBuilderPage(planId: 'p2', repository: repo))),
    'd05b-builder-phone': (844, () => dt(MealPlanBuilderPage(planId: 'p2', repository: repo))),
    'd06-review-queue': (844, () => FoodLogQueuePage(repository: repo)),
    'd07-review-day': (1300, () => dt(FoodLogDayPage(memberId: 'm1', day: '2026-11-19', repository: repo))),
    'd08-recipes': (844, () => dt(RecipesPage(repository: repo))),
    'd10-check-ins': (844, () => dt(UnreadCheckInsPage(repository: repo))),
    'd11-alerts': (844, () => dt(DietitianAlertsPage(repository: repo))),
    'd12-more': (1000, () => const DietitianMorePage()),
    'd13-profile': (1100, () => dt(DietitianProfilePage(repository: repo))),
    'd14-schedule': (1500, () => SchedulePage(repository: work, clock: clock, frame: (BuildContext c, String t, Widget b) => DietitianShell(index: 3, title: t, body: b))),
    'd15-earnings': (1700, () => dt(EarningsPage(repository: work))),
    'd16-schedule-doctor': (844, () => CRole.doctor(child: SchedulePage(repository: work, clock: clock))),
    'd17-earnings-instructor': (844, () => CRole.instructor(child: EarningsPage(repository: work))),
  };
  for (MapEntry<String, (double, Widget Function())> e in screens.entries) {
    testWidgets(e.key, (WidgetTester tester) async {
      phone(tester, height: e.value.$1);
      await tester.pumpWidget(_frame(e.value.$2()));
      await _shot(tester, e.key);
    }, skip: _out == null);
  }

  testWidgets('d09-recipe-editor', (WidgetTester tester) async {
    phone(tester, height: 1750);
    await tester.pumpWidget(_frame(dt(RecipeEditorPage(recipeId: 'r1', repository: repo))));
    await _shot(tester, 'd09-recipe-editor');
  }, skip: _out == null);

  for (final (String tab, String name, double h) in <(String, String, double)>[('Meals', 'd03b-client-meals', 1150), ('Progress', 'd03c-client-progress', 1500), ('Meal plan', 'd03d-client-meal-plan', 900), ('Assessment', 'd03e-client-not-shared', 844)]) {
    testWidgets(name, (WidgetTester tester) async {
      phone(tester, height: h);
      await tester.pumpWidget(_frame(dt(ClientPage(memberId: 'm1', repository: repo))));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(Tab, tab));
      await _shot(tester, name);
    }, skip: _out == null);
  }
}
