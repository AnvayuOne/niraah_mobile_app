import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/features/doctor/domain/doctor_work.dart';
import 'package:niraah/features/doctor/presentation/care_plan_pages.dart';
import 'package:niraah/features/doctor/presentation/doctor_more_pages.dart';
import 'package:niraah/features/provider_work/domain/provider_work.dart';
import 'package:niraah/features/provider_work/presentation/provider_work_pages.dart';

import '../helpers/pump_app.dart';

Json plan({String? decision}) => <String, dynamic>{
      'id': 'p1',
      'member': 'Asha',
      'status': 'in_review',
      'generatedBy': 'model',
      'dueAt': null,
      'canReturn': true,
      'returnNote': null,
      'sections': <Object>[
        <String, dynamic>{'kind': 'sleep', 'aiSuggestion': 'Wind down by 10 pm.', 'doctorVersion': null, 'decision': decision, 'clearedReason': null, 'needsDoseConfirmation': false},
      ],
      'tasks': <Object>[],
      'wellnessStatement': 'Niraah is a wellness service.',
    };

class FakeDoctor implements DoctorWorkRepository {
  FakeDoctor(this.current);

  Json current;
  final List<String> calls = <String>[];

  @override
  Future<Json> carePlan(String id) async => current;

  @override
  Future<Json> decide(String id, String kind, String decision, {String? text, String? reason}) async {
    calls.add('$kind:$decision');
    return current = plan(decision: decision);
  }

  @override
  Future<List<Json>> alerts({String? status}) async => <Json>[
        <String, dynamic>{
          'id': 'a1',
          'member': <String, dynamic>{'id': 'm1', 'name': 'Asha'},
          'kind': 'lab_urgent',
          'raisedBy': 'A lab value past its urgent threshold',
          'severity': 'urgent',
          'status': 'open',
          'onCall': true,
          'opened': false,
          'createdAt': '2026-11-17T08:00:00Z',
          'ageMinutes': 40,
        },
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeWork implements ProviderWorkRepository {
  @override
  Future<Json> earnings() async => <String, dynamic>{
        'availablePaise': 0,
        'pendingPaise': 50000,
        'paidPaise': 0,
        'lines': <Object>[
          <String, dynamic>{'id': 'l1', 'kind': 'Pre-score review', 'amountPaise': 50000, 'display': '₹500', 'status': 'pending', 'date': '2026-11-16T10:00:00Z', 'availableOn': '2026-11-23T10:00:00Z'},
        ],
        'rules': <Object>[<String, dynamic>{'kind': 'Pre-score review', 'amountPaise': 50000, 'sharePercent': null}],
      };

  @override
  Future<List<Json>> payouts() async => <Json>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> settle(WidgetTester tester) async {
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('a care plan cannot be signed until every section is decided; the AI text stays beside her decision (spec 011 §5, AC12)', (WidgetTester tester) async {
    final FakeDoctor repo = FakeDoctor(plan());
    await tester.pumpApp(CarePlanReviewPage(planId: 'p1', repository: repo));
    await settle(tester);
    expect(find.text('Wind down by 10 pm.'), findsOneWidget);
    expect(find.text('Decide every section to sign'), findsOneWidget);
    await tester.tap(find.text('Accept'));
    await settle(tester);
    expect(repo.calls, <String>['sleep:accepted']);
    expect(find.text('Sign the care plan'), findsOneWidget);
    expect(find.text('Wind down by 10 pm.'), findsOneWidget);
  });

  testWidgets('alerts list urgent ones with what raised them and their age (spec 011 §12 rule 3)', (WidgetTester tester) async {
    await tester.pumpApp(AlertsPage(repository: FakeDoctor(plan())));
    await settle(tester);
    expect(find.text('Urgent · Asha'), findsOneWidget);
    expect(find.text('A lab value past its urgent threshold'), findsOneWidget);
    expect(find.textContaining('40 min ago'), findsOneWidget);
  });

  testWidgets('earnings show lines, rules in plain words, and no cash-out with nothing available (spec 011 §14)', (WidgetTester tester) async {
    await tester.pumpApp(EarningsPage(repository: FakeWork()));
    await settle(tester);
    expect(find.text('Pre-score review: ₹500'), findsOneWidget);
    expect(find.text('Nothing available to cash out yet'), findsOneWidget);
    expect(find.textContaining('Pending'), findsWidgets);
  });
}
