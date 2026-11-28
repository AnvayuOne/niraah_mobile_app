import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../generated/niraah_assets.dart';
import '../motion/motion.dart';
import '../tokens/tokens.dart';

/// Dark-mode versions of the illustrations: `assets/images/dark/<same file name>`. When the app is dark and a
/// dark version is bundled it is shown; otherwise the light picture is used. Loaded once from the asset manifest.
abstract final class NDarkImages {
  static Set<String> _paths = <String>{};

  static String resolve(String path) {
    if (!NColors.dark) return path;
    final String dark = 'assets/images/dark/${path.split('/').last}';
    return _paths.contains(dark) ? dark : path;
  }

  static Future<void> load() async {
    try {
      final AssetManifest m = await AssetManifest.loadFromAssetBundle(rootBundle);
      _paths = m.listAssets().where((String a) => a.startsWith('assets/images/dark/')).toSet();
    } on Object {
      _paths = <String>{};
    }
  }
}

/// How an illustration enters. Entrances last [NMotion.slow] at most and
/// play once: continuous loops would break the 220 to 760 ms motion rule.
enum NEntrance { breathe, float, sway, none }

/// A generated image asset. Decorative images (no semantic label) are
/// excluded from screen readers.
class NIllustration extends StatelessWidget {
  const NIllustration({required this.asset, super.key, this.height, this.entrance = NEntrance.none, this.darkVersion = true});

  final NImageAsset asset;
  final double? height;
  final NEntrance entrance;

  /// False keeps the light picture in dark mode too (the animation spots, which keep their original look).
  final bool darkVersion;

  @override
  Widget build(BuildContext context) {
    final double h = height ?? asset.height;
    final double w = asset.width * (h / asset.height);
    final Widget image = Image.asset(
      (darkVersion ? NDarkImages.resolve(asset.path) : asset.path),
      width: w,
      height: h,
      fit: BoxFit.contain,
      excludeFromSemantics: asset.semanticLabel == null,
      semanticLabel: asset.semanticLabel,
    );
    if (entrance == NEntrance.none || NMotionRules.reduced(context)) return image;
    return TweenAnimationBuilder<double>(
      key: ValueKey<String>((darkVersion ? NDarkImages.resolve(asset.path) : asset.path)),
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

/// Shown where a Lottie animation used to be. The Lottie drawings are no
/// longer used anywhere: each one maps to the matching illustration from the
/// image set, which fades in once.
class NLottie extends StatelessWidget {
  const NLottie({required this.path, required this.size, super.key});

  final String path;
  final double size;

  static NImageAsset imageFor(String path) => switch (path) {
        NLotties.cycle => NImages.screen04CycleCenterWoman,
        NLotties.companion => NImages.i04FemaleAiCompanionOrb,
        NLotties.yoga => NImages.i02YogaPadmasanaBreathWoman,
        NLotties.nutrition => NImages.i10IndianThaliMealPlate,
        NLotties.doctor => NImages.i03FemaleGynecologistClipboard,
        NLotties.pregnancy => NImages.onb05PregnancyCare,
        NLotties.celebrate => NImages.onb07PrescoreBloom,
        _ => NImages.onb01SanctuaryWelcome,
      };

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        // The original light pictures in both themes: the dark redraws did not suit these spots.
        child: FittedBox(child: NIllustration(asset: imageFor(path), height: size, entrance: NEntrance.breathe, darkVersion: false)),
      );
}
