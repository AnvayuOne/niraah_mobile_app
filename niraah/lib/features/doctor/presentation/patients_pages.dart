import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/clinician_ui.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../provider_work/domain/provider_work.dart';
import '../domain/doctor_work.dart';
import 'doctor_shell.dart';
import 'json_view.dart';
import 'review_queue_page.dart';

String relationshipName(S s, String? k) => switch (k) {
  'dedicated' => s.drRelDedicated,
  'consult' => s.drRelConsult,
  'review' => s.drRelReview,
  _ => k ?? '',
};

/// Relationship tone: dedicated is hers (plum), consult (lavender), review (apricot).
CTone _relTone(String? k) => switch (k) {
  'dedicated' => CTone.plum,
  'consult' => CTone.lavender,
  'review' => CTone.apricot,
  _ => CTone.quiet,
};

/// Patients (spec 011 §2): exactly the members she has an active care relationship with, or past ones; name, age
/// band, relationship, plan, next appointment and markers. No scores, symptoms or lab values (AC7).
class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key, this.repository});

  final DoctorWorkRepository? repository;

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  late final DoctorWorkRepository _repo = widget.repository ?? getIt<DoctorWorkRepository>();
  final TextEditingController _search = TextEditingController();
  String? _kind;
  bool _openAlert = false;
  bool _planAwaiting = false;
  bool _past = false;
  late Future<List<Json>> _list = _load();

  /// The last list shown, kept on screen while a new filter loads so the header never flashes.
  List<Json>? _last;

  Future<List<Json>> _load() => _repo.patients(PatientFilters(search: _search.text, kind: _kind, openAlert: _openAlert ? true : null, planAwaiting: _planAwaiting ? true : null, past: _past));

  void _reload() => setState(() => _list = _load());

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Widget _chip(String label, bool selected, ValueChanged<bool> onSelected) => Padding(
    padding: const EdgeInsets.only(right: NSpace.xs),
    child: FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      labelStyle: NType.bodySm.copyWith(color: selected ? Colors.white : NColors.inkSecondary, fontWeight: FontWeight.w600),
      selectedColor: NColors.roleDoctor,
      backgroundColor: NColors.surfaceCard,
      side: BorderSide(color: selected ? NColors.roleDoctor : NColors.lineDefault),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NRadius.pill)),
      onSelected: (bool v) => setState(() {
        onSelected(v);
        _list = _load();
      }),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return DoctorShell(
      index: 1,
      title: s.pvShellPatients,
      body: FutureBuilder<List<Json>>(
        future: _list,
        builder: (BuildContext context, AsyncSnapshot<List<Json>> snap) {
          if (snap.hasError) {
            final Object e = snap.error!;
            if (e is AreaLocked) return AreaLockedView(refusal: e);
            return ErrorView(message: s.commonLoadError, retryLabel: s.tryAgain, onRetry: _reload);
          }
          final bool loading = snap.connectionState != ConnectionState.done;
          if (!loading) _last = snap.data;
          final List<Json>? rows = loading ? _last : snap.data;
          if (rows == null) return LoadingView(label: s.loading);
          int count(String k) => rows.where((Json p) => p.str('relationship') == k).length;
          final int alerts = rows.where((Json p) => p.flag('openAlert')).length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl),
            children: <Widget>[
              CHero(
                eyebrow: _past ? s.drPast : s.drAPatientsEyebrow,
                title: s.drAPatientsCount(rows.length),
                subtitle: s.drAPatientsAlerts(alerts),
                child: CStatGrid(
                  children: <Widget>[
                    CHeroStat(label: s.drRelDedicated, value: '${count('dedicated')}', icon: Icons.favorite_border_rounded),
                    CHeroStat(label: s.drRelConsult, value: '${count('consult')}', icon: Icons.medical_services_outlined),
                    CHeroStat(label: s.drRelReview, value: '${count('review')}', icon: Icons.fact_check_outlined),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.md),
              CEntrance(
                delayMs: 60,
                child: TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _reload(),
                  decoration: InputDecoration(
                    labelText: s.drSearchName,
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: NColors.surfaceCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(NRadius.pill),
                      borderSide: BorderSide(color: NColors.lineDefault),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(NRadius.pill),
                      borderSide: BorderSide(color: NColors.lineDefault),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: NSpace.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    _chip(s.drPast, _past, (bool v) => _past = v),
                    for (String k in const <String>['dedicated', 'consult', 'review']) _chip(relationshipName(s, k), _kind == k, (bool v) => _kind = v ? k : null),
                    _chip(s.drOpenAlert, _openAlert, (bool v) => _openAlert = v),
                    _chip(s.drPlanAwaiting, _planAwaiting, (bool v) => _planAwaiting = v),
                  ],
                ),
              ),
              SizedBox(
                height: NSpace.sm,
                child: loading ? LinearProgressIndicator(minHeight: 2, color: NColors.brandRosewood, backgroundColor: Colors.transparent) : null,
              ),
              if (rows.isEmpty)
                CEmpty(icon: Icons.people_outline_rounded, title: _past ? s.drNoPastPatients : s.drNoPatients)
              else
                for (int i = 0; i < rows.length; i++)
                  CEntrance(
                    delayMs: 40 * i.clamp(0, 8),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: NSpace.xs),
                      child: _patientRow(context, s, rows[i]),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  Widget _patientRow(BuildContext context, S s, Json p) {
    final String meta = <String>[
      ?p.str('ageBand'),
      relationshipName(s, p.str('relationship')),
      ?p.str('plan'),
      if (p.str('nextAppointment') != null) s.drNext(shortDate(context, p.str('nextAppointment')!)),
    ].where((String x) => x.isNotEmpty).join(' · ');
    final String sub = <String>[
      ?p.str('ageBand'),
      ?p.str('plan'),
      if (p.str('nextAppointment') != null) s.drNext(shortDate(context, p.str('nextAppointment')!)),
    ].where((String x) => x.isNotEmpty).join(' · ');
    final String name = p.str('name') ?? s.drUnnamed;
    return Semantics(
      button: true,
      label: '$name, $meta${p.flag('openAlert') ? ', ${s.drOpenAlert}' : ''}${p.flag('carePlanAwaiting') ? ', ${s.drPlanAwaiting}' : ''}',
      excludeSemantics: true,
      child: Material(
        color: p.flag('openAlert') ? NColors.statusClinicalRedFlagLight.withValues(alpha: 0.35) : NColors.surfaceCard,
        borderRadius: BorderRadius.circular(NRadius.lg),
        child: InkWell(
          onTap: () => context.push('/doctor/patients/${p.str('id')}'),
          borderRadius: BorderRadius.circular(NRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(NSpace.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(NRadius.lg),
              border: Border.all(color: p.flag('openAlert') ? NColors.statusClinicalRedFlag.withValues(alpha: 0.35) : NColors.lineDefault),
            ),
            child: Row(
              children: <Widget>[
                CAvatar(name: name, size: 44),
                const SizedBox(width: NSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
                      ),
                      if (sub.isNotEmpty)
                        Text(
                          sub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NType.bodySm.copyWith(color: NColors.inkMuted),
                        ),
                      const SizedBox(height: NSpace.xxs),
                      Wrap(
                        spacing: NSpace.xxs,
                        runSpacing: NSpace.xxs,
                        children: <Widget>[
                          if (p.str('relationship') != null) CPill(relationshipName(s, p.str('relationship')), tone: _relTone(p.str('relationship'))),
                          if (p.flag('openAlert')) CPill(s.drOpenAlert, tone: CTone.red),
                          if (p.flag('carePlanAwaiting')) CPill(s.drPlanAwaiting, tone: CTone.apricot),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One member, everything the doctor may see (spec 011 §3): the header with the consent tag and flags, then the
/// sections as a tab strip. A section without consent says "She has not shared this" and shows nothing (AC3).
class PatientPage extends StatefulWidget {
  const PatientPage({required this.memberId, super.key, this.repository});

  final String memberId;
  final DoctorWorkRepository? repository;

  @override
  State<PatientPage> createState() => _PatientPageState();
}

String _sectionName(S s, String k) => switch (k) {
  'assessment' => s.drSecAssessment,
  'cycle_symptoms' => s.drSecCycle,
  'care_plan' => s.drSecCarePlan,
  'prescriptions' => s.drSecAdvice,
  'labs' => s.drSecLabs,
  'meals' => s.drSecMeals,
  'shared_ai' => s.drSecShared,
  'notes' => s.drSecNotes,
  'timeline' => s.drSecTimeline,
  _ => humanise(k),
};

IconData _sectionIcon(String k) => switch (k) {
  'assessment' => Icons.insights_rounded,
  'cycle_symptoms' => Icons.water_drop_outlined,
  'care_plan' => Icons.draw_outlined,
  'prescriptions' => Icons.spa_outlined,
  'labs' => Icons.science_outlined,
  'meals' => Icons.restaurant_outlined,
  'shared_ai' => Icons.forum_outlined,
  'notes' => Icons.sticky_note_2_outlined,
  'timeline' => Icons.timeline_rounded,
  _ => Icons.article_outlined,
};

String _category(S s, String c) => switch (c) {
  'assessment' => s.drSecAssessment,
  'cycle_symptoms' => s.drSecCycle,
  'meals' => s.drSecMeals,
  'lab_reports' => s.drSecLabs,
  'messages' => s.drMessages,
  _ => humanise(c),
};

class _PatientPageState extends State<PatientPage> {
  late final DoctorWorkRepository _repo = widget.repository ?? getIt<DoctorWorkRepository>();
  late Future<Json> _header = _repo.patient(widget.memberId);

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return FutureBuilder<Json>(
      future: _header,
      builder: (BuildContext context, AsyncSnapshot<Json> snap) {
        final Json? h0 = snap.data;
        if (h0 == null) {
          return AreaScaffold(
            title: s.pvShellPatients,
            body: AsyncBody<Json>(future: _header, onRetry: () => setState(() => _header = _repo.patient(widget.memberId)), builder: (_, _) => const SizedBox.shrink()),
          );
        }
        final Json h = h0;
        final List<String> sections = h.strs('sections');
        return DefaultTabController(
          length: sections.length + 1,
          child: Scaffold(
            backgroundColor: NColors.surfacePage,
            appBar: AppBar(
              backgroundColor: NColors.surfacePage,
              title: Text(s.pvShellPatients, style: NType.h4.copyWith(color: NColors.inkPrimary)),
            ),
            body: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool inner) => <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(NSpace.md, 0, NSpace.md, NSpace.xs),
                    child: _PatientHeader(header: h),
                  ),
                ),
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabsDelegate(
                      TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: NColors.roleDoctor,
                        unselectedLabelColor: NColors.inkMuted,
                        labelStyle: NType.bodySm.copyWith(fontWeight: FontWeight.w700),
                        unselectedLabelStyle: NType.bodySm.copyWith(fontWeight: FontWeight.w600),
                        indicatorColor: NColors.brandRosewood,
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
                ),
              ],
              body: TabBarView(
                children: <Widget>[
                  _Summary(header: h, repo: _repo),
                  for (String k in sections) _Section(memberId: widget.memberId, section: k, repo: _repo, past: h.flag('past')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A tab's scrolling list under the pinned tab strip (injects the strip's overlap).
class _TabList extends StatelessWidget {
  const _TabList({required this.children});

  final List<Widget> children;
  static const EdgeInsets padding = EdgeInsets.fromLTRB(NSpace.md, NSpace.md, NSpace.md, NSpace.xl);

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: <Widget>[
      SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
      SliverPadding(
        padding: padding,
        sliver: SliverList(delegate: SliverChildListDelegate(children)),
      ),
    ],
  );
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

/// The plum header card: avatar, name, plan and relationship, flags as red pills and her consent per category.
class _PatientHeader extends StatelessWidget {
  const _PatientHeader({required this.header});

  final Json header;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Json h = header;
    final String name = h.str('name') ?? s.drUnnamed;
    final List<Json> consent = h.objs('consent');
    return CHero(
      eyebrow: h.flag('past') ? s.drPastPatient : s.pvShellPatients,
      title: name,
      subtitle: <String>[?h.str('ageBand'), ?h.str('plan')].join(' · '),
      trailing: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: NColors.brandApricot.withValues(alpha: 0.7), width: 2),
        ),
        child: CAvatar(name: name, size: 52),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: NSpace.xxs,
            runSpacing: NSpace.xxs,
            children: <Widget>[
              if (h.str('relationship') != null) _GlassPill(text: relationshipName(s, h.str('relationship')), strong: true),
              if (h.str('plan') != null) _GlassPill(text: h.str('plan')!),
              if (h.flag('past')) _GlassPill(text: s.drPastPatient),
              for (Json f in h.objs('flags'))
                Semantics(
                  label: '${s.drFlags}: ${f.str('name')} · ${f.str('severity')}',
                  excludeSemantics: true,
                  child: CPill('${f.str('name')} · ${f.str('severity')}', tone: CTone.red),
                ),
            ],
          ),
          if (consent.isNotEmpty) ...<Widget>[
            const SizedBox(height: NSpace.sm),
            Text(
              s.drConsent.toUpperCase(),
              style: NType.label.copyWith(color: NColors.inkSecondary, letterSpacing: 1.2, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: NSpace.xxs),
            Wrap(
              spacing: NSpace.xxs,
              runSpacing: NSpace.xxs,
              children: <Widget>[
                for (Json c in consent)
                  Semantics(
                    label: '${_category(s, c.str('category') ?? '')}: ${c.flag('shared') ? s.drConsentView : s.drConsentNone}',
                    excludeSemantics: true,
                    child: _GlassPill(text: _category(s, c.str('category') ?? ''), icon: c.flag('shared') ? Icons.visibility_outlined : Icons.visibility_off_outlined, dim: !c.flag('shared')),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A pill for the plum hero: glassy white, or apricot when [strong]; [dim] for a category she has not shared.
class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.text, this.icon, this.strong = false, this.dim = false});

  final String text;
  final IconData? icon;
  final bool strong;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final Color fg = strong ? NColors.inkPrimary : (dim ? NColors.inkMuted : NColors.inkSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: NSpace.xs + 2, vertical: 4),
      decoration: BoxDecoration(
        color: strong ? NColors.brandApricot : NColors.surfaceCard.withValues(alpha: dim ? 0.5 : 0.85),
        borderRadius: BorderRadius.circular(NRadius.pill),
        border: Border.all(color: NColors.lineDefault),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[Icon(icon, size: 13, color: fg), const SizedBox(width: 4)],
          Text(
            text,
            style: NType.caption.copyWith(color: fg, fontWeight: FontWeight.w700, letterSpacing: 0, decoration: dim ? TextDecoration.lineThrough : null, decorationColor: fg),
          ),
        ],
      ),
    );
  }
}

/// The care team and the clinician brief (spec 011 §3 "Header", §8).
class _Summary extends StatefulWidget {
  const _Summary({required this.header, required this.repo});

  final Json header;
  final DoctorWorkRepository repo;

  @override
  State<_Summary> createState() => _SummaryState();
}

class _SummaryState extends State<_Summary> {
  Future<Json>? _brief;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Json h = widget.header;
    final List<String> sections = h.strs('sections');
    return _TabList(
      children: <Widget>[
        if (!h.flag('past')) ...<Widget>[
          CPanel(
            title: s.drBrief,
            icon: Icons.auto_awesome_outlined,
            child: _brief == null
                ? NSecondaryButton(
                    label: s.drBriefOpen,
                    onPressed: () => setState(() {
                      _brief = widget.repo.brief(h.str('id')!);
                    }),
                  )
                : FutureBuilder<Json>(
                    future: _brief,
                    builder: (BuildContext context, AsyncSnapshot<Json> snap) {
                      if (snap.hasError) return Text(failureText(snap.error!, s.commonLoadError), style: NType.bodySm.copyWith(color: NColors.inkSecondary));
                      if (!snap.hasData) return Text(s.loading, style: NType.bodySm.copyWith(color: NColors.inkMuted));
                      final Json b = snap.data!;
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(NSpace.sm),
                        decoration: BoxDecoration(color: NColors.brandLavenderLight, borderRadius: BorderRadius.circular(NRadius.lg)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (b.str('label') != null) CPill(b.str('label')!, tone: CTone.lavender),
                            for (Json p in b.objs('points'))
                              Padding(
                                padding: const EdgeInsets.only(top: NSpace.xs),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: const EdgeInsets.only(top: 7, right: NSpace.xs),
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(color: NColors.brandRosewood, shape: BoxShape.circle),
                                    ),
                                    Expanded(
                                      child: Text('${p.str('text')} (${humanise(p.str('section') ?? '')})', style: NType.bodySm.copyWith(color: NColors.inkPrimary)),
                                    ),
                                  ],
                                ),
                              ),
                            JsonView(data: b.obj('facts')),
                            if (b.strs('notShared').isNotEmpty) ...<Widget>[
                              const SizedBox(height: NSpace.xs),
                              Text(s.drNotShared(b.strs('notShared').map((String c) => _category(s, c)).join(', ')), style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0)),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: NSpace.md),
        ],
        if (h.str('dedicatedDietitian') != null) ...<Widget>[
          CPanel(
            title: s.drACareTeam,
            icon: Icons.groups_outlined,
            child: CRow(
              title: s.drDietitian(h.str('dedicatedDietitian')!),
              leading: CAvatar(name: h.str('dedicatedDietitian'), size: 36),
            ),
          ),
          const SizedBox(height: NSpace.md),
        ],
        if (sections.isNotEmpty)
          CPanel(
            title: s.drADetails,
            icon: Icons.folder_open_outlined,
            child: Wrap(
              spacing: NSpace.xs,
              runSpacing: NSpace.xs,
              children: <Widget>[
                for (int i = 0; i < sections.length; i++)
                  ActionChip(
                    avatar: Icon(_sectionIcon(sections[i]), size: 16, color: NColors.brandRosewood),
                    label: Text(_sectionName(s, sections[i])),
                    labelStyle: NType.bodySm.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
                    backgroundColor: NColors.surfacePage,
                    side: BorderSide(color: NColors.lineDefault),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NRadius.pill)),
                    onPressed: () => DefaultTabController.of(context).animateTo(i + 1),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// One section of the profile, with its own actions: add a note (Notes), recommend tests (Labs).
class _Section extends StatefulWidget {
  const _Section({required this.memberId, required this.section, required this.repo, required this.past});

  final String memberId;
  final String section;
  final DoctorWorkRepository repo;
  final bool past;

  @override
  State<_Section> createState() => _SectionState();
}

class _SectionState extends State<_Section> with AutomaticKeepAliveClientMixin<_Section> {
  late Future<Json> _data = widget.repo.section(widget.memberId, widget.section);

  @override
  bool get wantKeepAlive => true;

  Future<void> _addNote() async {
    final S s = S.of(context);
    final String? text = await _prompt(context, s.drAddNote, s.drNoteHint, maxLength: 4000);
    if (text == null || !mounted) return;
    try {
      final Json r = await widget.repo.addNote(widget.memberId, text);
      if (mounted) setState(() => _data = Future<Json>.value(r));
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    }
  }

  Future<void> _recommend() async {
    final S s = S.of(context);
    final List<Json> tests = await widget.repo.labTests();
    if (!mounted) return;
    final Set<String> chosen = <String>{};
    final TextEditingController note = TextEditingController();
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => StatefulBuilder(
        builder: (BuildContext c, StateSetter set) => AlertDialog(
          title: Text(s.drRecommendTests),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                for (Json t in tests)
                  CheckboxListTile(
                    value: chosen.contains(t.str('id')),
                    onChanged: (bool? v) => set(() => (v ?? false) ? chosen.add(t.str('id')!) : chosen.remove(t.str('id'))),
                    title: Text(t.str('name') ?? ''),
                    subtitle: t.flag('fasting_needed') ? Text(s.labsFasting) : null,
                  ),
                TextField(
                  controller: note,
                  maxLength: 300,
                  decoration: InputDecoration(labelText: s.drRecommendNote),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text(s.commonCancel)),
            FilledButton(onPressed: chosen.isEmpty ? null : () => Navigator.of(c).pop(true), child: Text(s.drRecommend)),
          ],
        ),
      ),
    );
    final String text = note.text.trim();
    note.dispose();
    if (ok != true || !mounted) return;
    try {
      await widget.repo.recommendTests(widget.memberId, chosen.toList(), note: text.isEmpty ? null : text);
      if (!mounted) return;
      showNote(context, s.drRecommended);
      setState(() => _data = widget.repo.section(widget.memberId, widget.section));
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final S s = S.of(context);
    return AsyncBody<Json>(
      future: _data,
      onRetry: () => setState(() => _data = widget.repo.section(widget.memberId, widget.section)),
      builder: (BuildContext context, Json d) {
        if (!d.flag('shared')) {
          return _TabList(
            children: <Widget>[
              CEntrance(
                child: CEmpty(icon: Icons.lock_outline_rounded, title: s.drNotSharedSection, body: s.drALockedBody),
              ),
            ],
          );
        }
        final Set<String> used = <String>{'section', 'shared'};
        final List<Widget> visuals = <Widget>[
          if (widget.section == 'assessment') ?_assessment(s, d, used),
          if (widget.section == 'cycle_symptoms') ...<Widget>[?_cycles(s, d, used), ?_symptoms(s, d, used)],
        ];
        final bool rest = d.keys.any((String k) => !used.contains(k));
        return _TabList(
          children: <Widget>[
            if (widget.section == 'notes' && !widget.past) ...<Widget>[NSecondaryButton(label: s.drAddNote, onPressed: _addNote), const SizedBox(height: NSpace.sm)],
            if (widget.section == 'labs') ...<Widget>[NSecondaryButton(label: s.drRecommendTests, onPressed: _recommend), const SizedBox(height: NSpace.sm)],
            if (widget.section == 'care_plan')
              for (Json p in d.objs('plans'))
                if (p.str('status') == 'in_review')
                  Padding(
                    padding: const EdgeInsets.only(bottom: NSpace.xs),
                    child: OutlinedButton(onPressed: () => context.push('/doctor/care-plans/${p.str('id')}'), child: Text(s.drOpenDraft)),
                  ),
            for (int i = 0; i < visuals.length; i++) ...<Widget>[CEntrance(delayMs: 60 * i, child: visuals[i]), const SizedBox(height: NSpace.md)],
            if (rest)
              CPanel(
                title: visuals.isEmpty ? _sectionName(s, widget.section) : s.drADetails,
                icon: _sectionIcon(widget.section),
                child: JsonView(data: d, skip: used),
              ),
          ],
        );
      },
    );
  }

  /// The record holding a score: the section itself or its first nested record with `total`.
  Json? _scored(Json d, Set<String> used) {
    if (d['total'] is num) return d;
    for (MapEntry<String, dynamic> e in d.entries) {
      if (e.value is Map && (e.value as Map<dynamic, dynamic>)['total'] is num) {
        used.add(e.key);
        return d.obj(e.key);
      }
    }
    return null;
  }

  Widget? _assessment(S s, Json d, Set<String> used) {
    final Json? m = _scored(d, used);
    if (m == null) return null;
    if (identical(m, d)) used.addAll(<String>{'total', 'maximum', 'max', 'band', 'dimensions'});
    final double total = m.number('total')!;
    final double max = m.number('maximum') ?? m.number('max') ?? 100;
    final List<Json> dims = m.objs('dimensions');
    return CPanel(
      title: s.pvReviewScores,
      icon: Icons.insights_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              ScoreRing(value: total, max: max),
              const SizedBox(width: NSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      s.pvReviewTotal(total.round(), max.round(), m.str('band') ?? '—'),
                      style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
                    ),
                    if (m.str('band') != null) ...<Widget>[const SizedBox(height: NSpace.xxs), CPill(m.str('band')!, tone: CTone.rose)],
                  ],
                ),
              ),
            ],
          ),
          if (dims.isNotEmpty) ...<Widget>[
            const SizedBox(height: NSpace.md),
            CLabel(s.drADimensions),
            for (Json x in dims) DimensionBar(name: x.str('name') ?? '', points: x.number('points') ?? 0, max: x.number('max') ?? 1, level: x.str('level')),
          ],
        ],
      ),
    );
  }

  Widget? _cycles(S s, Json d, Set<String> used) {
    final List<(String, double)> lengths = <(String, double)>[];
    for (MapEntry<String, dynamic> e in d.entries) {
      final Object? v = e.value;
      if (v is! List || v.isEmpty) continue;
      if (e.key.toLowerCase().contains('length') && v.every((Object? x) => x is num)) {
        used.add(e.key);
        for (int i = 0; i < v.length; i++) {
          lengths.add(('${i + 1}', (v[i] as num).toDouble()));
        }
        break;
      }
      if (e.key == 'cycles' && v.every((Object? x) => x is Map)) {
        used.add(e.key);
        for (Json c in d.objs('cycles')) {
          final double? n = c.number('length') ?? c.number('lengthDays') ?? c.number('days');
          final String? start = c.str('start') ?? c.str('startedOn') ?? c.str('startDate');
          if (n != null) lengths.add((start == null ? '${lengths.length + 1}' : shortDate(context, start), n));
        }
        break;
      }
    }
    if (lengths.isEmpty) return null;
    final double avg = lengths.map(((String, double) x) => x.$2).reduce((double a, double b) => a + b) / lengths.length;
    final double top = lengths.map(((String, double) x) => x.$2).reduce(math.max).clamp(35, 90).toDouble();
    return CPanel(
      title: s.drACycleLengths,
      note: s.drACycleAvg(avg.round()),
      icon: Icons.water_drop_outlined,
      child: Column(
        children: <Widget>[
          for (final (String label, double n) in lengths)
            Padding(
              padding: const EdgeInsets.only(bottom: NSpace.xs),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 92,
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NType.caption.copyWith(color: NColors.inkSecondary, letterSpacing: 0),
                    ),
                  ),
                  Expanded(
                    child: CBar(value: n / top, height: 10, color: (n < 21 || n > 35) ? NColors.brandTerracotta : NColors.brandRosewood),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text(
                      s.drADays(n.round()),
                      textAlign: TextAlign.right,
                      style: NType.caption.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700, letterSpacing: 0, fontFeatures: const <FontFeature>[FontFeature.tabularFigures()]),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget? _symptoms(S s, Json d, Set<String> used) {
    final List<Json> list = d.objs('symptoms').where((Json x) => x.str('name') != null).toList();
    if (list.isEmpty) return null;
    used.add('symptoms');
    CTone tone(String? sev) {
      final String v = (sev ?? '').toLowerCase();
      final num? n = num.tryParse(v);
      if (v.contains('severe') || v.contains('high') || (n != null && n >= 3)) return CTone.apricot;
      if (v.contains('moderate') || v.contains('medium') || (n != null && n >= 2)) return CTone.rose;
      return CTone.sage;
    }

    return CPanel(
      title: s.drASymptoms,
      icon: Icons.monitor_heart_outlined,
      child: Wrap(
        spacing: NSpace.xs,
        runSpacing: NSpace.xs,
        children: <Widget>[for (Json x in list) CPill(x.str('severity') == null ? x.str('name')! : '${x.str('name')} · ${x.str('severity')}', tone: tone(x.str('severity')))],
      ),
    );
  }
}

/// A short text prompt; null when cancelled or empty.
Future<String?> _prompt(BuildContext context, String title, String hint, {int maxLength = 2000}) async {
  final S s = S.of(context);
  final TextEditingController c = TextEditingController();
  final String? r = await showDialog<String>(
    context: context,
    builder: (BuildContext d) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: c,
        autofocus: true,
        minLines: 3,
        maxLines: 8,
        maxLength: maxLength,
        decoration: InputDecoration(hintText: hint),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(d).pop(), child: Text(s.commonCancel)),
        FilledButton(onPressed: () => Navigator.of(d).pop(c.text.trim()), child: Text(s.drSave)),
      ],
    ),
  );
  c.dispose();
  return (r == null || r.isEmpty) ? null : r;
}

/// The same prompt, for other doctor screens.
Future<String?> promptText(BuildContext context, String title, String hint, {int maxLength = 2000}) => _prompt(context, title, hint, maxLength: maxLength);
