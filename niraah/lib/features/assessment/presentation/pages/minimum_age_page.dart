import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../design_system/generated/niraah_assets.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../design_system/widgets/n_button.dart';
import '../../../../design_system/widgets/n_illustration.dart';
import '../../../../design_system/widgets/n_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/constants/route_constants.dart';

/// Shown when the date of birth is below the minimum age and teen accounts
/// are off (spec 007 §1). The account can only contact support or delete.
class MinimumAgePage extends StatelessWidget {
  const MinimumAgePage({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return NPage(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Center(child: NIllustration(asset: NImages.i07CozyCrampsHerbalTeaWoman, height: NSpace.xl3 * 3, entrance: NEntrance.float)),
          const SizedBox(height: NSpace.lg),
          Semantics(header: true, child: Text(s.minimumAgeTitle, style: NType.h2.copyWith(color: NColors.inkPrimary))),
          const SizedBox(height: NSpace.sm),
          Text(s.minimumAgeBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
          const SizedBox(height: NSpace.md),
          Text(s.minimumAgeWrongDate, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
        ],
      ),
      footer: NPrimaryButton(label: s.minimumAgeContact, onPressed: () => context.push(RouteConstants.support)),
    );
  }
}
