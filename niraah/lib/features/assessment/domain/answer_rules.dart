import 'questionnaire.dart';

/// Selection rules for answer cards.
abstract final class AnswerRules {
  /// Toggles [value] in a multiple-choice selection. Choosing an exclusive
  /// option ("None of these") clears the others; choosing any other option
  /// clears the exclusive one.
  static List<String> toggleMultiple(Question q, List<String> current, String value) {
    final Set<String> exclusive = q.options.where((AnswerOption o) => o.exclusive).map((AnswerOption o) => o.value).toSet();
    if (current.contains(value)) {
      return current.where((String v) => v != value).toList(growable: false);
    }
    if (exclusive.contains(value)) return <String>[value];
    return <String>[...current.where((String v) => !exclusive.contains(v)), value];
  }

  /// Whether [answer] lets her move on from [q].
  static bool canContinue(Question q, Answer? answer) {
    if (!q.required) return true;
    if (answer == null || answer.isEmpty) return false;
    if (q.type == QuestionType.date) return DateTime.tryParse(answer.text ?? '') != null;
    return true;
  }
}
