import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/di/service_locator.dart';
import '../../design_system/generated/niraah_assets.dart';
import '../../design_system/theme/theme_controller.dart';
import '../../design_system/tokens/tokens.dart';
import '../../design_system/widgets/bottom_nav.dart';
import '../../design_system/widgets/clinician_ui.dart';
import '../../design_system/widgets/n_appearance.dart';
import '../../design_system/widgets/n_button.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/area/area_access.dart';
import '../../shared/area/area_widgets.dart';
import '../../shared/constants/route_constants.dart';
import '../doctor/presentation/json_view.dart';
import '../doctor/presentation/patients_pages.dart';
import '../provider_auth/presentation/provider_pages.dart';
import '../provider_work/domain/provider_work.dart';
import 'dietitian_repository.dart';
import 'meal_plan_pages.dart';

/// The dietitian workspace frame (spec 012 "Web and mobile"): Home, Clients, Review, Schedule, More.
class DietitianShell extends StatelessWidget {
  const DietitianShell({required this.index, required this.body, super.key, this.title});

  final int index;
  final Widget body;
  final String? title;

  static const List<String> paths = <String>['/dietitian', '/dietitian/clients', '/dietitian/review', '/dietitian/schedule', '/dietitian/more'];
  static const List<IconData> icons = <IconData>[Icons.home_rounded, Icons.groups_outlined, Icons.restaurant_menu_rounded, Icons.calendar_month_outlined, Icons.more_horiz_rounded];

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    CRole.fallback = CRole.dietitian(child: SizedBox.shrink());
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
              decoration: BoxDecoration(color: NColors.roleDietitian, shape: BoxShape.circle),
              child: Image.asset(NImages.niraahLogo.path, fit: BoxFit.contain, excludeFromSemantics: true),
            ),
            const SizedBox(width: NSpace.sm),
            Flexible(child: Text(title ?? s.dtShellTitle, overflow: TextOverflow.ellipsis, style: NType.h4.copyWith(color: NColors.inkPrimary))),
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
      body: SafeArea(top: false, child: CRole.dietitian(child: body)),
      bottomNavigationBar: NBottomNav(
        labels: <String>[s.pvShellHome, s.dtClients, s.dtReview, s.pvShellSchedule, s.pvShellMore],
        icons: icons,
        index: index,
        onSelected: (int i) {
          if (i != index) context.go(paths[i]);
        },
      ),
    );
  }
}

/// The page padding every dietitian list uses.
const EdgeInsets dtPagePadding = EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl);

/// A rounded search field on white.
class DtSearchField extends StatelessWidget {
  const DtSearchField({required this.controller, required this.label, required this.onSubmitted, super.key});

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder border = OutlineInputBorder(borderRadius: BorderRadius.circular(NRadius.pill), borderSide: BorderSide(color: NColors.lineDefault));
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: NColors.surfaceCard,
        border: border,
        enabledBorder: border,
      ),
    );
  }
}

/// A filter chip in the role colour.
class DtChip extends StatelessWidget {
  const DtChip({required this.label, required this.selected, required this.onSelected, super.key});

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final CRole role = CRole.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: NSpace.xs),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        labelStyle: NType.bodySm.copyWith(color: selected ? NColors.inkPrimary : NColors.inkSecondary, fontWeight: FontWeight.w600),
        selectedColor: role.light,
        backgroundColor: NColors.surfaceCard,
        side: BorderSide(color: selected ? role.accent : NColors.lineDefault),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NRadius.pill)),
        onSelected: onSelected,
      ),
    );
  }
}

/// A soft warning card (suppression, conflicts).
class DtNotice extends StatelessWidget {
  const DtNotice({required this.text, super.key, this.icon = Icons.visibility_off_outlined});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(NSpace.sm),
    decoration: BoxDecoration(
      color: NColors.statusWarningLight,
      borderRadius: BorderRadius.circular(NRadius.lg),
      border: Border.all(color: NColors.statusWarningText.withValues(alpha: 0.25)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 20, color: NColors.statusWarningText),
        const SizedBox(width: NSpace.xs),
        Expanded(child: Text(text, style: NType.bodySm.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600))),
      ],
    ),
  );
}

/// A row of small text actions under a card.
class DtActions extends StatelessWidget {
  const DtActions({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: NSpace.xxs),
    child: Wrap(spacing: NSpace.xxs, children: children),
  );
}

/// A white rounded card, optionally tinted, tappable and labelled.
class DtCard extends StatelessWidget {
  const DtCard({required this.child, super.key, this.tint, this.border, this.onTap, this.semanticsLabel});

  final Widget child;
  final Color? tint;
  final Color? border;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final Widget card = Material(
      color: tint ?? NColors.surfaceCard,
      borderRadius: BorderRadius.circular(NRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NRadius.lg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(NSpace.sm + 2),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(NRadius.lg), border: Border.all(color: border ?? NColors.lineDefault)),
          child: child,
        ),
      ),
    );
    if (semanticsLabel == null) return card;
    return Semantics(button: onTap != null, label: semanticsLabel, excludeSemantics: true, child: card);
  }
}

/// A small tinted square with the role colour's icon.
class DtIconChip extends StatelessWidget {
  const DtIconChip({required this.icon, super.key, this.size = 40});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: CRole.of(context).light, borderRadius: BorderRadius.circular(NRadius.md)),
    child: Icon(icon, color: CRole.of(context).accent, size: size * 0.5),
  );
}

String _hhmm(BuildContext context, String iso) => DateFormat.jm(Localizations.localeOf(context).toString()).format(DateTime.parse(iso).toLocal());

/// Dashboard (spec 012 §1): what needs me, each count opening its list, then today's appointments.
class DietitianDashboardPage extends StatefulWidget {
  const DietitianDashboardPage({super.key, this.repository});

  final DietitianRepository? repository;

  @override
  State<DietitianDashboardPage> createState() => _DietitianDashboardPageState();
}

class _DietitianDashboardPageState extends State<DietitianDashboardPage> {
  late final DietitianRepository _repo = widget.repository ?? getIt<DietitianRepository>();
  late Future<Json> _dash = _repo.dashboard();

  Future<void> _open(String path) async {
    await context.push(path);
    if (mounted) setState(() => _dash = _repo.dashboard());
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return DietitianShell(
      index: 0,
      body: AsyncBody<Json>(
        future: _dash,
        onRetry: () => setState(() => _dash = _repo.dashboard()),
        builder: (BuildContext context, Json d) {
          final Json n = d.obj('needsMe');
          final int plans = n.integer('mealPlansToBuild') + n.integer('mealPlansEnding');
          final int waiting = n.integer('foodLogs') + plans + n.integer('checkIns') + n.integer('alerts') + n.integer('messages');
          final List<Json> today = d.objs('today');
          return RefreshIndicator(
            onRefresh: () async => setState(() => _dash = _repo.dashboard()),
            child: ListView(
              padding: dtPagePadding,
              children: <Widget>[
                CHero(
                  eyebrow: s.pvDashNeedsMe,
                  title: s.pvDashGreeting(d.obj('dietitian').str('name') ?? ''),
                  subtitle: s.dtDashWaiting(waiting),
                  child: CStatGrid(
                    children: <Widget>[
                      CHeroStat(
                        label: s.dtFoodLogs,
                        value: '${n.integer('foodLogs')}',
                        icon: Icons.restaurant_menu_rounded,
                        note: n.str('oldestFoodLogDueAt') == null ? null : s.drDue(shortDate(context, n.str('oldestFoodLogDueAt')!)),
                        onTap: () => _open('/dietitian/review'),
                      ),
                      CHeroStat(
                        label: s.dtPlansToBuild,
                        value: '$plans',
                        icon: Icons.edit_calendar_outlined,
                        note: n.integer('mealPlansEnding') > 0 ? s.dtEndingSoon(n.integer('mealPlansEnding')) : null,
                        onTap: () => _open('/dietitian/meal-plans'),
                      ),
                      CHeroStat(label: s.dtCheckIns, value: '${n.integer('checkIns')}', icon: Icons.fact_check_outlined, onTap: () => _open('/dietitian/check-ins')),
                      CHeroStat(label: s.drAlerts, value: '${n.integer('alerts')}', icon: Icons.notification_important_outlined, alert: n.integer('alerts') > 0, onTap: () => _open('/dietitian/alerts')),
                      CHeroStat(label: s.msgTitle, value: '${n.integer('messages')}', icon: Icons.chat_bubble_outline_rounded, onTap: () => _open('/dietitian/messages')),
                    ],
                  ),
                ),
                const SizedBox(height: NSpace.md),
                CPanel(
                  title: s.pvDashToday,
                  icon: Icons.event_available_outlined,
                  action: TextButton(onPressed: () => context.go('/dietitian/schedule'), child: Text(s.pvShellSchedule)),
                  child: today.isEmpty
                      ? CEmpty(icon: Icons.event_available_outlined, title: s.pvDashNoAppointments)
                      : Column(
                          children: <Widget>[
                            for (int i = 0; i < today.length; i++)
                              CEntrance(
                                delayMs: 60 * i,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: NSpace.xs),
                                  child: _TodayRow(a: today[i], time: _hhmm(context, today[i].str('startsAt')!), first: i == 0),
                                ),
                              ),
                          ],
                        ),
                ),
                CLabel(s.dtDashShortcuts),
                CHubTile(icon: Icons.restaurant_rounded, title: s.dtMealPlans, subtitle: s.dtEndingSoon(n.integer('mealPlansEnding')), onTap: () => _open('/dietitian/meal-plans')),
                const SizedBox(height: NSpace.xs),
                CHubTile(icon: Icons.menu_book_outlined, title: s.dtRecipes, subtitle: s.dtRecipesSubtitle, onTap: () => _open('/dietitian/recipes')),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TodayRow extends StatelessWidget {
  const _TodayRow({required this.a, required this.time, required this.first});

  final Json a;
  final String time;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final CRole role = CRole.of(context);
    return Semantics(
      label: <String>[time, a.str('member') ?? '', ?a.str('reason'), if (a.flag('joinable')) s.pvDashJoinOnWeb].join(' · '),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(NSpace.sm),
        decoration: BoxDecoration(
          color: first ? role.light.withValues(alpha: 0.6) : NColors.surfacePage,
          borderRadius: BorderRadius.circular(NRadius.lg),
          border: Border.all(color: first ? role.accent.withValues(alpha: 0.35) : Colors.transparent),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 66,
              child: Text(time, style: NType.caption.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700, letterSpacing: 0, fontSize: 13)),
            ),
            CAvatar(name: a.str('member'), size: 36),
            const SizedBox(width: NSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(a.str('member') ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                  if (a.str('reason') != null) Text(a.str('reason')!, maxLines: 1, overflow: TextOverflow.ellipsis, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
                ],
              ),
            ),
            Tooltip(
              message: a.flag('joinable') ? s.pvDashJoinOnWeb : s.pvDashJoinSoon,
              child: a.flag('joinable') ? CPill(s.pvDashJoin, tone: CTone.sage) : Icon(Icons.videocam_off_outlined, size: 20, color: NColors.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// A meal plan state as a pill tone.
CTone planTone(String? st) => switch (st) {
  'active' => CTone.sage,
  'draft' => CTone.apricot,
  'scheduled' => CTone.lavender,
  _ => CTone.quiet,
};

/// Clients (spec 012 §2): her active clients, or past ones; meal plan state, last check-in and markers. No weights,
/// scores or lab values.
class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key, this.repository});

  final DietitianRepository? repository;

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  late final DietitianRepository _repo = widget.repository ?? getIt<DietitianRepository>();
  final TextEditingController _search = TextEditingController();
  String? _mealPlan;
  bool _openAlert = false;
  bool _past = false;
  late Future<List<Json>> _list = _load();

  /// The last list shown, kept on screen while a new filter loads so the header never flashes.
  List<Json>? _last;

  Future<List<Json>> _load() => _repo.clients(search: _search.text, mealPlan: _mealPlan, openAlert: _openAlert ? true : null, past: _past);

  void _set(VoidCallback f) => setState(() {
    f();
    _list = _load();
  });

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _plan(S s, Json p) => switch (p.str('state')) {
    'active' => p.str('until') == null ? s.dtPlanActive : s.dtPlanUntil(shortDate(context, p.str('until')!)),
    'draft' => s.dtPlanDraft,
    _ => s.dtPlanNone,
  };

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return DietitianShell(
      index: 1,
      title: s.dtClients,
      body: FutureBuilder<List<Json>>(
        future: _list,
        builder: (BuildContext context, AsyncSnapshot<List<Json>> snap) {
          final bool loading = snap.connectionState != ConnectionState.done;
          if (snap.hasError || (loading && _last == null)) {
            return AsyncBody<List<Json>>(future: _list, onRetry: () => _set(() {}), builder: (_, _) => const SizedBox.shrink());
          }
          if (!loading) _last = snap.data;
          final List<Json> rows = (loading ? _last : snap.data) ?? const <Json>[];
          int count(String st) => rows.where((Json c) => (c.obj('mealPlan').str('state') ?? 'none') == st).length;
          return ListView(
            padding: dtPagePadding,
            children: <Widget>[
              CHero(
                eyebrow: _past ? s.dtPastClients : s.dtClientsEyebrow,
                title: s.dtClientsCount(rows.length),
                subtitle: s.drAPatientsAlerts(rows.where((Json c) => c.flag('openAlert')).length),
                child: CStatGrid(
                  children: <Widget>[
                    CHeroStat(label: s.dtPlanActive, value: '${count('active')}', icon: Icons.check_circle_outline_rounded),
                    CHeroStat(label: s.dtPlanDraft, value: '${count('draft')}', icon: Icons.edit_note_rounded),
                    CHeroStat(label: s.dtPlanNone, value: '${count('none')}', icon: Icons.hourglass_empty_rounded),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.md),
              CEntrance(delayMs: 60, child: DtSearchField(controller: _search, label: s.drSearchName, onSubmitted: (_) => _set(() {}))),
              const SizedBox(height: NSpace.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    DtChip(label: s.dtPastClients, selected: _past, onSelected: (bool v) => _set(() => _past = v)),
                    for (final (String k, String l) in <(String, String)>[('none', s.dtPlanNone), ('draft', s.dtPlanDraft), ('active', s.dtPlanActive)])
                      DtChip(label: l, selected: _mealPlan == k, onSelected: (bool v) => _set(() => _mealPlan = v ? k : null)),
                    DtChip(label: s.drOpenAlert, selected: _openAlert, onSelected: (bool v) => _set(() => _openAlert = v)),
                  ],
                ),
              ),
              SizedBox(
                height: NSpace.sm,
                child: loading ? LinearProgressIndicator(minHeight: 2, color: CRole.of(context).accent, backgroundColor: Colors.transparent) : null,
              ),
              if (rows.isEmpty)
                CEmpty(icon: Icons.groups_outlined, title: s.dtNoClients)
              else
                for (int i = 0; i < rows.length; i++)
                  CEntrance(
                    delayMs: 40 * i.clamp(0, 8),
                    child: Padding(padding: const EdgeInsets.only(bottom: NSpace.xs), child: _clientRow(s, rows[i])),
                  ),
            ],
          );
        },
      ),
    );
  }

  Widget _clientRow(S s, Json c) {
    final String meta = <String>[
      ?c.str('ageBand'),
      relationshipName(s, c.str('relationship')),
      ?c.str('plan'),
      _plan(s, c.obj('mealPlan')),
      if (c.str('lastCheckIn') != null) s.dtLastCheckIn(shortDate(context, c.str('lastCheckIn')!)),
    ].join(' · ');
    final String sub = <String>[?c.str('ageBand'), ?c.str('plan')].join(' · ');
    final String name = c.str('name') ?? s.drUnnamed;
    return DtCard(
      onTap: () => context.push('/dietitian/clients/${c.str('id')}'),
      semanticsLabel: '${c.str('name') ?? ''}, $meta',
      tint: c.flag('openAlert') ? NColors.statusClinicalRedFlagLight.withValues(alpha: 0.35) : null,
      border: c.flag('openAlert') ? NColors.statusClinicalRedFlag.withValues(alpha: 0.35) : null,
      child: Row(
        children: <Widget>[
          CAvatar(name: name, size: 44),
          const SizedBox(width: NSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)),
                if (sub.isNotEmpty) Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
                if (c.str('lastCheckIn') != null)
                  Text(
                    s.dtLastCheckIn(shortDate(context, c.str('lastCheckIn')!)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0),
                  ),
                const SizedBox(height: NSpace.xxs),
                Wrap(
                  spacing: NSpace.xxs,
                  runSpacing: NSpace.xxs,
                  children: <Widget>[
                    if (c.str('relationship') != null) CPill(relationshipName(s, c.str('relationship')), tone: c.str('relationship') == 'dedicated' ? CTone.plum : CTone.lavender),
                    CPill(_plan(s, c.obj('mealPlan')), tone: planTone(c.obj('mealPlan').str('state'))),
                    if (c.flag('openAlert')) CPill(s.drOpenAlert, tone: CTone.red),
                    if (c.flag('unreviewedLogs')) CPill(s.dtUnreviewedLogs, tone: CTone.rose),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
        ],
      ),
    );
  }
}

/// One client (spec 012 §3): the header with consent tag, flags and the suppression banner, then the sections.
/// A section without consent says "She has not shared this" and shows nothing (AC4).
class ClientPage extends StatefulWidget {
  const ClientPage({required this.memberId, super.key, this.repository});

  final String memberId;
  final DietitianRepository? repository;

  @override
  State<ClientPage> createState() => _ClientPageState();
}

String _sectionName(S s, String k) => switch (k) {
  'meals' => s.drSecMeals,
  'meal_plan' => s.dtSecMealPlan,
  'progress' => s.dtSecProgress,
  'assessment' => s.drSecAssessment,
  'cycle_symptoms' => s.drSecCycle,
  'care_plan' => s.drSecCarePlan,
  'labs' => s.drSecLabs,
  'shared_ai' => s.drSecShared,
  'notes' => s.drSecNotes,
  _ => humanise(k),
};

IconData _sectionIcon(String k) => switch (k) {
  'meals' => Icons.restaurant_outlined,
  'meal_plan' => Icons.edit_calendar_outlined,
  'assessment' => Icons.insights_rounded,
  'cycle_symptoms' => Icons.water_drop_outlined,
  'care_plan' => Icons.draw_outlined,
  'labs' => Icons.science_outlined,
  'shared_ai' => Icons.forum_outlined,
  'notes' => Icons.sticky_note_2_outlined,
  _ => Icons.article_outlined,
};

class _ClientPageState extends State<ClientPage> {
  late final DietitianRepository _repo = widget.repository ?? getIt<DietitianRepository>();
  late Future<Json> _header = _repo.client(widget.memberId);

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return FutureBuilder<Json>(
      future: _header,
      builder: (BuildContext context, AsyncSnapshot<Json> snap) {
        final Json? h = snap.data;
        if (h == null) {
          return AreaScaffold(
            title: s.dtClients,
            body: AsyncBody<Json>(future: _header, onRetry: () => setState(() => _header = _repo.client(widget.memberId)), builder: (_, _) => const SizedBox.shrink()),
          );
        }
        final List<String> sections = h.strs('sections');
        return DefaultTabController(
          length: sections.length + 1,
          child: Scaffold(
            backgroundColor: NColors.surfacePage,
            appBar: AppBar(
              backgroundColor: NColors.surfacePage,
              surfaceTintColor: Colors.transparent,
              title: Text(s.dtClients, style: NType.h4.copyWith(color: NColors.inkPrimary)),
            ),
            body: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool inner) => <Widget>[
                SliverToBoxAdapter(
                  child: Padding(padding: const EdgeInsets.fromLTRB(NSpace.md, 0, NSpace.md, NSpace.xs), child: _ClientHeader(header: h)),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabsDelegate(
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelColor: NColors.inkPrimary,
                      unselectedLabelColor: NColors.inkMuted,
                      labelStyle: NType.bodySm.copyWith(fontWeight: FontWeight.w700),
                      unselectedLabelStyle: NType.bodySm.copyWith(fontWeight: FontWeight.w600),
                      indicatorColor: CRole.of(context).accent,
                      indicatorWeight: 3,
                      dividerColor: NColors.lineDefault,
                      padding: const EdgeInsets.symmetric(horizontal: NSpace.xs),
                      tabs: <Widget>[
                        Tab(text: s.drSecSummary),
                        for (String k in sections) Tab(text: _sectionName(s, k)),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                children: <Widget>[
                  _ClientSummary(header: h, repo: _repo),
                  for (String k in sections)
                    k == 'progress' ? ProgressView(memberId: widget.memberId, repository: _repo) : _ClientSection(memberId: widget.memberId, section: k, repo: _repo, past: h.flag('past')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TabsDelegate extends SliverPersistentHeaderDelegate {
  _TabsDelegate(this.tabs);

  final TabBar tabs;

  @override
  double get minExtent => tabs.preferredSize.height;

  @override
  double get maxExtent => tabs.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => ColoredBox(color: NColors.surfacePage, child: tabs);

  @override
  bool shouldRebuild(_TabsDelegate old) => old.tabs != tabs;
}

/// The warm header: avatar, name, plan and relationship, her doctor, flags as red pills and consent per category.
class _ClientHeader extends StatelessWidget {
  const _ClientHeader({required this.header});

  final Json header;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Json h = header;
    final String name = h.str('name') ?? s.drUnnamed;
    final List<Json> consent = h.objs('consent');
    return CHero(
      eyebrow: h.flag('past') ? s.dtPastClients : s.dtClients,
      title: name,
      subtitle: <String>[?h.str('ageBand'), ?h.str('plan'), if (h.str('relationship') != null) relationshipName(s, h.str('relationship'))].join(' · '),
      trailing: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: NColors.brandApricot.withValues(alpha: 0.7), width: 2)),
        child: CAvatar(name: name, size: 52),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (h.str('dedicatedDoctor') != null || h.objs('flags').isNotEmpty)
            Wrap(
              spacing: NSpace.xxs,
              runSpacing: NSpace.xxs,
              children: <Widget>[
                if (h.str('dedicatedDoctor') != null) _SoftPill(text: s.dtDoctor(h.str('dedicatedDoctor')!), icon: Icons.medical_services_outlined),
                for (Json f in h.objs('flags'))
                  Semantics(label: '${s.drFlags}: ${f.str('name')}', excludeSemantics: true, child: CPill(f.str('name') ?? '', tone: CTone.red)),
              ],
            ),
          if (consent.isNotEmpty) ...<Widget>[
            const SizedBox(height: NSpace.sm),
            Text(s.drConsent.toUpperCase(), style: NType.label.copyWith(color: NColors.inkSecondary, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
            const SizedBox(height: NSpace.xxs),
            Wrap(
              spacing: NSpace.xxs,
              runSpacing: NSpace.xxs,
              children: <Widget>[
                for (Json c in consent)
                  Semantics(
                    label: '${humanise(c.str('category') ?? '')}: ${c.flag('shared') ? s.drConsentView : s.drConsentNone}',
                    excludeSemantics: true,
                    child: _SoftPill(text: humanise(c.str('category') ?? ''), icon: c.flag('shared') ? Icons.visibility_outlined : Icons.visibility_off_outlined, dim: !c.flag('shared')),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A glassy white pill for the hero; [dim] for a category she has not shared.
class _SoftPill extends StatelessWidget {
  const _SoftPill({required this.text, this.icon, this.dim = false});

  final String text;
  final IconData? icon;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final Color fg = dim ? NColors.inkMuted : NColors.inkSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: NSpace.xs + 2, vertical: 4),
      decoration: BoxDecoration(
        color: NColors.surfaceCard.withValues(alpha: dim ? 0.5 : 0.9),
        borderRadius: BorderRadius.circular(NRadius.pill),
        border: Border.all(color: NColors.lineDefault),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[Icon(icon, size: 13, color: fg), const SizedBox(width: 4)],
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: NType.caption.copyWith(color: fg, fontWeight: FontWeight.w700, letterSpacing: 0, decoration: dim ? TextDecoration.lineThrough : null, decorationColor: fg),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientSummary extends StatefulWidget {
  const _ClientSummary({required this.header, required this.repo});

  final Json header;
  final DietitianRepository repo;

  @override
  State<_ClientSummary> createState() => _ClientSummaryState();
}

class _ClientSummaryState extends State<_ClientSummary> {
  Future<Json>? _brief;

  Future<void> _newPlan() async {
    final S s = S.of(context);
    try {
      final Json p = await widget.repo.createPlan(widget.header.str('id')!);
      if (mounted) await context.push('/dietitian/meal-plans/${p.str('id')}');
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Json h = widget.header;
    final CRole role = CRole.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.md, NSpace.md, NSpace.xl),
      children: <Widget>[
        if (h.str('suppressionBanner') != null) ...<Widget>[DtNotice(text: h.str('suppressionBanner')!), const SizedBox(height: NSpace.sm)],
        CPanel(
          title: s.dtCareTeam,
          icon: Icons.diversity_1_outlined,
          child: Column(
            children: <Widget>[
              _Fact(icon: Icons.handshake_outlined, label: s.dtRelationship, value: h.str('relationship') == null ? '—' : relationshipName(s, h.str('relationship'))),
              _Fact(icon: Icons.workspace_premium_outlined, label: s.dtPlanLabel, value: h.str('plan') ?? '—'),
              if (h.str('dedicatedDoctor') != null) _Fact(icon: Icons.medical_services_outlined, label: s.dtDoctorLabel, value: h.str('dedicatedDoctor')!),
            ],
          ),
        ),
        if (!h.flag('past')) ...<Widget>[
          const SizedBox(height: NSpace.md),
          NPrimaryButton(label: s.dtNewPlan, onPressed: _newPlan),
          const SizedBox(height: NSpace.md),
          CPanel(
            title: s.drBrief,
            icon: Icons.auto_awesome_outlined,
            child: _brief == null
                ? NSecondaryButton(label: s.drBriefOpen, onPressed: () => setState(() => _brief = widget.repo.brief(h.str('id')!)))
                : FutureBuilder<Json>(
                    future: _brief,
                    builder: (BuildContext context, AsyncSnapshot<Json> snap) {
                      if (snap.hasError) return Text(failureText(snap.error!, s.commonLoadError), style: NType.bodySm.copyWith(color: NColors.inkSecondary));
                      if (!snap.hasData) return Text(s.loading, style: NType.bodySm.copyWith(color: NColors.inkMuted));
                      final Json b = snap.data!;
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(NSpace.sm),
                        decoration: BoxDecoration(color: role.light.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(NRadius.lg)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (b.str('label') != null) CPill(b.str('label')!, tone: CTone.apricot),
                            for (Json p in b.objs('points'))
                              Padding(
                                padding: const EdgeInsets.only(top: NSpace.xs),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 7),
                                      child: Container(width: 6, height: 6, decoration: BoxDecoration(color: role.accent, shape: BoxShape.circle)),
                                    ),
                                    const SizedBox(width: NSpace.xs),
                                    Expanded(child: Text(p.str('text') ?? '', style: NType.bodySm.copyWith(color: NColors.inkPrimary))),
                                  ],
                                ),
                              ),
                            if (b.obj('facts').isNotEmpty) ...<Widget>[const SizedBox(height: NSpace.xs), JsonView(data: b.obj('facts'))],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: NSpace.xxs + 2),
    child: Row(
      children: <Widget>[
        Icon(icon, size: 18, color: NColors.inkMuted),
        const SizedBox(width: NSpace.sm),
        Expanded(child: Text(label, style: NType.bodySm.copyWith(color: NColors.inkSecondary))),
        Flexible(child: Text(value, textAlign: TextAlign.end, style: NType.bodySm.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700))),
      ],
    ),
  );
}

class _ClientSection extends StatefulWidget {
  const _ClientSection({required this.memberId, required this.section, required this.repo, required this.past});

  final String memberId;
  final String section;
  final DietitianRepository repo;
  final bool past;

  @override
  State<_ClientSection> createState() => _ClientSectionState();
}

class _ClientSectionState extends State<_ClientSection> with AutomaticKeepAliveClientMixin<_ClientSection> {
  late Future<Json> _data = widget.repo.section(widget.memberId, widget.section);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final S s = S.of(context);
    return AsyncBody<Json>(
      future: _data,
      onRetry: () => setState(() => _data = widget.repo.section(widget.memberId, widget.section)),
      builder: (BuildContext context, Json d) {
        if (!d.flag('shared')) {
          return ListView(
            padding: const EdgeInsets.all(NSpace.md),
            children: <Widget>[CEmpty(icon: Icons.visibility_off_outlined, title: s.drNotSharedSection)],
          );
        }
        final List<Json> days = widget.section == 'meals' ? d.objs('days') : const <Json>[];
        return ListView(
          padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.md, NSpace.md, NSpace.xl),
          children: <Widget>[
            if (widget.section == 'notes' && !widget.past) ...<Widget>[
              NSecondaryButton(
                label: s.drAddNote,
                onPressed: () async {
                  final String? t = await promptText(context, s.drAddNote, s.drNoteHint, maxLength: 4000);
                  if (t == null) return;
                  final Json r = await widget.repo.addNote(widget.memberId, t);
                  if (mounted) setState(() => _data = Future<Json>.value(r));
                },
              ),
              const SizedBox(height: NSpace.sm),
            ],
            if (days.isNotEmpty) ...<Widget>[_MealsLogged(days: days), const SizedBox(height: NSpace.md)],
            if (widget.section == 'meal_plan')
              for (Json p in d.objs('plans'))
                if (p.flag('mine'))
                  Padding(
                    padding: const EdgeInsets.only(bottom: NSpace.xs),
                    child: CRow(
                      title: p.str('title') ?? s.dtMealPlan,
                      subtitle: shortDate(context, p.str('startDate') ?? ''),
                      leading: const DtIconChip(icon: Icons.restaurant_rounded),
                      trailing: CPill(planStatusLabel(s, p.str('status')), tone: planTone(p.str('status'))),
                      onTap: () => context.push('/dietitian/meal-plans/${p.str('id')}'),
                    ),
                  ),
            CPanel(
              title: _sectionName(s, widget.section),
              icon: _sectionIcon(widget.section),
              child: JsonView(data: d, skip: const <String>{'section', 'shared'}),
            ),
          ],
        );
      },
    );
  }
}

/// Meals logged per day as bars, with each day's energy split when the server gives totals.
class _MealsLogged extends StatelessWidget {
  const _MealsLogged({required this.days});

  final List<Json> days;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    int logged(Json d) => d.number('meals')?.toInt() ?? d.objs('logs').length;
    final int most = days.map(logged).fold<int>(4, math.max);
    return CPanel(
      title: s.dtMealsLogged,
      icon: Icons.bar_chart_rounded,
      child: Column(
        children: <Widget>[
          for (Json d in days.take(7))
            Padding(
              padding: const EdgeInsets.only(bottom: NSpace.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(shortDate(context, d.str('day') ?? d.str('date') ?? ''), style: NType.bodySm.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                      ),
                      Text(s.dtLogs(logged(d)), style: NType.caption.copyWith(color: NColors.inkSecondary, letterSpacing: 0)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  CBar(value: logged(d) / most, color: CRole.of(context).accent),
                  if (d.obj('totals').isNotEmpty) ...<Widget>[const SizedBox(height: 6), MacroSplit(nutrients: d.obj('totals'), compact: true)],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Progress (spec 012 §7): check-ins as a trend with plan periods, reply and mark read, missed weeks with one nudge
/// each, and assigning a check-in questionnaire. No weight or waist for a flagged member.
class ProgressView extends StatefulWidget {
  const ProgressView({required this.memberId, required this.repository, super.key});

  final String memberId;
  final DietitianRepository repository;

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  late Future<Json> _data = widget.repository.progress(widget.memberId);

  Future<void> _act(Future<void> Function() f, String done) async {
    try {
      await f();
      if (!mounted) return;
      showNote(context, done);
      setState(() => _data = widget.repository.progress(widget.memberId));
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    }
  }

  Future<void> _assign() async {
    final S s = S.of(context);
    final List<Json> qs = await widget.repository.checkInQuestionnaires();
    if (!mounted) return;
    final Json? q = await showDialog<Json>(
      context: context,
      builder: (BuildContext d) => SimpleDialog(
        title: Text(s.dtAssign),
        children: <Widget>[
          if (qs.isEmpty) Padding(padding: const EdgeInsets.all(NSpace.lg), child: Text(s.dtNoQuestionnaires)),
          for (Json x in qs) SimpleDialogOption(onPressed: () => Navigator.of(d).pop(x), child: Text(x.str('name') ?? '')),
        ],
      ),
    );
    if (q == null || !mounted) return;
    final String? schedule = await showDialog<String>(
      context: context,
      builder: (BuildContext d) => SimpleDialog(
        title: Text(s.dtSchedule),
        children: <Widget>[
          for (final (String k, String l) in <(String, String)>[('weekly', s.drWeekly), ('fortnightly', s.dtFortnightly), ('monthly', s.dtMonthly)])
            SimpleDialogOption(onPressed: () => Navigator.of(d).pop(k), child: Text(l)),
        ],
      ),
    );
    if (schedule == null || !mounted) return;
    final DateTime now = DateTime.now();
    final DateTime? end = await showDatePicker(context: context, helpText: s.dtEndsOn, initialDate: now.add(const Duration(days: 56)), firstDate: now, lastDate: now.add(const Duration(days: 365)));
    String two(int v) => v.toString().padLeft(2, '0');
    await _act(() => widget.repository.assign(widget.memberId, q.str('id')!, schedule, end == null ? null : '${end.year}-${two(end.month)}-${two(end.day)}'), s.dtAssigned);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AsyncBody<Json>(
      future: _data,
      onRetry: () => setState(() => _data = widget.repository.progress(widget.memberId)),
      builder: (BuildContext context, Json d) {
        final List<Json> checkIns = d.objs('checkIns');
        return ListView(
          padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.md, NSpace.md, NSpace.xl),
          children: <Widget>[
            CPanel(
              title: s.checkInsTrend,
              icon: Icons.show_chart_rounded,
              note: d.objs('planPeriods').isEmpty
                  ? null
                  : s.dtPlanPeriods(d.objs('planPeriods').map((Json p) => '${shortDate(context, p.str('from') ?? '')}–${p.str('to') == null ? '' : shortDate(context, p.str('to')!)}').join(', ')),
              child: checkIns.isEmpty ? CEmpty(icon: Icons.fact_check_outlined, title: s.dtNoCheckIns) : _Trend(checkIns: checkIns),
            ),
            const SizedBox(height: NSpace.sm),
            for (int i = 0; i < checkIns.length; i++)
              CEntrance(
                delayMs: 40 * i.clamp(0, 6),
                child: Padding(padding: const EdgeInsets.only(bottom: NSpace.xs), child: _checkIn(s, checkIns[i])),
              ),
            if (d.objs('missed').isNotEmpty) ...<Widget>[
              CLabel(s.dtMissed),
              for (Json w in d.objs('missed'))
                Padding(
                  padding: const EdgeInsets.only(bottom: NSpace.xs),
                  child: DtCard(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.event_busy_outlined, color: NColors.inkMuted, size: 20),
                        const SizedBox(width: NSpace.sm),
                        Expanded(
                          child: Text(s.checkInsThisWeek(shortDate(context, w.str('week') ?? '')), style: NType.bodySm.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                        ),
                        if (w.flag('nudged'))
                          CPill(s.dtNudged, tone: CTone.sage)
                        else
                          TextButton(onPressed: () => _act(() => widget.repository.nudge(widget.memberId, w.str('week')!), s.dtNudgeSent), child: Text(s.dtNudge)),
                      ],
                    ),
                  ),
                ),
            ],
            const SizedBox(height: NSpace.md),
            NSecondaryButton(label: s.dtAssign, onPressed: _assign),
          ],
        );
      },
    );
  }

  Widget _checkIn(S s, Json c) {
    final List<String> metrics = <String>[
      if (c.number('energy') != null) s.checkInsEnergyValue(c.integer('energy')),
      if (c.number('cravings') != null) s.checkInsCravingsValue(c.integer('cravings')),
      if (c.number('weightKg') != null) s.checkInsWeightValue(c.number('weightKg')!.toStringAsFixed(1)),
      if (c.number('waistCm') != null) s.checkInsWaistValue(c.number('waistCm')!.toStringAsFixed(0)),
    ];
    final bool read = c.flag('read');
    final CRole role = CRole.of(context);
    return DtCard(
      tint: read ? null : role.light.withValues(alpha: 0.45),
      border: read ? null : role.accent.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(s.checkInsThisWeek(shortDate(context, c.str('week') ?? '')), style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)),
              ),
              if (!read) CPill(s.dtUnread, tone: CTone.apricot),
            ],
          ),
          if (metrics.isNotEmpty) ...<Widget>[
            const SizedBox(height: NSpace.xs),
            Semantics(
              label: metrics.join(' · '),
              excludeSemantics: true,
              child: Wrap(spacing: NSpace.xxs, runSpacing: NSpace.xxs, children: <Widget>[for (String m in metrics) CPill(m)]),
            ),
          ],
          if (c.str('note') != null) ...<Widget>[
            const SizedBox(height: NSpace.xs),
            Text(c.str('note')!, style: NType.bodySm.copyWith(color: NColors.inkPrimary)),
          ],
          if (c.str('reply') != null) ...<Widget>[
            const SizedBox(height: NSpace.xs),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(NSpace.xs + 2),
              decoration: BoxDecoration(color: NColors.surfacePage, borderRadius: BorderRadius.circular(NRadius.md)),
              child: Text(s.dtYourReply(c.str('reply')!), style: NType.caption.copyWith(color: NColors.inkSecondary, letterSpacing: 0)),
            ),
          ],
          DtActions(
            children: <Widget>[
              if (!read) TextButton(onPressed: () => _act(() => widget.repository.respond(c.str('id')!, null), s.dtMarkedRead), child: Text(s.dtMarkRead)),
              TextButton(
                onPressed: () async {
                  final String? t = await promptText(context, s.dtReply, s.dtReplyHint, maxLength: 500);
                  if (t != null) await _act(() => widget.repository.respond(c.str('id')!, t), s.dtReplied);
                },
                child: Text(s.dtReply),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Energy and cravings (1–5) for each week, oldest on the left.
class _Trend extends StatelessWidget {
  const _Trend({required this.checkIns});

  final List<Json> checkIns;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Color accent = CRole.of(context).accent;
    final String locale = Localizations.localeOf(context).toString();
    final List<Json> weeks = checkIns.take(8).toList().reversed.toList();
    Widget bar(num? v, Color c) => Container(
      width: 9,
      height: 6 + 60 * ((v ?? 0) / 5).clamp(0, 1).toDouble(),
      decoration: BoxDecoration(color: v == null ? NColors.surfaceBackdrop : c, borderRadius: BorderRadius.circular(NRadius.pill)),
    );
    Widget key(Color c, String l) => Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(l, style: NType.caption.copyWith(color: NColors.inkSecondary, letterSpacing: 0)),
      ],
    );
    return ExcludeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(spacing: NSpace.sm, children: <Widget>[key(accent, s.dtTrendEnergy), key(NColors.brandBlush, s.dtTrendCravings)]),
          const SizedBox(height: NSpace.sm),
          SizedBox(
            height: 92,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                for (Json w in weeks)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[bar(w.number('energy'), accent), const SizedBox(width: 3), bar(w.number('cravings'), NColors.brandBlush)],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateTime.tryParse(w.str('week') ?? '') == null ? '' : DateFormat.MMMd(locale).format(DateTime.parse(w.str('week')!)),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Check-ins received and not yet read (spec 012 §1).
class UnreadCheckInsPage extends StatefulWidget {
  const UnreadCheckInsPage({super.key, this.repository});

  final DietitianRepository? repository;

  @override
  State<UnreadCheckInsPage> createState() => _UnreadCheckInsPageState();
}

class _UnreadCheckInsPageState extends State<UnreadCheckInsPage> {
  late final DietitianRepository _repo = widget.repository ?? getIt<DietitianRepository>();
  late Future<List<Json>> _list = _repo.unreadCheckIns();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.dtCheckIns,
      body: AsyncBody<List<Json>>(
        future: _list,
        onRetry: () => setState(() => _list = _repo.unreadCheckIns()),
        builder: (BuildContext context, List<Json> rows) => ListView(
          padding: dtPagePadding,
          children: <Widget>[
            CHero(eyebrow: s.dtCheckIns, title: s.dtUnreadCount(rows.length), subtitle: s.dtCheckInsSubtitle),
            const SizedBox(height: NSpace.md),
            if (rows.isEmpty) CEmpty(icon: Icons.mark_email_read_outlined, title: s.dtNoUnreadCheckIns),
            for (int i = 0; i < rows.length; i++)
              CEntrance(
                delayMs: 40 * i.clamp(0, 8),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: NSpace.xs),
                  child: CRow(
                    title: rows[i].str('member') ?? s.drUnnamed,
                    subtitle: s.checkInsThisWeek(shortDate(context, rows[i].str('week') ?? '')),
                    leading: CAvatar(name: rows[i].str('member'), size: 40),
                    trailing: CPill(s.dtUnread, tone: CTone.apricot),
                    onTap: () async {
                      await context.push('/dietitian/clients/${rows[i].str('memberId')}');
                      if (mounted) setState(() => _list = _repo.unreadCheckIns());
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// More: every other area (spec 012 "Web and mobile").
class DietitianMorePage extends StatelessWidget {
  const DietitianMorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    Widget tile(IconData icon, String label, String path) => Padding(
      padding: const EdgeInsets.only(bottom: NSpace.xs),
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: CHubTile(icon: icon, title: label, onTap: () => context.push(path)),
      ),
    );
    return DietitianShell(
      index: 4,
      title: s.pvShellMore,
      body: ListView(
        padding: dtPagePadding,
        children: <Widget>[
          CHero(eyebrow: s.pvShellMore, title: s.dtShellTitle, subtitle: s.dtMoreSubtitle),
          const SizedBox(height: NSpace.xs),
          CLabel(s.dtMoreWork),
          tile(Icons.restaurant_rounded, s.dtMealPlans, '/dietitian/meal-plans'),
          tile(Icons.menu_book_outlined, s.dtRecipes, '/dietitian/recipes'),
          tile(Icons.fact_check_outlined, s.dtCheckIns, '/dietitian/check-ins'),
          tile(Icons.notification_important_outlined, s.drAlerts, '/dietitian/alerts'),
          tile(Icons.forum_outlined, s.msgTitle, '/dietitian/messages'),
          CLabel(s.drMoreYou),
          tile(Icons.account_balance_wallet_outlined, s.earnTitle, '/dietitian/earnings'),
          tile(Icons.person_outline_rounded, s.profileTitle, '/dietitian/profile'),
          tile(Icons.notifications_none_rounded, s.notifTitle, RouteConstants.notificationSettings),
          const SizedBox(height: NSpace.md),
          const NAppearanceCard(),
          const SizedBox(height: NSpace.md),
          OutlinedButton.icon(onPressed: () => providerSignOut(context), icon: const Icon(Icons.logout_rounded), label: Text(s.pvSignOut)),
        ],
      ),
    );
  }
}

/// Alerts for her clients (spec 012 §10): acknowledge, refer to her doctor with a note, resolve with a note.
class DietitianAlertsPage extends StatefulWidget {
  const DietitianAlertsPage({super.key, this.repository});

  final DietitianRepository? repository;

  @override
  State<DietitianAlertsPage> createState() => _DietitianAlertsPageState();
}

class _DietitianAlertsPageState extends State<DietitianAlertsPage> {
  late final DietitianRepository _repo = widget.repository ?? getIt<DietitianRepository>();
  late Future<List<Json>> _list = _repo.alerts(status: 'unresolved');

  Future<void> _act(Future<void> Function() f, String done) async {
    try {
      await f();
      if (!mounted) return;
      showNote(context, done);
      setState(() => _list = _repo.alerts(status: 'unresolved'));
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.drAlerts,
      body: AsyncBody<List<Json>>(
        future: _list,
        onRetry: () => setState(() => _list = _repo.alerts(status: 'unresolved')),
        builder: (BuildContext context, List<Json> rows) => ListView(
          padding: dtPagePadding,
          children: <Widget>[
            if (rows.isEmpty) CEmpty(icon: Icons.notifications_off_outlined, title: s.drNoAlerts),
            for (int i = 0; i < rows.length; i++)
              CEntrance(
                delayMs: 40 * i.clamp(0, 8),
                child: Padding(padding: const EdgeInsets.only(bottom: NSpace.xs), child: _alert(s, rows[i])),
              ),
          ],
        ),
      ),
    );
  }

  Widget _alert(S s, Json a) {
    final bool urgent = a.str('severity') == 'urgent';
    final String name = a.obj('member').str('name') ?? s.drUnnamed;
    return DtCard(
      tint: urgent ? NColors.statusClinicalRedFlagLight.withValues(alpha: 0.4) : null,
      border: urgent ? NColors.statusClinicalRedFlag.withValues(alpha: 0.35) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CAvatar(name: name, size: 38),
              const SizedBox(width: NSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)),
                    Text(s.drAge(a.integer('ageMinutes')), style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0)),
                  ],
                ),
              ),
              CPill(alertStatusLabel(s, a.str('status')), tone: a.str('status') == 'open' ? (urgent ? CTone.red : CTone.apricot) : CTone.quiet),
            ],
          ),
          const SizedBox(height: NSpace.xs),
          Text(a.str('raisedBy') ?? '', style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
          DtActions(
            children: <Widget>[
              if (a.str('status') == 'open') TextButton(onPressed: () => _act(() => _repo.acknowledge(a.str('id')!), s.drAcknowledged), child: Text(s.drAcknowledge)),
              TextButton(
                onPressed: () async {
                  final String? n = await promptText(context, s.dtRefer, s.dtReferHint);
                  if (n != null) await _act(() => _repo.refer(a.str('id')!, n), s.dtReferred);
                },
                child: Text(s.dtRefer),
              ),
              TextButton(
                onPressed: () async {
                  final String? n = await promptText(context, s.drResolve, s.drResolveHint);
                  if (n != null) await _act(() => _repo.resolve(a.str('id')!, n), s.drResolved);
                },
                child: Text(s.drResolve),
              ),
              TextButton(onPressed: () => context.push('/dietitian/clients/${a.obj('member').str('id')}'), child: Text(s.drOpenProfile)),
            ],
          ),
        ],
      ),
    );
  }
}

String alertStatusLabel(S s, String? st) => switch (st) {
  'open' => s.drAlertOpen,
  'acknowledged' => s.drAlertAcknowledged,
  'resolved' => s.drAlertResolved,
  _ => st ?? '',
};

/// Her profile (spec 012 §12).
class DietitianProfilePage extends StatefulWidget {
  const DietitianProfilePage({super.key, this.repository});

  final DietitianRepository? repository;

  @override
  State<DietitianProfilePage> createState() => _DietitianProfilePageState();
}

class _DietitianProfilePageState extends State<DietitianProfilePage> {
  late final DietitianRepository _repo = widget.repository ?? getIt<DietitianRepository>();
  late Future<Json> _p = _repo.profile();
  final TextEditingController _bio = TextEditingController();
  final TextEditingController _languages = TextEditingController();
  final TextEditingController _specialities = TextEditingController();
  bool _filled = false;

  @override
  void dispose() {
    _bio.dispose();
    _languages.dispose();
    _specialities.dispose();
    super.dispose();
  }

  List<String> _split(String v) => v.split(',').map((String x) => x.trim()).where((String x) => x.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.profileTitle,
      body: AsyncBody<Json>(
        future: _p,
        onRetry: () => setState(() => _p = _repo.profile()),
        builder: (BuildContext context, Json p) {
          if (!_filled) {
            _filled = true;
            _bio.text = p.str('bio') ?? '';
            _languages.text = p.strs('languages').join(', ');
            _specialities.text = p.strs('specialities').join(', ');
          }
          final num? avg = p.obj('rating').number('average');
          return ListView(
            padding: dtPagePadding,
            children: <Widget>[
              CHero(
                eyebrow: s.profileTitle,
                title: p.str('name') ?? '',
                subtitle: s.drApproval(p.str('approvalStatus') ?? ''),
                trailing: avg == null
                    ? null
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: NSpace.xxs + 2),
                        decoration: BoxDecoration(color: NColors.surfaceCard, borderRadius: BorderRadius.circular(NRadius.pill), border: Border.all(color: NColors.lineDefault)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.star_rounded, size: 16, color: NColors.brandTerracotta),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                s.drRating(avg.toStringAsFixed(1), p.obj('rating').integer('count')),
                                style: NType.caption.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700, letterSpacing: 0),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: NSpace.md),
              CPanel(
                title: s.dtAboutYou,
                icon: Icons.badge_outlined,
                child: Column(
                  children: <Widget>[
                    TextField(controller: _bio, minLines: 3, maxLines: 6, maxLength: 1000, decoration: InputDecoration(labelText: s.drBio)),
                    const SizedBox(height: NSpace.xs),
                    TextField(controller: _languages, decoration: InputDecoration(labelText: s.drLanguages, helperText: s.drCommaSeparated)),
                    const SizedBox(height: NSpace.sm),
                    TextField(controller: _specialities, decoration: InputDecoration(labelText: s.dtSpecialities, helperText: s.drCommaSeparated)),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.md),
              NPrimaryButton(
                label: s.profileSave,
                onPressed: () async {
                  try {
                    final Json r = await _repo.updateProfile(bio: _bio.text.trim(), languages: _split(_languages.text), specialities: _split(_specialities.text));
                    if (!context.mounted) return;
                    setState(() => _p = Future<Json>.value(r));
                    showNote(context, s.profileSaved);
                  } on Object catch (e) {
                    if (context.mounted) showNote(context, failureText(e, s.commonLoadError));
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
