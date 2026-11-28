import '../domain/cycle.dart';

/// Reads the cycle shapes of `/api/v1` (packages/contracts/src/member.ts `Cycle`, `CycleSummary`,
/// `DailyLog`, `AdviceCard`) into the domain types. The server works out every prediction, phase and
/// advice card; this only copies them (spec 010 §3, AC10).
abstract final class CycleParser {
  static CycleDocument document(Map<String, dynamic> json) {
    final Map<dynamic, dynamic> logs = (json['logs'] as Map?) ?? const <dynamic, dynamic>{};
    final Map<dynamic, dynamic>? pattern = json['pattern'] as Map?;
    return CycleDocument(
      today: '${json['today']}',
      summary: summary(json['summary'] as Map<dynamic, dynamic>),
      periods: ((json['periods'] as List<dynamic>?) ?? const <dynamic>[]).map((dynamic p) {
        final Map<dynamic, dynamic> m = p as Map<dynamic, dynamic>;
        return Period(start: '${m['start']}', end: m['end'] as String?);
      }).toList(growable: false),
      markers: ((json['markers'] as List<dynamic>?) ?? const <dynamic>[]).map((dynamic m) => cycleMarkerFrom('$m')).whereType<CycleMarker>().toList(growable: false),
      logs: <IsoDate, DailyLog>{
        for (MapEntry<dynamic, dynamic> e in logs.entries) '${e.key}': dailyLog(e.value as Map<dynamic, dynamic>),
      },
      history: ((json['history'] as List<dynamic>?) ?? const <dynamic>[]).map((dynamic h) {
        final Map<dynamic, dynamic> m = h as Map<dynamic, dynamic>;
        return CycleHistoryRow(start: '${m['start']}', cycleLength: _int(m['cycleLength'])!, periodLength: _int(m['periodLength']));
      }).toList(growable: false),
      average: _int(json['average']),
      range: _pair(json['range']),
      pattern: pattern == null ? null : CyclePattern(count: _int(pattern['count'])!, min: _int(pattern['min'])!, max: _int(pattern['max'])!),
      advice: ((json['advice'] as List<dynamic>?) ?? const <dynamic>[]).map((dynamic a) => advice(a as Map<dynamic, dynamic>)).toList(growable: false),
      disclaimer: '${json['disclaimer'] ?? ''}',
      wellness: '${json['wellness'] ?? ''}',
    );
  }

  /// The summary union on `state`: noData, off (with the marker) or estimate (spec 010 §3 "Predictions").
  static CycleSummary summary(Map<dynamic, dynamic> s) {
    switch (s['state']) {
      case 'off':
        CycleMarker? reason = cycleMarkerFrom('${s['reason']}');
        return reason == null ? const CycleNoData() : CycleOff(reason);
      case 'estimate':
        return CycleEstimate(
          basis: s['basis'] == 'assessment' ? PredictionBasis.assessment : PredictionBasis.logs,
          dayOfCycle: _int(s['dayOfCycle'])!,
          ringLength: _int(s['ringLength'])!,
          meanLength: _int(s['meanLength']),
          halfWidth: _int(s['halfWidth']),
          windowStart: s['windowStart'] as String?,
          windowEnd: s['windowEnd'] as String?,
          daysToNext: _pair(s['daysToNext']),
          periodLength: _int(s['periodLength'])!,
          fertileStart: _int(s['fertileStart']),
          ovulationDay: _int(s['ovulationDay']),
          phase: phase(s['phase']),
          late: s['late'] == true,
        );
      default:
        return const CycleNoData();
    }
  }

  static Phase? phase(Object? raw) => raw is String ? Phase.values.asNameMap()[raw] : null;

  /// Values the app has no word for are left out rather than guessed.
  static DailyLog dailyLog(Map<dynamic, dynamic> m) => DailyLog(
        date: '${m['date']}',
        flow: PeriodFlow.values.asNameMap()[m['flow']],
        mood: Mood.values.asNameMap()[m['mood']],
        energy: Energy.values.asNameMap()[m['energy']],
        note: m['note'] as String?,
      );

  /// The `DailyLogSave` body: only the fields she changed, so the server merges field by field (AC9).
  static Map<String, dynamic> patchBody(DailyLogPatch p) => <String, dynamic>{
        if (p.flow != null) 'flow': p.flow!.name,
        if (p.mood != null) 'mood': p.mood!.name,
        if (p.energy != null) 'energy': p.energy!.name,
        if (p.note != null) 'note': p.note,
      };

  static AdviceCard advice(Map<dynamic, dynamic> a) =>
      AdviceCard(key: '${a['key']}', title: '${a['title']}', text: '${a['text']}', notPassedOn: a['notPassedOn'] as String?);

  static String markerKey(CycleMarker m) => switch (m) {
        CycleMarker.pregnant => 'pregnant',
        CycleMarker.breastfeeding => 'breastfeeding',
        CycleMarker.hormonalContraception => 'hormonal_contraception',
        CycleMarker.noPeriods => 'no_periods',
      };

  static PeriodError? periodError(Object? reason) => switch (reason) {
        'future' => PeriodError.future,
        'endBeforeStart' => PeriodError.endBeforeStart,
        'overlaps' => PeriodError.overlaps,
        _ => null,
      };

  static int? _int(Object? v) => v is num ? v.round() : null;

  static (int, int)? _pair(Object? v) => v is List && v.length == 2 ? (_int(v[0])!, _int(v[1])!) : null;
}
