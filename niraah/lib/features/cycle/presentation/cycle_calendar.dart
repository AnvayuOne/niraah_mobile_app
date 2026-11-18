import 'dart:math' as math;

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../design_system/tokens/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/calendar.dart';
import '../domain/cycle.dart';

/// Spoken label for a day: "Saturday, 14 November, period, logged, today, has a log".
String dayLabel(S s, String locale, DayCell c) => <String>[
      DateFormat('EEEE, d MMMM', locale).format(IsoDates.toLocalDate(c.date)),
      if (c.logged) s.cycleDayLogged,
      if (c.predicted) s.cycleDayPredicted,
      if (c.today) s.cycleDayToday,
      if (c.hasLog) s.cycleDayHasLog,
    ].join(', ');

/// The month calendar (spec 010 §3 "Cycle screen" 1), mirroring the web:
/// logged days solid terracotta, the estimated window dashed, today ringed in
/// plum, days outside the month in muted ink (never faded by opacity), and
/// future days not tappable.
class CycleCalendar extends StatelessWidget {
  const CycleCalendar({
    required this.doc,
    required this.year,
    required this.month,
    required this.onPrevious,
    required this.onNext,
    required this.onDay,
    super.key,
  });

  final CycleDocument doc;
  final int year;

  /// 1 to 12.
  final int month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<IsoDate> onDay;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String locale = Localizations.localeOf(context).toString();
    final List<DayCell> cells = monthGrid(doc, year, month);
    // 2024-01-01 was a Monday.
    final List<String> weekdays = <String>[for (int i = 0; i < 7; i++) DateFormat.E(locale).format(DateTime(2024, 1, 1 + i))];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Semantics(
                header: true,
                liveRegion: true,
                child: Text(DateFormat.yMMMM(locale).format(DateTime(year, month)), style: NType.h4.copyWith(color: NColors.inkPrimary)),
              ),
            ),
            IconButton(tooltip: s.cyclePrevMonth, onPressed: onPrevious, icon: const Icon(Icons.chevron_left_rounded, color: NColors.inkSecondary)),
            IconButton(tooltip: s.cycleNextMonth, onPressed: onNext, icon: const Icon(Icons.chevron_right_rounded, color: NColors.inkSecondary)),
          ],
        ),
        const SizedBox(height: NSpace.xs),
        ExcludeSemantics(
          child: Row(
            children: <Widget>[
              for (final String w in weekdays)
                Expanded(child: Text(w, textAlign: TextAlign.center, style: NType.label.copyWith(color: NColors.inkMuted))),
            ],
          ),
        ),
        const SizedBox(height: NSpace.xs),
        for (int r = 0; r < cells.length ~/ 7; r++)
          Row(
            children: <Widget>[
              for (final DayCell c in cells.sublist(r * 7, r * 7 + 7))
                Expanded(child: _DayButton(cell: c, label: dayLabel(s, locale, c), onTap: c.future ? null : () => onDay(c.date))),
            ],
          ),
        const SizedBox(height: NSpace.md),
        Wrap(
          spacing: NSpace.md,
          runSpacing: NSpace.xs,
          children: <Widget>[
            _Legend(painter: _CellPainter(logged: true, predicted: false, today: false), text: s.cycleLegendLogged),
            _Legend(painter: _CellPainter(logged: false, predicted: true, today: false), text: s.cycleLegendPredicted),
            _Legend(painter: _CellPainter(logged: false, predicted: false, today: true), text: s.cycleLegendToday),
          ],
        ),
      ],
    );
  }
}

class _DayButton extends StatelessWidget {
  const _DayButton({required this.cell, required this.label, required this.onTap});

  final DayCell cell;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final DayCell c = cell;
    final Color ink = c.logged ? NColors.inkOnBrand : (c.inMonth && !c.future ? NColors.inkPrimary : NColors.inkMuted);
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: NLayout.minTapTarget / 2,
        child: SizedBox(
          height: NLayout.minTapTarget + NSpace.xxs,
          child: Center(
            child: SizedBox.square(
              dimension: NLayout.minTapTarget - NSpace.xxs,
              child: CustomPaint(
                painter: _CellPainter(logged: c.logged, predicted: c.predicted && !c.logged, today: c.today),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Text(
                      '${int.parse(c.date.substring(8))}',
                      style: NType.bodySm.copyWith(color: ink, fontWeight: c.today || c.logged ? FontWeight.w700 : FontWeight.w500),
                    ),
                    if (c.hasLog && !c.logged)
                      Positioned(
                        bottom: NSpace.xxs,
                        child: Container(
                          width: NSpace.xxs,
                          height: NSpace.xxs,
                          decoration: const BoxDecoration(color: NColors.brandTerracotta, shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CellPainter extends CustomPainter {
  _CellPainter({required this.logged, required this.predicted, required this.today});

  final bool logged;
  final bool predicted;
  final bool today;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double r = size.shortestSide / 2 - 3;
    if (logged) canvas.drawCircle(c, r, Paint()..color = NColors.brandTerracotta);
    if (predicted) {
      final Paint p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = NColors.brandTerracotta;
      const int dashes = 12;
      const double sweep = 2 * math.pi / dashes;
      for (int i = 0; i < dashes; i++) {
        canvas.drawArc(Rect.fromCircle(center: c, radius: r), i * sweep, sweep * 0.55, false, p);
      }
    }
    if (today) {
      canvas.drawCircle(
        c,
        r + 2.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = NColors.actionPrimary,
      );
    }
  }

  @override
  bool shouldRepaint(_CellPainter old) => old.logged != logged || old.predicted != predicted || old.today != today;
}

class _Legend extends StatelessWidget {
  const _Legend({required this.painter, required this.text});

  final CustomPainter painter;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ExcludeSemantics(child: SizedBox.square(dimension: NSpace.lg - NSpace.xxs, child: CustomPaint(painter: painter))),
          const SizedBox(width: NSpace.xs),
          Flexible(child: Text(text, style: NType.label.copyWith(color: NColors.inkSecondary))),
        ],
      );
}
