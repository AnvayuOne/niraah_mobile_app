import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/clinician_ui.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../provider_work/domain/provider_work.dart';
import '../domain/doctor_work.dart';
import 'doctor_list_card.dart';
import 'patients_pages.dart';

String sectionName(S s, String k) => switch (k) {
  'nutrition' => s.careNutrition,
  'movement' => s.careMovement,
  'sleep' => s.careSleep,
  'supplements' => s.careSupplements,
  _ => k,
};

/// Care plans waiting for her signature (spec 011 §5 "When a draft exists"): offered to her, claimed by her, or
/// in the shared queue. Opening an unclaimed one claims it.
class CarePlanQueuePage extends StatefulWidget {
  const CarePlanQueuePage({super.key, this.repository});

  final DoctorWorkRepository? repository;

  @override
  State<CarePlanQueuePage> createState() => _CarePlanQueuePageState();
}

class _CarePlanQueuePageState extends State<CarePlanQueuePage> {
  late final DoctorWorkRepository _repo = widget.repository ?? getIt<DoctorWorkRepository>();
  late Future<List<Json>> _list = _repo.carePlanQueue();

  Future<void> _open(Json p) async {
    final S s = S.of(context);
    try {
      if (!p.flag('claimedByMe')) await _repo.claimCarePlan(p.str('id')!);
      if (!mounted) return;
      await context.push('/doctor/care-plans/${p.str('id')}');
      if (mounted) setState(() => _list = _repo.carePlanQueue());
    } on Object catch (e) {
      if (!mounted) return;
      showNote(context, failureText(e, s.commonLoadError));
      setState(() => _list = _repo.carePlanQueue());
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.drCarePlans,
      body: AsyncBody<List<Json>>(
        future: _list,
        onRetry: () => setState(() => _list = _repo.carePlanQueue()),
        builder: (BuildContext context, List<Json> rows) => rows.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(NSpace.md),
                child: Align(alignment: Alignment.topCenter, child: CEmpty(icon: Icons.assignment_turned_in_outlined, title: s.drNoCarePlans)),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.sm, NSpace.md, NSpace.xl),
                children: <Widget>[
                  DrStagger(
                    children: <Widget>[
                      for (Json p in rows)
                        DrListCard(
                          name: p.str('member') ?? s.drUnnamed,
                          semanticsLabel: p.str('member'),
                          onTap: () => _open(p),
                          accent: p.flag('claimedByMe') ? NColors.roleDoctor : null,
                          subtitle: p.str('dueAt') != null ? s.drDue(shortDate(context, p.str('dueAt')!)) : null,
                          pills: <Widget>[
                            if (p.flag('claimedByMe'))
                              CPill(s.drClaimedByMe, tone: CTone.plum)
                            else if (p.flag('offeredToMe'))
                              CPill(s.drOfferedToMe, tone: CTone.apricot)
                            else
                              CPill(s.drSharedQueue),
                            if (p.flag('revision')) CPill(s.drRevision, tone: CTone.lavender),
                            if (p.str('generatedBy') == 'empty') CPill(s.drEmptyPlan, tone: CTone.rose),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

/// Review and sign (spec 011 §5 "The review screen", "Signing"): for each section the AI's suggestion, never
/// changed, and her decision: accept, edit or clear. Dose-like text is confirmed; tasks are set; a plan can be
/// returned once; signing needs every section decided and one kept.
class CarePlanReviewPage extends StatefulWidget {
  const CarePlanReviewPage({required this.planId, super.key, this.repository});

  final String planId;
  final DoctorWorkRepository? repository;

  @override
  State<CarePlanReviewPage> createState() => _CarePlanReviewPageState();
}

class _CarePlanReviewPageState extends State<CarePlanReviewPage> {
  late final DoctorWorkRepository _repo = widget.repository ?? getIt<DoctorWorkRepository>();

  /// Return and revise answer with a new plan; the page follows it.
  late String _id = widget.planId;
  late Future<Json> _plan = _repo.carePlan(_id);
  bool _busy = false;

  Future<void> _apply(Future<Json> Function() action, {String? done}) async {
    setState(() => _busy = true);
    try {
      final Json p = await action();
      if (!mounted) return;
      setState(() {
        _id = p.str('id') ?? _id;
        _plan = Future<Json>.value(p);
      });
      if (done != null) showNote(context, done);
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit(Json sec) async {
    final S s = S.of(context);
    final TextEditingController c = TextEditingController(text: sec.str('doctorVersion') ?? sec.str('aiSuggestion') ?? '');
    final String? text = await showDialog<String>(
      context: context,
      builder: (BuildContext d) => AlertDialog(
        title: Text(sectionName(s, sec.str('kind') ?? '')),
        content: TextField(controller: c, autofocus: true, minLines: 4, maxLines: 12, maxLength: 1200),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(d).pop(), child: Text(s.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(d).pop(c.text.trim()), child: Text(s.drSave)),
        ],
      ),
    );
    c.dispose();
    if (text == null || text.isEmpty) return;
    await _apply(() => _repo.decide(_id, sec.str('kind')!, 'edited', text: text));
  }

  Future<void> _clear(Json sec) async {
    final S s = S.of(context);
    final String? reason = await promptText(context, s.drClearSection, s.drClearReason, maxLength: 300);
    await _apply(() => _repo.decide(_id, sec.str('kind')!, 'cleared', reason: reason));
  }

  Future<void> _addTask(Json plan) async {
    final S s = S.of(context);
    String kind = carePlanKinds.first;
    String frequency = 'daily';
    final TextEditingController title = TextEditingController();
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext d) => StatefulBuilder(
        builder: (BuildContext d, StateSetter set) => AlertDialog(
          title: Text(s.drAddTask),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: title,
                autofocus: true,
                maxLength: 120,
                decoration: InputDecoration(labelText: s.drTaskTitle),
              ),
              DropdownButton<String>(
                value: kind,
                isExpanded: true,
                items: <DropdownMenuItem<String>>[for (String k in carePlanKinds) DropdownMenuItem<String>(value: k, child: Text(sectionName(s, k)))],
                onChanged: (String? v) => set(() => kind = v ?? kind),
              ),
              DropdownButton<String>(
                value: frequency,
                isExpanded: true,
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(value: 'daily', child: Text(s.drDaily)),
                  DropdownMenuItem<String>(value: 'weekdays', child: Text(s.drWeekdays)),
                  DropdownMenuItem<String>(value: 'weekly', child: Text(s.drWeekly)),
                ],
                onChanged: (String? v) => set(() => frequency = v ?? frequency),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(s.commonCancel)),
            FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(s.drSave)),
          ],
        ),
      ),
    );
    final String t = title.text.trim();
    title.dispose();
    if (ok != true || t.isEmpty) return;
    final List<Json> tasks = <Json>[
      for (Json x in plan.objs('tasks')) <String, dynamic>{'kind': x.str('kind'), 'title': x.str('title'), 'frequency': x.str('frequency')},
      <String, dynamic>{'kind': kind, 'title': t, 'frequency': frequency},
    ];
    await _apply(() => _repo.setTasks(_id, tasks));
  }

  Future<void> _removeTask(Json plan, Json task) async {
    final List<Json> tasks = <Json>[
      for (Json x in plan.objs('tasks'))
        if (x.str('id') != task.str('id')) <String, dynamic>{'kind': x.str('kind'), 'title': x.str('title'), 'frequency': x.str('frequency')},
    ];
    await _apply(() => _repo.setTasks(_id, tasks));
  }

  Future<void> _return() async {
    final S s = S.of(context);
    final String? note = await promptText(context, s.drReturn, s.drReturnHint, maxLength: 1000);
    if (note == null) return;
    await _apply(() => _repo.returnPlan(_id, note), done: s.drReturned);
  }

  Future<void> _sign(Json plan) async {
    final S s = S.of(context);
    final List<Json> sections = plan.objs('sections');
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext d) => AlertDialog(
        title: Text(s.drSignTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (Json sec in sections) Text('${sectionName(s, sec.str('kind') ?? '')}: ${_decision(s, sec.str('decision'))}'),
            const SizedBox(height: NSpace.sm),
            Text(plan.str('wellnessStatement') ?? '', style: NType.caption.copyWith(color: NColors.inkMuted)),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(s.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(s.drSign)),
        ],
      ),
    );
    if (ok != true) return;
    await _apply(() => _repo.signPlan(_id), done: s.drSigned);
  }

  String _decision(S s, String? d) => switch (d) {
    'accepted' => s.drAccepted,
    'edited' => s.drEdited,
    'cleared' => s.drCleared,
    _ => s.drUndecided,
  };

  IconData _icon(String? k) => switch (k) {
    'nutrition' => Icons.restaurant_outlined,
    'movement' => Icons.directions_walk_rounded,
    'sleep' => Icons.bedtime_outlined,
    'supplements' => Icons.medication_outlined,
    _ => Icons.notes_rounded,
  };

  CTone _tone(String? d) => switch (d) {
    'accepted' => CTone.sage,
    'edited' => CTone.lavender,
    'cleared' => CTone.quiet,
    _ => CTone.apricot,
  };

  Widget _section(S s, Json sec, bool editable, int i) {
    final String? decision = sec.str('decision');
    final String kind = sec.str('kind') ?? '';
    return Padding(
      padding: const EdgeInsets.only(top: NSpace.md),
      child: CEntrance(
        delayMs: 60 * i,
        child: CPanel(
          title: sectionName(s, kind),
          icon: _icon(kind),
          action: CPill(_decision(s, decision), tone: _tone(decision)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Opacity(
                opacity: decision == 'cleared' || decision == 'edited' ? 0.75 : 1,
                child: DrTextBox(label: s.drAiSuggestion, text: sec.str('aiSuggestion') ?? s.drNoSuggestion, icon: Icons.auto_awesome_outlined, textColor: NColors.inkSecondary),
              ),
              if (decision == 'edited') ...<Widget>[
                const SizedBox(height: NSpace.xs),
                DrTextBox(label: s.drYourVersion, text: sec.str('doctorVersion') ?? '', icon: Icons.edit_outlined, color: NColors.brandBlushLight, labelColor: NColors.brandRosewood),
              ],
              if (decision == 'cleared' && sec.str('clearedReason') != null) ...<Widget>[
                const SizedBox(height: NSpace.xs),
                Text(s.drClearedBecause(sec.str('clearedReason')!), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              ],
              if (sec.flag('needsDoseConfirmation')) ...<Widget>[
                const SizedBox(height: NSpace.xs),
                Container(
                  padding: const EdgeInsets.fromLTRB(NSpace.sm, NSpace.sm, NSpace.sm, NSpace.xxs),
                  decoration: BoxDecoration(color: NColors.statusWarningLight, borderRadius: BorderRadius.circular(NRadius.md)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(Icons.warning_amber_rounded, size: 18, color: NColors.statusWarningText),
                          const SizedBox(width: NSpace.xs),
                          Expanded(child: Text(s.drDoseWarning, style: NType.bodySm.copyWith(color: NColors.inkPrimary))),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(onPressed: _busy ? null : () => _apply(() => _repo.confirmDose(_id, sec.str('kind')!)), child: Text(s.drDoseConfirm)),
                      ),
                    ],
                  ),
                ),
              ],
              if (editable) ...<Widget>[
                const SizedBox(height: NSpace.sm),
                Wrap(
                  spacing: NSpace.xs,
                  runSpacing: NSpace.xs,
                  children: <Widget>[
                    if (sec.str('aiSuggestion') != null)
                      _DecisionChip(label: s.drAccept, icon: Icons.check_rounded, selected: decision == 'accepted', onTap: _busy ? null : () => _apply(() => _repo.decide(_id, sec.str('kind')!, 'accepted'))),
                    _DecisionChip(label: s.drEdit, icon: Icons.edit_outlined, selected: decision == 'edited', onTap: _busy ? null : () => _edit(sec)),
                    _DecisionChip(label: s.drClear, icon: Icons.block_rounded, selected: decision == 'cleared', onTap: _busy ? null : () => _clear(sec)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.drCarePlan,
      body: AsyncBody<Json>(
        future: _plan,
        onRetry: () => setState(() => _plan = _repo.carePlan(_id)),
        builder: (BuildContext context, Json p) {
          final bool editable = p.str('status') == 'in_review';
          final List<Json> sections = p.objs('sections');
          final int decided = sections.where((Json x) => x.str('decision') != null).length;
          final bool allDecided = decided == sections.length;
          final bool oneKept = sections.any((Json x) => x.str('decision') == 'accepted' || x.str('decision') == 'edited');
          final bool dosesConfirmed = sections.every((Json x) => !x.flag('needsDoseConfirmation'));
          final List<Json> tasks = p.objs('tasks');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.lg),
                  children: <Widget>[
                    CHero(
                      eyebrow: s.drCarePlan,
                      title: p.str('member') ?? '',
                      subtitle: <String>[
                        if (p.str('dueAt') != null) s.drDue(shortDate(context, p.str('dueAt')!)),
                        if (p.str('generatedBy') == 'empty') s.drEmptyPlan,
                        if (!editable) p.str('status') ?? '',
                      ].join(' · '),
                      trailing: CAvatar(name: p.str('member'), size: 44),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                '$decided/${sections.length}',
                                style: NType.h2.copyWith(color: NColors.inkPrimary, fontFamily: NType.body.fontFamily, fontWeight: FontWeight.w700, height: 1, fontFeatures: const <FontFeature>[FontFeature.tabularFigures()]),
                              ),
                              const SizedBox(width: NSpace.sm),
                              Expanded(child: Text(s.drDecidedCount(decided, sections.length), style: NType.bodySm.copyWith(color: NColors.inkSecondary))),
                            ],
                          ),
                          const SizedBox(height: NSpace.xs),
                          CBar(value: sections.isEmpty ? 0 : decided / sections.length, color: NColors.brandApricot, height: 6),
                        ],
                      ),
                    ),
                    if (p.str('returnNote') != null) ...<Widget>[
                      const SizedBox(height: NSpace.md),
                      DrTextBox(label: s.drReturn, text: s.drReturnNoteWas(p.str('returnNote')!), icon: Icons.undo_rounded, color: NColors.brandApricotLight, labelColor: NColors.statusWarningText),
                    ],
                    for (int i = 0; i < sections.length; i++) _section(s, sections[i], editable, i),
                    const SizedBox(height: NSpace.md),
                    CPanel(
                      title: s.drTasks,
                      icon: Icons.checklist_rounded,
                      action: editable ? TextButton.icon(onPressed: _busy ? null : () => _addTask(p), icon: const Icon(Icons.add_rounded, size: 18), label: Text(s.drAddTask)) : null,
                      child: tasks.isEmpty
                          ? Text(s.drNoTasks, style: NType.bodySm.copyWith(color: NColors.inkMuted))
                          : Column(
                              children: <Widget>[
                                for (int i = 0; i < tasks.length; i++)
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: NSpace.xs),
                                    decoration: BoxDecoration(border: i == 0 ? null : Border(top: BorderSide(color: NColors.lineDefault))),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(color: NColors.brandBlushLight, borderRadius: BorderRadius.circular(NRadius.sm)),
                                          child: Icon(_icon(tasks[i].str('kind')), size: 16, color: NColors.brandRosewood),
                                        ),
                                        const SizedBox(width: NSpace.sm),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(tasks[i].str('title') ?? '', style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                                              Text(
                                                '${sectionName(s, tasks[i].str('kind') ?? '')} · ${tasks[i].str('frequency')}${tasks[i].flag('proposedByAi') ? ' · ${s.drProposedByAi}' : ''}',
                                                style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (editable) IconButton(tooltip: s.drRemoveTask, icon: Icon(Icons.close_rounded, size: 20, color: NColors.inkMuted), onPressed: _busy ? null : () => _removeTask(p, tasks[i])),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: NSpace.md),
                    Text(p.str('wellnessStatement') ?? '', style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0)),
                  ],
                ),
              ),
              if (editable)
                DrStickyBar(
                  children: <Widget>[
                    NPrimaryButton(
                      label: s.drSign,
                      loading: _busy,
                      inactiveHint: !allDecided ? s.drDecideAll : (!oneKept ? s.drKeepOne : s.drConfirmDoses),
                      onPressed: allDecided && oneKept && dosesConfirmed ? () => _sign(p) : null,
                    ),
                    if (p.flag('canReturn')) TextButton(onPressed: _busy ? null : _return, child: Text(s.drReturn)),
                  ],
                )
              else if (p.str('status') == 'signed')
                DrStickyBar(
                  children: <Widget>[
                    NSecondaryButton(
                      label: s.drRevise,
                      onPressed: _busy ? null : () => _apply(() => _repo.revisePlan(_id), done: s.drRevisionStarted),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Accept, edit or clear: a pill that shows which one she chose.
class _DecisionChip extends StatelessWidget {
  const _DecisionChip({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: selected ? NColors.roleDoctor : NColors.surfaceCard,
          shape: StadiumBorder(side: BorderSide(color: selected ? NColors.roleDoctor : NColors.lineStrong)),
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: Container(
              constraints: const BoxConstraints(minHeight: NLayout.minTapTarget),
              padding: const EdgeInsets.symmetric(horizontal: NSpace.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(icon, size: 16, color: selected ? NColors.brandApricot : NColors.inkSecondary),
                  const SizedBox(width: 6),
                  Text(label, style: NType.bodySm.copyWith(color: selected ? Colors.white : NColors.inkPrimary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      );
}
