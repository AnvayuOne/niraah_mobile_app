import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../design_system/widgets/n_button.dart';
import '../../../../design_system/widgets/n_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/area/area_access.dart';
import '../../../../shared/area/area_widgets.dart';
import '../../../../shared/constants/route_constants.dart';
import '../../../me/domain/me.dart';
import '../../domain/auth_repository.dart';

/// Paused, suspended and pending-deletion members (spec 003 "Account states at sign-in"): a neutral
/// screen with no data. She has already proved she holds the number, so she is told plainly.
class AccountStatusPage extends StatelessWidget {
  const AccountStatusPage({required this.state, super.key});

  final String? state;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final (String title, String body) = switch (state) {
      'paused' => (s.stPausedTitle, s.stPausedBody),
      'deletion_pending' => (s.stDeletionTitle, s.stDeletionBody),
      _ => (s.stSuspendedTitle, s.stSuspendedBody),
    };
    return NPage(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: NSpace.xl),
          Semantics(header: true, child: Text(title, style: NType.h2.copyWith(color: NColors.inkPrimary))),
          const SizedBox(height: NSpace.sm),
          Text(body, style: NType.body.copyWith(color: NColors.inkSecondary)),
        ],
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // In the grace period she can cancel deletion or sign out, nothing else (spec 010 "Account states", AC46, AC47).
          if (state == 'deletion_pending') ...<Widget>[
            NPrimaryButton(
              label: s.stCancelDeletion,
              onPressed: () async {
                try {
                  await getIt<MeRepository>().cancelDeletion();
                  if (context.mounted) context.go(RouteConstants.home);
                } on Object catch (e) {
                  if (context.mounted) showNote(context, failureText(e, s.commonLoadError));
                }
              },
            ),
            const SizedBox(height: NSpace.sm),
          ],
          NSecondaryButton(
            label: s.pvSignOut,
            onPressed: () async {
              await getIt<SecondCheckRepository>().signOut();
              if (context.mounted) context.go(RouteConstants.signIn);
            },
          ),
        ],
      ),
    );
  }
}
