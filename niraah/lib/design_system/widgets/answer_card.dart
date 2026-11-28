import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../generated/niraah_assets.dart';
import '../motion/motion.dart';
import '../tokens/color_roles.dart';
import '../tokens/tokens.dart';

/// One selectable answer. Announced as a radio button in a group for single
/// choice, and as a checkbox for multiple choice.
class AnswerCard extends StatelessWidget {
  const AnswerCard({required this.label, required this.selected, required this.onTap, super.key, this.multiple = false, this.colorToken, this.icon, this.imagePath, this.fallbackIcon});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool multiple;
  final String? colorToken;
  final NImageAsset? icon;

  /// A picture for this option (assets/images/options/…). Until the file exists, [fallbackIcon] shows.
  final String? imagePath;
  final IconData? fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final Color tint = NColorRoles.answer(colorToken);
    final Duration d = NMotionRules.duration(context, NMotion.fast);
    return Semantics(
      container: true,
      button: false,
      checked: selected,
      inMutuallyExclusiveGroup: !multiple,
      label: label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(NRadius.lg),
            child: AnimatedContainer(
              duration: d,
              curve: NMotionRules.curve,
              constraints: const BoxConstraints(minHeight: NLayout.minTapTarget + NSpace.sm),
              padding: const EdgeInsets.symmetric(horizontal: NSpace.md, vertical: NSpace.sm),
              decoration: BoxDecoration(
                color: selected ? tint : NColors.surfaceCard,
                borderRadius: BorderRadius.circular(NRadius.lg),
                border: Border.all(color: selected ? NColors.actionPrimary : NColors.lineDefault, width: selected ? 2 : 1),
                boxShadow: selected ? NShadow.sm : NShadow.xs,
              ),
              child: Row(
                children: <Widget>[
                  AnimatedContainer(
                    duration: d,
                    width: 56,
                    height: 56,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(color: selected ? NColors.surfaceCard : tint, borderRadius: BorderRadius.circular(NRadius.md)),
                    child: _picture(selected),
                  ),
                  const SizedBox(width: NSpace.sm),
                  Expanded(
                    child: Text(
                      label,
                      style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: NSpace.sm),
                  _Indicator(selected: selected, multiple: multiple, duration: d),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension on AnswerCard {
  Widget? _picture(bool selected) {
    final Widget fallback = icon != null
        ? Padding(
            padding: const EdgeInsets.all(NSpace.xs),
            child: Image.asset(icon!.path, fit: BoxFit.contain, excludeFromSemantics: true),
          )
        : Icon(fallbackIcon ?? Icons.circle_outlined, size: 28, color: selected ? NColors.actionPrimary : NColors.brandRosewood);
    final String? path = imagePath == null ? null : NOptionImages.resolve(imagePath!);
    if (path == null) return fallback;
    return Image.asset(path, fit: BoxFit.cover, excludeFromSemantics: true, errorBuilder: (_, _, _) => fallback);
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({required this.selected, required this.multiple, required this.duration});

  final bool selected;
  final bool multiple;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: NMotionRules.curve,
      width: NSpace.lg,
      height: NSpace.lg,
      decoration: BoxDecoration(
        color: selected ? NColors.actionPrimary : NColors.surfaceCard,
        shape: multiple ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: multiple ? BorderRadius.circular(NRadius.sm - NSpace.xxs) : null,
        border: Border.all(color: selected ? NColors.actionPrimary : NColors.lineStrong, width: 2),
      ),
      child: selected ? Icon(Icons.check_rounded, size: NSpace.md, color: NColors.actionOnPrimary) : null,
    );
  }
}

/// Which option pictures are bundled, read once from the asset manifest at start-up.
abstract final class NOptionImages {
  static Set<String> _paths = <String>{};

  static bool has(String path) => resolve(path) != null;

  /// The picture to show: in dark mode its dark version (assets/images/options_dark/…) when bundled.
  static String? resolve(String path) {
    if (NColors.dark) {
      final String dark = path.replaceFirst('/options/', '/options_dark/');
      if (_paths.contains(dark)) return dark;
    }
    return _paths.contains(path) ? path : null;
  }

  static Future<void> load() async {
    try {
      final AssetManifest m = await AssetManifest.loadFromAssetBundle(rootBundle);
      _paths = m.listAssets().where((String a) => a.startsWith('assets/images/options/') || a.startsWith('assets/images/options_dark/')).toSet();
    } on Object {
      _paths = <String>{};
    }
  }
}
