import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../provider_work/domain/provider_work.dart';
import '../domain/doctor_work.dart';
import 'doctor_shell.dart';
import 'json_view.dart';

String relationshipName(S s, String? k) => switch (k) {
  'dedicated' => s.drRelDedicated,
  'consult' => s.drRelConsult,
  'review' => s.drRelReview,
  _ => k ?? '',
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

  Future<List<Json>> _load() => _repo.patients(PatientFilters(search: _search.text, kind: _kind, openAlert: _openAlert ? true : null, planAwaiting: _planAwaiting ? true : null, past: _past));

  void _reload() => setState(() => _list = _load());

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return DoctorShell(
      index: 1,
      title: s.pvShellPatients,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.sm, NSpace.lg, 0),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _reload(),
              decoration: InputDecoration(labelText: s.drSearchName, prefixIcon: const Icon(Icons.search_rounded)),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: NSpace.lg, vertical: NSpace.xs),
            child: Row(
              children: <Widget>[
                FilterChip(
                  label: Text(s.drPast),
                  selected: _past,
                  onSelected: (bool v) => setState(() {
                    _past = v;
                    _list = _load();
                  }),
                ),
                const SizedBox(width: NSpace.xs),
                for (final String k in const <String>['dedicated', 'consult', 'review']) ...<Widget>[
                  FilterChip(
                    label: Text(relationshipName(s, k)),
                    selected: _kind == k,
                    onSelected: (bool v) => setState(() {
                      _kind = v ? k : null;
                      _list = _load();
                    }),
                  ),
                  const SizedBox(width: NSpace.xs),
                ],
                FilterChip(
                  label: Text(s.drOpenAlert),
                  selected: _openAlert,
                  onSelected: (bool v) => setState(() {
                    _openAlert = v;
                    _list = _load();
                  }),
                ),
                const SizedBox(width: NSpace.xs),
                FilterChip(
                  label: Text(s.drPlanAwaiting),
                  selected: _planAwaiting,
                  onSelected: (bool v) => setState(() {
                    _planAwaiting = v;
                    _list = _load();
                  }),
                ),
              ],
            ),
          ),
          Expanded(
            child: AsyncBody<List<Json>>(
              future: _list,
              onRetry: _reload,
              builder: (BuildContext context, List<Json> rows) => rows.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(NSpace.lg),
                      child: EmptyNote(text: _past ? s.drNoPastPatients : s.drNoPatients),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(NSpace.lg),
                      itemCount: rows.length,
                      separatorBuilder: (_, _) => const SizedBox(height: NSpace.xs),
                      itemBuilder: (BuildContext context, int i) {
                        final Json p = rows[i];
                        final String meta = <String>[
                          ?p.str('ageBand'),
                          relationshipName(s, p.str('relationship')),
                          ?p.str('plan'),
                          if (p.str('nextAppointment') != null) s.drNext(shortDate(context, p.str('nextAppointment')!)),
                        ].where((String x) => x.isNotEmpty).join(' · ');
                        return NCard(
                          semanticsLabel: '${p.str('name') ?? ''}, $meta',
                          onTap: () => context.push('/doctor/patients/${p.str('id')}'),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      p.str('name') ?? s.drUnnamed,
                                      style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
                                    ),
                                    Text(meta, style: NType.caption.copyWith(color: NColors.inkSecondary)),
                                  ],
                                ),
                              ),
                              if (p.flag('openAlert'))
                                Tooltip(
                                  message: s.drOpenAlert,
                                  child: const Icon(Icons.notification_important_outlined, color: NColors.statusClinicalRedFlag),
                                ),
                              if (p.flag('carePlanAwaiting'))
                                Tooltip(
                                  message: s.drPlanAwaiting,
                                  child: const Icon(Icons.assignment_late_outlined, color: NColors.inkSecondary),
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

/// One member, everything the doctor may see (spec 011 §3): the header with the consent tag and flags, then the
/// sections as a tab strip. A section without consent says "She has not shared this" and shows nothing (AC3).
class PatientPage extends StatefulWidget {
  const PatientPage({required this.memberId, super.key, this.repository});

  final String memberId;
  final DoctorWorkRepository? repository;

  @override
  State<PatientPage> createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  late final DoctorWorkRepository _repo = widget.repository ?? getIt<DoctorWorkRepository>();
  late Future<Json> _header = _repo.patient(widget.memberId);

  String _section(S s, String k) => switch (k) {
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
                _Summary(header: h, repo: _repo),
                for (final String k in sections) _Section(memberId: widget.memberId, section: k, repo: _repo, past: h.flag('past')),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The header and the clinician brief (spec 011 §3 "Header", §8).
class _Summary extends StatefulWidget {
  const _Summary({required this.header, required this.repo});

  final Json header;
  final DoctorWorkRepository repo;

  @override
  State<_Summary> createState() => _SummaryState();
}

class _SummaryState extends State<_Summary> {
  Future<Json>? _brief;

  String _category(S s, String c) => switch (c) {
    'assessment' => s.drSecAssessment,
    'cycle_symptoms' => s.drSecCycle,
    'meals' => s.drSecMeals,
    'lab_reports' => s.drSecLabs,
    'messages' => s.drMessages,
    _ => humanise(c),
  };

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Json h = widget.header;
    return ListView(
      padding: const EdgeInsets.all(NSpace.lg),
      children: <Widget>[
        Text(
          <String>[?h.str('ageBand'), ?h.str('plan'), if (h.str('relationship') != null) relationshipName(s, h.str('relationship')), if (h.flag('past')) s.drPastPatient].join(' · '),
          style: NType.bodySm.copyWith(color: NColors.inkSecondary),
        ),
        if (h.str('dedicatedDietitian') != null) Text(s.drDietitian(h.str('dedicatedDietitian')!), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
        NSectionTitle(s.drConsent),
        Wrap(
          spacing: NSpace.xs,
          runSpacing: NSpace.xs,
          children: <Widget>[
            for (final Json c in h.objs('consent'))
              Chip(
                avatar: Icon(c.flag('shared') ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 16),
                label: Text('${_category(s, c.str('category') ?? '')}: ${c.flag('shared') ? s.drConsentView : s.drConsentNone}'),
              ),
          ],
        ),
        if (h.objs('flags').isNotEmpty) ...<Widget>[
          NSectionTitle(s.drFlags),
          Wrap(
            spacing: NSpace.xs,
            children: <Widget>[for (final Json f in h.objs('flags')) Chip(label: Text('${f.str('name')} · ${f.str('severity')}'))],
          ),
        ],
        if (!h.flag('past')) ...<Widget>[
          NSectionTitle(s.drBrief),
          if (_brief == null)
            NSecondaryButton(label: s.drBriefOpen, onPressed: () => setState(() => _brief = widget.repo.brief(h.str('id')!)))
          else
            FutureBuilder<Json>(
              future: _brief,
              builder: (BuildContext context, AsyncSnapshot<Json> snap) {
                if (snap.hasError) return Text(failureText(snap.error!, s.commonLoadError), style: NType.bodySm.copyWith(color: NColors.inkSecondary));
                if (!snap.hasData) return Text(s.loading);
                final Json b = snap.data!;
                return NCard(
                  color: NColors.brandLavenderLight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        b.str('label') ?? '',
                        style: NType.caption.copyWith(color: NColors.inkSecondary, fontWeight: FontWeight.w700),
                      ),
                      for (final Json p in b.objs('points'))
                        Padding(
                          padding: const EdgeInsets.only(top: NSpace.xxs),
                          child: Text('• ${p.str('text')} (${humanise(p.str('section') ?? '')})'),
                        ),
                      JsonView(data: b.obj('facts')),
                      if (b.strs('notShared').isNotEmpty)
                        Text(s.drNotShared(b.strs('notShared').map((String c) => _category(s, c)).join(', ')), style: NType.caption.copyWith(color: NColors.inkMuted)),
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
                for (final Json t in tests)
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
          return Padding(
            padding: const EdgeInsets.all(NSpace.lg),
            child: EmptyNote(text: s.drNotSharedSection),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(NSpace.lg),
          children: <Widget>[
            if (widget.section == 'notes' && !widget.past) ...<Widget>[NSecondaryButton(label: s.drAddNote, onPressed: _addNote), const SizedBox(height: NSpace.sm)],
            if (widget.section == 'labs') ...<Widget>[NSecondaryButton(label: s.drRecommendTests, onPressed: _recommend), const SizedBox(height: NSpace.sm)],
            if (widget.section == 'care_plan')
              for (final Json p in d.objs('plans'))
                if (p.str('status') == 'in_review')
                  Padding(
                    padding: const EdgeInsets.only(bottom: NSpace.xs),
                    child: OutlinedButton(onPressed: () => context.push('/doctor/care-plans/${p.str('id')}'), child: Text(s.drOpenDraft)),
                  ),
            JsonView(data: d, skip: const <String>{'section', 'shared'}),
          ],
        );
      },
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
