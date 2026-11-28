import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/design_system/tokens/tokens.dart';
import 'package:niraah/features/assessment/domain/questionnaire.dart';
import 'package:niraah/features/cycle/domain/cycle.dart';
import 'package:niraah/features/cycle/presentation/cycle_cubit.dart';
import 'package:niraah/features/cycle/presentation/cycle_page.dart';
import 'package:niraah/features/symptoms/domain/symptoms.dart';
import 'package:niraah/sample/sample_backend.dart';
import 'package:niraah/sample/sample_cycle_repository.dart';
import 'package:niraah/sample/sample_store.dart';
import 'package:niraah/sample/sample_symptoms_repository.dart';

import '../helpers/pump_app.dart';

const IsoDate today = '2026-11-14';
const List<Period> regularHistory = <Period>[
  Period(start: '2026-08-10', end: '2026-08-14'),
  Period(start: '2026-09-07', end: '2026-09-11'),
  Period(start: '2026-10-06', end: '2026-10-10'),
  Period(start: '2026-11-03', end: '2026-11-07'),
];

SampleBackend backendWithAnswers() => SampleBackend()
  ..submit(<String, Answer>{
    'cycle_regularity': const Answer.values(<String>['regular']),
  });

void main() {
  late SampleStore store;
  late SampleCycleRepository cycle;
  late SampleSymptomsRepository symptoms;

  setUp(() {
    store = SampleStore()..periods.addAll(regularHistory);
    final SampleBackend backend = backendWithAnswers();
    cycle = SampleCycleRepository(store, backend, today: () => today);
    symptoms = SampleSymptomsRepository(store, backend, today: () => today);
  });

  group('periods', () {
    test('AC13: a marker turns predictions off; breastfeeding alone does not', () async {
      expect((await cycle.getCycle()).summary, isA<CycleEstimate>());
      await cycle.setMarkers(<CycleMarker>[CycleMarker.hormonalContraception]);
      expect((await cycle.getCycle()).summary, const CycleOff(CycleMarker.hormonalContraception));
      await cycle.setMarkers(<CycleMarker>[CycleMarker.breastfeeding]);
      expect((await cycle.getCycle()).summary, isA<CycleEstimate>());
      await cycle.setMarkers(<CycleMarker>[CycleMarker.pregnant]);
      expect((await cycle.getCycle()).summary, const CycleOff(CycleMarker.pregnant));
    });

    test('AC15: editing a period leaves daily logs as they were', () async {
      await cycle.saveDailyLog('2026-11-04', const DailyLogPatch(flow: PeriodFlow.heavy, mood: Mood.low));
      await cycle.saveDailyLog('2026-11-10', const DailyLogPatch(energy: Energy.high));
      final Map<IsoDate, DailyLog> before = Map<IsoDate, DailyLog>.of((await cycle.getCycle()).logs);
      final PeriodSaveResult r = await cycle.savePeriod(const Period(start: '2026-11-03', end: '2026-11-08'), replacing: '2026-11-03');
      expect(r.ok, isTrue);
      final CycleDocument after = await cycle.getCycle();
      expect(after.logs, before);
      expect(after.periods.where((Period p) => p.start == '2026-11-03').single.end, '2026-11-08');
      await cycle.deletePeriod('2026-11-03');
      expect((await cycle.getCycle()).logs, before);
    });

    test('future dates, an end before the start, and overlaps are refused', () async {
      expect((await cycle.savePeriod(const Period(start: '2026-11-20'))).error, PeriodError.future);
      expect((await cycle.savePeriod(const Period(start: '2026-11-10', end: '2026-11-09'))).error, PeriodError.endBeforeStart);
      expect((await cycle.savePeriod(const Period(start: '2026-11-05'))).error, PeriodError.overlaps);
    });

    test('history is oldest first in the document; the free plan shows the not-passed-on line on advice', () async {
      store.periods
        ..clear()
        ..add(const Period(start: '2026-08-10'));
      final CycleDocument doc = await cycle.getCycle();
      expect(doc.advice.single.key, 'cycle.no_period_90');
      expect(doc.advice.single.notPassedOn, 'Niraah has not passed this on to a doctor. Please see a doctor yourself.');
      expect(doc.disclaimer, 'Predictions are estimates. Do not use them to prevent or plan a pregnancy.');
    });
  });

  group('symptoms', () {
    test('AC17: a red-flag symptom returns its advice at once, with the not-passed-on line', () async {
      final SymptomLogResult r = await symptoms.logSymptom(date: today, symptom: 'severe_pelvic_pain', severity: 3);
      expect(r.ok, isTrue);
      expect(r.advice?.key, 'symptom.severe_pelvic_pain');
      expect(r.advice?.title, 'Please see a doctor soon');
      expect(r.advice?.notPassedOn, isNotNull);
    });

    test('AC17: minSeverity: very heavy bleeding raises advice from 7 up', () async {
      expect((await symptoms.logSymptom(date: today, symptom: 'very_heavy_bleeding', severity: 6)).advice, isNull);
      expect((await symptoms.logSymptom(date: today, symptom: 'very_heavy_bleeding', severity: 7)).advice?.key, 'symptom.very_heavy_bleeding');
      expect((await symptoms.logSymptom(date: today, symptom: 'cramps', severity: 10)).advice, isNull);
    });

    test('AC18: severity 0 and 11 are refused and nothing is stored', () async {
      expect((await symptoms.logSymptom(date: today, symptom: 'cramps', severity: 0)).error, SymptomLogError.severity);
      expect((await symptoms.logSymptom(date: today, symptom: 'cramps', severity: 11)).error, SymptomLogError.severity);
      expect((await symptoms.logSymptom(date: today, symptom: 'unknown', severity: 5)).error, SymptomLogError.unknownSymptom);
      expect(store.symptomLogs, isEmpty);
    });

    test('frequent is the top four by count; history is newest first with the phase that day', () async {
      for (String k in <String>['cramps', 'cramps', 'cramps', 'bloating', 'bloating', 'acne', 'headache', 'nausea']) {
        await symptoms.logSymptom(date: today, symptom: k, severity: 4);
      }
      final SymptomsDocument doc = await symptoms.getSymptoms();
      expect(doc.frequent.map((SymptomRef r) => r.key), <String>['cramps', 'bloating', 'acne', 'headache']);
      expect(doc.history.first.symptom.key, 'nausea');
      expect(doc.history.first.phase, Phase.ovulatory);
      expect(doc.severityLow, 'Mild');
      expect(doc.severityHigh, 'Very strong');
    });
  });

  group('calendar', () {
    Future<void> pumpCycle(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await cycle.saveDailyLog('2026-11-12', const DailyLogPatch(mood: Mood.calm));
      final CycleCubit cubit = CycleCubit(cycle);
      await cubit.load();
      await tester.pumpWidget(wrapApp(CyclePage(cubit: cubit), reducedMotion: true, size: const Size(390, 3200)));
      await tester.pumpAndSettle();
    }

    testWidgets('every day cell has a full spoken label', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpCycle(tester);
      expect(find.bySemanticsLabel('Thursday, 5 November, period, logged'), findsOneWidget);
      expect(find.bySemanticsLabel('Saturday, 14 November, today'), findsOneWidget);
      expect(find.bySemanticsLabel('Thursday, 12 November, has a log'), findsOneWidget);
      expect(find.bySemanticsLabel('Monday, 30 November, next period estimated'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('days outside the month use muted ink, not opacity', (WidgetTester tester) async {
      await pumpCycle(tester);
      // November 2026 starts on a Sunday, so the grid opens with 26 to 31 October.
      final Text oct26 = tester.widget<Text>(find.text('26').first);
      expect(oct26.style?.color, NColors.inkMuted);
      expect(find.byType(Opacity), findsNothing);
    });

    testWidgets('history, pattern and situation show; tapping a day opens its sheet', (WidgetTester tester) async {
      await pumpCycle(tester);
      expect(find.text('Current cycle'), findsOneWidget);
      expect(find.text('29-day cycle · period 5 days'), findsOneWidget);
      expect(find.text('Your last 3 cycles ranged from 28 to 29 days.'), findsOneWidget);
      expect(find.text('Average 28 days · Range 28 to 29 days'), findsOneWidget);
      expect(find.text('None of these'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Tuesday, 10 November'));
      await tester.pumpAndSettle();
      expect(find.text('My period started this day'), findsOneWidget);
      expect(find.text('My period ended this day'), findsOneWidget);
    });
  });
}
