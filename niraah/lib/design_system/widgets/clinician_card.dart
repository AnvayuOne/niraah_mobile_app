import 'package:material_ui/material_ui.dart';

import '../generated/niraah_assets.dart';
import '../tokens/tokens.dart';
import 'n_illustration.dart';

enum ClinicianCardState { notRequired, awaitingReview, verified, followUpRequested }

/// The clinician card on the pre-score (spec 007 §7). The seal and the words
/// "Clinician Verified" appear only in [ClinicianCardState.verified].
class ClinicianCard extends StatelessWidget {
  const ClinicianCard({
    required this.state,
    required this.title,
    super.key,
    this.body,
    this.actionLabel,
    this.onAction,
  });

  final ClinicianCardState state;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final bool verified = state == ClinicianCardState.verified;
    final Color bg = switch (state) {
      ClinicianCardState.verified => NColors.brandSage,
      ClinicianCardState.followUpRequested => NColors.brandBlushLight,
      _ => NColors.surfaceCard,
    };
    final IconData icon = switch (state) {
      ClinicianCardState.notRequired => Icons.menu_book_rounded,
      ClinicianCardState.awaitingReview => Icons.schedule_rounded,
      ClinicianCardState.verified => Icons.verified_rounded,
      ClinicianCardState.followUpRequested => Icons.chat_bubble_outline_rounded,
    };
    return Container(
      padding: const EdgeInsets.all(NSpace.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(NRadius.lg),
        border: Border.all(color: NColors.lineDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (verified)
            const NIllustration(asset: NImages.screen03ClinicianVerifiedDoctor, height: NSpace.xl3)
          else
            Icon(icon, color: NColors.actionLink),
          const SizedBox(width: NSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)),
                if (body != null) ...<Widget>[
                  const SizedBox(height: NSpace.xxs),
                  Text(body!, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                ],
                if (actionLabel != null && onAction != null)
                  Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: onAction, child: Text(actionLabel!))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
