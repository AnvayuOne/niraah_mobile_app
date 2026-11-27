import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../design_system/generated/niraah_assets.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_illustration.dart';
import '../../../design_system/widgets/n_page.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/home.dart';
import 'home_labels.dart';

/// Placeholder for an area of the workspace built in a later phase.
class AreaComingSoonPage extends StatelessWidget {
  const AreaComingSoonPage({required this.area, super.key});

  final Area area;

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
          Semantics(header: true, child: Text(s.areaName(area), style: NType.h2.copyWith(color: NColors.inkPrimary))),
          const SizedBox(height: NSpace.xs),
          Text(s.navComingSoon(s.areaName(area)), textAlign: TextAlign.center, style: NType.body.copyWith(color: NColors.inkSecondary)),
        ],
      ),
    );
  }
}
