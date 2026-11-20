import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

import '../motion/motion.dart';
import '../tokens/tokens.dart';

/// "Living" layer of the Niraah UI: soft entrances, tactile presses, gentle
/// tilt and halos. Everything follows constitution §8.4: entrances play once
/// within 220 to 760 ms, nothing loops, and with reduced motion nothing moves.

/// Fades and lifts its child in once. Stagger siblings with [delay].
class NFadeUp extends StatefulWidget {
  const NFadeUp({required this.child, super.key, this.delay = Duration.zero, this.offset = NSpace.md});

  final Widget child;
  final Duration delay;
  final double offset;

  /// Stagger step between siblings, kept small so a whole screen settles
  /// within the motion budget.
  static const Duration step = Duration(milliseconds: 60);

  @override
  State<NFadeUp> createState() => _NFadeUpState();
}

class _NFadeUpState extends State<NFadeUp> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: NMotion.medium);
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: NMotionRules.curve);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (NMotionRules.reduced(context)) {
      _c.value = 1;
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _t,
    child: widget.child,
    builder: (BuildContext context, Widget? child) => Opacity(
      opacity: _t.value,
      child: Transform.translate(offset: Offset(0, widget.offset * (1 - _t.value)), child: child),
    ),
  );
}

/// Staggers a list of children with [NFadeUp].
List<Widget> nStagger(List<Widget> children, {Duration start = Duration.zero}) => <Widget>[
  for (int i = 0; i < children.length; i++) NFadeUp(delay: start + NFadeUp.step * math.min(i, 8), child: children[i]),
];

/// Shrinks slightly while pressed so taps feel tactile. Purely visual: the
/// child keeps its own semantics and tap handling.
class NPressable extends StatefulWidget {
  const NPressable({required this.child, super.key, this.enabled = true, this.scale = 0.97});

  final Widget child;
  final bool enabled;
  final double scale;

  @override
  State<NPressable> createState() => _NPressableState();
}

class _NPressableState extends State<NPressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.enabled && _down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => _set(true),
    onPointerUp: (_) => _set(false),
    onPointerCancel: (_) => _set(false),
    child: AnimatedScale(
      scale: _down ? widget.scale : 1,
      duration: NMotionRules.duration(context, NMotion.fast),
      curve: NMotionRules.curve,
      child: widget.child,
    ),
  );
}

/// Tilts its child toward the pointer on hover (web and desktop). Driven by
/// the pointer, never by a timer.
class NTilt extends StatefulWidget {
  const NTilt({required this.child, super.key, this.maxAngle = 0.08, this.lift = 6});

  final Widget child;
  final double maxAngle;
  final double lift;

  @override
  State<NTilt> createState() => _NTiltState();
}

class _NTiltState extends State<NTilt> {
  Offset _p = Offset.zero; // -1..1 in both axes
  bool _hover = false;

  void _move(PointerEvent e, Size size) {
    if (size.isEmpty) return;
    setState(() => _p = Offset((e.localPosition.dx / size.width) * 2 - 1, (e.localPosition.dy / size.height) * 2 - 1));
  }

  @override
  Widget build(BuildContext context) {
    if (NMotionRules.reduced(context)) return widget.child;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final Size size = Size(c.maxWidth.isFinite ? c.maxWidth : 0, c.maxHeight.isFinite ? c.maxHeight : 0);
        return MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() {
            _hover = false;
            _p = Offset.zero;
          }),
          onHover: (PointerHoverEvent e) => _move(e, size.isEmpty ? (context.size ?? Size.zero) : size),
          child: TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(end: _p),
            duration: NMotion.fast,
            curve: NMotionRules.curve,
            child: widget.child,
            builder: (BuildContext context, Offset p, Widget? child) => Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..translateByDouble(0, _hover ? -widget.lift : 0, 0, 1)
                ..rotateX(-p.dy * widget.maxAngle)
                ..rotateY(p.dx * widget.maxAngle),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// A soft radial glow placed behind art or a heading. Static.
class NHalo extends StatelessWidget {
  const NHalo({required this.child, super.key, this.color = NColors.brandBlush, this.size = 280});

  final Widget child;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    clipBehavior: Clip.none,
    children: <Widget>[
      IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: <Color>[color.withValues(alpha: 0.55), color.withValues(alpha: 0)]),
          ),
        ),
      ),
      child,
    ],
  );
}

/// Page backdrop with two faint brand washes (blush top right, lavender
/// bottom left), as on the Niraah website.
class NBackdrop extends StatelessWidget {
  const NBackdrop({required this.child, super.key, this.base = NColors.surfacePage});

  final Widget child;
  final Color base;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: base),
    child: Stack(
      children: <Widget>[
        const Positioned(top: -120, right: -100, child: _Wash(color: NColors.brandBlushLight, size: 340)),
        const Positioned(bottom: -140, left: -120, child: _Wash(color: NColors.brandLavenderLight, size: 380)),
        Positioned.fill(child: child),
      ],
    ),
  );
}

class _Wash extends StatelessWidget {
  const _Wash({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: <Color>[color, color.withValues(alpha: 0)]),
      ),
    ),
  );
}

/// Rounded-square ("squircle") icon tile in a brand tint, used for quick
/// actions and feature lists.
class NSquircleIcon extends StatelessWidget {
  const NSquircleIcon({
    required this.icon,
    super.key,
    this.tint = NColors.brandBlushLight,
    this.color = NColors.brandRosewood,
    this.size = 48,
  });

  final IconData icon;
  final Color tint;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: tint,
        shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(size * 0.55)),
      ),
      child: Icon(icon, color: color, size: size * 0.48),
    ),
  );
}

/// Small frosted label floating over art ("Verified doctors", "Private").
class NGlassChip extends StatelessWidget {
  const NGlassChip({required this.icon, required this.label, super.key});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: NSpace.xs),
    decoration: BoxDecoration(
      color: NColors.surfaceCard.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(NRadius.pill),
      border: Border.all(color: NColors.lineDefault),
      boxShadow: NShadow.md,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: NColors.brandRosewood),
        const SizedBox(width: NSpace.xs),
        Text(
          label,
          style: NType.label.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
