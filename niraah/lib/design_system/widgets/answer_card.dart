import 'package:material_ui/material_ui.dart';

import '../generated/niraah_assets.dart';
import '../motion/motion.dart';
import '../tokens/color_roles.dart';
import '../tokens/tokens.dart';

/// One selectable answer. Announced as a radio button in a group for single
/// choice, and as a checkbox for multiple choice.
class AnswerCard extends StatelessWidget {
  const AnswerCard({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
    this.multiple = false,
    this.colorToken,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool multiple;
  final String? colorToken;
  final NImageAsset? icon;

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
                border: Border.all(
                  color: selected ? NColors.actionPrimary : NColors.lineDefault,
                  width: selected ? 2 : 1,
                ),
                boxShadow: selected ? NShadow.sm : NShadow.xs,
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: NSpace.xl + NSpace.xxs,
                    height: NSpace.xl + NSpace.xxs,
                    decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(NRadius.md)),
                    padding: const EdgeInsets.all(NSpace.xxs),
                    child: icon == null ? null : Image.asset(icon!.path, fit: BoxFit.contain, excludeFromSemantics: true),
                  ),
                  const SizedBox(width: NSpace.sm),
                  Expanded(
                    child: Text(label, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
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
      child: selected ? const Icon(Icons.check_rounded, size: NSpace.md, color: NColors.actionOnPrimary) : null,
    );
  }
}
