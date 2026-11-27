import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/constants/route_constants.dart';
import '../../cycle/domain/cycle.dart';
import '../../cycle/presentation/advice_card_view.dart';
import '../../home/presentation/home_labels.dart';
import '../domain/symptoms.dart';
import 'symptoms_cubit.dart';

/// The symptom tracker (spec 010 §4), mirroring
/// apps/web/src/app/(member)/cycle/symptoms/symptoms-screen.tsx. Severity is
/// hers to judge; nothing grades it.
class SymptomsPage extends StatelessWidget {
  const SymptomsPage({super.key, this.cubit});

  /// For tests and screenshots.
  final SymptomsCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final SymptomsCubit? given = cubit;
    return given != null
        ? BlocProvider<SymptomsCubit>.value(value: given, child: const _SymptomsView())
        : BlocProvider<SymptomsCubit>(create: (_) => SymptomsCubit(getIt<SymptomsRepository>())..load(), child: const _SymptomsView());
  }
}

class _SymptomsView extends StatelessWidget {
  const _SymptomsView();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<SymptomsCubit, SymptomsState>(
      builder: (BuildContext context, SymptomsState st) {
        final SymptomsDocument? doc = st.document;
        final Widget body = st.status == SymptomsStatus.failure
            ? ErrorView(message: s.commonLoadError, retryLabel: s.tryAgain, onRetry: context.read<SymptomsCubit>().load)
            : doc == null
                ? LoadingView(label: s.loadSymptoms, kind: NLoaderKind.symptoms)
                : _content(context, s, doc);
        return Scaffold(backgroundColor: NColors.surfacePage, body: SafeArea(child: body));
      },
    );
  }

  Widget _content(BuildContext context, S s, SymptomsDocument doc) {
    final String locale = Localizations.localeOf(context).toString();
    Widget chips(List<SymptomRef> list) => Wrap(
          spacing: NSpace.xs,
          runSpacing: NSpace.xs,
          children: <Widget>[
            for (SymptomRef r in list)
              ActionChip(
                label: Text(r.name),
                labelStyle: NType.bodySm.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w500),
                backgroundColor: NColors.surfaceCard,
                side: BorderSide(color: NColors.lineDefault),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: NSpace.xs),
                onPressed: () => showSymptomSheet(context, context.read<SymptomsCubit>(), r, doc),
              ),
          ],
        );
    Widget heading(String t) => Padding(
          padding: const EdgeInsets.only(bottom: NSpace.sm),
          child: Semantics(header: true, child: Text(t, style: NType.h4.copyWith(color: NColors.inkPrimary))),
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.sm, NSpace.lg, NSpace.xl),
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => context.canPop() ? context.pop() : context.go(RouteConstants.cycle),
            icon: Icon(Icons.arrow_back_rounded, color: NColors.inkMuted),
            label: Text(s.symptomsBack, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
          ),
        ),
        Semantics(header: true, child: Text(s.symptomsTitle, style: NType.h2.copyWith(color: NColors.inkPrimary))),
        const SizedBox(height: NSpace.xxs),
        Text(s.symptomsPick, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
        const SizedBox(height: NSpace.lg),
        if (doc.frequent.isNotEmpty) ...<Widget>[heading(s.symptomsFrequent), chips(doc.frequent), const SizedBox(height: NSpace.lg)],
        for (SymptomCategory c in doc.categories) ...<Widget>[heading(c.name), chips(c.symptoms), const SizedBox(height: NSpace.lg)],
        heading(s.symptomsHistoryTitle),
        if (doc.history.isEmpty)
          Text(s.symptomsHistoryEmpty, style: NType.bodySm.copyWith(color: NColors.inkMuted))
        else
          for (SymptomHistoryEntry h in doc.history)
            Container(
              margin: const EdgeInsets.only(bottom: NSpace.xs),
              padding: const EdgeInsets.symmetric(horizontal: NSpace.md, vertical: NSpace.sm),
              decoration: BoxDecoration(color: NColors.surfaceCard, borderRadius: BorderRadius.circular(NRadius.lg), boxShadow: NShadow.xs),
              child: MergeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(s.symptomsHistoryRow(h.symptom.name, h.severity), style: NType.body.copyWith(color: NColors.inkPrimary)),
                    Text(
                      <String>[
                        DateFormat('d MMM', locale).format(IsoDates.toLocalDate(h.date)),
                        if (h.phase != null) s.symptomsPhaseOnDay(s.phaseName(h.phase!)),
                      ].join(' · '),
                      style: NType.label.copyWith(color: NColors.inkMuted),
                    ),
                    if (h.note != null) Text(h.note!, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

Future<void> showSymptomSheet(BuildContext context, SymptomsCubit cubit, SymptomRef symptom, SymptomsDocument doc) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: NColors.surfacePage,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(NRadius.xl))),
      builder: (BuildContext sheet) => BlocProvider<SymptomsCubit>.value(
        value: cubit,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheet).bottom),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(NSpace.lg, 0, NSpace.lg, NSpace.lg),
              child: SymptomSheet(symptom: symptom, low: doc.severityLow, high: doc.severityHigh),
            ),
          ),
        ),
      ),
    );

class SymptomSheet extends StatefulWidget {
  const SymptomSheet({required this.symptom, required this.low, required this.high, super.key});

  final SymptomRef symptom;
  final String low;
  final String high;

  @override
  State<SymptomSheet> createState() => _SymptomSheetState();
}

class _SymptomSheetState extends State<SymptomSheet> {
  int _severity = 5;
  final TextEditingController _note = TextEditingController();
  AdviceCard? _advice;
  bool _refused = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final S s = S.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final SymptomLogResult r = await context.read<SymptomsCubit>().log(widget.symptom.key, _severity, _note.text);
    if (!mounted) return;
    if (!r.ok) {
      setState(() => _refused = r.error == SymptomLogError.severity);
      return;
    }
    if (r.advice != null) {
      // Red-flag advice is shown at once, in place of closing (spec 010 §4.4, AC17).
      setState(() => _advice = r.advice);
    } else {
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(s.symptomsSaved(widget.symptom.name))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<Widget> children = <Widget>[
      Semantics(header: true, child: Text(widget.symptom.name, style: NType.h3.copyWith(color: NColors.inkPrimary))),
      const SizedBox(height: NSpace.md),
    ];
    if (_advice != null) {
      children.addAll(<Widget>[
        Semantics(liveRegion: true, child: Text(s.symptomsSaved(widget.symptom.name), style: NType.bodySm.copyWith(color: NColors.inkMuted))),
        const SizedBox(height: NSpace.md),
        AdviceCardView(card: _advice!),
        const SizedBox(height: NSpace.md),
        NPrimaryButton(label: s.symptomsDone, onPressed: () => Navigator.of(context).pop()),
      ]);
    } else {
      children.addAll(<Widget>[
        Text(s.symptomsSeverityLabel, style: NType.label.copyWith(color: NColors.inkSecondary)),
        const SizedBox(height: NSpace.xs),
        ExcludeSemantics(
          child: Text(s.symptomsSeverityValue(_severity), textAlign: TextAlign.center, style: NType.h3.copyWith(color: NColors.inkPrimary)),
        ),
        Slider(
          value: _severity.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: s.symptomsSeverityValue(_severity),
          activeColor: NColors.actionPrimary,
          inactiveColor: NColors.lineStrong,
          semanticFormatterCallback: (double v) => s.symptomsSeverityValue(v.round()),
          onChanged: (double v) => setState(() {
            _severity = v.round();
            _refused = false;
          }),
        ),
        ExcludeSemantics(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(widget.low, style: NType.label.copyWith(color: NColors.inkMuted)),
              Text(widget.high, style: NType.label.copyWith(color: NColors.inkMuted)),
            ],
          ),
        ),
        if (_refused)
          Padding(
            padding: const EdgeInsets.only(top: NSpace.xs),
            child: Semantics(liveRegion: true, child: Text(s.symptomsSeverityRefused, style: NType.bodySm.copyWith(color: NColors.statusAttention))),
          ),
        const SizedBox(height: NSpace.md),
        TextField(controller: _note, maxLength: 280, decoration: InputDecoration(labelText: s.symptomsNoteLabel)),
        const SizedBox(height: NSpace.sm),
        NPrimaryButton(label: s.symptomsSave, onPressed: _save),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: children);
  }
}
