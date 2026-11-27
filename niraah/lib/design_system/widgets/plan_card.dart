import 'package:material_ui/material_ui.dart';

import '../tokens/color_roles.dart';
import '../tokens/tokens.dart';

/// A plan on the plans screen. Content (lines, price text) is supplied by the
/// caller from the plans list; nothing here is hard-coded per plan.
class PlanCard extends StatelessWidget {
  const PlanCard({
    required this.name,
    required this.description,
    required this.priceText,
    required this.priceNote,
    required this.lines,
    required this.colorToken,
    required this.actionLabel,
    required this.onAction,
    super.key,
    this.badge,
    this.recommendedLabel,
    this.quietAction = false,
  });

  /// An outlined action, for the plan she already holds.
  final bool quietAction;

  final String name;
  final String description;
  final String priceText;
  final String priceNote;
  final List<String> lines;
  final String colorToken;
  final String actionLabel;
  final VoidCallback onAction;
  final String? badge;

  /// "Recommended for you", when the server marked this plan.
  final String? recommendedLabel;

  @override
  Widget build(BuildContext context) {
    final Color bg = NColorRoles.plan(colorToken);
    final Color ink = NColorRoles.onPlan(colorToken);
    final bool recommended = recommendedLabel != null;
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(NRadius.xl),
        border: Border.all(color: recommended ? NColors.actionPrimary : NColors.lineDefault, width: recommended ? 2 : 1),
        boxShadow: recommended ? NShadow.md : NShadow.xs,
      ),
      padding: const EdgeInsets.all(NSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (recommended || badge != null)
            Padding(
              padding: const EdgeInsets.only(bottom: NSpace.sm),
              child: Wrap(
                spacing: NSpace.xs,
                runSpacing: NSpace.xs,
                children: <Widget>[
                  if (recommended) _Pill(text: recommendedLabel!, background: NColors.actionPrimary, ink: NColors.actionOnPrimary),
                  if (badge != null) _Pill(text: badge!, background: NColors.surfaceCard, ink: NColors.inkPrimary),
                ],
              ),
            ),
          Text(name, style: NType.h3.copyWith(color: ink)),
          const SizedBox(height: NSpace.xxs),
          Text(description, style: NType.bodySm.copyWith(color: ink)),
          const SizedBox(height: NSpace.md),
          Text(priceText, style: NType.h2.copyWith(color: ink)),
          Text(priceNote, style: NType.label.copyWith(color: ink, letterSpacing: 0)),
          const SizedBox(height: NSpace.md),
          for (String line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: NSpace.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.check_circle_rounded, size: NSpace.lg - NSpace.xxs, color: ink),
                  const SizedBox(width: NSpace.xs),
                  Expanded(child: Text(line, style: NType.bodySm.copyWith(color: ink))),
                ],
              ),
            ),
          const SizedBox(height: NSpace.sm),
          SizedBox(
            width: double.infinity,
            child: quietAction
                ? OutlinedButton(onPressed: onAction, child: Text(actionLabel))
                : FilledButton(
                    style: colorToken == 'tier3'
                        ? FilledButton.styleFrom(backgroundColor: NColors.surfaceCard, foregroundColor: NColors.actionPrimary)
                        : null,
                    onPressed: onAction,
                    child: Text(actionLabel),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.background, required this.ink});

  final String text;
  final Color background;
  final Color ink;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: NSpace.xxs),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(NRadius.pill)),
        child: Text(text, style: NType.label.copyWith(color: ink)),
      );
}
