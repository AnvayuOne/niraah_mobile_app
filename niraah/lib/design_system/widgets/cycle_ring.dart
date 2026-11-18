import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../tokens/tokens.dart';

/// What the ring draws. Days are 1-based days of the cycle.
class CycleRingData {
  const CycleRingData({
    required this.dayOfCycle,
    required this.ringLength,
    required this.periodDays,
    this.fertileStart,
    this.fertileEnd,
  });

  final int dayOfCycle;
  final int ringLength;

  /// Logged period days at the start of this cycle.
  final int periodDays;
  final int? fertileStart;
  final int? fertileEnd;
}

/// The cycle ring (after design/assets/source/svg/cycle_ring_day14_ovulation.svg):
/// blush track, lavender arc from day 1 to today, period days in terracotta,
/// the fertile window as a sage outline, today as a cream dot with a
/// terracotta outline. It never moves, so it is the same with reduced motion.
///
/// Colour carries nothing on its own: [semanticLabel] states everything the
/// ring shows, and [center] shows the day and phase as text.
class CycleRing extends StatelessWidget {
  const CycleRing({required this.semanticLabel, required this.center, super.key, this.data, this.diameter = 220});

  final CycleRingData? data;
  final Widget center;
  final String semanticLabel;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: diameter,
          child: CustomPaint(painter: _RingPainter(data), child: Center(child: center)),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.data);

  final CycleRingData? data;

  // Proportions from the SVG's 220 viewBox: radius 86, stroke 20.
  static const double _radius = 86 / 220;
  static const double _stroke = 20 / 220;
  static const double _top = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final Offset c = Offset(w / 2, w / 2);
    final double r = w * _radius;
    final double stroke = w * _stroke;
    final Rect rect = Rect.fromCircle(center: c, radius: r);

    Paint band(Color color, double width) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = color;

    canvas.drawCircle(c, r, band(NColors.brandBlush, stroke));

    final CycleRingData? d = data;
    if (d == null) return;
    final double len = math.max(1, d.ringLength).toDouble();
    double angle(double days) => _top + 2 * math.pi * (days / len).clamp(0, 1);
    double sweep(double from, double to) => angle(to) - angle(from);

    final double today = math.min(d.dayOfCycle.toDouble(), len);
    canvas.drawArc(rect, _top, sweep(0, today), false, band(NColors.brandLavender, stroke));

    final double period = math.min(d.periodDays.toDouble(), today);
    if (period > 0) canvas.drawArc(rect, _top, sweep(0, period), false, band(NColors.brandTerracotta, stroke));

    if (d.fertileStart != null && d.fertileEnd != null) {
      final double from = (d.fertileStart! - 1).toDouble();
      final double to = d.fertileEnd!.toDouble();
      final Paint outline = band(NColors.brandSage, stroke * 0.18);
      final double inset = stroke / 2;
      canvas
        ..drawArc(Rect.fromCircle(center: c, radius: r + inset), angle(from), sweep(from, to), false, outline)
        ..drawArc(Rect.fromCircle(center: c, radius: r - inset), angle(from), sweep(from, to), false, outline);
      for (final double day in <double>[from, to]) {
        final double a = angle(day);
        final Offset dir = Offset(math.cos(a), math.sin(a));
        canvas.drawLine(c + dir * (r - inset), c + dir * (r + inset), outline);
      }
    }

    final double a = angle(today - 0.5);
    final Offset dot = c + Offset(math.cos(a), math.sin(a)) * r;
    canvas
      ..drawCircle(dot, stroke * 0.55, Paint()..color = NColors.surfacePage)
      ..drawCircle(dot, stroke * 0.55, band(NColors.brandTerracotta, stroke * 0.15));
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.data != data;
}
