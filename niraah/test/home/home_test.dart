import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/features/assessment/domain/questionnaire.dart';
import 'package:niraah/features/cycle/domain/cycle.dart';
import 'package:niraah/features/home/domain/home.dart';
import 'package:niraah/features/home/presentation/home_cubit.dart';
import 'package:niraah/features/home/presentation/home_page.dart';
import 'package:niraah/sample/sample_backend.dart';
import 'package:niraah/sample/sample_home.dart';

import '../helpers/pump_app.dart';

const List<Period> regularHistory = <Period>[
  Period(start: '2026-08-10', end: '2026-08-14'),
  Period(start: '2026-09-07', end: '2026-09-11'),
  Period(start: '2026-10-06', end: '2026-10-10'),
  Period(start: '2026-11-03', end: '2026-11-07'),
];

SampleHomeRepository repoWithPreScore({String today = '2026-11-14'}) {
  final SampleBackend backend = SampleBackend();
  backend.submit(<String, Answer>{
    'cycle_regularity': const Answer.values(<String>['regular']),
    'sleep': const Answer.values(<String>['light']),
  });
  return SampleHomeRepository(backend, name: () => 'Priya', today: () => today);
}

Future<HomeCubit> pumpHome(WidgetTester tester, SampleHomeRepository repo) async {
  // Tall enough that the whole Home list is built, not only the first screen.
  tester.view.physicalSize = const Size(390, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final HomeCubit cubit = HomeCubit(repo);
  await cubit.load();
  await tester.pumpWidget(wrapApp(HomePage(cubit: cubit), reducedMotion: true, size: const Size(390, 2400)));
  await tester.pumpAndSettle();
  return cubit;
}

void main() {
  test('without a pre-score Home is the gate', () async {
    final HomeDocument doc = await SampleHomeRepository(SampleBackend()).getHome();
    expect(doc, isA<HomeGate>());
  });

  testWidgets('gate screen shows the check-in message and Continue', (WidgetTester tester) async {
    await pumpHome(tester, SampleHomeRepository(SampleBackend()));
    expect(find.text('Your health check-in comes first'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  test('AC9: a second save for the same date updates that day\'s log', () async {
    final SampleHomeRepository repo = repoWithPreScore();
    await repo.saveTodayLog(const DailyLogPatch(flow: PeriodFlow.light));
    final DailyLog second = await repo.saveTodayLog(const DailyLogPatch(mood: Mood.calm));
    expect(repo.logCount, 1);
    expect(second.flow, PeriodFlow.light);
    expect(second.mood, Mood.calm);
    final DailyLog third = await repo.saveTodayLog(const DailyLogPatch(flow: PeriodFlow.heavy));
    expect(repo.logCount, 1);
    expect(third.flow, PeriodFlow.heavy);
  });

  test('the daily suggestion is stable within a day and follows the phase', () {
    final first = pickSuggestion(Phase.luteal, '2026-11-14');
    expect(pickSuggestion(Phase.luteal, '2026-11-14'), first);
    expect(first.writtenBy, SuggestionAuthor.rules);
    // 2026-11-14 is day-of-year index 317. Luteal shortlist: 2 luteal items then 3 "any" items;
    // 317 % 5 = 2, the first "any" item. With no phase: 317 % 3 = 2, the third "any" item.
    expect(first.title, 'A glass of water');
    expect(pickSuggestion(null, '2026-11-14').title, 'A short stretch');
  });

  testWidgets('AC8: with no period logged there is no day or phase, and the invitation shows', (WidgetTester tester) async {
    await pumpHome(tester, repoWithPreScore());
    expect(find.textContaining('Day '), findsNothing);
    expect(find.textContaining('phase'), findsNothing);
    expect(find.text('Tell us when your last period started.'), findsOneWidget);
    expect(find.text('Choose a date to save'), findsOneWidget);
  });

  testWidgets('ring semantics state day, phase and that it is estimated', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    final SampleHomeRepository repo = repoWithPreScore()..seedPeriods(regularHistory);
    await pumpHome(tester, repo);
    final Finder ring = find.bySemanticsLabel(RegExp('^Your cycle\\. Day 12'));
    expect(ring, findsOneWidget);
    final String label = tester.getSemantics(ring).label;
    expect(label, contains('Day 12'));
    expect(label, contains('Ovulatory phase, estimated'));
    expect(label, contains('Next period estimated in 15 to 19 days'));
    handle.dispose();
  });

  testWidgets('saving a period start replaces the invitation with the ring day', (WidgetTester tester) async {
    final SampleHomeRepository repo = repoWithPreScore();
    final HomeCubit cubit = await pumpHome(tester, repo);
    await cubit.logPeriodStart('2026-11-01');
    await tester.pumpAndSettle();
    expect(find.text('Day 14'), findsOneWidget);
    expect(find.text('Tell us when your last period started.'), findsNothing);
    expect(find.text('This estimate is based on your health check-in. Log two cycles for a closer one.'), findsOneWidget);
  });

  testWidgets('flow is two taps: chip, then an option that saves and closes', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    final SampleHomeRepository repo = repoWithPreScore();
    await pumpHome(tester, repo);
    await tester.tap(find.bySemanticsLabel('Flow: Add'));
    await tester.pumpAndSettle();
    expect(find.text('Flow today'), findsOneWidget);
    await tester.tap(find.text('Medium'));
    await tester.pumpAndSettle();
    expect(find.text('Flow today'), findsNothing);
    expect(find.bySemanticsLabel('Flow: Medium'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('hiding the pre-score card removes it', (WidgetTester tester) async {
    await pumpHome(tester, repoWithPreScore());
    expect(find.text('Your wellness pre-score'), findsOneWidget);
    await tester.tap(find.text('Hide'));
    await tester.pumpAndSettle();
    expect(find.text('Your wellness pre-score'), findsNothing);
  });
}
