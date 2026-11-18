import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/presentation/home_labels.dart';
import '../domain/cycle.dart';
import 'cycle_cubit.dart';

Future<void> _sheet(BuildContext context, CycleCubit cubit, Widget child) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: NColors.surfacePage,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(NRadius.xl))),
      builder: (BuildContext sheet) => BlocProvider<CycleCubit>.value(
        value: cubit,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheet).bottom),
          child: SafeArea(
            child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(NSpace.lg, 0, NSpace.lg, NSpace.lg), child: child),
          ),
        ),
      ),
    );

String _fmt(BuildContext context, DateTime d) => DateFormat('EEEE, d MMMM y', Localizations.localeOf(context).toString()).format(d);

Future<DateTime?> _pick(BuildContext context, IsoDate today, DateTime? initial, String help) => showDatePicker(
      context: context,
      initialDate: initial ?? IsoDates.toLocalDate(today),
      firstDate: IsoDates.toLocalDate(today).subtract(const Duration(days: 730)),
      lastDate: IsoDates.toLocalDate(today),
      helpText: help,
    );

Widget _errorLine(String text) => Padding(
      padding: const EdgeInsets.only(top: NSpace.xs),
      child: Semantics(liveRegion: true, child: Text(text, style: NType.bodySm.copyWith(color: NColors.statusAttention))),
    );

// ---------- Log a period ----------

Future<void> showPeriodSheet(BuildContext context, CycleCubit cubit, IsoDate today) => _sheet(context, cubit, _PeriodSheet(today: today));

class _PeriodSheet extends StatefulWidget {
  const _PeriodSheet({required this.today});

  final IsoDate today;

  @override
  State<_PeriodSheet> createState() => _PeriodSheetState();
}

class _PeriodSheetState extends State<_PeriodSheet> {
  DateTime? _start;
  DateTime? _end;
  PeriodError? _error;

  Future<void> _save() async {
    final PeriodSaveResult r = await context.read<CycleCubit>().savePeriod(
          Period(start: IsoDates.format(_start!), end: _end == null ? null : IsoDates.format(_end!)),
        );
    if (!mounted) return;
    if (r.ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _error = r.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(header: true, child: Text(s.cyclePeriodSheetTitle, style: NType.h3.copyWith(color: NColors.inkPrimary))),
        const SizedBox(height: NSpace.md),
        _DateField(
          label: s.cycleStartLabel,
          value: _start == null ? null : _fmt(context, _start!),
          onTap: () async {
            final DateTime? d = await _pick(context, widget.today, _start, s.cycleStartLabel);
            if (d != null) {
              setState(() {
                _start = d;
                _error = null;
              });
            }
          },
        ),
        const SizedBox(height: NSpace.sm),
        _DateField(
          label: s.cycleEndLabel,
          value: _end == null ? null : _fmt(context, _end!),
          onTap: () async {
            final DateTime? d = await _pick(context, widget.today, _end ?? _start, s.cycleEndLabel);
            if (d != null) {
              setState(() {
                _end = d;
                _error = null;
              });
            }
          },
        ),
        if (_error != null) _errorLine(s.periodError(_error!)),
        const SizedBox(height: NSpace.md),
        NPrimaryButton(label: s.cycleSavePeriod, inactiveHint: s.cycleSavePeriodInactive, onPressed: _start == null ? null : _save),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.value, required this.onTap});

  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: value == null ? label : '$label, $value',
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(NRadius.lg),
          child: Container(
            constraints: const BoxConstraints(minHeight: NLayout.minTapTarget + NSpace.sm),
            padding: const EdgeInsets.symmetric(horizontal: NSpace.md, vertical: NSpace.sm),
            decoration: BoxDecoration(
              color: NColors.surfaceCard,
              borderRadius: BorderRadius.circular(NRadius.lg),
              border: Border.all(color: value == null ? NColors.lineDefault : NColors.actionPrimary),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.calendar_today_rounded, color: NColors.actionLink),
                const SizedBox(width: NSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(label, style: NType.label.copyWith(color: NColors.inkMuted)),
                      if (value != null) Text(value!, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

// ---------- Day sheet ----------

Future<void> showDaySheet(BuildContext context, CycleCubit cubit, IsoDate date) => _sheet(context, cubit, _DaySheet(date: date));

class _DaySheet extends StatefulWidget {
  const _DaySheet({required this.date});

  final IsoDate date;

  @override
  State<_DaySheet> createState() => _DaySheetState();
}

class _DaySheetState extends State<_DaySheet> {
  late final TextEditingController _note = TextEditingController();
  PeriodError? _error;
  bool _noteLoaded = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _period(Future<PeriodSaveResult> Function() save) async {
    final PeriodSaveResult r = await save();
    if (mounted) setState(() => _error = r.error);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final IsoDate d = widget.date;
    return BlocBuilder<CycleCubit, CycleState>(
      builder: (BuildContext context, CycleState st) {
        final CycleDocument? doc = st.document;
        if (doc == null) return const SizedBox.shrink();
        final CycleCubit cubit = context.read<CycleCubit>();
        final DailyLog log = doc.logs[d] ?? DailyLog(date: d);
        if (!_noteLoaded) {
          _note.text = log.note ?? '';
          _noteLoaded = true;
        }
        final bool isStart = doc.periods.any((Period p) => p.start == d);
        // A period that started before this day, within 15 days, can be ended here (as on web).
        final List<Period> before = doc.periods.where((Period p) => p.start.compareTo(d) < 0 && IsoDates.daysBetween(p.start, d) <= 15).toList()
          ..sort((Period a, Period b) => a.start.compareTo(b.start));
        final Period? endable = before.isEmpty ? null : before.last;

        Widget chips<T extends Enum>(String title, List<T> options, T? selected, String Function(T) name, DailyLogPatch Function(T) patch) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: NType.label.copyWith(color: NColors.inkMuted)),
                const SizedBox(height: NSpace.xxs),
                Wrap(
                  spacing: NSpace.xs,
                  runSpacing: NSpace.xs,
                  children: <Widget>[
                    for (final T o in options)
                      Semantics(
                        container: true,
                        checked: o == selected,
                        inMutuallyExclusiveGroup: true,
                        label: '$title, ${name(o)}',
                        onTap: () => cubit.saveDailyLog(d, patch(o)),
                        child: ExcludeSemantics(
                          child: ChoiceChip(
                            label: Text(name(o)),
                            selected: o == selected,
                            showCheckmark: false,
                            labelStyle: NType.bodySm.copyWith(
                              color: o == selected ? NColors.actionOnPrimary : NColors.inkPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            selectedColor: NColors.actionPrimary,
                            backgroundColor: NColors.surfaceCard,
                            side: const BorderSide(color: NColors.lineDefault),
                            shape: const StadiumBorder(),
                            onSelected: (_) => cubit.saveDailyLog(d, patch(o)),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: NSpace.md),
              ],
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Semantics(header: true, child: Text(DateFormat('EEEE, d MMMM', Localizations.localeOf(context).toString()).format(IsoDates.toLocalDate(d)), style: NType.h3.copyWith(color: NColors.inkPrimary))),
            const SizedBox(height: NSpace.md),
            if (isStart)
              NSecondaryButton(label: s.cycleRemovePeriod, onPressed: () => cubit.deletePeriod(d))
            else
              NPrimaryButton(label: s.cyclePeriodStartedHere, onPressed: () => _period(() => cubit.savePeriod(Period(start: d)))),
            if (!isStart && endable != null) ...<Widget>[
              const SizedBox(height: NSpace.xs),
              NSecondaryButton(
                label: s.cyclePeriodEndedHere,
                onPressed: () => _period(() => cubit.savePeriod(Period(start: endable.start, end: d), replacing: endable.start)),
              ),
            ],
            if (_error != null) _errorLine(s.periodError(_error!)),
            const SizedBox(height: NSpace.lg),
            chips<PeriodFlow>(s.homeLogFlow, PeriodFlow.values, log.flow, s.flowName, (PeriodFlow v) => DailyLogPatch(flow: v)),
            chips<Mood>(s.homeLogMood, Mood.values, log.mood, s.moodName, (Mood v) => DailyLogPatch(mood: v)),
            chips<Energy>(s.homeLogEnergy, Energy.values, log.energy, s.energyName, (Energy v) => DailyLogPatch(energy: v)),
            TextField(
              controller: _note,
              minLines: 2,
              maxLines: 4,
              maxLength: 280,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: s.cycleNote),
            ),
            const SizedBox(height: NSpace.sm),
            NPrimaryButton(
              label: s.cycleSaveNote,
              inactiveHint: s.cycleSaveNoteInactive,
              onPressed: _note.text.trim().isEmpty ? null : () => cubit.saveDailyLog(d, DailyLogPatch(note: _note.text.trim())),
            ),
          ],
        );
      },
    );
  }
}

// ---------- Your situation ----------

Future<void> showMarkersSheet(BuildContext context, CycleCubit cubit, List<CycleMarker> current) =>
    _sheet(context, cubit, _MarkersSheet(current: current));

class _MarkersSheet extends StatefulWidget {
  const _MarkersSheet({required this.current});

  final List<CycleMarker> current;

  @override
  State<_MarkersSheet> createState() => _MarkersSheetState();
}

class _MarkersSheetState extends State<_MarkersSheet> {
  late final Set<CycleMarker> _chosen = widget.current.toSet();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(header: true, child: Text(s.cycleSituationTitle, style: NType.h3.copyWith(color: NColors.inkPrimary))),
        const SizedBox(height: NSpace.xs),
        Text(s.cycleSituationHint, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
        const SizedBox(height: NSpace.sm),
        for (final CycleMarker m in CycleMarker.values)
          CheckboxListTile(
            value: _chosen.contains(m),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(s.markerName(m), style: NType.body.copyWith(color: NColors.inkPrimary)),
            // Each change saves at once, as on web.
            onChanged: (bool? v) {
              setState(() => v == true ? _chosen.add(m) : _chosen.remove(m));
              context.read<CycleCubit>().setMarkers(<CycleMarker>[for (final CycleMarker x in CycleMarker.values) if (_chosen.contains(x)) x]);
            },
          ),
        const SizedBox(height: NSpace.sm),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(s.homeClose)),
      ],
    );
  }
}
