import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/features/assessment/data/questionnaire_parser.dart';
import 'package:niraah/features/assessment/domain/prescore.dart';
import 'package:niraah/features/assessment/domain/questionnaire.dart';
import 'package:niraah/sample/sample_content.dart';
import 'package:niraah/sample/sample_scoring.dart';

Answer v(String value) => Answer.values(<String>[value]);

void main() {
  final QuestionnaireDocument doc = QuestionnaireParser.parse(jsonDecode(sampleQuestionnaireJson) as Map<String, dynamic>);
  final SampleScorer scorer = SampleScorer(jsonDecode(sampleScoringJson) as Map<String, dynamic>);

  test('best answers on the sample give 100, Thriving, no flags, no program', () {
    final ScoreResult r = scorer.score(doc, <String, Answer>{
      'date_of_birth': const Answer.text('1995-05-01'),
      'cycle_regularity': v('regular'),
      'mood': v('energetic'),
      'symptoms': v('none'),
      'diet': v('balanced'),
      'activity': v('5'),
      'stress': v('1'),
      'sleep': v('rested'),
      'goal': v('pcos'),
    });
    expect(r.total, 100);
    expect(r.band.label, 'Thriving');
    expect(r.flags, isEmpty);
    expect(r.program, isNull);
    expect(r.dimensions.map((ScoredDimension d) => d.level), everyElement('Strong'));
  });

  test('hand-computed case: total 18, Needs care, three flags, fertility program', () {
    // cycle 0/10 x30 = 0; metabolic (0+3+3)/30 x30 = 6; mind (4+2)/20 x20 = 6;
    // rest 3/10 x20 = 6. Total 18.
    final ScoreResult r = scorer.score(doc, <String, Answer>{
      'cycle_regularity': v('rare'),
      'last_period': v('over_3_months'),
      'mood': v('anxious'),
      'symptoms': const Answer.values(<String>['acne', 'heavy_bleeding']),
      'diet': v('rushed'),
      'activity': v('2'),
      'stress': v('4'),
      'sleep': v('tired'),
      'goal': v('conceive'),
    });
    expect(r.total, 18);
    expect(r.band.label, 'Needs care');
    expect(r.flags.map((RaisedFlag f) => f.key), <String>['missed_periods_3_plus', 'heavy_bleeding', 'trying_to_conceive']);
    expect(r.flags.firstWhere((RaisedFlag f) => f.key == 'heavy_bleeding').severity, FlagSeverity.urgent);
    expect(r.program, 'Fertility journey');
    expect(r.fallbackObservations.length, lessThanOrEqualTo(4));
  });

  test('server discards an answer to a question its condition hides', () {
    final ScoreResult r = scorer.score(doc, <String, Answer>{
      'cycle_regularity': v('regular'),
      'last_period': v('over_3_months'),
    });
    expect(r.keptAnswers.containsKey('last_period'), isFalse);
    expect(r.flags.where((RaisedFlag f) => f.key == 'missed_periods_3_plus'), isEmpty);
  });

  group('hidden question reduces the dimension maximum', () {
    const QuestionnaireDocument small = QuestionnaireDocument(
      questionnaireKey: 't',
      versionNumber: 1,
      estimatedMinutes: 1,
      questions: <Question>[
        Question(
          key: 'q1',
          type: QuestionType.singleChoice,
          required: true,
          text: 'Q1',
          options: <AnswerOption>[AnswerOption(value: 'a', label: 'A'), AnswerOption(value: 'b', label: 'B')],
        ),
        Question(
          key: 'q2',
          type: QuestionType.singleChoice,
          required: true,
          text: 'Q2',
          options: <AnswerOption>[AnswerOption(value: 'x', label: 'X'), AnswerOption(value: 'y', label: 'Y')],
          displayCondition: DisplayCondition(
            match: ConditionMatch.all,
            rules: <ConditionRule>[ConditionRule(questionKey: 'q1', operator: ConditionOperator.isOneOf, values: <String>['b'])],
          ),
        ),
      ],
    );
    final SampleScorer s = SampleScorer(<String, dynamic>{
      'totalMaximum': 50,
      'dimensions': <Map<String, dynamic>>[
        <String, dynamic>{'key': 'd', 'name': 'D', 'maximum': 10, 'share': 100},
      ],
      'levels': <Map<String, dynamic>>[
        <String, dynamic>{'from': 70, 'label': 'Strong'},
        <String, dynamic>{'from': 0, 'label': 'Needs care'},
      ],
      'weights': <String, dynamic>{
        'q1': <String, dynamic>{'a': <String, dynamic>{'d': 4}, 'b': <String, dynamic>{'d': 0}},
        'q2': <String, dynamic>{'x': <String, dynamic>{'d': 6}, 'y': <String, dynamic>{'d': 2}},
      },
      'flagsRaised': <String, dynamic>{},
      'flags': <String, dynamic>{},
      'bands': <Map<String, dynamic>>[
        <String, dynamic>{'min': 25, 'max': 50, 'label': 'High', 'message': '', 'color': 'mint', 'fallbackObservation': ''},
        <String, dynamic>{'min': 0, 'max': 24, 'label': 'Low', 'message': '', 'color': 'blush', 'fallbackObservation': ''},
      ],
    });

    test('q2 hidden: maximum 10 - 6 = 4, raw 4, total 50 of 50', () {
      final ScoreResult r = s.score(small, <String, Answer>{'q1': v('a')});
      expect(r.dimensions.single.maximum, 4);
      expect(r.total, 50);
      expect(r.band.label, 'High');
    });

    test('q2 shown: raw 2 of 10, total 10 of 50', () {
      final ScoreResult r = s.score(small, <String, Answer>{'q1': v('b'), 'q2': v('y')});
      expect(r.dimensions.single.maximum, 10);
      expect(r.total, 10);
      expect(r.dimensions.single.level, 'Needs care');
    });
  });
}
