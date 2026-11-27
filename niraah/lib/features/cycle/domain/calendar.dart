import 'cycle.dart';

/// One day of the month grid, matching apps/web/src/features/cycle/calendar.ts.
class DayCell {
  const DayCell({
    required this.date,
    required this.inMonth,
    required this.logged,
    required this.predicted,
    required this.today,
    required this.hasLog,
    required this.periodStart,
    required this.future,
  });

  final IsoDate date;
  final bool inMonth;

  /// Inside a logged period, or a day with flow (spec 010 §3).
  final bool logged;

  /// Inside the estimated window, and never in the past.
  final bool predicted;
  final bool today;
  final bool hasLog;
  final bool periodStart;
  final bool future;
}

/// A month grid of whole weeks starting on Monday (spec 010 §3 "Cycle screen" 1).
/// [month] is 1 to 12.
List<DayCell> monthGrid(CycleDocument doc, int year, int month) {
  final IsoDate first = IsoDates.format(DateTime.utc(year, month));
  final int offset = DateTime.utc(year, month).weekday - 1;
  final IsoDate start = IsoDates.addDays(first, -offset);
  final int daysInMonth = DateTime.utc(year, month + 1, 0).day;
  final int cells = ((offset + daysInMonth) / 7).ceil() * 7;

  final CycleSummary s = doc.summary;
  final (IsoDate, IsoDate)? window =
      s is CycleEstimate && s.windowStart != null && s.windowEnd != null ? (s.windowStart!, s.windowEnd!) : null;

  return <DayCell>[
    for (int i = 0; i < cells; i++)
      () {
        final IsoDate date = IsoDates.addDays(start, i);
        final DailyLog? log = doc.logs[date];
        final bool inPeriod = doc.periods.any((Period p) => date.compareTo(p.start) >= 0 && date.compareTo(p.end ?? p.start) <= 0);
        final bool flowed = log?.flow != null && log!.flow != PeriodFlow.none;
        return DayCell(
          date: date,
          inMonth: int.parse(date.substring(5, 7)) == month,
          logged: inPeriod || flowed,
          predicted: window != null && date.compareTo(window.$1) >= 0 && date.compareTo(window.$2) <= 0 && date.compareTo(doc.today) >= 0,
          today: date == doc.today,
          hasLog: log != null && !log.isEmpty,
          periodStart: doc.periods.any((Period p) => p.start == date),
          future: date.compareTo(doc.today) > 0,
        );
      }(),
  ];
}
