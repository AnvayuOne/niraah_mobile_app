import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/bottom_nav.dart';
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
    return Scaffold(
      backgroundColor: NColors.surfacePage,
      appBar: AppBar(
        backgroundColor: NColors.surfacePage,
        automaticallyImplyLeading: false,
        title: Text(title ?? s.pvShellNav, style: NType.h4.copyWith(color: NColors.inkPrimary)),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () => providerSignOut(context),
            icon: const Icon(Icons.logout_rounded, size: NSpace.md + NSpace.xxs),
            label: Text(s.pvSignOut),
          ),
        ],
      ),
      body: SafeArea(top: false, child: body),
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
