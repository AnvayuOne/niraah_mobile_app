import 'package:material_ui/material_ui.dart';

import '../tokens/tokens.dart';

/// A dimension's name and level in words ("Sleep · Steady"). Never points.
class LevelChip extends StatelessWidget {
  const LevelChip({required this.name, required this.level, super.key});

  final String name;
  final String level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: NSpace.xs),
      decoration: BoxDecoration(
        color: NColors.surfaceCard,
        borderRadius: BorderRadius.circular(NRadius.pill),
        border: Border.all(color: NColors.lineDefault),
      ),
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(text: name, style: NType.bodySm.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
            TextSpan(text: ' · $level', style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
          ],
        ),
      ),
    );
  }
}
