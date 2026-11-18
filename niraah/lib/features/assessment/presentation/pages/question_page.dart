import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../design_system/assets/asset_lookup.dart';
import '../../../../design_system/generated/niraah_assets.dart';
import '../../../../design_system/motion/motion.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../design_system/widgets/answer_card.dart';
import '../../../../design_system/widgets/date_of_birth_input.dart';
import '../../../../design_system/widgets/loading_view.dart';
import '../../../../design_system/widgets/n_button.dart';
import '../../../../design_system/widgets/n_illustration.dart';
import '../../../../design_system/widgets/scale_selector.dart';
import '../../../../design_system/widgets/step_progress.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/constants/route_constants.dart';
import '../../domain/answer_rules.dart';
import '../../domain/questionnaire.dart';
import '../assessment_cubit.dart';

/// One question per page (spec 007 §2), with any number of questions and
/// any supported type.
class QuestionPage extends StatelessWidget {
  const QuestionPage({super.key});

  static NEntrance _entrance(IllustrationMotion m) => switch (m) {
        IllustrationMotion.breathe => NEntrance.breathe,
        IllustrationMotion.float => NEntrance.float,
        IllustrationMotion.sway => NEntrance.sway,
        IllustrationMotion.none => NEntrance.none,
      };

  Future<void> _next(BuildContext context) async {
    final S s = S.of(context);
    final Advance a = await context.read<AssessmentCubit>().next();
    if (!context.mounted) return;
    switch (a) {
      case Advance.nextQuestion:
        break;
      case Advance.readyToSubmit:
        context.go(RouteConstants.processing);
      case Advance.minimumAge:
        context.go(RouteConstants.minimumAge);
      case Advance.failed:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.assessmentSaveFailed)));
    }
  }

  void _back(BuildContext context) {
    if (!context.read<AssessmentCubit>().back()) context.go(RouteConstants.assessmentStart);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<AssessmentCubit, AssessmentState>(
      builder: (BuildContext context, AssessmentState st) {
        final Question? q = st.current;
        if (q == null) return Scaffold(body: LoadingView(label: s.loading));
        final Answer? answer = st.answers[q.key];
        final bool unknownType = q.type == QuestionType.unknown;
        final bool canGo = !unknownType && AnswerRules.canContinue(q, answer);
        final NImageAsset? art = NAssetLookup.image(q.illustrationId);
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? _) {
            if (!didPop) _back(context);
          },
          child: Scaffold(
            backgroundColor: NColors.surfacePage,
            body: Column(
              children: <Widget>[
                Container(
                  color: NColors.surfaceWarm,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(NSpace.xs, NSpace.xs, NSpace.lg, NSpace.lg),
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            tooltip: s.back,
                            onPressed: () => _back(context),
                            icon: const Icon(Icons.arrow_back_rounded, color: NColors.inkPrimary),
                          ),
                          Expanded(
                            child: StepProgress(
                              current: st.step,
                              total: st.visible.length,
                              label: s.assessmentStep(st.step, st.visible.length),
                              section: s.assessmentSection,
                              onBrand: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: NMotionRules.duration(context, NMotion.medium),
                    switchInCurve: NMotionRules.curve,
                    child: ListView(
                      key: ValueKey<String>(q.key),
                      padding: const EdgeInsets.all(NSpace.lg),
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(NSpace.lg),
                          decoration: BoxDecoration(
                            color: NColors.surfaceCard,
                            borderRadius: BorderRadius.circular(NRadius.xl),
                            boxShadow: NShadow.sm,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Semantics(header: true, child: Text(q.text, style: NType.h3.copyWith(color: NColors.inkPrimary))),
                              if (q.helpText != null) ...<Widget>[
                                const SizedBox(height: NSpace.xs),
                                Text(q.helpText!, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
                              ],
                              if (art != null) ...<Widget>[
                                const SizedBox(height: NSpace.md),
                                Center(child: NIllustration(asset: art, height: NSpace.xl3 * 2 + NSpace.lg, entrance: _entrance(q.motion))),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: NSpace.md),
                        if (unknownType)
                          Text(s.assessmentUpdateApp, style: NType.body.copyWith(color: NColors.inkPrimary))
                        else
                          _AnswerInput(question: q, answer: answer),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(NSpace.lg, 0, NSpace.lg, NSpace.lg),
                    child: Column(
                      children: <Widget>[
                        NPrimaryButton(
                          label: st.isLast ? s.assessmentSeeResult : s.continueLabel,
                          inactiveHint: s.assessmentChooseToContinue,
                          trailingArrow: true,
                          loading: st.status == AssessmentStatus.saving,
                          onPressed: canGo ? () => _next(context) : null,
                        ),
                        if (!q.required && (answer == null || answer.isEmpty))
                          TextButton(onPressed: () => _next(context), child: Text(s.skip)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnswerInput extends StatelessWidget {
  const _AnswerInput({required this.question, required this.answer});

  final Question question;
  final Answer? answer;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final AssessmentCubit cubit = context.read<AssessmentCubit>();
    final Question q = question;
    final List<String> chosen = answer?.values ?? const <String>[];
    switch (q.type) {
      case QuestionType.singleChoice:
      case QuestionType.multipleChoice:
        final bool multi = q.type == QuestionType.multipleChoice;
        return Column(
          children: <Widget>[
            for (final AnswerOption o in q.options)
              Padding(
                padding: const EdgeInsets.only(bottom: NSpace.sm),
                child: AnswerCard(
                  label: o.label,
                  multiple: multi,
                  selected: chosen.contains(o.value),
                  colorToken: o.colorToken,
                  icon: NAssetLookup.image(o.iconId),
                  onTap: () {
                    final List<String> next = multi ? AnswerRules.toggleMultiple(q, chosen, o.value) : <String>[o.value];
                    next.isEmpty ? cubit.clearAnswer(q.key) : cubit.answer(q.key, Answer.values(next));
                  },
                ),
              ),
          ],
        );
      case QuestionType.scale:
        return ScaleSelector(
          steps: <ScaleStep>[for (final AnswerOption o in q.options) ScaleStep(value: o.value, label: o.label)],
          selected: chosen.firstOrNull,
          selectedLabelBuilder: s.assessmentScaleSelected,
          onSelected: (String v) => cubit.answer(q.key, Answer.values(<String>[v])),
        );
      case QuestionType.date:
        return DateOfBirthInput(
          value: DateTime.tryParse(answer?.text ?? ''),
          placeholder: s.assessmentChooseDate,
          chosenLabel: s.assessmentDateChosen,
          onChanged: (DateTime d) => cubit.answer(q.key, Answer.text(DateFormat('yyyy-MM-dd').format(d))),
        );
      case QuestionType.number:
      case QuestionType.shortText:
        return _TextAnswer(question: q, initial: answer?.text ?? '');
      case QuestionType.unknown:
        return const SizedBox.shrink();
    }
  }
}

class _TextAnswer extends StatefulWidget {
  const _TextAnswer({required this.question, required this.initial});

  final Question question;
  final String initial;

  @override
  State<_TextAnswer> createState() => _TextAnswerState();
}

class _TextAnswerState extends State<_TextAnswer> {
  late final TextEditingController _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool number = widget.question.type == QuestionType.number;
    final AssessmentCubit cubit = context.read<AssessmentCubit>();
    return TextField(
      controller: _c,
      maxLength: widget.question.maxLength,
      minLines: number ? 1 : 2,
      maxLines: number ? 1 : 4,
      keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      inputFormatters: number ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))] : null,
      decoration: InputDecoration(labelText: widget.question.text, floatingLabelBehavior: FloatingLabelBehavior.never, hintText: S.of(context).assessmentTextHint),
      onChanged: (String v) => v.trim().isEmpty ? cubit.clearAnswer(widget.question.key) : cubit.answer(widget.question.key, Answer.text(v)),
    );
  }
}
