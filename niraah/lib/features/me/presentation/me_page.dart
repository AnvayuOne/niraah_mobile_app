import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/area_navigation.dart';
import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/bottom_nav.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../../shared/constants/route_constants.dart';
import '../../home/domain/home.dart';
import '../../home/presentation/home_labels.dart';
import '../domain/me.dart';

/// The Me tab (spec 010 "Navigation" 1: everything else is reached from Home or Me): her plan, the other areas
/// of her workspace as the server lists them, and profile, privacy, notifications and sign-out. An area her plan
/// does not include is listed with a quiet lock and opens its "not on your plan" state; an area her account kind
/// can never use is not listed (rule 3).
class MePage extends StatefulWidget {
  const MePage({super.key, this.repository});

  final MeRepository? repository;

  @override
  State<MePage> createState() => _MePageState();
}

/// Areas reached from Me, in this order, with their screens. The five bottom-bar places are not repeated.
const List<(String, String)> meAreas = <(String, String)>[
  ('meals', RouteConstants.meals),
  ('symptoms', RouteConstants.symptoms),
  ('programs', RouteConstants.programs),
  ('care_plan', RouteConstants.carePlan),
  ('labs', RouteConstants.labs),
  ('community', RouteConstants.community),
  ('specialists', RouteConstants.bookDoctor),
];

class _MeData {
  const _MeData(this.workspace, this.plan);

  final Workspace workspace;
  final CurrentPlan? plan;
}

class _MePageState extends State<MePage> {
  late final MeRepository _repo = widget.repository ?? getIt<MeRepository>();
  late Future<_MeData> _data = _load();

  Future<_MeData> _load() async {
    final Workspace w = await _repo.workspace();
    CurrentPlan? plan;
    // A teen account has no plans or payment (spec 010 "Teen accounts" 2).
    if (!w.teen) {
      try {
        plan = await _repo.currentPlan();
      } on Object {
        plan = null;
      }
    }
    return _MeData(w, plan);
  }

  void _reload() => setState(() => _data = _load());

  Future<void> _open(AreaState a, String route) async {
    if (a.available) {
      await context.push(route);
    } else {
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => AreaScaffold(
          title: a.name,
          body: AreaLockedView(
            refusal: AreaLocked(message: a.locked ? S.of(context).areaNotOnPlan(a.name) : a.text ?? a.name, status: a.status, description: a.description, plans: a.plans, startsOn: a.startsOn),
          ),
        ),
      ));
    }
    if (mounted) _reload();
  }

  Future<void> _signOut() async {
    await _repo.signOut();
    if (mounted) context.go(RouteConstants.signIn);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Scaffold(
      backgroundColor: NColors.surfacePage,
      body: SafeArea(
        child: AsyncBody<_MeData>(
          future: _data,
          onRetry: _reload,
          builder: (BuildContext context, _MeData d) {
            final Workspace w = d.workspace;
            return RefreshIndicator(
              onRefresh: () async => _reload(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, NSpace.lg, NSpace.xl),
                children: <Widget>[
                  Semantics(header: true, child: Text(w.displayName ?? s.navMe, style: NType.h2.copyWith(color: NColors.inkPrimary))),
                  if (!w.teen) ...<Widget>[
                    NSectionTitle(s.meYourPlan),
                    _PlanCard(plan: d.plan),
                  ],
                  NSectionTitle(s.meAreas),
                  for (final (String key, String route) in meAreas)
                    if (w.area(key) case final AreaState a) ...<Widget>[
                      _Row(
                        icon: _icon(key),
                        text: a.name,
                        locked: !a.available,
                        lockedLabel: s.meLocked,
                        onTap: () => _open(a, route),
                      ),
                      const SizedBox(height: NSpace.xs),
                    ],
                  // Messages with her care team (spec 015); the screen says when her plan has no messaging.
                  if (!w.teen) ...<Widget>[
                    _Row(icon: Icons.forum_outlined, text: s.msgTitle, onTap: () => context.push(RouteConstants.messages)),
                    const SizedBox(height: NSpace.xs),
                  ],
                  NSectionTitle(s.meSettings),
                  _Row(icon: Icons.person_outline_rounded, text: s.profileTitle, onTap: () => context.push(RouteConstants.profile)),
                  const SizedBox(height: NSpace.xs),
                  _Row(icon: Icons.shield_outlined, text: s.privacyTitle, onTap: () => context.push(RouteConstants.privacy)),
                  const SizedBox(height: NSpace.xs),
                  _Row(icon: Icons.notifications_none_rounded, text: s.notifTitle, onTap: () => context.push(RouteConstants.notificationSettings)),
                  const SizedBox(height: NSpace.lg),
                  OutlinedButton.icon(onPressed: _signOut, icon: const Icon(Icons.logout_rounded), label: Text(s.pvSignOut)),
                  const SizedBox(height: NSpace.lg),
                  Text(s.meWellness, style: NType.caption.copyWith(color: NColors.inkMuted)),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: NBottomNav(
        labels: <String>[for (final Area a in Area.values) s.areaName(a)],
        index: 4,
        onSelected: (int i) {
          if (i != 4) goToArea(context, Area.values[i]);
        },
      ),
    );
  }

  static IconData _icon(String key) => switch (key) {
        'meals' => Icons.restaurant_rounded,
        'symptoms' => Icons.healing_outlined,
        'programs' => Icons.route_outlined,
        'care_plan' => Icons.assignment_outlined,
        'labs' => Icons.science_outlined,
        'community' => Icons.forum_outlined,
        'specialists' => Icons.medical_services_outlined,
        _ => Icons.circle_outlined,
      };
}

extension on AreaState {
  bool get locked => status == 'locked';
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});

  final CurrentPlan? plan;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final CurrentPlan? p = plan;
    return NCard(
      color: NColors.brandLavenderLight,
      onTap: () => context.push(RouteConstants.plans),
      semanticsLabel: p == null ? s.meNoPlan : p.name,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(p?.name ?? s.meNoPlan, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)),
                if (p != null) ...<Widget>[
                  if (p.priceDisplay != null) Text(p.priceDisplay!, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                  if (p.cancelled && p.endsAt != null)
                    Text(s.mePlanEnds(shortDate(context, p.endsAt!)), style: NType.bodySm.copyWith(color: NColors.inkSecondary))
                  else if (p.retired && p.endsAt != null)
                    Text(s.mePlanRetired(shortDate(context, p.endsAt!)), style: NType.bodySm.copyWith(color: NColors.inkSecondary))
                  else if (p.renewsAt != null)
                    Text(s.mePlanRenews(shortDate(context, p.renewsAt!)), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                ],
                const SizedBox(height: NSpace.xxs),
                Text(s.meSeePlans, style: NType.bodySm.copyWith(color: NColors.actionLink, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.text, required this.onTap, this.locked = false, this.lockedLabel});

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool locked;
  final String? lockedLabel;

  @override
  Widget build(BuildContext context) => NCard(
        onTap: onTap,
        semanticsLabel: locked && lockedLabel != null ? '$text, $lockedLabel' : text,
        child: Row(
          children: <Widget>[
            Icon(icon, color: NColors.inkSecondary),
            const SizedBox(width: NSpace.sm),
            Expanded(child: Text(text, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600))),
            if (locked) const Icon(Icons.lock_outline_rounded, size: 18, color: NColors.inkMuted),
            const SizedBox(width: NSpace.xxs),
            const Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
          ],
        ),
      );
}
