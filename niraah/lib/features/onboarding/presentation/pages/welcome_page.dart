import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../design_system/generated/niraah_assets.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../design_system/widgets/n_button.dart';
import '../../../../design_system/widgets/n_illustration.dart';
import '../../../../design_system/widgets/n_living.dart';
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
      decor: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: nStagger(<Widget>[
          const SizedBox(height: NSpace.md),
          Center(
            child: SizedBox(
              height: NSpace.xl3 * 4 + NSpace.xl,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: <Widget>[
                  const NHalo(
                    size: NSpace.xl3 * 5,
                    child: NLottie(path: NLotties.celebrate, size: NSpace.xl3 * 4),
                  ),
                  Positioned(
                    left: 0,
                    top: NSpace.lg,
                    child: NGlassChip(icon: Icons.verified_outlined, label: s.welcomeChipDoctors),
                  ),
                  Positioned(
                    right: 0,
                    bottom: NSpace.lg,
                    child: NGlassChip(icon: Icons.lock_outline_rounded, label: s.welcomeChipPrivate),
                  ),
                ],
              ),
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
                const NSquircleIcon(icon: Icons.spa_outlined, size: 36, tint: NColors.surfaceCard),
                const SizedBox(width: NSpace.sm),
                Expanded(
                  child: Text(s.welcomeWellness, style: NType.bodySm.copyWith(color: NColors.inkPrimary)),
                ),
              ],
            ),
          ),
        ]),
      ),
      footer: NPrimaryButton(label: s.welcomeContinue, trailingArrow: true, onPressed: () => context.go(RouteConstants.signIn)),
    );
  }
}
