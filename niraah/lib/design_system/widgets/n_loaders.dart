import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';

import '../motion/motion.dart';
import '../tokens/tokens.dart';

/// Looping loaders for waits the member can see (making a diet plan, AI Care
/// thinking). They hold still with reduced motion, and under `flutter test`
/// so widget tests can settle.
bool _still(BuildContext context) => NMotionRules.reduced(context) || (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST'));

mixin _Looping<T extends StatefulWidget> on State<T>, SingleTickerProviderStateMixin<T> {
  late final AnimationController loop = AnimationController(vsync: this, duration: loopDuration);
  Duration get loopDuration;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still(context)) {
      loop.value = 0.3;
    } else if (!loop.isAnimating) {
      loop.repeat();
    }
  }

  @override
  void dispose() {
    loop.dispose();
    super.dispose();
  }
}

/// A kadhai on a flame: the ladle stirs, vegetables drop in and steam rises.
class NCookingAnimation extends StatefulWidget {
  const NCookingAnimation({super.key, this.size = 220});

  final double size;

  @override
  State<NCookingAnimation> createState() => _NCookingAnimationState();
}

class _NCookingAnimationState extends State<NCookingAnimation> with SingleTickerProviderStateMixin, _Looping<NCookingAnimation> {
  @override
  Duration get loopDuration => const Duration(milliseconds: 2400);

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: loop,
        builder: (BuildContext context, _) => CustomPaint(painter: _KadhaiPainter(loop.value)),
      ),
    ),
  );
}

class _KadhaiPainter extends CustomPainter {
  _KadhaiPainter(this.t);

  final double t;

  static const List<Color> _veg = <Color>[NColors.brandSage, NColors.brandApricot, NColors.brandTerracotta, Color(0xFFE9C46A)];

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset c = Offset(w / 2, h * 0.62);
    final double r = w * 0.34;

    // Soft halo.
    canvas.drawCircle(Offset(w / 2, h * 0.55), w * 0.46, Paint()..color = NColors.brandApricotLight);

    // Flame: three flickering tongues under the pan.
    for (int i = -1; i <= 1; i++) {
      final double flick = 0.8 + 0.2 * math.sin((t * 2 * math.pi * 3) + i * 1.7);
      final double fx = c.dx + i * r * 0.35;
      final double fy = c.dy + r * 0.62;
      final double fh = r * 0.38 * flick * (i == 0 ? 1.2 : 0.9);
      final Path flame = Path()
        ..moveTo(fx - r * 0.1, fy + fh * 0.3)
        ..quadraticBezierTo(fx - r * 0.12, fy - fh * 0.3, fx, fy - fh)
        ..quadraticBezierTo(fx + r * 0.12, fy - fh * 0.3, fx + r * 0.1, fy + fh * 0.3)
        ..close();
      canvas.drawPath(flame, Paint()..color = const Color(0xFFF4A259).withValues(alpha: 0.85));
      canvas.drawPath(Path()..addOval(Rect.fromCenter(center: Offset(fx, fy), width: r * 0.1, height: fh * 0.6)), Paint()..color = const Color(0xFFFFE08A));
    }
    // Stove grate.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.9), width: r * 2.1, height: r * 0.12), const Radius.circular(6)),
      Paint()..color = NColors.inkSecondary.withValues(alpha: 0.6),
    );

    // Kadhai body and handles.
    final Rect bowl = Rect.fromCenter(center: c, width: r * 2, height: r * 1.3);
    final Paint metal = Paint()..color = const Color(0xFF8A5A44);
    canvas.drawArc(bowl, 0, math.pi, true, metal);
    for (final double side in <double>[-1, 1]) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(c.dx + side * r * 1.05, c.dy - r * 0.02), width: r * 0.32, height: r * 0.26),
        side < 0 ? math.pi * 0.5 : -math.pi * 0.5,
        math.pi,
        false,
        Paint()
          ..color = const Color(0xFF6E4535)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.07,
      );
    }
    // Curry surface, gently bubbling.
    final Rect surface = Rect.fromCenter(center: c, width: r * 1.92, height: r * 0.34);
    canvas.drawOval(surface, Paint()..color = const Color(0xFFE39B4B));
    for (int i = 0; i < 5; i++) {
      final double p = (t * 2 + i / 5) % 1;
      final double bx = c.dx + (i - 2) * r * 0.32;
      canvas.drawCircle(Offset(bx, c.dy - r * 0.02), r * 0.04 * math.sin(p * math.pi), Paint()..color = const Color(0xFFF6C177));
    }
    canvas.drawOval(
      surface,
      Paint()
        ..color = const Color(0xFF6E4535)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.05,
    );

    // Vegetables dropping in, one after another.
    for (int i = 0; i < 4; i++) {
      final double p = (t + i / 4) % 1;
      if (p > 0.55) continue;
      final double q = p / 0.55;
      final double vx = c.dx + (i - 1.5) * r * 0.42;
      final double vy = h * 0.12 + (c.dy - h * 0.12) * Curves.easeIn.transform(q);
      canvas.save();
      canvas.translate(vx, vy);
      canvas.rotate(q * math.pi * (i.isEven ? 1 : -1));
      final Paint vp = Paint()..color = _veg[i];
      if (i.isEven) {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: r * 0.16, height: r * 0.16), Radius.circular(r * 0.04)), vp);
      } else {
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 0.2, height: r * 0.12), vp);
      }
      canvas.restore();
    }

    // Ladle stirring in a small circle.
    final double a = t * 2 * math.pi;
    final Offset tip = Offset(c.dx + math.cos(a) * r * 0.45, c.dy + math.sin(a) * r * 0.08);
    final Offset handle = Offset(tip.dx + r * 0.75, tip.dy - r * 0.95);
    canvas.drawLine(
      tip,
      handle,
      Paint()
        ..color = const Color(0xFFB07A55)
        ..strokeWidth = r * 0.07
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(Rect.fromCenter(center: tip, width: r * 0.26, height: r * 0.12), Paint()..color = const Color(0xFFB07A55));

    // Steam: three wisps rising and fading.
    for (int i = 0; i < 3; i++) {
      final double p = (t + i / 3) % 1;
      final double sx = c.dx + (i - 1) * r * 0.5;
      final double sy = c.dy - r * 0.25 - p * r * 1.1;
      final Path wisp = Path()..moveTo(sx, sy + r * 0.3);
      for (int k = 1; k <= 6; k++) {
        wisp.lineTo(sx + math.sin(k + p * 6) * r * 0.06, sy + r * 0.3 - k * r * 0.07);
      }
      canvas.drawPath(
        wisp,
        Paint()
          ..color = NColors.inkMuted.withValues(alpha: (1 - p) * 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.045
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_KadhaiPainter old) => old.t != t;
}

/// Steps through short status lines while something long runs.
class NRotatingStatus extends StatefulWidget {
  const NRotatingStatus({required this.lines, super.key, this.every = const Duration(milliseconds: 2600)});

  final List<String> lines;
  final Duration every;

  @override
  State<NRotatingStatus> createState() => _NRotatingStatusState();
}

class _NRotatingStatusState extends State<NRotatingStatus> {
  int _i = 0;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || _still(context)) return;
    _started = true;
    _tick();
  }

  void _tick() => Future<void>.delayed(widget.every, () {
    if (!mounted) return;
    setState(() => _i = (_i + 1) % widget.lines.length);
    _tick();
  });

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: AnimatedSwitcher(
      duration: NMotion.medium,
      transitionBuilder: (Widget child, Animation<double> a) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(a),
          child: child,
        ),
      ),
      child: Text(
        widget.lines[_i],
        key: ValueKey<int>(_i),
        textAlign: TextAlign.center,
        style: NType.body.copyWith(color: NColors.inkSecondary),
      ),
    ),
  );
}

/// AI Care is writing: three dots bounce in a reply bubble, with a status line.
class NTypingBubble extends StatefulWidget {
  const NTypingBubble({required this.label, super.key});

  final String label;

  @override
  State<NTypingBubble> createState() => _NTypingBubbleState();
}

class _NTypingBubbleState extends State<NTypingBubble> with SingleTickerProviderStateMixin, _Looping<NTypingBubble> {
  @override
  Duration get loopDuration => const Duration(milliseconds: 1100);

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: widget.label,
    child: ExcludeSemantics(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: NSpace.md, vertical: NSpace.sm),
          decoration: BoxDecoration(
            color: NColors.surfaceCard,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(NRadius.lg),
              topRight: Radius.circular(NRadius.lg),
              bottomRight: Radius.circular(NRadius.lg),
              bottomLeft: Radius.circular(4),
            ),
            boxShadow: NShadow.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedBuilder(
                animation: loop,
                builder: (BuildContext context, _) => Row(
                  children: <Widget>[
                    for (int i = 0; i < 3; i++)
                      Transform.translate(
                        offset: Offset(0, -5 * math.max(0, math.sin((loop.value - i * 0.18) * 2 * math.pi))),
                        child: Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          decoration: BoxDecoration(color: <Color>[NColors.brandRosewood, NColors.brandTerracotta, NColors.brandApricot][i], shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: NSpace.sm),
              Flexible(
                child: Text(widget.label, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// A short label followed by three dots that fade in turn.
class NFadingDots extends StatefulWidget {
  const NFadingDots({required this.label, super.key, this.color = NColors.inkMuted});

  final String label;
  final Color color;

  @override
  State<NFadingDots> createState() => _NFadingDotsState();
}

class _NFadingDotsState extends State<NFadingDots> with SingleTickerProviderStateMixin, _Looping<NFadingDots> {
  @override
  Duration get loopDuration => const Duration(milliseconds: 1200);

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: loop,
    builder: (BuildContext context, _) => Text.rich(
      TextSpan(
        text: widget.label.replaceAll(RegExp(r'[.…]+$'), ''),
        children: <InlineSpan>[
          for (int i = 0; i < 3; i++)
            TextSpan(
              text: '.',
              style: TextStyle(color: widget.color.withValues(alpha: (loop.value * 3 - i).clamp(0.15, 1.0))),
            ),
        ],
      ),
      style: NType.bodySm.copyWith(color: widget.color),
    ),
  );
}

/// Which picture a loading screen shows, so each area of the app waits in its own way.
enum NLoaderKind { brand, cycle, meals, chat, care, plans, symptoms, assessment, secure }

/// A small looping picture for a loading screen, drawn in code in the brand palette.
class NThemedLoader extends StatefulWidget {
  const NThemedLoader({required this.kind, super.key, this.size = 132});

  final NLoaderKind kind;
  final double size;

  @override
  State<NThemedLoader> createState() => _NThemedLoaderState();
}

class _NThemedLoaderState extends State<NThemedLoader> with SingleTickerProviderStateMixin, _Looping<NThemedLoader> {
  @override
  Duration get loopDuration => const Duration(milliseconds: 2200);

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: loop,
        builder: (BuildContext context, _) => CustomPaint(painter: _ThemedPainter(widget.kind, loop.value)),
      ),
    ),
  );
}

class _ThemedPainter extends CustomPainter {
  _ThemedPainter(this.kind, this.t);

  final NLoaderKind kind;
  final double t;

  Paint fill(Color c) => Paint()..color = c;
  Paint stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final Offset c = Offset(s / 2, s / 2);
    final double wave = math.sin(t * 2 * math.pi);
    canvas.drawCircle(c, s * 0.48, fill(NColors.brandBlushLight.withValues(alpha: 0.9)));
    switch (kind) {
      case NLoaderKind.cycle:
        // 28 days around a ring; a highlight travels the cycle while the moon in the middle waxes and wanes.
        for (int i = 0; i < 28; i++) {
          final double a = -math.pi / 2 + i / 28 * 2 * math.pi;
          final double d = ((t * 28 - i) % 28 + 28) % 28;
          final double glow = d < 5 ? 1 - d / 5 : 0;
          final Color col = i < 5 ? NColors.brandRosewood : (i >= 11 && i <= 16 ? NColors.brandLavender : NColors.brandApricot);
          canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * s * 0.36, s * (0.022 + 0.02 * glow), fill(col.withValues(alpha: 0.35 + 0.65 * glow)));
        }
        canvas.drawCircle(c, s * 0.15, fill(NColors.brandApricot));
        final double phase = (t * 2) % 2;
        final double off = (phase < 1 ? phase : 2 - phase) * s * 0.3;
        canvas.save();
        canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: s * 0.15)));
        canvas.drawCircle(c + Offset(-s * 0.15 + off, 0), s * 0.15, fill(NColors.brandBlushLight));
        canvas.restore();
      case NLoaderKind.meals:
        // A thali fills katori by katori.
        canvas.drawCircle(c, s * 0.34, fill(const Color(0xFFE7E1DA)));
        canvas.drawCircle(c, s * 0.3, fill(Colors.white));
        const List<Color> foods = <Color>[Color(0xFFE9B44C), NColors.brandSage, Color(0xFFD9774B), NColors.brandApricot];
        for (int i = 0; i < 4; i++) {
          final double a = -math.pi / 2 + i * math.pi / 2;
          final double p = ((t * 4 - i) % 4 + 4) % 4;
          final double grow = p < 1 ? Curves.easeOutBack.transform(p.clamp(0, 1)) : (p < 3 ? 1 : 1 - (p - 3));
          final Offset at = c + Offset(math.cos(a), math.sin(a)) * s * 0.16;
          canvas.drawCircle(at, s * 0.085, fill(const Color(0xFFD8D2CB)));
          canvas.drawCircle(at, s * 0.07 * grow.clamp(0.0, 1.1), fill(foods[i]));
        }
        canvas.drawLine(Offset(s * 0.86, s * 0.25), Offset(s * 0.86, s * 0.75), stroke(NColors.inkMuted, s * 0.025));
        canvas.drawLine(Offset(s * 0.14, s * 0.25), Offset(s * 0.14, s * 0.75), stroke(NColors.inkMuted, s * 0.025));
      case NLoaderKind.chat:
        // Two speech bubbles take turns; dots bounce in the reply.
        final RRect a = RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.16, s * 0.24, s * 0.48, s * 0.28), Radius.circular(s * 0.1));
        final RRect b = RRect.fromRectAndRadius(Rect.fromLTWH(s * 0.36, s * 0.5, s * 0.48, s * 0.26), Radius.circular(s * 0.1));
        canvas.drawRRect(a, fill(NColors.brandRosewood.withValues(alpha: 0.85 + 0.15 * wave)));
        canvas.drawRRect(b, fill(Colors.white));
        canvas.drawRRect(b, stroke(NColors.brandLavender, s * 0.012));
        for (int i = 0; i < 3; i++) {
          final double lift = math.max(0, math.sin((t - i * 0.15) * 2 * math.pi)) * s * 0.035;
          canvas.drawCircle(Offset(s * (0.5 + i * 0.1), s * 0.63 - lift), s * 0.025, fill(NColors.brandTerracotta));
        }
        canvas.drawLine(Offset(s * 0.26, s * 0.36), Offset(s * 0.54, s * 0.36), stroke(Colors.white, s * 0.03));
        canvas.drawLine(Offset(s * 0.26, s * 0.43), Offset(s * 0.44, s * 0.43), stroke(Colors.white.withValues(alpha: 0.7), s * 0.03));
      case NLoaderKind.care:
        // A heartbeat traced across a soft card.
        final Path ecg = Path()..moveTo(s * 0.12, c.dy);
        final List<Offset> pts = <Offset>[
          Offset(s * 0.36, c.dy),
          Offset(s * 0.42, c.dy - s * 0.08),
          Offset(s * 0.48, c.dy + s * 0.18),
          Offset(s * 0.55, c.dy - s * 0.26),
          Offset(s * 0.61, c.dy + s * 0.06),
          Offset(s * 0.66, c.dy),
          Offset(s * 0.88, c.dy),
        ];
        for (final Offset p in pts) {
          ecg.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(ecg, stroke(NColors.lineDefault, s * 0.03));
        final ui.PathMetric m = ecg.computeMetrics().first;
        final double head = t * m.length;
        canvas.drawPath(m.extractPath(math.max(0, head - m.length * 0.45), head), stroke(NColors.brandRosewood, s * 0.035));
        final ui.Tangent? tip = m.getTangentForOffset(head);
        if (tip != null) canvas.drawCircle(tip.position, s * 0.03, fill(NColors.brandTerracotta));
      case NLoaderKind.plans:
        // Three plan cards lift in turn.
        const List<Color> tiers = <Color>[NColors.brandSageLight, NColors.brandApricot, NColors.brandRosewood];
        for (int i = 0; i < 3; i++) {
          final double p = math.max(0, math.sin((t - i / 3) * 2 * math.pi));
          final Rect r = Rect.fromCenter(center: Offset(s * (0.3 + i * 0.2), s * 0.55 - p * s * 0.08), width: s * 0.22, height: s * 0.34);
          canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(s * 0.04)), fill(tiers[i]));
          canvas.drawLine(r.topLeft + Offset(s * 0.04, s * 0.07), r.topRight + Offset(-s * 0.04, s * 0.07), stroke(Colors.white.withValues(alpha: 0.8), s * 0.022));
          canvas.drawCircle(r.bottomCenter + Offset(0, -s * 0.07), s * 0.025, fill(Colors.white));
        }
      case NLoaderKind.symptoms:
        // A heart with ripples, like a check-in with the body.
        for (int i = 0; i < 3; i++) {
          final double p = (t + i / 3) % 1;
          canvas.drawCircle(c, s * (0.14 + 0.3 * p), stroke(NColors.brandBlush.withValues(alpha: 1 - p), s * 0.02));
        }
        final double beat = 1 + 0.08 * math.max(0, math.sin(t * 4 * math.pi));
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.scale(beat);
        final double h = s * 0.13;
        final Path heart = Path()
          ..moveTo(0, h * 0.9)
          ..cubicTo(-h * 1.6, -h * 0.2, -h * 0.7, -h * 1.3, 0, -h * 0.45)
          ..cubicTo(h * 0.7, -h * 1.3, h * 1.6, -h * 0.2, 0, h * 0.9)
          ..close();
        canvas.drawPath(heart, fill(NColors.brandRosewood));
        canvas.restore();
      case NLoaderKind.assessment:
        // A clipboard whose answers tick off one by one.
        final Rect board = Rect.fromCenter(center: c + Offset(0, s * 0.03), width: s * 0.48, height: s * 0.6);
        canvas.drawRRect(RRect.fromRectAndRadius(board, Radius.circular(s * 0.05)), fill(Colors.white));
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(c.dx, board.top), width: s * 0.2, height: s * 0.07), Radius.circular(s * 0.03)), fill(NColors.brandTerracotta));
        for (int i = 0; i < 3; i++) {
          final double y = board.top + s * (0.16 + i * 0.14);
          final bool done = t * 4 > i + 0.5;
          canvas.drawCircle(Offset(board.left + s * 0.08, y), s * 0.035, fill(done ? NColors.brandSage : NColors.lineDefault));
          if (done) {
            canvas.drawPath(
              Path()
                ..moveTo(board.left + s * 0.062, y)
                ..lineTo(board.left + s * 0.077, y + s * 0.016)
                ..lineTo(board.left + s * 0.1, y - s * 0.016),
              stroke(Colors.white, s * 0.014),
            );
          }
          canvas.drawLine(Offset(board.left + s * 0.15, y), Offset(board.right - s * 0.06, y), stroke(NColors.lineDefault, s * 0.03));
        }
      case NLoaderKind.secure:
        // A padlock with a turning ring: keeping her account safe.
        canvas.drawArc(Rect.fromCircle(center: c, radius: s * 0.36), t * 2 * math.pi, math.pi * 1.2, false, stroke(NColors.brandRosewood, s * 0.03));
        final Rect body = Rect.fromCenter(center: c + Offset(0, s * 0.06), width: s * 0.3, height: s * 0.24);
        canvas.drawArc(Rect.fromCenter(center: Offset(c.dx, body.top), width: s * 0.2, height: s * 0.22), math.pi, math.pi, false, stroke(NColors.inkSecondary, s * 0.04));
        canvas.drawRRect(RRect.fromRectAndRadius(body, Radius.circular(s * 0.05)), fill(NColors.brandTerracotta));
        canvas.drawCircle(body.center, s * 0.03 * (1 + 0.2 * wave), fill(Colors.white));
      case NLoaderKind.brand:
        canvas.drawArc(Rect.fromCircle(center: c, radius: s * 0.4), t * 2 * math.pi, math.pi * 0.7, false, stroke(NColors.brandRosewood, s * 0.03));
    }
  }

  @override
  bool shouldRepaint(_ThemedPainter old) => old.t != t || old.kind != kind;
}

/// The wait after the health check-in while the pre-score is worked out: a score gauge sweeps, four areas
/// (cycle, metabolic, mind, rest) light up around it, and the steps underneath tick off one by one.
class NScoringAnimation extends StatefulWidget {
  const NScoringAnimation({required this.areas, required this.steps, super.key, this.size = 230});

  /// Four short area names, shown around the gauge.
  final List<String> areas;
  final List<String> steps;
  final double size;

  @override
  State<NScoringAnimation> createState() => _NScoringAnimationState();
}

class _NScoringAnimationState extends State<NScoringAnimation> with SingleTickerProviderStateMixin, _Looping<NScoringAnimation> {
  int _done = 0;
  bool _started = false;

  @override
  Duration get loopDuration => const Duration(milliseconds: 2600);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || _still(context)) return;
    _started = true;
    _tick();
  }

  void _tick() => Future<void>.delayed(const Duration(milliseconds: 1300), () {
    if (!mounted || _done >= widget.steps.length - 1) return;
    setState(() => _done++);
    _tick();
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      ExcludeSemantics(
        child: SizedBox.square(
          dimension: widget.size,
          child: AnimatedBuilder(
            animation: loop,
            builder: (BuildContext context, _) => CustomPaint(
              painter: _ScoringPainter(loop.value, _done / math.max(1, widget.steps.length - 1)),
              child: Stack(
                children: <Widget>[
                  for (int i = 0; i < 4 && i < widget.areas.length; i++)
                    Align(
                      alignment: const <Alignment>[Alignment(-1, -0.15), Alignment(-0.55, -1), Alignment(0.55, -1), Alignment(1, -0.15)][i],
                      child: Text(
                        widget.areas[i],
                        style: NType.caption.copyWith(color: NColors.inkSecondary, fontWeight: FontWeight.w700),
                      ),
                    ),
                  Align(
                    alignment: const Alignment(0, 0.25),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.auto_awesome_rounded, color: NColors.brandRosewood.withValues(alpha: 0.6 + 0.4 * math.sin(loop.value * math.pi))),
                        Text('${(_done / math.max(1, widget.steps.length - 1) * 100).round()}%', style: NType.h2.copyWith(color: NColors.inkPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: NSpace.lg),
      IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int i = 0; i < widget.steps.length; i++)
              AnimatedOpacity(
                duration: NMotion.medium,
                opacity: i <= _done ? 1 : 0.4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: NSpace.xxs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AnimatedSwitcher(
                        duration: NMotion.medium,
                        child: i < _done
                            ? const Icon(Icons.check_circle_rounded, key: ValueKey<String>('done'), size: 20, color: NColors.statusSuccess)
                            : i == _done
                            ? const SizedBox(
                                key: ValueKey<String>('now'),
                                width: 20,
                                height: 20,
                                child: Padding(
                                  padding: EdgeInsets.all(2),
                                  child: CircularProgressIndicator(strokeWidth: 2.4, color: NColors.brandRosewood),
                                ),
                              )
                            : const Icon(Icons.radio_button_unchecked_rounded, key: ValueKey<String>('todo'), size: 20, color: NColors.lineStrong),
                      ),
                      const SizedBox(width: NSpace.sm),
                      Text(
                        widget.steps[i],
                        style: NType.body.copyWith(color: i <= _done ? NColors.inkPrimary : NColors.inkMuted, fontWeight: i == _done ? FontWeight.w600 : null),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

class _ScoringPainter extends CustomPainter {
  _ScoringPainter(this.t, this.progress);

  final double t;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final Offset c = Offset(s / 2, s * 0.56);
    final double r = s * 0.36;
    const double start = math.pi * 0.8;
    const double sweep = math.pi * 1.4;
    canvas.drawCircle(c, r * 0.78, Paint()..color = NColors.brandBlushLight);
    final Rect arc = Rect.fromCircle(center: c, radius: r);
    canvas.drawArc(
      arc,
      start,
      sweep,
      false,
      Paint()
        ..color = NColors.lineDefault
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.06
        ..strokeCap = StrokeCap.round,
    );
    // The filled part follows the steps; a light shimmer runs along it.
    final double fillTo = 0.12 + 0.88 * progress;
    canvas.drawArc(
      arc,
      start,
      sweep * fillTo,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: start,
          endAngle: start + sweep,
          colors: const <Color>[NColors.brandApricot, NColors.brandTerracotta, NColors.brandRosewood],
          transform: const GradientRotation(0),
        ).createShader(arc)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.06
        ..strokeCap = StrokeCap.round,
    );
    final double shimmer = start + sweep * fillTo * t;
    canvas.drawCircle(c + Offset(math.cos(shimmer), math.sin(shimmer)) * r, s * 0.022, Paint()..color = Colors.white.withValues(alpha: 0.9));
    // Four area orbs light up in turn.
    const List<Color> areaColors = <Color>[NColors.brandBlush, NColors.brandApricot, NColors.brandLavender, NColors.brandSage];
    for (int i = 0; i < 4; i++) {
      final double a = start + sweep * (0.08 + i * 0.28);
      final double lit = math.max(0, math.sin((t - i / 4) * 2 * math.pi));
      final Offset at = c + Offset(math.cos(a), math.sin(a)) * (r + s * 0.09);
      canvas.drawCircle(at, s * (0.03 + 0.012 * lit), Paint()..color = areaColors[i]);
      canvas.drawCircle(at, s * (0.05 + 0.03 * lit), Paint()..color = areaColors[i].withValues(alpha: 0.25 * lit));
    }
  }

  @override
  bool shouldRepaint(_ScoringPainter old) => old.t != t || old.progress != progress;
}
