// SAMPLE ONLY (constitution §2 rule 6). Stands in for the server's symptom
// tracker (spec 010 §4), mirroring apps/web/src/sample/symptoms-repository.ts.

import 'dart:convert';

import '../features/cycle/domain/cycle.dart';
import '../features/symptoms/domain/symptoms.dart';
import 'sample_backend.dart';
import 'sample_content.dart';
import 'sample_cycle.dart';
import 'sample_cycle_repository.dart';
import 'sample_store.dart';

class _Entry {
  const _Entry(this.key, this.name, this.category, this.redFlagMessage, this.minSeverity);

  final String key;
  final String name;
  final String category;
  final String? redFlagMessage;
  final int minSeverity;
}

class SampleSymptomsRepository implements SymptomsRepository {
  SampleSymptomsRepository(this._store, this._backend, {IsoDate Function()? today}) : _today = today ?? IsoDates.localToday {
    final Map<String, dynamic> c = jsonDecode(sampleSymptomsJson) as Map<String, dynamic>;
    _categories = (c['categories'] as List<dynamic>).cast<Map<String, dynamic>>();
    final Map<String, dynamic> words = c['severityWords'] as Map<String, dynamic>;
    _low = words['low'] as String;
    _high = words['high'] as String;
    for (final dynamic raw in c['symptoms'] as List<dynamic>) {
      final Map<String, dynamic> s = raw as Map<String, dynamic>;
      final Map<String, dynamic>? flag = s['redFlag'] as Map<String, dynamic>?;
      _byKey[s['key'] as String] = _Entry(
        s['key'] as String,
        s['name'] as String,
        s['category'] as String,
        flag?['message'] as String?,
        (flag?['minSeverity'] as int?) ?? 1,
      );
    }
  }

  final SampleStore _store;
  final SampleBackend _backend;
  final IsoDate Function() _today;
  late final List<Map<String, dynamic>> _categories;
  late final String _low;
  late final String _high;
  final Map<String, _Entry> _byKey = <String, _Entry>{};

  SymptomRef _ref(String key) => SymptomRef(key: key, name: _byKey[key]?.name ?? key);

  @override
  Future<SymptomsDocument> getSymptoms() async {
    final Map<String, int> counts = <String, int>{};
    for (final SampleSymptomLog l in _store.symptomLogs) {
      counts[l.symptom] = (counts[l.symptom] ?? 0) + 1;
    }
    final List<MapEntry<String, int>> ranked = counts.entries.toList()
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) => b.value != a.value ? b.value - a.value : a.key.compareTo(b.key));
    final List<SymptomRef> frequent = <SymptomRef>[
      for (final MapEntry<String, int> e in ranked.take(4))
        if (_byKey.containsKey(e.key)) _ref(e.key),
    ];

    final String? regularity = _backend.answerValue('cycle_regularity');
    final List<SampleSymptomLog> recent = List<SampleSymptomLog>.of(_store.symptomLogs)
      ..sort((SampleSymptomLog a, SampleSymptomLog b) => a.date != b.date ? b.date.compareTo(a.date) : b.id.compareTo(a.id));

    return SymptomsDocument(
      today: _today(),
      categories: <SymptomCategory>[
        for (final Map<String, dynamic> c in _categories)
          SymptomCategory(
            key: c['key'] as String,
            name: c['name'] as String,
            symptoms: <SymptomRef>[
              for (final _Entry e in _byKey.values)
                if (e.category == c['key']) SymptomRef(key: e.key, name: e.name),
            ],
          ),
      ],
      frequent: frequent,
      severityLow: _low,
      severityHigh: _high,
      history: <SymptomHistoryEntry>[
        for (final SampleSymptomLog l in recent.take(30))
          SymptomHistoryEntry(
            id: l.id,
            date: l.date,
            symptom: _ref(l.symptom),
            severity: l.severity,
            note: l.note,
            phase: switch (summariseCycle(
              today: l.date,
              periods: _store.periods.where((Period p) => p.start.compareTo(l.date) <= 0).toList(),
              markers: _store.markers,
              regularity: regularity,
            )) {
              final CycleEstimate e => e.phase,
              _ => null,
            },
          ),
      ],
    );
  }

  @override
  Future<SymptomLogResult> logSymptom({required IsoDate date, required String symptom, required int severity, String? note}) async {
    if (severity < 1 || severity > 10) return const SymptomLogResult.refused(SymptomLogError.severity);
    final _Entry? entry = _byKey[symptom];
    if (entry == null) return const SymptomLogResult.refused(SymptomLogError.unknownSymptom);
    final String? trimmed = note?.trim();
    _store.symptomLogs.add(
      SampleSymptomLog(id: _store.newId(), date: date, symptom: symptom, severity: severity, note: trimmed == null || trimmed.isEmpty ? null : trimmed),
    );
    // A red-flag rule shows its advice at once (spec 010 §4.4, AC17).
    final String? flag = entry.redFlagMessage;
    return SymptomLogResult.ok(flag != null && severity >= entry.minSeverity ? sampleAdviceCard(flag) : null);
  }
}
