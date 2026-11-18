import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/di/service_locator.dart';
import '../../design_system/tokens/tokens.dart';
import '../../design_system/widgets/bottom_nav.dart';
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
    return Scaffold(
      backgroundColor: NColors.surfacePage,
      appBar: AppBar(
        backgroundColor: NColors.surfacePage,
        automaticallyImplyLeading: false,
        title: Text(title ?? s.pvRoleDietitian, style: NType.h4.copyWith(color: NColors.inkPrimary)),
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

/// A count that opens its list (spec 012 §1 rule 1).
class _Count extends StatelessWidget {
  const _Count({required this.label, required this.count, required this.onTap, this.detail});

  final String label;
  final int count;
  final String? detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => NCard(
    color: count > 0 ? NColors.brandLavenderLight : NColors.surfaceCard,
    onTap: onTap,
    semanticsLabel: '$label: $count',
    child: Row(
      children: <Widget>[
        Text('$count', style: NType.h2.copyWith(color: NColors.inkPrimary)),
        const SizedBox(width: NSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
              ),
              if (detail != null) Text(detail!, style: NType.caption.copyWith(color: NColors.inkSecondary)),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
      ],
    ),
  );
}

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
    final String locale = Localizations.localeOf(context).toString();
    return DietitianShell(
      index: 0,
      body: AsyncBody<Json>(
        future: _dash,
        onRetry: () => setState(() => _dash = _repo.dashboard()),
        builder: (BuildContext context, Json d) {
          final Json n = d.obj('needsMe');
          return RefreshIndicator(
            onRefresh: () async => setState(() => _dash = _repo.dashboard()),
            child: ListView(
              padding: const EdgeInsets.all(NSpace.lg),
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text(s.pvDashGreeting(d.obj('dietitian').str('name') ?? ''), style: NType.h2.copyWith(color: NColors.inkPrimary)),
                ),
                NSectionTitle(s.pvDashNeedsMe),
                _Count(
                  label: s.dtFoodLogs,
                  count: n.integer('foodLogs'),
                  detail: n.str('oldestFoodLogDueAt') == null ? null : s.drDue(shortDate(context, n.str('oldestFoodLogDueAt')!)),
                  onTap: () => _open('/dietitian/review'),
                ),
                const SizedBox(height: NSpace.xs),
                _Count(
                  label: s.dtPlansToBuild,
                  count: n.integer('mealPlansToBuild') + n.integer('mealPlansEnding'),
                  detail: s.dtEndingSoon(n.integer('mealPlansEnding')),
                  onTap: () => _open('/dietitian/meal-plans'),
                ),
                const SizedBox(height: NSpace.xs),
                _Count(label: s.dtCheckIns, count: n.integer('checkIns'), onTap: () => _open('/dietitian/check-ins')),
                const SizedBox(height: NSpace.xs),
                _Count(label: s.drAlerts, count: n.integer('alerts'), onTap: () => _open('/dietitian/alerts')),
                const SizedBox(height: NSpace.xs),
                _Count(label: s.msgTitle, count: n.integer('messages'), onTap: () => _open('/dietitian/messages')),
                NSectionTitle(s.pvDashToday),
                if (d.objs('today').isEmpty) Text(s.pvDashNoAppointments, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
                for (final Json a in d.objs('today'))
                  NCard(
                    child: Text(
                      <String>[
                        DateFormat.jm(locale).format(DateTime.parse(a.str('startsAt')!).toLocal()),
                        a.str('member') ?? '',
                        ?a.str('reason'),
                        if (a.flag('joinable')) s.pvDashJoinOnWeb,
                      ].join(' · '),
                      style: NType.body.copyWith(color: NColors.inkPrimary),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.sm, NSpace.lg, 0),
            child: TextField(
              controller: _search,
              onSubmitted: (_) => _set(() {}),
              decoration: InputDecoration(labelText: s.drSearchName, prefixIcon: const Icon(Icons.search_rounded)),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: NSpace.lg, vertical: NSpace.xs),
            child: Row(
              children: <Widget>[
                FilterChip(label: Text(s.dtPastClients), selected: _past, onSelected: (bool v) => _set(() => _past = v)),
                const SizedBox(width: NSpace.xs),
                for (final (String k, String l) in <(String, String)>[('none', s.dtPlanNone), ('draft', s.dtPlanDraft), ('active', s.dtPlanActive)]) ...<Widget>[
                  FilterChip(label: Text(l), selected: _mealPlan == k, onSelected: (bool v) => _set(() => _mealPlan = v ? k : null)),
                  const SizedBox(width: NSpace.xs),
                ],
                FilterChip(label: Text(s.drOpenAlert), selected: _openAlert, onSelected: (bool v) => _set(() => _openAlert = v)),
              ],
            ),
          ),
          Expanded(
            child: AsyncBody<List<Json>>(
              future: _list,
              onRetry: () => _set(() {}),
              builder: (BuildContext context, List<Json> rows) => rows.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(NSpace.lg),
                      child: EmptyNote(text: s.dtNoClients),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(NSpace.lg),
                      itemCount: rows.length,
                      separatorBuilder: (_, _) => const SizedBox(height: NSpace.xs),
                      itemBuilder: (BuildContext context, int i) {
                        final Json c = rows[i];
                        final String meta = <String>[
                          ?c.str('ageBand'),
                          relationshipName(s, c.str('relationship')),
                          ?c.str('plan'),
                          _plan(s, c.obj('mealPlan')),
                          if (c.str('lastCheckIn') != null) s.dtLastCheckIn(shortDate(context, c.str('lastCheckIn')!)),
                        ].join(' · ');
                        return NCard(
                          onTap: () => context.push('/dietitian/clients/${c.str('id')}'),
                          semanticsLabel: '${c.str('name') ?? ''}, $meta',
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      c.str('name') ?? s.drUnnamed,
                                      style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
                                    ),
                                    Text(meta, style: NType.caption.copyWith(color: NColors.inkSecondary)),
                                  ],
                                ),
                              ),
                              if (c.flag('openAlert'))
                                Tooltip(
                                  message: s.drOpenAlert,
                                  child: const Icon(Icons.notification_important_outlined, color: NColors.statusClinicalRedFlag),
                                ),
                              if (c.flag('unreviewedLogs'))
                                Tooltip(
                                  message: s.dtUnreviewedLogs,
                                  child: const Icon(Icons.restaurant_menu_rounded, color: NColors.inkSecondary),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
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

class _ClientPageState extends State<ClientPage> {
  late final DietitianRepository _repo = widget.repository ?? getIt<DietitianRepository>();
  late Future<Json> _header = _repo.client(widget.memberId);

  String _section(S s, String k) => switch (k) {
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
              title: Text(h.str('name') ?? s.drUnnamed),
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: <Widget>[
                  Tab(text: s.drSecSummary),
                  for (final String k in sections) Tab(text: _section(s, k)),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                _ClientSummary(header: h, repo: _repo),
                for (final String k in sections)
                  k == 'progress' ? ProgressView(memberId: widget.memberId, repository: _repo) : _ClientSection(memberId: widget.memberId, section: k, repo: _repo, past: h.flag('past')),
              ],
            ),
          ),
        );
      },
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
    return ListView(
      padding: const EdgeInsets.all(NSpace.lg),
      children: <Widget>[
        if (h.str('suppressionBanner') != null) ...<Widget>[
          NCard(
            color: NColors.statusWarningLight,
            child: Text(
              h.str('suppressionBanner')!,
              style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: NSpace.sm),
        ],
        Text(
          <String>[?h.str('ageBand'), ?h.str('plan'), if (h.str('relationship') != null) relationshipName(s, h.str('relationship'))].join(' · '),
          style: NType.bodySm.copyWith(color: NColors.inkSecondary),
        ),
        if (h.str('dedicatedDoctor') != null) Text(s.dtDoctor(h.str('dedicatedDoctor')!), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
        NSectionTitle(s.drConsent),
        Wrap(
          spacing: NSpace.xs,
          runSpacing: NSpace.xs,
          children: <Widget>[for (final Json c in h.objs('consent')) Chip(label: Text('${humanise(c.str('category') ?? '')}: ${c.flag('shared') ? s.drConsentView : s.drConsentNone}'))],
        ),
        if (h.objs('flags').isNotEmpty) ...<Widget>[
          NSectionTitle(s.drFlags),
          Wrap(
            spacing: NSpace.xs,
            children: <Widget>[for (final Json f in h.objs('flags')) Chip(label: Text(f.str('name') ?? ''))],
          ),
        ],
        if (!h.flag('past')) ...<Widget>[
          const SizedBox(height: NSpace.md),
          NPrimaryButton(label: s.dtNewPlan, onPressed: _newPlan),
          NSectionTitle(s.drBrief),
          if (_brief == null)
            NSecondaryButton(label: s.drBriefOpen, onPressed: () => setState(() => _brief = widget.repo.brief(h.str('id')!)))
          else
            FutureBuilder<Json>(
              future: _brief,
              builder: (BuildContext context, AsyncSnapshot<Json> snap) {
                if (snap.hasError) return Text(failureText(snap.error!, s.commonLoadError));
                if (!snap.hasData) return Text(s.loading);
                final Json b = snap.data!;
                return NCard(
                  color: NColors.brandLavenderLight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(b.str('label') ?? '', style: NType.caption.copyWith(fontWeight: FontWeight.w700)),
                      for (final Json p in b.objs('points')) Text('• ${p.str('text')}'),
                      JsonView(data: b.obj('facts')),
                    ],
                  ),
                );
              },
            ),
        ],
      ],
    );
  }
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
          return Padding(
            padding: const EdgeInsets.all(NSpace.lg),
            child: EmptyNote(text: s.drNotSharedSection),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(NSpace.lg),
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
            if (widget.section == 'meal_plan')
              for (final Json p in d.objs('plans'))
                if (p.flag('mine'))
                  Padding(
                    padding: const EdgeInsets.only(bottom: NSpace.xs),
                    child: OutlinedButton(
                      onPressed: () => context.push('/dietitian/meal-plans/${p.str('id')}'),
                      child: Text('${p.str('title') ?? s.dtMealPlan} · ${p.str('status')} · ${shortDate(context, p.str('startDate') ?? '')}'),
                    ),
                  ),
            JsonView(data: d, skip: const <String>{'section', 'shared'}),
          ],
        );
      },
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
          for (final Json x in qs) SimpleDialogOption(onPressed: () => Navigator.of(d).pop(x), child: Text(x.str('name') ?? '')),
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
      builder: (BuildContext context, Json d) => ListView(
        padding: const EdgeInsets.all(NSpace.lg),
        children: <Widget>[
          if (d.objs('planPeriods').isNotEmpty)
            Text(
              s.dtPlanPeriods(d.objs('planPeriods').map((Json p) => '${shortDate(context, p.str('from') ?? '')}–${p.str('to') == null ? '' : shortDate(context, p.str('to')!)}').join(', ')),
              style: NType.caption.copyWith(color: NColors.inkSecondary),
            ),
          NSectionTitle(s.checkInsTrend),
          if (d.objs('checkIns').isEmpty) EmptyNote(text: s.dtNoCheckIns),
          for (final Json c in d.objs('checkIns'))
            Padding(
              padding: const EdgeInsets.only(bottom: NSpace.xs),
              child: NCard(
                color: c.flag('read') ? NColors.surfaceCard : NColors.brandLavenderLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(s.checkInsThisWeek(shortDate(context, c.str('week') ?? '')), style: NType.body.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      <String>[
                        if (c.number('energy') != null) s.checkInsEnergyValue(c.integer('energy')),
                        if (c.number('cravings') != null) s.checkInsCravingsValue(c.integer('cravings')),
                        if (c.number('weightKg') != null) s.checkInsWeightValue(c.number('weightKg')!.toStringAsFixed(1)),
                        if (c.number('waistCm') != null) s.checkInsWaistValue(c.number('waistCm')!.toStringAsFixed(0)),
                      ].join(' · '),
                      style: NType.bodySm.copyWith(color: NColors.inkSecondary),
                    ),
                    if (c.str('note') != null) Text(c.str('note')!, style: NType.bodySm),
                    if (c.str('reply') != null) Text(s.dtYourReply(c.str('reply')!), style: NType.caption.copyWith(color: NColors.inkSecondary)),
                    Wrap(
                      spacing: NSpace.xs,
                      children: <Widget>[
                        if (!c.flag('read')) TextButton(onPressed: () => _act(() => widget.repository.respond(c.str('id')!, null), s.dtMarkedRead), child: Text(s.dtMarkRead)),
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
              ),
            ),
          if (d.objs('missed').isNotEmpty) ...<Widget>[
            NSectionTitle(s.dtMissed),
            for (final Json w in d.objs('missed'))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.checkInsThisWeek(shortDate(context, w.str('week') ?? ''))),
                trailing: w.flag('nudged')
                    ? Text(s.dtNudged)
                    : TextButton(onPressed: () => _act(() => widget.repository.nudge(widget.memberId, w.str('week')!), s.dtNudgeSent), child: Text(s.dtNudge)),
              ),
          ],
          const SizedBox(height: NSpace.md),
          NSecondaryButton(label: s.dtAssign, onPressed: _assign),
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
        builder: (BuildContext context, List<Json> rows) => rows.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(NSpace.lg),
                child: EmptyNote(text: s.dtNoUnreadCheckIns),
              )
            : ListView(
                padding: const EdgeInsets.all(NSpace.lg),
                children: <Widget>[
                  for (final Json c in rows)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(c.str('member') ?? s.drUnnamed),
                      subtitle: Text(s.checkInsThisWeek(shortDate(context, c.str('week') ?? ''))),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () async {
                        await context.push('/dietitian/clients/${c.str('memberId')}');
                        if (mounted) setState(() => _list = _repo.unreadCheckIns());
                      },
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
    Widget row(IconData icon, String label, String path) => Padding(
      padding: const EdgeInsets.only(bottom: NSpace.xs),
      child: NCard(
        onTap: () => context.push(path),
        semanticsLabel: label,
        child: Row(
          children: <Widget>[
            Icon(icon, color: NColors.inkSecondary),
            const SizedBox(width: NSpace.sm),
            Expanded(
              child: Text(
                label,
                style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
          ],
        ),
      ),
    );
    return DietitianShell(
      index: 4,
      title: s.pvShellMore,
      body: ListView(
        padding: const EdgeInsets.all(NSpace.lg),
        children: <Widget>[
          row(Icons.restaurant_rounded, s.dtMealPlans, '/dietitian/meal-plans'),
          row(Icons.menu_book_outlined, s.dtRecipes, '/dietitian/recipes'),
          row(Icons.fact_check_outlined, s.dtCheckIns, '/dietitian/check-ins'),
          row(Icons.notification_important_outlined, s.drAlerts, '/dietitian/alerts'),
          row(Icons.forum_outlined, s.msgTitle, '/dietitian/messages'),
          row(Icons.account_balance_wallet_outlined, s.earnTitle, '/dietitian/earnings'),
          row(Icons.person_outline_rounded, s.profileTitle, '/dietitian/profile'),
          row(Icons.notifications_none_rounded, s.notifTitle, RouteConstants.notificationSettings),
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
        builder: (BuildContext context, List<Json> rows) => rows.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(NSpace.lg),
                child: EmptyNote(text: s.drNoAlerts),
              )
            : ListView(
                padding: const EdgeInsets.all(NSpace.lg),
                children: <Widget>[
                  for (final Json a in rows) ...<Widget>[
                    NCard(
                      color: a.str('severity') == 'urgent' ? NColors.statusClinicalRedFlagLight : NColors.surfaceCard,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(a.obj('member').str('name') ?? s.drUnnamed, style: NType.body.copyWith(fontWeight: FontWeight.w700)),
                          Text(a.str('raisedBy') ?? '', style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                          Text('${alertStatusLabel(s, a.str('status'))} · ${s.drAge(a.integer('ageMinutes'))}', style: NType.caption.copyWith(color: NColors.inkSecondary)),
                          Wrap(
                            spacing: NSpace.xs,
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
                    ),
                    const SizedBox(height: NSpace.xs),
                  ],
                ],
              ),
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
          return ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              Text(p.str('name') ?? '', style: NType.h3),
              Text(s.drApproval(p.str('approvalStatus') ?? ''), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              if (p.obj('rating').number('average') != null)
                Text(s.drRating(p.obj('rating').number('average')!.toStringAsFixed(1), p.obj('rating').integer('count')), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              TextField(
                controller: _bio,
                minLines: 3,
                maxLines: 6,
                maxLength: 1000,
                decoration: InputDecoration(labelText: s.drBio),
              ),
              TextField(
                controller: _languages,
                decoration: InputDecoration(labelText: s.drLanguages, helperText: s.drCommaSeparated),
              ),
              TextField(
                controller: _specialities,
                decoration: InputDecoration(labelText: s.dtSpecialities, helperText: s.drCommaSeparated),
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
