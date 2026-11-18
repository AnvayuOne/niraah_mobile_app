import '../domain/questionnaire.dart';

/// Parses the client version document (spec 005) from JSON. Text comes either as a plain string
/// (the sample) or per language with English required (the API: `{"en": "..."}`).
abstract final class QuestionnaireParser {
  static QuestionnaireDocument parse(Map<String, dynamic> json) {
    final List<dynamic> raw = json['questions'] as List<dynamic>;
    return QuestionnaireDocument(
      questionnaireKey: json['questionnaireKey'] as String,
      versionNumber: json['versionNumber'] as int,
      estimatedMinutes: (json['estimatedMinutes'] as int?) ?? 3,
      questions: raw.map((dynamic q) => _question(Map<String, dynamic>.from(q as Map))).toList(growable: false),
    );
  }

  /// English text from either shape.
  static String? _text(Object? v) => v is Map ? v['en'] as String? : v as String?;

  static Question _question(Map<String, dynamic> j) {
    final QuestionType type = questionTypeFrom(j['type'] as String);
    final List<dynamic> opts = (j['options'] ?? j['steps'] ?? const <dynamic>[]) as List<dynamic>;
    final Map<dynamic, dynamic>? settings = j['settings'] as Map?;
    return Question(
      key: j['key'] as String,
      type: type,
      required: (j['required'] as bool?) ?? false,
      text: _text(j['text']) ?? '',
      helpText: _text(j['helpText']),
      illustrationId: j['illustration'] as String?,
      motion: motionFrom(j['motion'] as String?),
      maxLength: (j['maxLength'] ?? settings?['maxLength']) as int?,
      options: opts.map((dynamic o) => _option(Map<String, dynamic>.from(o as Map))).toList(growable: false),
      displayCondition: j['displayCondition'] == null ? null : _condition(Map<String, dynamic>.from(j['displayCondition'] as Map)),
    );
  }

  static AnswerOption _option(Map<String, dynamic> j) => AnswerOption(
        value: j['value'] as String,
        label: _text(j['label']) ?? '',
        colorToken: j['color'] as String?,
        iconId: j['icon'] as String?,
        exclusive: (j['exclusive'] as bool?) ?? false,
      );

  static DisplayCondition _condition(Map<String, dynamic> j) => DisplayCondition(
        match: j['match'] == 'any' ? ConditionMatch.any : ConditionMatch.all,
        rules: (j['rules'] as List<dynamic>).map((dynamic r) {
          final Map<dynamic, dynamic> m = r as Map;
          return ConditionRule(
            questionKey: m['question'] as String,
            // "is" and "is any of" both match when a chosen value is listed (spec 005).
            operator: m['operator'] == 'is_not' ? ConditionOperator.isNot : ConditionOperator.isOneOf,
            values: (m['values'] as List<dynamic>).cast<String>(),
          );
        }).toList(growable: false),
      );
}
