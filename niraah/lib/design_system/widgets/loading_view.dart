import 'package:material_ui/material_ui.dart';

import '../generated/niraah_assets.dart';
import '../tokens/tokens.dart';
import 'n_loaders.dart';
import 'n_shimmer.dart';

export 'n_loaders.dart' show NLoaderKind;

/// A loading screen. Each area passes its own [kind], so the wait looks like the place she is going:
/// a cycle ring for Cycle, a thali for Meals, speech bubbles for AI Care, a heartbeat for care, and so on.
class LoadingView extends StatelessWidget {
  const LoadingView({required this.label, super.key, this.kind = NLoaderKind.brand});

  /// Announced to screen readers and shown under the picture.
  final String label;
  final NLoaderKind kind;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: label,
        // Scales down inside a short box (a loading card inside a list) instead of overflowing.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (kind == NLoaderKind.brand)
                  const NBrandMark()
                else if (kind == NLoaderKind.meals)
                  const NMealLoader()
                else
                  NThemedLoader(kind: kind),
                const SizedBox(height: NSpace.md),
                NFadingDots(color: NColors.inkMuted, label: label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The Niraah mark breathing in a soft blush glow: the brand loading moment, the same as the website's.
/// Still when the device asks for reduced motion.
class NBrandMark extends StatefulWidget {
  const NBrandMark({super.key, this.size = 128});

  final double size;

  @override
  State<NBrandMark> createState() => _NBrandMarkState();
}

class _NBrandMarkState extends State<NBrandMark> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _c.value = 0.5;
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
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
    return SizedBox(
      width: s,
      height: s,
      child: AnimatedBuilder(
        animation: _c,
        builder: (BuildContext context, Widget? child) {
          final double t = Curves.easeInOut.transform(_c.value);
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Transform.scale(
                scale: 0.9 + 0.16 * t,
                child: Container(
                  width: s,
                  height: s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        NColors.brandBlush.withValues(alpha: 0.55 + 0.3 * t),
                        NColors.brandBlushLight.withValues(alpha: 0.95),
                        NColors.brandBlushLight.withValues(alpha: 0),
                      ],
                      stops: const <double>[0.45, 0.75, 1],
                    ),
                  ),
                ),
              ),
              child!,
            ],
          );
        },
        child: Container(
          width: s * 0.66,
          height: s * 0.66,
          decoration: BoxDecoration(color: NColors.surfaceCard, shape: BoxShape.circle, boxShadow: NShadow.sm),
          alignment: Alignment.center,
          child: Image.asset(NImages.niraahLogo.path, width: s * 0.4, height: s * 0.4, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
