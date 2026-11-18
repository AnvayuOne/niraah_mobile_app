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
                padding: const EdgeInsets.all(NSpace.lg),
                child: EmptyNote(text: s.drNoCarePlans),
              )
            : ListView(
                padding: const EdgeInsets.all(NSpace.lg),
                children: <Widget>[
                  for (final Json p in rows) ...<Widget>[
                    NCard(
                      onTap: () => _open(p),
                      semanticsLabel: p.str('member'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            p.str('member') ?? s.drUnnamed,
                            style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            <String>[
                              if (p.str('dueAt') != null) s.drDue(shortDate(context, p.str('dueAt')!)),
                              if (p.flag('claimedByMe')) s.drClaimedByMe else if (p.flag('offeredToMe')) s.drOfferedToMe else s.drSharedQueue,
                              if (p.flag('revision')) s.drRevision,
                              if (p.str('generatedBy') == 'empty') s.drEmptyPlan,
                            ].join(' · '),
                            style: NType.caption.copyWith(color: NColors.inkSecondary),
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
                items: <DropdownMenuItem<String>>[for (final String k in carePlanKinds) DropdownMenuItem<String>(value: k, child: Text(sectionName(s, k)))],
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
      for (final Json x in plan.objs('tasks')) <String, dynamic>{'kind': x.str('kind'), 'title': x.str('title'), 'frequency': x.str('frequency')},
      <String, dynamic>{'kind': kind, 'title': t, 'frequency': frequency},
    ];
    await _apply(() => _repo.setTasks(_id, tasks));
  }

  Future<void> _removeTask(Json plan, Json task) async {
    final List<Json> tasks = <Json>[
      for (final Json x in plan.objs('tasks'))
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
            for (final Json sec in sections) Text('${sectionName(s, sec.str('kind') ?? '')}: ${_decision(s, sec.str('decision'))}'),
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
          final bool allDecided = sections.every((Json x) => x.str('decision') != null);
          final bool oneKept = sections.any((Json x) => x.str('decision') == 'accepted' || x.str('decision') == 'edited');
          final bool dosesConfirmed = sections.every((Json x) => !x.flag('needsDoseConfirmation'));
          return ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              Text(p.str('member') ?? '', style: NType.h3.copyWith(color: NColors.inkPrimary)),
              Text(
                <String>[
                  if (p.str('dueAt') != null) s.drDue(shortDate(context, p.str('dueAt')!)),
                  if (p.str('generatedBy') == 'empty') s.drEmptyPlan,
                  if (!editable) p.str('status') ?? '',
                ].join(' · '),
                style: NType.bodySm.copyWith(color: NColors.inkSecondary),
              ),
              if (p.str('returnNote') != null) Text(s.drReturnNoteWas(p.str('returnNote')!), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              for (final Json sec in sections) ...<Widget>[
                NSectionTitle(sectionName(s, sec.str('kind') ?? '')),
                NCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        s.drAiSuggestion,
                        style: NType.caption.copyWith(color: NColors.inkMuted, fontWeight: FontWeight.w700),
                      ),
                      Text(sec.str('aiSuggestion') ?? s.drNoSuggestion, style: NType.body.copyWith(color: NColors.inkSecondary)),
                      if (sec.str('decision') == 'edited') ...<Widget>[
                        const SizedBox(height: NSpace.xs),
                        Text(
                          s.drYourVersion,
                          style: NType.caption.copyWith(color: NColors.inkMuted, fontWeight: FontWeight.w700),
                        ),
                        Text(sec.str('doctorVersion') ?? '', style: NType.body.copyWith(color: NColors.inkPrimary)),
                      ],
                      if (sec.str('decision') == 'cleared' && sec.str('clearedReason') != null)
                        Text(s.drClearedBecause(sec.str('clearedReason')!), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                      const SizedBox(height: NSpace.xs),
                      Text(
                        _decision(s, sec.str('decision')),
                        style: NType.caption.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
                      ),
                      if (sec.flag('needsDoseConfirmation'))
                        NCard(
                          color: NColors.statusWarningLight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(s.drDoseWarning, style: NType.bodySm.copyWith(color: NColors.inkPrimary)),
                              TextButton(onPressed: _busy ? null : () => _apply(() => _repo.confirmDose(_id, sec.str('kind')!)), child: Text(s.drDoseConfirm)),
                            ],
                          ),
                        ),
                      if (editable)
                        Wrap(
                          spacing: NSpace.xs,
                          children: <Widget>[
                            if (sec.str('aiSuggestion') != null) OutlinedButton(onPressed: _busy ? null : () => _apply(() => _repo.decide(_id, sec.str('kind')!, 'accepted')), child: Text(s.drAccept)),
                            OutlinedButton(onPressed: _busy ? null : () => _edit(sec), child: Text(s.drEdit)),
                            TextButton(onPressed: _busy ? null : () => _clear(sec), child: Text(s.drClear)),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
              NSectionTitle(s.drTasks),
              if (p.objs('tasks').isEmpty) Text(s.drNoTasks, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              for (final Json t in p.objs('tasks'))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.str('title') ?? ''),
                  subtitle: Text('${sectionName(s, t.str('kind') ?? '')} · ${t.str('frequency')}${t.flag('proposedByAi') ? ' · ${s.drProposedByAi}' : ''}'),
                  trailing: editable ? IconButton(tooltip: s.drRemoveTask, icon: const Icon(Icons.close_rounded), onPressed: _busy ? null : () => _removeTask(p, t)) : null,
                ),
              if (editable) TextButton.icon(onPressed: _busy ? null : () => _addTask(p), icon: const Icon(Icons.add_rounded), label: Text(s.drAddTask)),
              const SizedBox(height: NSpace.lg),
              if (editable) ...<Widget>[
                NPrimaryButton(
                  label: s.drSign,
                  loading: _busy,
                  inactiveHint: !allDecided ? s.drDecideAll : (!oneKept ? s.drKeepOne : s.drConfirmDoses),
                  onPressed: allDecided && oneKept && dosesConfirmed ? () => _sign(p) : null,
                ),
                if (p.flag('canReturn')) ...<Widget>[const SizedBox(height: NSpace.xs), NSecondaryButton(label: s.drReturn, onPressed: _busy ? null : _return)],
              ] else if (p.str('status') == 'signed')
                NSecondaryButton(
                  label: s.drRevise,
                  onPressed: _busy ? null : () => _apply(() => _repo.revisePlan(_id), done: s.drRevisionStarted),
                ),
              const SizedBox(height: NSpace.sm),
              Text(p.str('wellnessStatement') ?? '', style: NType.caption.copyWith(color: NColors.inkMuted)),
            ],
          );
        },
      ),
    );
  }
}
