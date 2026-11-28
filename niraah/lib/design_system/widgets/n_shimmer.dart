import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../generated/niraah_assets.dart';
import '../tokens/tokens.dart';

// Loading, the same language as the website (design pass 2026-11-26): placeholders in the shape of the page with
// one soft light sweeping across them, shown only if loading lasts (no flash on a quick load), still when the device
// asks for reduced motion. And one meal loader for everything food: the thali with rising steam.

bool _still(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Drives every shimmer shape below it from one clock, so the sweep runs across the page as one light.
class NShimmerScope extends StatefulWidget {
  const NShimmerScope({required this.child, super.key});

  final Widget child;

  static Animation<double>? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<_ShimmerClock>()?.animation;

  @override
  State<NShimmerScope> createState() => _NShimmerScopeState();
}

class _NShimmerScopeState extends State<NShimmerScope> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _ShimmerClock(animation: _c, child: widget.child);
}

class _ShimmerClock extends InheritedWidget {
  const _ShimmerClock({required this.animation, required super.child});

  final Animation<double> animation;

  @override
  bool updateShouldNotify(_ShimmerClock old) => old.animation != animation;
}

enum NShimmerTone { blush, soft, light }

/// One placeholder shape.
class NShimmer extends StatelessWidget {
  const NShimmer({super.key, this.width, this.height = 12, this.radius = NRadius.sm, this.tone = NShimmerTone.blush, this.circle = false});

  final double? width;
  final double height;
  final double radius;
  final NShimmerTone tone;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final Animation<double>? clock = NShimmerScope.of(context);
    final Color base = switch (tone) {
      NShimmerTone.blush => NColors.brandBlushLight,
      NShimmerTone.soft => NColors.surfaceWarm.withValues(alpha: 0.7),
      NShimmerTone.light => Colors.white.withValues(alpha: 0.62),
    };
    Widget box(double t) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment(-1.6 + 3.2 * t, -0.3),
          end: Alignment(-0.6 + 3.2 * t, 0.3),
          colors: <Color>[base, Color.lerp(base, Colors.white, 0.75)!, base],
          stops: const <double>[0.1, 0.5, 0.9],
        ),
      ),
    );
    if (clock == null) return box(-1);
    return AnimatedBuilder(animation: clock, builder: (_, _) => box(clock.value));
  }
}

/// Shows [child] only after a short wait, so a quick load never flashes a placeholder.
class NAppearLate extends StatefulWidget {
  const NAppearLate({required this.child, super.key, this.after = const Duration(milliseconds: 180)});

  final Widget child;
  final Duration after;

  @override
  State<NAppearLate> createState() => _NAppearLateState();
}

class _NAppearLateState extends State<NAppearLate> {
  bool _show = false;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(widget.after, () {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      AnimatedOpacity(opacity: _show ? 1 : 0, duration: const Duration(milliseconds: 320), curve: Curves.easeOut, child: widget.child);
}

/// A page loading: a title line, then cards with an avatar and lines, in the page's own shape.
class NPagePlaceholder extends StatelessWidget {
  const NPagePlaceholder({
    required this.label,
    super.key,
    this.cards = 3,
    this.padding = const EdgeInsets.fromLTRB(NSpace.lg, NSpace.md, NSpace.lg, NSpace.lg),
  });

  final String label;
  final int cards;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    liveRegion: true,
    child: ExcludeSemantics(
      child: NAppearLate(
        child: NShimmerScope(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const NShimmer(width: 140, height: 14),
                const SizedBox(height: NSpace.md),
                for (int i = 0; i < cards; i++) ...<Widget>[
                  Container(
                    padding: const EdgeInsets.all(NSpace.md),
                    decoration: BoxDecoration(
                      color: NColors.surfaceCard,
                      borderRadius: BorderRadius.circular(NRadius.lg),
                      border: Border.all(color: NColors.lineDefault.withValues(alpha: 0.6)),
                      boxShadow: NShadow.xs,
                    ),
                    child: Row(
                      children: <Widget>[
                        const NShimmer(width: 44, height: 44, circle: true),
                        const SizedBox(width: NSpace.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              FractionallySizedBox(widthFactor: i.isEven ? 0.55 : 0.7, child: const NShimmer(height: 12)),
                              const SizedBox(height: NSpace.xs),
                              FractionallySizedBox(
                                widthFactor: i.isEven ? 0.85 : 0.6,
                                child: const NShimmer(height: 10, tone: NShimmerTone.soft),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: NSpace.sm),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// The meal loader for everything food (meals, diet plan, meal scan): the thali on a breathing blush-apricot glow,
/// steam rising from it, and a slow rosewood ring turning around the plate. Still for reduced motion.
class NMealLoader extends StatefulWidget {
  const NMealLoader({super.key, this.size = 176});

  final double size;

  static const NImageAsset thali = NImages.i10IndianThaliMealPlate;

  @override
  State<NMealLoader> createState() => _NMealLoaderState();
}

class _NMealLoaderState extends State<NMealLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still(context)) {
      _c.value = 0.35;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double s = widget.size;
    final double plate = s * 0.62;
    return ExcludeSemantics(
      child: SizedBox(
        width: s,
        height: s * 1.12,
        child: AnimatedBuilder(
          animation: _c,
          builder: (BuildContext context, Widget? plateImage) {
            final double t = _c.value;
            final double breathe = 0.5 + 0.5 * math.sin(t * 2 * math.pi);
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned(
                  top: s * 0.12,
                  child: Transform.scale(
                    scale: 0.94 + 0.08 * breathe,
                    child: Container(
                      width: s,
                      height: s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: <Color>[
                            NColors.brandApricotLight,
                            NColors.brandBlushLight.withValues(alpha: 0.9),
                            NColors.brandBlushLight.withValues(alpha: 0),
                          ],
                          stops: const <double>[0.35, 0.72, 1],
                        ),
                      ),
                    ),
                  ),
                ),
                // The turning ring: two soft rosewood arcs round the plate.
                Positioned(
                  top: s * 0.12 + (s - plate * 1.22) / 2,
                  child: Transform.rotate(
                    angle: t * 2 * math.pi,
                    child: CustomPaint(size: Size.square(plate * 1.22), painter: _RingPainter(NColors.brandRosewood)),
                  ),
                ),
                // The plate, floating a little.
                Positioned(
                  top: s * 0.12 + (s - plate) / 2 + 2 * math.sin(t * 2 * math.pi),
                  child: Container(
                    width: plate,
                    height: plate,
                    decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: NShadow.md),
                    child: plateImage,
                  ),
                ),
                // Steam rising from the plate.
                Positioned(
                  top: 0,
                  child: CustomPaint(size: Size(s * 0.5, s * 0.3), painter: _SteamPainter(t, NColors.brandRosewood)),
                ),
              ],
            );
          },
          child: Image.asset(NMealLoader.thali.path, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect r = Offset.zero & size;
    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color.withValues(alpha: 0.12);
    canvas.drawOval(r.deflate(2), track);
    final Paint arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(colors: <Color>[color.withValues(alpha: 0), color.withValues(alpha: 0.8)]).createShader(r);
    canvas.drawArc(r.deflate(2), -math.pi / 2, math.pi * 0.7, false, arc);
    canvas.drawArc(r.deflate(2), math.pi / 2, math.pi * 0.7, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.color != color;
}

class _SteamPainter extends CustomPainter {
  _SteamPainter(this.t, this.color);

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 3; i++) {
      final double phase = (t + i / 3) % 1;
      final double x = size.width * (0.25 + 0.25 * i);
      final double rise = phase * size.height * 0.55;
      final double opacity = math.sin(phase * math.pi) * 0.55;
      final Paint p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: opacity);
      final Path path = Path();
      final double bottom = size.height - rise;
      path.moveTo(x, bottom);
      for (double y = 0; y <= size.height * 0.45; y += 2) {
        path.lineTo(x + math.sin((y / size.height) * 4 * math.pi + i) * 5, bottom - y);
      }
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(_SteamPainter old) => old.t != t || old.color != color;
}
