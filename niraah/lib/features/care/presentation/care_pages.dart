import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../../shared/constants/route_constants.dart';
import '../domain/care.dart';

/// Programs (spec 010 §10 "Programs"): published programs with what each is for and its length, the one her
/// pre-score suggests marked, and her progress. One program at a time (AC37); missed days never reset it.
class ProgramsPage extends StatefulWidget {
  const ProgramsPage({super.key, this.repository});

  final CareRepository? repository;

  @override
  State<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<ProgramsPage> {
  late final CareRepository _repo = widget.repository ?? getIt<CareRepository>();
  late Future<ProgramsDocument> _doc = _repo.programs();
  bool _busy = false;

  void _reload() => setState(() => _doc = _repo.programs());

  Future<void> _run(Future<void> Function() action, String done) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      showNote(context, done);
      _reload();
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _enrol(Program p) async {
    final S s = S.of(context);
    final DateTime today = DateTime.now();
    final DateTime? start = await showDatePicker(
      context: context,
      helpText: s.programsStartOn,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
    );
    if (start == null || !mounted) return;
    String two(int v) => v.toString().padLeft(2, '0');
    await _run(() => _repo.enrol(p.id, startOn: '${start.year}-${two(start.month)}-${two(start.day)}'), s.programsJoined(p.name));
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.programsTitle,
      body: AsyncBody<ProgramsDocument>(
        future: _doc,
        onRetry: _reload,
        builder: (BuildContext context, ProgramsDocument d) {
          final Enrolment? e = d.enrolment;
          return ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              if (e != null) ...<Widget>[
                NCard(
                  color: NColors.brandSageLight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(e.name, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                      const SizedBox(height: NSpace.xxs),
                      Text(e.weeks == null ? s.programsWeek(e.week) : s.programsWeekOf(e.week, e.weeks!), style: NType.body.copyWith(color: NColors.inkSecondary)),
                      Text(s.programsStarted(shortDate(context, e.startedOn)), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                      if (e.paused) Text(s.programsPaused, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                      const SizedBox(height: NSpace.sm),
                      Wrap(
                        spacing: NSpace.xs,
                        children: <Widget>[
                          OutlinedButton(
                            onPressed: _busy ? null : () => _run(() => _repo.setProgramStatus(e.paused ? 'active' : 'paused'), e.paused ? s.programsResumed : s.programsPausedNote),
                            child: Text(e.paused ? s.programsResume : s.programsPause),
                          ),
                          TextButton(onPressed: _busy ? null : () => _run(() => _repo.setProgramStatus('left'), s.programsLeft), child: Text(s.programsLeave)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: NSpace.sm),
              ],
              NSectionTitle(s.programsAll),
              if (d.programs.isEmpty) EmptyNote(text: s.programsEmpty),
              for (Program p in d.programs) ...<Widget>[
                NCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (p.suggested)
                        Container(
                          margin: const EdgeInsets.only(bottom: NSpace.xs),
                          padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: NSpace.xxs),
                          decoration: BoxDecoration(color: NColors.brandApricotLight, borderRadius: BorderRadius.circular(NRadius.pill)),
                          child: Text(s.programsSuggested, style: NType.caption.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                        ),
                      Text(p.name, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)),
                      if (p.weeks != null) Text(s.programsLength(p.weeks!), style: NType.caption.copyWith(color: NColors.inkSecondary)),
                      const SizedBox(height: NSpace.xs),
                      Text(p.description, style: NType.body.copyWith(color: NColors.inkSecondary)),
                      if (e == null) ...<Widget>[
                        const SizedBox(height: NSpace.sm),
                        OutlinedButton(onPressed: _busy ? null : () => _enrol(p), child: Text(s.programsJoin)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: NSpace.sm),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// The care plan (spec 010 §10 "Care plan" and "Daily tasks"): only a plan a doctor signed, with its sections as
/// written; while waiting, what will appear. Today's tasks to tick, and her week as what she did.
class CarePlanPage extends StatefulWidget {
  const CarePlanPage({super.key, this.repository});

  final CareRepository? repository;

  @override
  State<CarePlanPage> createState() => _CarePlanPageState();
}

class _CarePlanPageState extends State<CarePlanPage> {
  late final CareRepository _repo = widget.repository ?? getIt<CareRepository>();
  late Future<(CarePlanDocument, CareTasks?)> _doc = _load();

  Future<(CarePlanDocument, CareTasks?)> _load() async {
    final CarePlanDocument plan = await _repo.carePlan();
    CareTasks? tasks;
    try {
      tasks = await _repo.tasks();
    } on AreaLocked {
      tasks = null;
    }
    return (plan, tasks);
  }

  Future<void> _tick(CareTask t, bool done) async {
    try {
      await _repo.tick(t.id, done);
      if (mounted) setState(() => _doc = _load());
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    }
  }

  static String _kind(S s, String k) => switch (k) {
        'nutrition' => s.careNutrition,
        'movement' => s.careMovement,
        'sleep' => s.careSleep,
        'supplements' => s.careSupplements,
        _ => k,
      };

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.careTitle,
      body: AsyncBody<(CarePlanDocument, CareTasks?)>(
        future: _doc,
        onRetry: () => setState(() => _doc = _load()),
        builder: (BuildContext context, (CarePlanDocument, CareTasks?) d) {
          final (CarePlanDocument doc, CareTasks? tasks) = d;
          final SignedPlan? p = doc.plan;
          return ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              if (p == null)
                EmptyNote(text: doc.waiting ?? s.careNone)
              else ...<Widget>[
                Text(s.careSignedBy(p.doctor ?? s.careYourDoctor, shortDate(context, p.signedOn)), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                for (CarePlanSection sec in p.sections) ...<Widget>[
                  NSectionTitle(_kind(s, sec.kind)),
                  NCard(child: Text(sec.text, style: NType.body.copyWith(color: NColors.inkPrimary))),
                ],
              ],
              if (tasks?.today case final List<CareTask> today) ...<Widget>[
                NSectionTitle(s.careTodayTasks),
                if (today.isEmpty) EmptyNote(text: s.careNoTasks),
                for (CareTask t in today)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: t.done,
                    onChanged: (bool? v) => _tick(t, v ?? false),
                    title: Text(t.title, style: NType.body.copyWith(color: NColors.inkPrimary)),
                  ),
              ],
              if (tasks != null && tasks.week.any((({String date, int done}) d) => d.done > 0)) ...<Widget>[
                NSectionTitle(s.careWeek),
                for (final ({String date, int done}) day in tasks.week)
                  if (day.done > 0) Text(s.careWeekDay(shortDate(context, day.date), day.done), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              ],
              const SizedBox(height: NSpace.lg),
              NSecondaryButton(label: s.checkInsTitle, onPressed: () => context.push(RouteConstants.checkIns)),
              if (doc.history.isNotEmpty) ...<Widget>[
                NSectionTitle(s.careHistory),
                for (final ({String doctor, String signedOn}) h in doc.history)
                  Text(s.careSignedBy(h.doctor.isEmpty ? s.careYourDoctor : h.doctor, shortDate(context, h.signedOn)), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Weekly check-ins (spec 010 §11): this week's questions when one is due, and her trend. A lapsed check-in is
/// simply not offered, never marked missed (AC38).
class CheckInsPage extends StatefulWidget {
  const CheckInsPage({super.key, this.repository});

  final CareRepository? repository;

  @override
  State<CheckInsPage> createState() => _CheckInsPageState();
}

class _CheckInsPageState extends State<CheckInsPage> {
  late final CareRepository _repo = widget.repository ?? getIt<CareRepository>();
  late Future<CheckInsDocument> _doc = _repo.checkIns();
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _waist = TextEditingController();
  final TextEditingController _note = TextEditingController();
  int? _energy;
  int? _cravings;
  bool _saving = false;

  @override
  void dispose() {
    _weight.dispose();
    _waist.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final S s = S.of(context);
    setState(() => _saving = true);
    try {
      await _repo.submitCheckIn(CheckInAnswers(
        weightKg: double.tryParse(_weight.text.trim()),
        waistCm: double.tryParse(_waist.text.trim()),
        energy: _energy,
        cravings: _cravings,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      ));
      if (!mounted) return;
      showNote(context, s.checkInsSaved);
      setState(() => _doc = _repo.checkIns());
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _scale(String label, int? value, ValueChanged<int> onPick) {
    final S s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: NType.body.copyWith(color: NColors.inkPrimary)),
        const SizedBox(height: NSpace.xxs),
        Wrap(
          spacing: NSpace.xs,
          children: <Widget>[
            for (int i = 1; i <= 5; i++) ChoiceChip(label: Text('$i'), selected: value == i, onSelected: (_) => onPick(i), tooltip: s.checkInsScale(i)),
          ],
        ),
        Text(s.checkInsScaleEnds, style: NType.caption.copyWith(color: NColors.inkMuted)),
        const SizedBox(height: NSpace.sm),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.checkInsTitle,
      body: AsyncBody<CheckInsDocument>(
        future: _doc,
        onRetry: () => setState(() => _doc = _repo.checkIns()),
        builder: (BuildContext context, CheckInsDocument d) {
          final CheckInDue? due = d.due;
          return ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              if (due == null)
                EmptyNote(text: s.checkInsNoneDue)
              else ...<Widget>[
                Text(s.checkInsThisWeek(shortDate(context, due.weekStart)), style: NType.h4.copyWith(color: NColors.inkPrimary)),
                const SizedBox(height: NSpace.sm),
                if (due.fields.contains('weight'))
                  TextField(controller: _weight, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: s.checkInsWeight)),
                if (due.fields.contains('waist'))
                  TextField(controller: _waist, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: s.checkInsWaist)),
                const SizedBox(height: NSpace.sm),
                if (due.fields.contains('energy')) _scale(s.checkInsEnergy, _energy, (int v) => setState(() => _energy = v)),
                if (due.fields.contains('cravings')) _scale(s.checkInsCravings, _cravings, (int v) => setState(() => _cravings = v)),
                if (due.fields.contains('note')) TextField(controller: _note, maxLength: 500, maxLines: 3, decoration: InputDecoration(labelText: s.checkInsNote)),
                const SizedBox(height: NSpace.sm),
                NPrimaryButton(label: s.checkInsSubmit, loading: _saving, onPressed: _submit),
              ],
              NSectionTitle(s.checkInsTrend),
              if (d.trend.isEmpty) EmptyNote(text: s.checkInsTrendEmpty),
              for (TrendPoint t in d.trend)
                Padding(
                  padding: const EdgeInsets.only(bottom: NSpace.xs),
                  child: Text(
                    <String>[
                      shortDate(context, t.week),
                      if (t.energy != null) s.checkInsEnergyValue(t.energy!),
                      if (t.cravings != null) s.checkInsCravingsValue(t.cravings!),
                      if (t.weightKg != null) s.checkInsWeightValue(t.weightKg!.toStringAsFixed(1)),
                      if (t.waistCm != null) s.checkInsWaistValue(t.waistCm!.toStringAsFixed(0)),
                    ].join(' · '),
                    style: NType.bodySm.copyWith(color: NColors.inkSecondary),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
