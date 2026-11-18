import 'package:equatable/equatable.dart';

/// The client view of a questionnaire version (spec 005, "API behaviour for
/// clients"). It carries no weights, maximums, band boundaries or flags:
/// scoring happens only on the server.

enum QuestionType { singleChoice, multipleChoice, scale, number, date, shortText, unknown }

QuestionType questionTypeFrom(String raw) => switch (raw) {
      'single_choice' => QuestionType.singleChoice,
      'multiple_choice' => QuestionType.multipleChoice,
      'scale' => QuestionType.scale,
      'number' => QuestionType.number,
      'date' => QuestionType.date,
      'short_text' => QuestionType.shortText,
      _ => QuestionType.unknown,
    };

/// Motion an illustration enters with. Entrances use token durations only.
enum IllustrationMotion { breathe, float, sway, none }

IllustrationMotion motionFrom(String? raw) => switch (raw) {
      'breathe' => IllustrationMotion.breathe,
      'float' => IllustrationMotion.float,
      'sway' => IllustrationMotion.sway,
      _ => IllustrationMotion.none,
    };

class AnswerOption extends Equatable {
  const AnswerOption({
    required this.value,
    required this.label,
    this.colorToken,
    this.iconId,
    this.exclusive = false,
  });

  final String value;
  final String label;

  /// Name of a token in the answer palette, for example `mint`.
  final String? colorToken;
  final String? iconId;

  /// "None of these": choosing it clears the others.
  final bool exclusive;

  @override
  List<Object?> get props => <Object?>[value, label, colorToken, iconId, exclusive];
}

enum ConditionOperator { isOneOf, isNot }

class ConditionRule extends Equatable {
  const ConditionRule({required this.questionKey, required this.operator, required this.values});

  final String questionKey;
  final ConditionOperator operator;
  final List<String> values;

  @override
  List<Object?> get props => <Object?>[questionKey, operator, values];
}

enum ConditionMatch { all, any }

class DisplayCondition extends Equatable {
  const DisplayCondition({required this.match, required this.rules});

  final ConditionMatch match;
  final List<ConditionRule> rules;

  @override
  List<Object?> get props => <Object?>[match, rules];
}

class Question extends Equatable {
  const Question({
    required this.key,
    required this.type,
    required this.required,
    required this.text,
    this.helpText,
    this.illustrationId,
    this.motion = IllustrationMotion.none,
    this.options = const <AnswerOption>[],
    this.displayCondition,
    this.maxLength,
  });

  final String key;
  final QuestionType type;
  final bool required;
  final String text;
  final String? helpText;
  final String? illustrationId;
  final IllustrationMotion motion;

  /// Answer options; for a scale, its steps in order.
  final List<AnswerOption> options;
  final DisplayCondition? displayCondition;
  final int? maxLength;

  @override
  List<Object?> get props => <Object?>[key, type, required, text, helpText, illustrationId, motion, options, displayCondition, maxLength];
}

class QuestionnaireDocument extends Equatable {
  const QuestionnaireDocument({
    required this.questionnaireKey,
    required this.versionNumber,
    required this.estimatedMinutes,
    required this.questions,
  });

  final String questionnaireKey;
  final int versionNumber;
  final int estimatedMinutes;
  final List<Question> questions;

  Question? question(String key) {
    for (final Question q in questions) {
      if (q.key == key) return q;
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[questionnaireKey, versionNumber, estimatedMinutes, questions];
}

/// A member's answer to one question. Choice answers hold option values;
/// other types hold a single text value (a date is `yyyy-MM-dd`).
class Answer extends Equatable {
  const Answer.values(this.values) : text = null;
  const Answer.text(String this.text) : values = const <String>[];

  final List<String> values;
  final String? text;

  bool get isEmpty => values.isEmpty && (text == null || text!.trim().isEmpty);

  @override
  List<Object?> get props => <Object?>[values, text];
}

typedef Answers = Map<String, Answer>;
