import 'questionnaire.dart';

/// Evaluates display conditions (spec 005). Conditions are one level deep:
/// a rule refers to an earlier question's answer, never to another condition.
///
/// Clients evaluate them for a smooth flow; the server evaluates them again on
/// submission and ignores answers to questions that should have been hidden.
abstract final class DisplayConditions {
  static bool isVisible(Question q, Answers answers) {
    final DisplayCondition? c = q.displayCondition;
    if (c == null) return true;
    bool test(ConditionRule r) {
      final List<String> chosen = answers[r.questionKey]?.values ?? const <String>[];
      final bool hit = chosen.any(r.values.contains);
      return r.operator == ConditionOperator.isOneOf ? hit : !hit;
    }

    return c.match == ConditionMatch.all ? c.rules.every(test) : c.rules.any(test);
  }

  /// Questions she will see, in order, given the answers so far.
  static List<Question> visible(QuestionnaireDocument doc, Answers answers) =>
      doc.questions.where((Question q) => isVisible(q, answers)).toList(growable: false);

  /// Answers with every answer to a now-hidden question removed.
  static Answers withoutHidden(QuestionnaireDocument doc, Answers answers) {
    final Answers kept = <String, Answer>{};
    for (Question q in doc.questions) {
      final Answer? a = answers[q.key];
      if (a != null && isVisible(q, kept)) kept[q.key] = a;
    }
    return kept;
  }
}
