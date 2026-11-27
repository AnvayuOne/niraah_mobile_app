import 'package:material_ui/material_ui.dart';

import '../motion/motion.dart';
import '../tokens/tokens.dart';

class ScaleStep {
  const ScaleStep({required this.value, required this.label});

  final String value;
  final String label;
}

/// A scale with a word for each step. Each step is a radio button in a group.
class ScaleSelector extends StatelessWidget {
  const ScaleSelector({
    required this.steps,
    required this.selected,
    required this.onSelected,
    required this.selectedLabelBuilder,
    super.key,
  });

  final List<ScaleStep> steps;
  final String? selected;
  final ValueChanged<String> onSelected;
  final String Function(String label) selectedLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final Duration d = NMotionRules.duration(context, NMotion.fast);
    final ScaleStep? chosen = steps.where((ScaleStep s) => s.value == selected).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            for (int i = 0; i < steps.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: NSpace.xs),
              Expanded(
                child: Semantics(
                  container: true,
                  checked: steps[i].value == selected,
                  inMutuallyExclusiveGroup: true,
                  label: steps[i].label,
                  onTap: () => onSelected(steps[i].value),
                  child: ExcludeSemantics(
                    child: InkWell(
                      onTap: () => onSelected(steps[i].value),
                      borderRadius: BorderRadius.circular(NRadius.md),
                      child: AnimatedContainer(
                        duration: d,
                        curve: NMotionRules.curve,
                        constraints: const BoxConstraints(minHeight: NLayout.minTapTarget + NSpace.xl),
                        padding: const EdgeInsets.symmetric(horizontal: NSpace.xxs, vertical: NSpace.sm),
                        decoration: BoxDecoration(
                          color: steps[i].value == selected ? NColors.brandBlushLight : NColors.surfaceCard,
                          borderRadius: BorderRadius.circular(NRadius.md),
                          border: Border.all(
                            color: steps[i].value == selected ? NColors.actionPrimary : NColors.lineDefault,
                            width: steps[i].value == selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('${i + 1}', style: NType.h4.copyWith(color: NColors.inkPrimary)),
                            const SizedBox(height: NSpace.xxs),
                            Text(
                              steps[i].label,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: NType.label.copyWith(color: NColors.inkSecondary, letterSpacing: 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: NSpace.sm),
        if (chosen != null)
          Text(selectedLabelBuilder(chosen.label), textAlign: TextAlign.center, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
      ],
    );
  }
}
