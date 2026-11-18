import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';

import '../generated/niraah_assets.dart';
import '../motion/motion.dart';
import '../tokens/tokens.dart';

/// How an illustration enters. Entrances last [NMotion.slow] at most and
/// play once: continuous loops would break the 220 to 760 ms motion rule.
enum NEntrance { breathe, float, sway, none }

/// A generated image asset. Decorative images (no semantic label) are
/// excluded from screen readers.
class NIllustration extends StatelessWidget {
  const NIllustration({required this.asset, super.key, this.height, this.entrance = NEntrance.none});

  final NImageAsset asset;
  final double? height;
  final NEntrance entrance;

  @override
  Widget build(BuildContext context) {
    final double h = height ?? asset.height;
    final double w = asset.width * (h / asset.height);
    final Widget image = Image.asset(
      asset.path,
      width: w,
      height: h,
      fit: BoxFit.contain,
      excludeFromSemantics: asset.semanticLabel == null,
      semanticLabel: asset.semanticLabel,
    );
    if (entrance == NEntrance.none || NMotionRules.reduced(context)) return image;
    return TweenAnimationBuilder<double>(
      key: ValueKey<String>(asset.path),
      tween: Tween<double>(begin: 0, end: 1),
      duration: NMotion.slow,
      curve: NMotionRules.curve,
      child: image,
      builder: (BuildContext context, double t, Widget? child) {
        final double inv = 1 - t;
        final Matrix4 m = switch (entrance) {
          NEntrance.breathe => Matrix4.diagonal3Values(0.96 + 0.04 * t, 0.96 + 0.04 * t, 1),
          NEntrance.float => Matrix4.translationValues(0, NSpace.sm * inv, 0),
          NEntrance.sway => Matrix4.rotationZ(-0.035 * inv),
          NEntrance.none => Matrix4.identity(),
        };
        return Opacity(opacity: t, child: Transform(alignment: Alignment.center, transform: m, child: child));
      },
    );
  }
}

/// A Lottie animation from the generated set. With reduced motion it shows
/// its first frame and does not move. Always decorative.
class NLottie extends StatelessWidget {
  const NLottie({required this.path, required this.size, super.key});

  final String path;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bool reduced = NMotionRules.reduced(context);
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Lottie.asset(path, animate: !reduced, repeat: !reduced, fit: BoxFit.contain),
      ),
    );
  }
}
