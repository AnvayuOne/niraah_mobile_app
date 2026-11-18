import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/features/home/data/home_parser.dart';
import 'package:niraah/features/home/domain/home.dart';
import 'package:niraah/features/home/presentation/home_cubit.dart';
import 'package:niraah/features/home/presentation/home_page.dart';

import '../helpers/pump_app.dart';

Map<String, dynamic> homeJson() => <String, dynamic>{
      'name': 'Meera',
      'today': '2026-11-17',
      'areas': <String>['home', 'cycle'],
      'notice': <String, dynamic>{'kind': 'trialEnding', 'text': 'Your trial ends on 20 November.', 'date': '2026-11-20'},
      'cycle': null,
      'todayLog': null,
      'suggestion': null,
      'prescore': null,
      'tasks': <Object>[
        <String, dynamic>{'id': 't1', 'title': 'Walk 20 minutes', 'done': false},
      ],
      'next': <String, dynamic>{'kind': 'consult', 'startsAt': '2026-11-18T05:30:00Z', 'with': 'Dr Rao', 'title': null},
      'checkIn': <String, dynamic>{'weekStart': '2026-11-16', 'fields': <String>['energy']},
      'wellness': '',
    };

class _Repo implements HomeRepository {
  _Repo(this.doc);

  final HomeDocument doc;

  @override
  Future<HomeDocument> getHome() async => doc;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('Home reads the next consult and a due check-in (spec 010 §2)', () {
    final HomeContent h = HomeParser.content(homeJson());
    expect(h.next!.withName, 'Dr Rao');
    expect(h.next!.isClass, isFalse);
    expect(h.checkInWeek, '2026-11-16');
    expect(h.tasks!.single.title, 'Walk 20 minutes');
  });

  testWidgets('Home shows one notice, today\'s tasks without "overdue", what\'s next and the check-in (spec 010 §2, AC36, AC38)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final HomeCubit cubit = HomeCubit(_Repo(HomeParser.content(homeJson())));
    await cubit.load();
    await tester.pumpWidget(wrapApp(HomePage(cubit: cubit), reducedMotion: true, size: const Size(390, 2600)));
    await tester.pumpAndSettle();
    expect(find.text('Your trial ends on 20 November.'), findsOneWidget);
    expect(find.text('Walk 20 minutes'), findsOneWidget);
    expect(find.text('Consult with Dr Rao'), findsOneWidget);
    expect(find.text('Your weekly check-in'), findsOneWidget);
    expect(find.textContaining(RegExp('overdue|missed', caseSensitive: false)), findsNothing);
  });
}
