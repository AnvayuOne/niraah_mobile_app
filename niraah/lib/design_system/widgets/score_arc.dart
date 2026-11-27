import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../motion/motion.dart';
import '../tokens/tokens.dart';

/// The pre-score on a soft arc, counting up once. With reduced motion the
/// final value is drawn at once and nothing moves.
class ScoreArc extends StatelessWidget {
  const ScoreArc({
    required this.total,
    required this.maximum,
    required this.caption,
    required this.semanticLabel,
    super.key,
    this.diameter = 220,
  });

  final int total;
  final int maximum;

  /// "out of 100".
  final String caption;
  final String semanticLabel;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final double target = maximum == 0 ? 0 : (total / maximum).clamp(0, 1).toDouble();
    Widget frame(double fraction) => _ArcFrame(
          fraction: fraction,
          shown: (fraction * maximum).round(),
          caption: caption,
          diameter: diameter,
        );
    return Semantics(
      container: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: NMotionRules.reduced(context)
            ? frame(target)
            : TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: target),
                duration: NMotion.slow,
                curve: NMotionRules.curve,
                builder: (BuildContext context, double v, Widget? _) => frame(v),
              ),
      ),
    );
  }
}

class _ArcFrame extends StatelessWidget {
  const _ArcFrame({required this.fraction, required this.shown, required this.caption, required this.diameter});

  final double fraction;
  final int shown;
  final String caption;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter * 0.82,
      child: CustomPaint(
        painter: _ArcPainter(fraction),
        child: Padding(
          padding: EdgeInsets.only(top: diameter * 0.2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('$shown', key: const ValueKey<String>('score-arc-value'), style: NType.h1.copyWith(color: NColors.inkPrimary)),
              Text(caption, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.fraction);

  final double fraction;

  static const double _start = math.pi * 0.75;
  static const double _sweep = math.pi * 1.5;

  /// Angle covered by the rounded start cap (stroke is 7% of the width).
  static const double _capAngle = 0.12;

  @override
  void paint(Canvas canvas, Size size) {
    final double stroke = size.width * 0.07;
    final Rect rect = Rect.fromCircle(center: Offset(size.width / 2, size.width / 2), radius: size.width / 2 - stroke);
    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = NColors.brandBlushLight;
    canvas.drawArc(rect, _start, _sweep, false, track);
    if (fraction <= 0) return;
    final Paint fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      // Blush to rosewood over the filled part, so every score ends in rosewood.
      // It starts a little before the arc so the rounded start cap stays blush.
      ..shader = SweepGradient(
        endAngle: _capAngle + math.max(_sweep * fraction, 0.01),
        colors: <Color>[NColors.brandBlush, NColors.brandBlush, NColors.brandRosewood],
        stops: const <double>[0, 0.08, 1],
        transform: const GradientRotation(_start - _capAngle),
      ).createShader(rect);
    canvas.drawArc(rect, _start, _sweep * fraction, false, fill);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.fraction != fraction;
}
