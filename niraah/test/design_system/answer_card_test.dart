import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/design_system/widgets/answer_card.dart';
import 'package:niraah/features/assessment/domain/answer_rules.dart';
import 'package:niraah/features/assessment/domain/questionnaire.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('single-choice card is announced as a selected radio in a group', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpApp(Scaffold(body: AnswerCard(label: 'Tired', selected: true, onTap: () {})));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Tired')),
      matchesSemantics(
        label: 'Tired',
        hasCheckedState: true,
        isChecked: true,
        isInMutuallyExclusiveGroup: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('multiple-choice card is a checkbox, not in a group', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpApp(Scaffold(body: AnswerCard(label: 'Acne', selected: false, multiple: true, onTap: () {})));
    final SemanticsNode node = tester.getSemantics(find.bySemanticsLabel('Acne'));
    expect(node, matchesSemantics(label: 'Acne', hasCheckedState: true, isChecked: false, hasTapAction: true));
    expect(node.getSemanticsData().flagsCollection.isInMutuallyExclusiveGroup, isFalse);
    handle.dispose();
  });

  testWidgets('tapping the card calls onTap', (WidgetTester tester) async {
    int taps = 0;
    await tester.pumpApp(Scaffold(body: AnswerCard(label: 'Rested', selected: false, onTap: () => taps++)));
    await tester.tap(find.text('Rested'));
    expect(taps, 1);
  });

  group('exclusive option', () {
    const Question q = Question(
      key: 'symptoms',
      type: QuestionType.multipleChoice,
      required: true,
      text: 'Any of these?',
      options: <AnswerOption>[
        AnswerOption(value: 'acne', label: 'Acne'),
        AnswerOption(value: 'hair', label: 'Hair'),
        AnswerOption(value: 'none', label: 'None of these', exclusive: true),
      ],
    );

    test('choosing "None of these" clears the others', () {
      expect(AnswerRules.toggleMultiple(q, <String>['acne', 'hair'], 'none'), <String>['none']);
    });

    test('choosing another option clears "None of these"', () {
      expect(AnswerRules.toggleMultiple(q, <String>['none'], 'acne'), <String>['acne']);
    });

    test('choosing a chosen option removes it', () {
      expect(AnswerRules.toggleMultiple(q, <String>['acne', 'hair'], 'acne'), <String>['hair']);
    });
  });
}
