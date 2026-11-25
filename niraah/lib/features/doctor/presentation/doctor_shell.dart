import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../design_system/generated/niraah_assets.dart';
import '../../../design_system/theme/theme_controller.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/bottom_nav.dart';
import '../../../design_system/widgets/clinician_ui.dart';
import '../../../design_system/widgets/n_appearance.dart';
import '../../../l10n/app_localizations.dart';
import '../../provider_auth/presentation/provider_pages.dart';

/// The doctor workspace frame (spec 011 "Web and mobile"), mirroring
/// apps/web/src/components/DoctorShell.tsx: Home, Patients, Queue, Schedule, More.
class DoctorShell extends StatelessWidget {
  const DoctorShell({required this.index, required this.body, super.key, this.title});

  final int index;
  final Widget body;
  final String? title;

  static const List<String> paths = <String>['/doctor', '/doctor/patients', '/doctor/queue', '/doctor/schedule', '/doctor/more'];

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    CRole.fallback = CRole.doctor(child: SizedBox.shrink());
    return Scaffold(
      backgroundColor: NColors.surfacePage,
      appBar: AppBar(
        backgroundColor: NColors.surfacePage,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: NSpace.lg,
        title: Row(
          children: <Widget>[
            Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: NColors.brandPlum, shape: BoxShape.circle),
              child: Image.asset(NImages.niraahLogo.path, fit: BoxFit.contain, excludeFromSemantics: true),
            ),
            const SizedBox(width: NSpace.sm),
            Flexible(child: Text(title ?? s.pvShellNav, overflow: TextOverflow.ellipsis, style: NType.h4.copyWith(color: NColors.inkPrimary))),
          ],
        ),
        actions: <Widget>[
          if (NThemeController.darkModeEnabled) ...<Widget>[const Center(child: NThemeToggle()), const SizedBox(width: NSpace.xs)],
          IconButton(
            tooltip: s.pvSignOut,
            onPressed: () => providerSignOut(context),
            icon: Icon(Icons.logout_rounded, color: NColors.inkSecondary),
          ),
          const SizedBox(width: NSpace.xs),
        ],
      ),
      body: SafeArea(top: false, child: CRole.doctor(child: body)),
      bottomNavigationBar: NBottomNav(
        labels: <String>[s.pvShellHome, s.pvShellPatients, s.pvShellQueue, s.pvShellSchedule, s.pvShellMore],
        icons: NBottomNav.doctorIcons,
        index: index,
        onSelected: (int i) {
          if (i != index) context.go(paths[i]);
        },
      ),
    );
  }
}

/// Patients, Schedule and More arrive later in Phase 4.
class DoctorComingSoon extends StatelessWidget {
  const DoctorComingSoon({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String area = <String>[s.pvShellHome, s.pvShellPatients, s.pvShellQueue, s.pvShellSchedule, s.pvShellMore][index];
    return DoctorShell(
      index: index,
      title: area,
      body: Padding(
        padding: const EdgeInsets.all(NSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(area, style: NType.h2.copyWith(color: NColors.inkPrimary)),
            ),
            const SizedBox(height: NSpace.sm),
            Text(s.pvShellComingSoon(area), style: NType.body.copyWith(color: NColors.inkSecondary)),
          ],
        ),
      ),
    );
  }
}

String dueText(S s, double? h) => h == null
    ? ''
    : h <= 0
    ? s.pvQueueOverdue
    : (h < 1 ? s.pvQueueDueUnderHour : s.pvQueueDue(h.round()));
