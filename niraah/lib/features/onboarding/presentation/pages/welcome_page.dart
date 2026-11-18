import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../design_system/generated/niraah_assets.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../design_system/widgets/n_button.dart';
import '../../../../design_system/widgets/n_illustration.dart';
import '../../../../design_system/widgets/n_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/constants/route_constants.dart';

/// What Niraah is, that it is a wellness service, and one way on (spec 010 §1).
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return NPage(
      background: NColors.surfacePage,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: NSpace.md),
          Center(
            child: Container(
              decoration: BoxDecoration(color: NColors.surfaceWarm, borderRadius: BorderRadius.circular(NRadius.xl)),
              padding: const EdgeInsets.all(NSpace.md),
              child: const NIllustration(asset: NImages.onb07PrescoreBloom, height: NSpace.xl3 * 4, entrance: NEntrance.float),
            ),
          ),
          const SizedBox(height: NSpace.xl),
          Text(s.welcomeTitle, style: NType.h2.copyWith(color: NColors.inkPrimary)),
          const SizedBox(height: NSpace.sm),
          Text(s.welcomeBody, style: NType.bodyLg.copyWith(color: NColors.inkSecondary)),
          const SizedBox(height: NSpace.md),
          Container(
            padding: const EdgeInsets.all(NSpace.md),
            decoration: BoxDecoration(color: NColors.brandBlushLight, borderRadius: BorderRadius.circular(NRadius.lg)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.spa_outlined, color: NColors.actionLink),
                const SizedBox(width: NSpace.sm),
                Expanded(child: Text(s.welcomeWellness, style: NType.bodySm.copyWith(color: NColors.inkPrimary))),
              ],
            ),
          ),
        ],
      ),
      footer: NPrimaryButton(label: s.welcomeContinue, trailingArrow: true, onPressed: () => context.go(RouteConstants.signIn)),
    );
  }
}
