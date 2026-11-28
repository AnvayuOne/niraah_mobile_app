import 'package:material_ui/material_ui.dart';

import '../motion/motion.dart';
import '../tokens/tokens.dart';

/// "Step N of M" with a bar. M is the number of questions currently expected
/// for her answers so far (spec 007 §2.2).
class StepProgress extends StatelessWidget {
  const StepProgress({
    required this.current,
    required this.total,
    required this.label,
    required this.section,
    super.key,
    this.onBrand = true,
  });

  final int current;
  final int total;
  final String label;
  final String section;

  /// Drawn on the coral header.
  final bool onBrand;

  @override
  Widget build(BuildContext context) {
    final double fraction = total == 0 ? 0 : (current / total).clamp(0, 1).toDouble();
    final Color ink = onBrand ? NColors.inkOnBrand : NColors.inkSecondary;
    final Color track = onBrand ? NColors.inkOnBrand.withValues(alpha: 0.3) : NColors.lineDefault;
    final Color fill = onBrand ? NColors.inkOnBrand : NColors.actionLink;
    return Semantics(
      container: true,
      label: label,
      value: '${(fraction * 100).round()}%',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text(section.toUpperCase(), style: NType.caption.copyWith(color: ink))),
                Text(label, style: NType.label.copyWith(color: ink)),
              ],
            ),
            const SizedBox(height: NSpace.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(NRadius.pill),
              child: SizedBox(
                height: NSpace.xxs + 2,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(child: ColoredBox(color: track)),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: fraction),
                      duration: NMotionRules.duration(context, NMotion.medium),
                      curve: NMotionRules.curve,
                      builder: (BuildContext context, double v, Widget? _) =>
                          FractionallySizedBox(widthFactor: v, heightFactor: 1, child: ColoredBox(color: fill)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
