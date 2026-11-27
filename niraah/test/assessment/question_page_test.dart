import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/features/assessment/domain/questionnaire.dart';
import 'package:niraah/features/assessment/presentation/assessment_cubit.dart';
import 'package:niraah/features/assessment/presentation/pages/question_page.dart';
import 'package:niraah/sample/sample_backend.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<AssessmentCubit> loaded() async {
    final AssessmentCubit c = AssessmentCubit(SampleAssessmentRepository(SampleBackend()));
    await c.load();
    return c;
  }

  testWidgets('continue is inactive and guides until a required question is answered', (WidgetTester tester) async {
    // Everything runs in the test's fake time, so stream events reach the
    // widgets; the sample's simulated network delay is pumped through.
    final AssessmentCubit cubit = AssessmentCubit(SampleAssessmentRepository(SampleBackend()));
    final Future<void> loading = cubit.load();
    await tester.pump(const Duration(seconds: 1));
    await loading;
    await tester.pumpApp(BlocProvider<AssessmentCubit>.value(value: cubit, child: const QuestionPage()), reducedMotion: true);

    expect(find.text('When were you born?'), findsOneWidget);
    expect(find.text('Choose an answer to continue'), findsOneWidget);
    final FilledButton button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);

    cubit.answer('date_of_birth', const Answer.text('1995-05-01'));
    await tester.pumpAndSettle();
    expect(find.text('Choose an answer to continue'), findsNothing);
    expect(find.text('Continue'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNotNull);
  });

  test('step count follows display conditions and a changed answer drops hidden ones', () async {
    final AssessmentCubit c = await loaded();
    final int base = c.state.visible.length;
    c.answer('cycle_regularity', const Answer.values(<String>['rare']));
    expect(c.state.visible.length, base + 1);
    c.answer('last_period', const Answer.values(<String>['over_3_months']));
    c.answer('cycle_regularity', const Answer.values(<String>['regular']));
    expect(c.state.visible.length, base);
    expect(c.state.answers.containsKey('last_period'), isFalse);
  });

  test('a date of birth under 18 stops the assessment', () async {
    final AssessmentCubit c = await loaded();
    final DateTime now = DateTime.now();
    c.answer('date_of_birth', Answer.text('${now.year - 15}-01-01'));
    expect(await c.next(), Advance.minimumAge);
    expect(c.state.status, AssessmentStatus.minimumAge);
    expect(c.state.answers, isEmpty);
  });
}
