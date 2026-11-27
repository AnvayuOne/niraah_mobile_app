import '../../cycle/data/cycle_parser.dart';
import '../domain/symptoms.dart';

/// Reads `/me/symptoms` (packages/contracts/src/member.ts `Symptoms`) into the tracker document
/// (spec 010 §4). The phase on each entry is the server's estimate.
abstract final class SymptomsParser {
  static SymptomsDocument document(Map<String, dynamic> json) {
    final Map<dynamic, dynamic> words = (json['severityWords'] as Map?) ?? const <dynamic, dynamic>{};
    return SymptomsDocument(
      today: '${json['today']}',
      categories: ((json['categories'] as List<dynamic>?) ?? const <dynamic>[]).map((dynamic c) {
        final Map<dynamic, dynamic> m = c as Map<dynamic, dynamic>;
        return SymptomCategory(key: '${m['key']}', name: '${m['name']}', symptoms: _refs(m['symptoms']));
      }).toList(growable: false),
      frequent: _refs(json['frequent']),
      severityLow: '${words['low'] ?? ''}',
      severityHigh: '${words['high'] ?? ''}',
      history: ((json['history'] as List<dynamic>?) ?? const <dynamic>[]).map((dynamic e) {
        final Map<dynamic, dynamic> m = e as Map<dynamic, dynamic>;
        return SymptomHistoryEntry(
          id: '${m['id']}',
          date: '${m['date']}',
          symptom: _ref(m['symptom'] as Map<dynamic, dynamic>),
          severity: (m['severity'] as num).round(),
          note: m['note'] as String?,
          phase: CycleParser.phase(m['phase']),
        );
      }).toList(growable: false),
    );
  }

  /// A refusal names its field (AC18): severity outside 1 to 10, or a symptom not in the catalogue.
  static SymptomLogError? refusal(int status, String? field) {
    if (status != 400) return null;
    return switch (field) {
      'severity' => SymptomLogError.severity,
      'symptom' => SymptomLogError.unknownSymptom,
      _ => null,
    };
  }

  static SymptomRef _ref(Map<dynamic, dynamic> m) => SymptomRef(key: '${m['key']}', name: '${m['name']}');

  static List<SymptomRef> _refs(Object? raw) =>
      ((raw as List<dynamic>?) ?? const <dynamic>[]).map((dynamic s) => _ref(s as Map<dynamic, dynamic>)).toList(growable: false);
}
