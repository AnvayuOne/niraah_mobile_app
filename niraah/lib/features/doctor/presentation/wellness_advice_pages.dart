import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/clinician_ui.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../provider_work/domain/provider_work.dart';
import '../../provider_work/presentation/provider_work_pages.dart';
import '../domain/doctor_work.dart';
import 'doctor_list_card.dart';

/// Drafts of wellness advice (spec 011 §7 "Writing" 5): listed until signed or discarded. The screen says "Wellness
/// advice", as the member's document does; `prescriptions` is only the API's name.
class AdviceDraftsPage extends StatefulWidget {
  const AdviceDraftsPage({super.key, this.repository});

  final DoctorWorkRepository? repository;

  @override
  State<AdviceDraftsPage> createState() => _AdviceDraftsPageState();
}

class _AdviceDraftsPageState extends State<AdviceDraftsPage> {
  late final DoctorWorkRepository _repo = widget.repository ?? getIt<DoctorWorkRepository>();
  late Future<List<Json>> _list = _repo.prescriptionDrafts();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.drAdviceDrafts,
      body: AsyncBody<List<Json>>(
        future: _list,
        onRetry: () => setState(() => _list = _repo.prescriptionDrafts()),
        builder: (BuildContext context, List<Json> rows) => rows.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(NSpace.md),
                child: Align(alignment: Alignment.topCenter, child: CEmpty(icon: Icons.edit_note_rounded, title: s.drNoDrafts)),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.sm, NSpace.md, NSpace.xl),
                children: <Widget>[
                  DrStagger(
                    children: <Widget>[
                      for (Json d in rows)
                        DrListCard(
                          name: d.str('memberName') ?? '',
                          semanticsLabel: d.str('memberName'),
                          subtitle: s.drUpdated(shortDate(context, d.str('updatedAt') ?? '')),
                          pills: <Widget>[if (d.flag('isCorrection')) CPill(s.drCorrection, tone: CTone.apricot)],
                          onTap: () async {
                            await openAdvice(context, d.str('id')!, repository: _repo);
                            if (mounted) setState(() => _list = _repo.prescriptionDrafts());
                          },
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

Future<void> openAdvice(BuildContext context, String id, {DoctorWorkRepository? repository}) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => AdviceEditorPage(adviceId: id, repository: repository),
  ),
);

/// Starts wellness advice for a consult (spec 011 §7 "Who and when" 2) and opens it.
Future<void> startAdvice(BuildContext context, String appointmentId, {DoctorWorkRepository? repository}) async {
  final DoctorWorkRepository repo = repository ?? getIt<DoctorWorkRepository>();
  try {
    final String id = await repo.createPrescription(appointmentId);
    if (context.mounted) await openAdvice(context, id, repository: repo);
  } on Object catch (e) {
    if (context.mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
  }
}

class _Line {
  _Line({required this.supplementId, required this.label, this.dosePattern = '', this.timing, this.duration = '', this.instructions = ''});

  final String supplementId;
  final String label;
  String dosePattern;
  String? timing;
  String duration;
  String instructions;

  Json toJson() => <String, dynamic>{
    'supplementId': supplementId,
    'dosePattern': dosePattern,
    'timing': timing,
    'duration': duration.isEmpty ? null : duration,
    'instructions': instructions.isEmpty ? null : instructions,
  };
}

/// Writing and signing wellness advice (spec 011 §7): assessment in plain words, supplement lines from the
/// catalogue only, advice, a "see a doctor in person" line, follow-up and tests. Her reported medicines sit beside
/// it. Text that names a medicine or a dose is confirmed before signing (AC43); signing asks for her password and
/// authenticator code again (AC22). Nothing here is suggested by AI.
class AdviceEditorPage extends StatefulWidget {
  const AdviceEditorPage({required this.adviceId, super.key, this.repository, this.providerWork});

  final String adviceId;
  final DoctorWorkRepository? repository;
  final ProviderWorkRepository? providerWork;

  @override
  State<AdviceEditorPage> createState() => _AdviceEditorPageState();
}

class _AdviceEditorPageState extends State<AdviceEditorPage> {
  late final DoctorWorkRepository _repo = widget.repository ?? getIt<DoctorWorkRepository>();
  late final ProviderWorkRepository _work = widget.providerWork ?? getIt<ProviderWorkRepository>();
  late Future<Json> _doc = _repo.prescription(widget.adviceId);
  Future<Json>? _medicines;
  final TextEditingController _assessment = TextEditingController();
  final TextEditingController _advice = TextEditingController();
  final TextEditingController _seeDoctor = TextEditingController();
  final TextEditingController _tests = TextEditingController();
  String? _followUp;
  List<_Line> _lines = <_Line>[];
  bool _filled = false;
  bool _busy = false;

  @override
  void dispose() {
    for (TextEditingController c in <TextEditingController>[_assessment, _advice, _seeDoctor, _tests]) {
      c.dispose();
    }
    super.dispose();
  }

  void _fill(Json d) {
    _filled = true;
    _assessment.text = d.str('assessment') ?? '';
    _advice.text = d.str('advice') ?? '';
    _seeDoctor.text = d.str('seeDoctorLine') ?? '';
    _tests.text = d.strs('testsAdvised').join(', ');
    _followUp = d.str('followUpOn');
    _lines = <_Line>[
      for (Json l in d.objs('lines'))
        _Line(
          supplementId: l.str('supplementId')!,
          label: <String>[?l.str('supplement'), ?l.str('form'), ?l.str('strength')].join(' · '),
          dosePattern: l.str('dosePattern') ?? '',
          timing: l.str('timing'),
          duration: l.str('duration') ?? '',
          instructions: l.str('instructions') ?? '',
        ),
    ];
    _medicines ??= _repo.medicines(d.str('memberId')!);
  }

  Json get _patch => <String, dynamic>{
    'assessment': _assessment.text.trim().isEmpty ? null : _assessment.text.trim(),
    'advice': _advice.text.trim().isEmpty ? null : _advice.text.trim(),
    'seeDoctorLine': _seeDoctor.text.trim().isEmpty ? null : _seeDoctor.text.trim(),
    'followUpOn': _followUp,
    'testsAdvised': _tests.text.split(',').map((String x) => x.trim()).where((String x) => x.isNotEmpty).toList(),
    'lines': <Json>[for (final _Line l in _lines) l.toJson()],
  };

  Future<Json?> _run(Future<Json> Function() action, {String? done}) async {
    setState(() => _busy = true);
    try {
      final Json d = await action();
      if (!mounted) return null;
      setState(() {
        _filled = false;
        _doc = Future<Json>.value(d);
      });
      if (done != null) showNote(context, done);
      return d;
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() => _run(() => _repo.updatePrescription(widget.adviceId, _patch), done: S.of(context).drSaved);

  Future<void> _addLine() async {
    final S s = S.of(context);
    final List<Json> catalogue = await _repo.supplements();
    if (!mounted) return;
    final Json? pick = await showDialog<Json>(
      context: context,
      builder: (BuildContext d) => SimpleDialog(
        title: Text(s.drChooseSupplement),
        children: <Widget>[
          if (catalogue.isEmpty) Padding(padding: const EdgeInsets.all(NSpace.lg), child: Text(s.drNoSupplements)),
          for (Json c in catalogue) SimpleDialogOption(onPressed: () => Navigator.of(d).pop(c), child: Text(<String>[?c.str('name'), ?c.str('form'), ?c.str('strength')].join(' · '))),
        ],
      ),
    );
    if (pick == null || !mounted) return;
    final _Line line = _Line(supplementId: pick.str('id')!, label: <String>[?pick.str('name'), ?pick.str('form'), ?pick.str('strength')].join(' · '));
    if (await _editLine(line)) setState(() => _lines.add(line));
  }

  Future<bool> _editLine(_Line line) async {
    final S s = S.of(context);
    final TextEditingController dose = TextEditingController(text: line.dosePattern);
    final TextEditingController duration = TextEditingController(text: line.duration);
    final TextEditingController instructions = TextEditingController(text: line.instructions);
    String? timing = line.timing;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext d) => StatefulBuilder(
        builder: (BuildContext d, StateSetter set) => AlertDialog(
          title: Text(line.label),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: dose,
                  maxLength: 20,
                  decoration: InputDecoration(labelText: s.drDosePattern, hintText: '1-0-1'),
                ),
                DropdownButton<String?>(
                  value: timing,
                  isExpanded: true,
                  hint: Text(s.drTiming),
                  items: <DropdownMenuItem<String?>>[
                    DropdownMenuItem<String?>(value: 'before_food', child: Text(s.drBeforeFood)),
                    DropdownMenuItem<String?>(value: 'after_food', child: Text(s.drAfterFood)),
                    DropdownMenuItem<String?>(value: 'with_food', child: Text(s.drWithFood)),
                    DropdownMenuItem<String?>(value: 'any_time', child: Text(s.drAnyTime)),
                  ],
                  onChanged: (String? v) => set(() => timing = v),
                ),
                TextField(
                  controller: duration,
                  maxLength: 60,
                  decoration: InputDecoration(labelText: s.drDuration),
                ),
                TextField(
                  controller: instructions,
                  maxLength: 300,
                  decoration: InputDecoration(labelText: s.drInstructions),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(s.commonCancel)),
            FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(s.drSave)),
          ],
        ),
      ),
    );
    if (ok == true) {
      line
        ..dosePattern = dose.text.trim()
        ..timing = timing
        ..duration = duration.text.trim()
        ..instructions = instructions.text.trim();
    }
    dose.dispose();
    duration.dispose();
    instructions.dispose();
    return ok ?? false;
  }

  Future<void> _sign() async {
    final S s = S.of(context);
    // Save first, so what she signs is what she sees.
    final Json? saved = await _run(() => _repo.updatePrescription(widget.adviceId, _patch));
    if (saved == null || !mounted) return;
    final String? proof = await staffCheck(context, _work);
    if (proof == null || !mounted) return;
    await _run(() => _repo.signPrescription(widget.adviceId, proof), done: s.drAdviceSigned);
  }

  Future<void> _discard() async {
    final S s = S.of(context);
    setState(() => _busy = true);
    try {
      await _repo.discardPrescription(widget.adviceId);
      if (!mounted) return;
      showNote(context, s.drDiscarded);
      Navigator.of(context).pop();
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _timing(S s, String? t) => switch (t) {
    'before_food' => s.drBeforeFood,
    'after_food' => s.drAfterFood,
    'with_food' => s.drWithFood,
    'any_time' => s.drAnyTime,
    _ => '',
  };

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.drWellnessAdvice,
      body: AsyncBody<Json>(
        future: _doc,
        onRetry: () => setState(() => _doc = _repo.prescription(widget.adviceId)),
        builder: (BuildContext context, Json d) {
          if (!_filled) _fill(d);
          final bool draft = d.str('status') == 'draft';
          final List<Json> wording = d.objs('wording');
          if (!draft) {
            final List<Json> lines = d.objs('lines');
            return ListView(
              padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl),
              children: <Widget>[
                CHero(
                  eyebrow: s.drWellnessAdvice,
                  title: d.str('memberName') ?? s.drAdviceSignedOn(shortDate(context, d.str('signedAt') ?? '')),
                  subtitle: <String>[
                    if (d.str('memberName') != null) s.drAdviceSignedOn(shortDate(context, d.str('signedAt') ?? '')),
                    if (d.str('verificationCode') != null) s.drVerificationCode(d.str('verificationCode')!),
                  ].join('\n'),
                  trailing: CircleAvatar(radius: 20, backgroundColor: NColors.brandApricot, child: Icon(Icons.verified_rounded, color: NColors.brandPlum)),
                ),
                const SizedBox(height: NSpace.md),
                CPanel(
                  title: s.drAssessment,
                  icon: Icons.assignment_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _ReadOnly(label: s.drAssessment, value: d.str('assessment')),
                      if (lines.isNotEmpty) ...<Widget>[
                        Text(s.drSupplements.toUpperCase(), style: NType.label.copyWith(color: NColors.inkMuted, letterSpacing: 1, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        for (Json l in lines)
                          Padding(
                            padding: const EdgeInsets.only(bottom: NSpace.xs),
                            child: Text('• ${l.str('supplement')} ${l.str('strength') ?? ''} · ${l.str('dosePattern')} · ${_timing(s, l.str('timing'))} · ${l.str('duration') ?? ''}', style: NType.body.copyWith(color: NColors.inkPrimary)),
                          ),
                        const SizedBox(height: NSpace.xs),
                      ],
                      _ReadOnly(label: s.drAdvice, value: d.str('advice')),
                      _ReadOnly(label: s.drSeeDoctorLine, value: d.str('seeDoctorLine')),
                    ],
                  ),
                ),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.lg),
                  children: <Widget>[
                    FutureBuilder<Json>(
                      future: _medicines,
                      builder: (BuildContext context, AsyncSnapshot<Json> snap) {
                        final Json? m = snap.data;
                        if (m == null) return const SizedBox.shrink();
                        final String text = !m.flag('shared')
                            ? s.drMedicinesNotShared
                            : !m.flag('recorded')
                            ? (m.flag('onMedication') ? s.drOnMedicationFlag : s.drMedicinesNotRecorded)
                            : s.drMedicinesReported(m.strs('medicines').join(', '), m.strs('allergies').join(', '));
                        return Padding(
                          padding: const EdgeInsets.only(bottom: NSpace.md),
                          child: DrTextBox(label: s.drMedicinesTitle, text: text, icon: Icons.medication_outlined, color: NColors.brandApricotLight, labelColor: NColors.statusWarningText),
                        );
                      },
                    ),
                    CPanel(
                      title: s.drAssessment,
                      icon: Icons.assignment_outlined,
                      child: TextField(
                        controller: _assessment,
                        minLines: 2,
                        maxLines: 6,
                        maxLength: 2000,
                        decoration: InputDecoration(labelText: s.drAssessment, helperText: s.drAssessmentHelp, helperMaxLines: 3),
                      ),
                    ),
                    const SizedBox(height: NSpace.md),
                    CPanel(
                      title: s.drSupplements,
                      icon: Icons.medication_outlined,
                      note: s.drSupplementsOnly,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          for (final _Line l in _lines)
                            Padding(
                              padding: const EdgeInsets.only(bottom: NSpace.xs),
                              child: CRow(
                                title: l.label,
                                subtitle: <String>[l.dosePattern, _timing(s, l.timing), l.duration].where((String x) => x.isNotEmpty).join(' · '),
                                onTap: () async {
                                  if (await _editLine(l)) setState(() {});
                                },
                                trailing: IconButton(tooltip: s.drRemoveLine, icon: Icon(Icons.close_rounded, size: 20, color: NColors.inkMuted), onPressed: () => setState(() => _lines.remove(l))),
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(onPressed: _lines.length >= 20 ? null : _addLine, icon: const Icon(Icons.add_rounded), label: Text(s.drAddSupplement)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: NSpace.md),
                    CPanel(
                      title: s.drAdvice,
                      icon: Icons.spa_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          TextField(
                            controller: _advice,
                            minLines: 2,
                            maxLines: 8,
                            maxLength: 4000,
                            decoration: InputDecoration(labelText: s.drAdvice),
                          ),
                          const SizedBox(height: NSpace.xs),
                          TextField(
                            controller: _seeDoctor,
                            minLines: 1,
                            maxLines: 3,
                            maxLength: 500,
                            decoration: InputDecoration(labelText: s.drSeeDoctorLine),
                          ),
                          const SizedBox(height: NSpace.xs),
                          TextField(
                            controller: _tests,
                            decoration: InputDecoration(labelText: s.drTestsAdvised, helperText: s.drCommaSeparated),
                          ),
                          const SizedBox(height: NSpace.sm),
                          Container(
                            padding: const EdgeInsets.only(left: NSpace.sm),
                            decoration: BoxDecoration(color: NColors.surfacePage, borderRadius: BorderRadius.circular(NRadius.md)),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.event_outlined, size: 18, color: NColors.brandRosewood),
                                const SizedBox(width: NSpace.xs),
                                Expanded(child: Text(_followUp == null ? s.drNoFollowUp : s.drFollowUpOn(shortDate(context, _followUp!)), style: NType.bodySm.copyWith(color: NColors.inkPrimary))),
                                TextButton(
                                  onPressed: () async {
                                    final DateTime now = DateTime.now();
                                    final DateTime? f = await showDatePicker(context: context, initialDate: now.add(const Duration(days: 30)), firstDate: now, lastDate: now.add(const Duration(days: 365)));
                                    if (f == null) return;
                                    String two(int v) => v.toString().padLeft(2, '0');
                                    setState(() => _followUp = '${f.year}-${two(f.month)}-${two(f.day)}');
                                  },
                                  child: Text(s.drSetFollowUp),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (Json w in wording)
                      if (!w.flag('confirmed'))
                        Padding(
                          padding: const EdgeInsets.only(top: NSpace.md),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(NSpace.sm, NSpace.sm, NSpace.sm, NSpace.xxs),
                            decoration: BoxDecoration(color: NColors.statusWarningLight, borderRadius: BorderRadius.circular(NRadius.lg)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(Icons.warning_amber_rounded, size: 18, color: NColors.statusWarningText),
                                    const SizedBox(width: NSpace.xs),
                                    Expanded(child: Text(s.drWordingCheck(w.str('label') ?? ''), style: NType.bodySm.copyWith(color: NColors.inkPrimary))),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(onPressed: _busy ? null : () => _run(() => _repo.confirmWording(widget.adviceId, w.str('field')!)), child: Text(s.drConfirmOwnDoctor)),
                                ),
                              ],
                            ),
                          ),
                        ),
                    const SizedBox(height: NSpace.sm),
                    Center(child: TextButton(onPressed: _busy ? null : _discard, child: Text(s.drDiscard, style: TextStyle(color: NColors.statusClinicalRedFlag)))),
                  ],
                ),
              ),
              DrStickyBar(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(child: NSecondaryButton(label: s.drSaveDraft, onPressed: _busy ? null : _save)),
                      const SizedBox(width: NSpace.sm),
                      Expanded(child: NPrimaryButton(label: s.drSignAdvice, loading: _busy, onPressed: _sign)),
                    ],
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

class _ReadOnly extends StatelessWidget {
  const _ReadOnly({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) => value == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(bottom: NSpace.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: NType.caption.copyWith(color: NColors.inkMuted)),
              Text(value!, style: NType.body.copyWith(color: NColors.inkPrimary)),
            ],
          ),
        );
}
