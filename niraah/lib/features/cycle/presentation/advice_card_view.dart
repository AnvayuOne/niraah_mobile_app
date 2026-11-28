import 'package:material_ui/material_ui.dart';

import '../../../design_system/tokens/tokens.dart';
import '../domain/cycle.dart';

/// A rule-raised advice card with clinician wording (spec 010 §3, §4,
/// "Wellness-only wording"). Never carries an upsell (AC50).
class AdviceCardView extends StatelessWidget {
  const AdviceCardView({required this.card, super.key});

  final AdviceCard card;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: card.title,
      child: Container(
        padding: const EdgeInsets.all(NSpace.lg),
        decoration: BoxDecoration(
          color: NColors.statusAttentionLight,
          borderRadius: BorderRadius.circular(NRadius.xl),
          border: Border.all(color: NColors.statusAttention.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(card.title, style: NType.h4.copyWith(color: NColors.statusAttention)),
            const SizedBox(height: NSpace.xs),
            Text(card.text, style: NType.body.copyWith(color: NColors.inkSecondary)),
            if (card.notPassedOn != null) ...<Widget>[
              const SizedBox(height: NSpace.xs),
              Text(card.notPassedOn!, style: NType.bodySm.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}
