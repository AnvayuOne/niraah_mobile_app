import 'dart:math' as math;
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import '../../../design_system/motion/motion.dart';
import '../../../design_system/tokens/tokens.dart';
import '../domain/meals.dart';

/// The photo while the AI reads it: a light beam sweeps the plate inside
/// corner brackets, and the status line steps through what is happening.
class ScanningPhoto extends StatefulWidget {
  const ScanningPhoto({required this.photo, required this.steps, super.key});

  final Uint8List photo;
  final List<String> steps;

  @override
  State<ScanningPhoto> createState() => _ScanningPhotoState();
}

class _ScanningPhotoState extends State<ScanningPhoto> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
  int _step = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (NMotionRules.reduced(context)) return;
    if (!_c.isAnimating) _c.repeat(reverse: true);
    _tick();
  }

  void _tick() {
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _step = math.min(_step + 1, widget.steps.length - 1));
      if (_step < widget.steps.length - 1) _tick();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      ClipRRect(
        borderRadius: BorderRadius.circular(NRadius.xl),
        child: AspectRatio(
          aspectRatio: 4 / 5,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.memory(widget.photo, fit: BoxFit.cover),
              Container(color: Colors.black.withValues(alpha: 0.18)),
              AnimatedBuilder(
                animation: _c,
                builder: (BuildContext context, _) => CustomPaint(painter: _BeamPainter(_c.value)),
              ),
              const Padding(
                padding: EdgeInsets.all(NSpace.lg),
                child: CustomPaint(painter: _CornersPainter()),
              ),
              Positioned(
                left: NSpace.md,
                right: NSpace.md,
                bottom: NSpace.md,
                child: AnimatedSwitcher(
                  duration: NMotion.medium,
                  child: _Pill(key: ValueKey<int>(_step), text: widget.steps[_step]),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: NSpace.md),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (int i = 0; i < widget.steps.length; i++)
            AnimatedContainer(
              duration: NMotion.medium,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _step ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(color: i <= _step ? NColors.brandTerracotta : NColors.lineDefault, borderRadius: BorderRadius.circular(NRadius.pill)),
            ),
        ],
      ),
    ],
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: NSpace.md, vertical: NSpace.sm),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(NRadius.pill)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: NColors.brandTerracotta)),
        const SizedBox(width: NSpace.sm),
        Flexible(
          child: Text(
            text,
            style: NType.bodySm.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _BeamPainter extends CustomPainter {
  _BeamPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final double y = size.height * (0.08 + 0.84 * t);
    final Rect glow = Rect.fromLTWH(0, y - 60, size.width, 60);
    canvas.drawRect(
      glow,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[NColors.brandApricot.withValues(alpha: 0), NColors.brandApricot.withValues(alpha: 0.45)],
        ).createShader(glow),
    );
    canvas.drawLine(
      Offset(NSpace.md, y),
      Offset(size.width - NSpace.md, y),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3),
    );
  }

  @override
  bool shouldRepaint(_BeamPainter old) => old.t != t;
}

class _CornersPainter extends CustomPainter {
  const _CornersPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const double l = 28;
    for (final (double x, double y, double dx, double dy) in <(double, double, double, double)>[(0, 0, 1, 1), (size.width, 0, -1, 1), (0, size.height, 1, -1), (size.width, size.height, -1, -1)]) {
      canvas.drawPath(
        Path()
          ..moveTo(x, y + dy * l)
          ..lineTo(x, y)
          ..lineTo(x + dx * l, y),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_CornersPainter old) => false;
}

/// Sums the nutrients that are known; null when none are.
Nutrients? sumNutrients(Iterable<Nutrients?> all) {
  final List<Nutrients> list = all.whereType<Nutrients>().toList();
  if (list.isEmpty) return null;
  final bool kcal = list.every((Nutrients n) => n.energyKcal != null);
  return Nutrients(
    energyKcal: kcal ? list.fold<double>(0, (double a, Nutrients n) => a + n.energyKcal!) : null,
    proteinG: list.fold<double>(0, (double a, Nutrients n) => a + n.proteinG),
    carbohydrateG: list.fold<double>(0, (double a, Nutrients n) => a + n.carbohydrateG),
    fatG: list.fold<double>(0, (double a, Nutrients n) => a + n.fatG),
    fibreG: list.fold<double>(0, (double a, Nutrients n) => a + n.fibreG),
  );
}

/// The plate's nutrients: calories count up in the middle of a ring split by
/// protein, carbs and fat; each macro fills its own bar underneath.
class NutrientSummary extends StatelessWidget {
  const NutrientSummary({required this.n, required this.title, super.key});

  final Nutrients n;
  final String title;

  @override
  Widget build(BuildContext context) {
    final bool reduced = NMotionRules.reduced(context);
    final List<(String, double, Color, double)> macros = <(String, double, Color, double)>[
      ('Protein', n.proteinG, NColors.brandSage, 4),
      ('Carbs', n.carbohydrateG, NColors.brandApricot, 4),
      ('Fat', n.fatG, NColors.brandLavender, 9),
      ('Fibre', n.fibreG, NColors.brandTerracotta, 0),
    ];
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: reduced ? 1 : 0, end: 1),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double t, _) => Container(
        padding: const EdgeInsets.all(NSpace.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[NColors.brandApricotLight, NColors.surfaceCard]),
          borderRadius: BorderRadius.circular(NRadius.xl),
          border: Border.all(color: NColors.lineDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: NType.label.copyWith(color: NColors.inkMuted)),
            const SizedBox(height: NSpace.md),
            Row(
              children: <Widget>[
                SizedBox.square(
                  dimension: 118,
                  child: CustomPaint(
                    painter: _MacroRing(<(double, Color)>[for (final m in macros.take(3)) (m.$2 * m.$4, m.$3)], t),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: n.energyKcal == null
                            ? <Widget>[
                                Text('${(n.proteinG * t).round()} g', style: NType.h3.copyWith(color: NColors.inkPrimary)),
                                Text('protein', style: NType.caption.copyWith(color: NColors.inkMuted)),
                              ]
                            : <Widget>[
                                Text('${(n.energyKcal! * t).round()}', style: NType.h2.copyWith(color: NColors.inkPrimary, height: 1)),
                                Text('kcal', style: NType.caption.copyWith(color: NColors.inkMuted)),
                              ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: NSpace.lg),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      for (final m in macros) ...<Widget>[
                        _MacroBar(label: m.$1, grams: m.$2, color: m.$3, t: t, max: math.max(1, macros.map((x) => x.$2).reduce(math.max))),
                        const SizedBox(height: NSpace.xs),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({required this.label, required this.grams, required this.color, required this.t, required this.max});

  final String label;
  final double grams;
  final Color color;
  final double t;
  final double max;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label, style: NType.caption.copyWith(color: NColors.inkSecondary)),
          ),
          Text(
            '${(grams * t).toStringAsFixed(grams < 10 ? 1 : 0)} g',
            style: NType.caption.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      const SizedBox(height: 3),
      ClipRRect(
        borderRadius: BorderRadius.circular(NRadius.pill),
        child: LinearProgressIndicator(value: (grams / max) * t, minHeight: 6, color: color, backgroundColor: color.withValues(alpha: 0.18)),
      ),
    ],
  );
}

class _MacroRing extends CustomPainter {
  _MacroRing(this.parts, this.t);

  final List<(double, Color)> parts;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect r = Offset.zero & size;
    final Rect ring = r.deflate(8);
    canvas.drawArc(
      ring,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = NColors.lineDefault
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );
    final double total = parts.fold<double>(0, (double a, (double, Color) p) => a + p.$1);
    if (total <= 0) return;
    double start = -math.pi / 2;
    for (final (double v, Color c) in parts) {
      final double sweep = (v / total) * math.pi * 2 * t;
      if (sweep > 0.02) {
        canvas.drawArc(
          ring,
          start + 0.03,
          sweep - 0.06,
          false,
          Paint()
            ..color = c
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 12,
        );
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_MacroRing old) => old.t != t;
}

/// Slides and fades a child in after [index] × 120 ms.
class SlideInItem extends StatelessWidget {
  const SlideInItem({required this.index, required this.child, super.key});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (NMotionRules.reduced(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + index * 120),
      curve: Interval(math.min(0.9, index * 120 / (420 + index * 120)), 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (BuildContext context, double t, Widget? c) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 24 * (1 - t)), child: c),
      ),
    );
  }
}
