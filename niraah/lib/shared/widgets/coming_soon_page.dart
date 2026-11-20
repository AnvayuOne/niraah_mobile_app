import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../design_system/generated/niraah_assets.dart';
import '../../design_system/tokens/tokens.dart';
import '../../design_system/widgets/n_illustration.dart';
import '../../design_system/widgets/n_page.dart';
import '../../l10n/app_localizations.dart';

/// Placeholder for areas built in later phases (home, booking, support).
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return NPage(
      onBack: context.canPop() ? () => context.pop() : null,
      backLabel: s.back,
      body: Column(
        children: <Widget>[
          const SizedBox(height: NSpace.xl),
          const NLottie(path: NLotties.yoga, size: NSpace.xl3 * 3),
          const SizedBox(height: NSpace.lg),
          Text(s.comingSoonTitle, style: NType.h3.copyWith(color: NColors.inkPrimary)),
          const SizedBox(height: NSpace.xs),
          Text(s.comingSoonBody, textAlign: TextAlign.center, style: NType.body.copyWith(color: NColors.inkSecondary)),
        ],
      ),
    );
  }
}
