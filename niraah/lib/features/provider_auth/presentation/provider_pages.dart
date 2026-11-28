import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../design_system/widgets/n_page.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/constants/route_constants.dart';
import '../../provider_work/domain/provider_work.dart';
import '../domain/provider_auth.dart';
import 'application_form.dart';

Future<void> providerSignOut(BuildContext context) async {
  await getIt<ProviderAuthRepository>().signOut();
  if (context.mounted) context.go(RouteConstants.signIn);
}

/// Application status page for a provider who is not yet approved (spec 001
/// AC5), mirroring apps/web/src/app/provider/status/status-screen.tsx. It is
/// the only page she can reach.
class ProviderStatusPage extends StatelessWidget {
  const ProviderStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return FutureBuilder<ProviderSession?>(
      future: getIt<ProviderAuthRepository>().currentSession(),
      builder: (BuildContext context, AsyncSnapshot<ProviderSession?> snap) {
        if (snap.connectionState != ConnectionState.done) return Scaffold(body: LoadingView(label: s.loadCare, kind: NLoaderKind.care));
        final ProviderSession? session = snap.data;
        return NPage(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (session != null) Text(session.name, style: NType.label.copyWith(color: NColors.inkMuted)),
              const SizedBox(height: NSpace.xs),
              Semantics(header: true, child: Text(s.pvStatusTitle, style: NType.h2.copyWith(color: NColors.inkPrimary))),
              const SizedBox(height: NSpace.sm),
              Text(s.pvStatusBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
              const SizedBox(height: NSpace.lg),
              // Her application: details, documents and Submit (spec 006 "Completing the application").
              ApplicationForm(
                onChanged: (Json app) async {
                  if (app['status'] != 'approved') return;
                  final ProviderSession? fresh = await getIt<ProviderAuthRepository>().currentSession();
                  if (fresh != null && context.mounted) context.go(homeFor(fresh));
                },
              ),
            ],
          ),
          footer: NSecondaryButton(label: s.pvSignOut, onPressed: () => providerSignOut(context)),
        );
      },
    );
  }
}

/// A provider workspace that is not built yet (dietitian, instructor), with
/// sign out. Mirrors apps/web/src/components/RoleComingSoon.tsx.
class RoleComingSoonPage extends StatelessWidget {
  const RoleComingSoonPage({required this.role, super.key});

  final ProviderRole role;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String body = switch (role) {
      ProviderRole.dietitian => s.pvShellRoleSoon(s.pvRoleDietitian),
      ProviderRole.instructor => s.pvShellRoleSoon(s.pvRoleInstructor),
      ProviderRole.doctor => s.pvShellRoleSoon(s.pvShellNav.toLowerCase()),
      // The admin workspace is web only (spec 001 "Clients at launch").
      ProviderRole.admin => s.pvRoleAdminWebOnly,
    };
    return NPage(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: NSpace.xl),
          Semantics(header: true, child: Text(s.comingSoonTitle, style: NType.h2.copyWith(color: NColors.inkPrimary))),
          const SizedBox(height: NSpace.sm),
          Text(body, style: NType.body.copyWith(color: NColors.inkSecondary)),
        ],
      ),
      footer: NSecondaryButton(label: s.pvSignOut, onPressed: () => providerSignOut(context)),
    );
  }
}
