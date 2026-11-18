import 'package:equatable/equatable.dart';

/// Cycle types, matching the server's cycle summary (spec 010 §3) and
/// apps/web/src/features/cycle/types.ts. Dates are calendar dates
/// (`yyyy-MM-dd`) in the member's time zone.

typedef IsoDate = String;

enum CycleMarker { pregnant, breastfeeding, hormonalContraception, noPeriods }

CycleMarker? cycleMarkerFrom(String raw) => switch (raw) {
      'pregnant' => CycleMarker.pregnant,
      'breastfeeding' => CycleMarker.breastfeeding,
      'hormonal_contraception' => CycleMarker.hormonalContraception,
      'no_periods' => CycleMarker.noPeriods,
      _ => null,
    };

enum Phase { menstrual, follicular, ovulatory, luteal }

enum PredictionBasis { logs, assessment }

class Period extends Equatable {
  const Period({required this.start, this.end});

  final IsoDate start;
  final IsoDate? end;

  @override
  List<Object?> get props => <Object?>[start, end];
}

sealed class CycleSummary extends Equatable {
  const CycleSummary();
}

/// No period logged: no day of cycle, no phase, no window (spec 010 AC8).
class CycleNoData extends CycleSummary {
  const CycleNoData();

  @override
  List<Object?> get props => const <Object?>[];
}

/// Predictions paused, and why (spec 010 §3 rule 5).
class CycleOff extends CycleSummary {
  const CycleOff(this.reason);

  final CycleMarker reason;

  @override
  List<Object?> get props => <Object?>[reason];
}

class CycleEstimate extends CycleSummary {
  const CycleEstimate({
    required this.basis,
    required this.dayOfCycle,
    required this.ringLength,
    required this.periodLength,
    required this.late,
    this.meanLength,
    this.halfWidth,
    this.windowStart,
    this.windowEnd,
    this.daysToNext,
    this.fertileStart,
    this.ovulationDay,
    this.phase,
  });

  final PredictionBasis basis;
  final int dayOfCycle;

  /// Length used to draw the ring: the mean when known, otherwise 28.
  final int ringLength;
  final int? meanLength;
  final int? halfWidth;
  final IsoDate? windowStart;
  final IsoDate? windowEnd;

  /// Days until the window starts and ends, each at least 0.
  final (int, int)? daysToNext;
  final int periodLength;
  final int? fertileStart;
  final int? ovulationDay;
  final Phase? phase;
  final bool late;

  @override
  List<Object?> get props => <Object?>[
        basis, dayOfCycle, ringLength, meanLength, halfWidth, windowStart, windowEnd,
        daysToNext, periodLength, fertileStart, ovulationDay, phase, late,
      ];
}

enum PeriodFlow { none, spotting, light, medium, heavy }

enum Mood { calm, happy, low, anxious, irritable }

enum Energy { low, okay, high }

/// One per member per day; saving again updates it (spec 010 AC9).
class DailyLog extends Equatable {
  const DailyLog({required this.date, this.flow, this.mood, this.energy, this.note});

  final IsoDate date;
  final PeriodFlow? flow;
  final Mood? mood;
  final Energy? energy;
  final String? note;

  bool get isEmpty => flow == null && mood == null && energy == null && (note == null || note!.isEmpty);

  /// Merges a change into this log, keeping the date.
  DailyLog merge(DailyLogPatch p) => DailyLog(
        date: date,
        flow: p.flow ?? flow,
        mood: p.mood ?? mood,
        energy: p.energy ?? energy,
        note: p.note ?? note,
      );

  @override
  List<Object?> get props => <Object?>[date, flow, mood, energy, note];
}

class DailyLogPatch {
  const DailyLogPatch({this.flow, this.mood, this.energy, this.note});

  final PeriodFlow? flow;
  final Mood? mood;
  final Energy? energy;
  final String? note;
}

/// A rule-raised advice card with clinician-written wording (spec 010 §3, AC16).
class AdviceCard extends Equatable {
  const AdviceCard({required this.key, required this.title, required this.text, this.notPassedOn});

  final String key;
  final String title;
  final String text;

  /// Present when her plan sends nothing to a clinician (spec 010
  /// "Wellness-only wording" 2).
  final String? notPassedOn;

  @override
  List<Object?> get props => <Object?>[key, title, text, notPassedOn];
}

class CycleHistoryRow extends Equatable {
  const CycleHistoryRow({required this.start, required this.cycleLength, this.periodLength});

  final IsoDate start;
  final int cycleLength;
  final int? periodLength;

  @override
  List<Object?> get props => <Object?>[start, cycleLength, periodLength];
}

class CyclePattern extends Equatable {
  const CyclePattern({required this.count, required this.min, required this.max});

  final int count;
  final int min;
  final int max;

  @override
  List<Object?> get props => <Object?>[count, min, max];
}

/// The Cycle screen as the server returns it (spec 010 §3), matching
/// apps/web/src/features/cycle/types.ts.
class CycleDocument extends Equatable {
  const CycleDocument({
    required this.today,
    required this.summary,
    required this.periods,
    required this.markers,
    required this.logs,
    required this.history,
    required this.advice,
    required this.disclaimer,
    required this.wellness,
    this.average,
    this.range,
    this.pattern,
  });

  final IsoDate today;
  final CycleSummary summary;
  final List<Period> periods;
  final List<CycleMarker> markers;
  final Map<IsoDate, DailyLog> logs;

  /// Past cycles, oldest first (rule 12).
  final List<CycleHistoryRow> history;
  final int? average;
  final (int, int)? range;
  final CyclePattern? pattern;
  final List<AdviceCard> advice;

  /// Clinician content, keyed (spec 010 AC14, AC51).
  final String disclaimer;
  final String wellness;

  @override
  List<Object?> get props => <Object?>[today, summary, periods, markers, logs, history, average, range, pattern, advice, disclaimer, wellness];
}

enum PeriodError { endBeforeStart, future, overlaps }

/// Null error means saved.
class PeriodSaveResult {
  const PeriodSaveResult.ok() : error = null;
  const PeriodSaveResult.refused(PeriodError this.error);

  final PeriodError? error;

  bool get ok => error == null;
}

abstract interface class CycleRepository {
  Future<CycleDocument> getCycle();

  /// Adds a period, or replaces the one that started on [replacing]
  /// (spec 010 §3.1, AC15). Never touches daily logs.
  Future<PeriodSaveResult> savePeriod(Period period, {IsoDate? replacing});

  Future<void> deletePeriod(IsoDate start);

  Future<void> setMarkers(List<CycleMarker> markers);

  Future<DailyLog> saveDailyLog(IsoDate date, DailyLogPatch patch);
}

/// Calendar-date arithmetic on `yyyy-MM-dd`, in UTC so time zones and daylight
/// saving never shift a day.
abstract final class IsoDates {
  static DateTime _utc(IsoDate d) => DateTime.utc(int.parse(d.substring(0, 4)), int.parse(d.substring(5, 7)), int.parse(d.substring(8, 10)));

  static int daysBetween(IsoDate a, IsoDate b) => _utc(b).difference(_utc(a)).inDays;

  static IsoDate addDays(IsoDate d, int n) => format(_utc(d).add(Duration(days: n)));

  static IsoDate format(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Today in the device's time zone.
  static IsoDate localToday([DateTime? now]) => format(now ?? DateTime.now());

  static DateTime toLocalDate(IsoDate d) => DateTime(int.parse(d.substring(0, 4)), int.parse(d.substring(5, 7)), int.parse(d.substring(8, 10)));
}
