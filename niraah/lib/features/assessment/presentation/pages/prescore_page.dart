import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../design_system/tokens/tokens.dart';
import '../../../../design_system/widgets/clinician_card.dart';
import '../../../../design_system/widgets/level_chip.dart';
import '../../../../design_system/widgets/loading_view.dart';
import '../../../../design_system/widgets/n_button.dart';
import '../../../../design_system/widgets/score_arc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/constants/route_constants.dart';
import '../../domain/prescore.dart';
import '../assessment_cubit.dart';

/// The wellness pre-score (spec 007 §5).
class PreScorePage extends StatelessWidget {
  const PreScorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<AssessmentCubit, AssessmentState>(
      builder: (BuildContext context, AssessmentState st) {
        final PreScore? p = st.preScore;
        if (p == null) return Scaffold(body: LoadingView(label: s.loadAssessment, kind: NLoaderKind.assessment));
        return PreScoreView(preScore: p);
      },
    );
  }
}

/// The screen itself, separate from the flow so it can be tested and shown
/// in every review state.
class PreScoreView extends StatelessWidget {
  const PreScoreView({required this.preScore, super.key});

  final PreScore preScore;

  ClinicianCard _clinician(S s) {
    final PreScore p = preScore;
    return switch (p.reviewState) {
      ReviewState.notRequired => ClinicianCard(
          state: ClinicianCardState.notRequired,
          title: s.clinicianNotRequired,
          body: p.plansIncludingReview.isEmpty ? null : s.clinicianIncludedIn(p.plansIncludingReview.join(', ')),
        ),
      ReviewState.awaitingReview => ClinicianCard(state: ClinicianCardState.awaitingReview, title: s.clinicianAwaiting(p.reviewTarget ?? '')),
      ReviewState.verified => ClinicianCard(
          state: ClinicianCardState.verified,
          title: s.clinicianVerified,
          body: p.reviewer == null ? null : s.clinicianVerifiedBy(p.reviewer!.name, p.reviewer!.speciality),
        ),
      ReviewState.followUpRequested => ClinicianCard(
          state: ClinicianCardState.followUpRequested,
          title: s.clinicianFollowUp(p.reviewer?.name ?? ''),
          body: p.doctorNote,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final PreScore p = preScore;
    final NextAction next = nextActionFor(p);
    final List<RaisedFlag> urgent = p.flags.where((RaisedFlag f) => f.severity == FlagSeverity.urgent && f.careMessage != null).toList();
    final (String primaryLabel, String primaryRoute) = switch (next) {
      NextAction.bookDoctor => (s.nextBookDoctor, RouteConstants.bookDoctor),
      NextAction.seePlans => (s.nextSeePlans, RouteConstants.plans),
      NextAction.goHome => (s.nextGoHome, RouteConstants.home),
    };
    return Scaffold(
      backgroundColor: NColors.surfacePage,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(NSpace.lg),
          children: <Widget>[
            if (urgent.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: NSpace.lg),
                padding: const EdgeInsets.all(NSpace.md),
                decoration: BoxDecoration(color: NColors.statusAttentionLight, borderRadius: BorderRadius.circular(NRadius.lg)),
                child: Semantics(
                  container: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (String m in urgent.map((RaisedFlag f) => f.careMessage!).toSet())
                        Text(m, style: NType.body.copyWith(color: NColors.statusAttention, fontWeight: FontWeight.w700)),
                      if (p.reviewState == ReviewState.notRequired) ...<Widget>[
                        const SizedBox(height: NSpace.xxs),
                        Text(s.prescoreFreeNoDoctor, style: NType.bodySm.copyWith(color: NColors.inkPrimary)),
                      ],
                    ],
                  ),
                ),
              ),
            Semantics(header: true, child: Text(s.prescoreTitle, textAlign: TextAlign.center, style: NType.screenTitle.copyWith(color: NColors.inkPrimary))),
            const SizedBox(height: NSpace.md),
            Center(
              child: ScoreArc(
                total: p.total,
                maximum: p.maximum,
                caption: s.prescoreOutOf(p.maximum),
                semanticLabel: s.prescoreScoreLabel(p.total, p.maximum, p.band.label),
              ),
            ),
            ExcludeSemantics(child: Text(p.band.label, textAlign: TextAlign.center, style: NType.h3.copyWith(color: NColors.actionLink))),
            const SizedBox(height: NSpace.xxs),
            Text(p.band.message, textAlign: TextAlign.center, style: NType.body.copyWith(color: NColors.inkSecondary)),
            const SizedBox(height: NSpace.xs),
            Text(s.prescoreNotDiagnosis, textAlign: TextAlign.center, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
            const SizedBox(height: NSpace.lg),
            Text(s.prescoreNoticed, style: NType.h4.copyWith(color: NColors.inkPrimary)),
            const SizedBox(height: NSpace.xs),
            for (String o in p.observations.take(4))
              Container(
                margin: const EdgeInsets.only(bottom: NSpace.xs),
                padding: const EdgeInsets.all(NSpace.md),
                decoration: BoxDecoration(color: NColors.surfaceCard, borderRadius: BorderRadius.circular(NRadius.lg), boxShadow: NShadow.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ExcludeSemantics(child: Icon(Icons.auto_awesome_rounded, color: NColors.brandRosewood, size: NSpace.lg - NSpace.xxs)),
                    const SizedBox(width: NSpace.sm),
                    Expanded(child: Text(o, style: NType.bodySm.copyWith(color: NColors.inkPrimary))),
                  ],
                ),
              ),
            const SizedBox(height: NSpace.md),
            Text(s.prescoreAreas, style: NType.h4.copyWith(color: NColors.inkPrimary)),
            const SizedBox(height: NSpace.xs),
            Wrap(
              spacing: NSpace.xs,
              runSpacing: NSpace.xs,
              children: <Widget>[for (DimensionLevel d in p.dimensions) LevelChip(name: d.name, level: d.level)],
            ),
            const SizedBox(height: NSpace.lg),
            _clinician(s),
            if (p.suggestedProgram != null) ...<Widget>[
              const SizedBox(height: NSpace.md),
              Text(s.prescoreProgram, style: NType.label.copyWith(color: NColors.inkMuted)),
              Text(p.suggestedProgram!, style: NType.h4.copyWith(color: NColors.inkPrimary)),
            ],
            const SizedBox(height: NSpace.xl),
            NPrimaryButton(label: primaryLabel, trailingArrow: true, onPressed: () => context.go(primaryRoute)),
            if (next != NextAction.goHome) ...<Widget>[
              const SizedBox(height: NSpace.xs),
              TextButton(onPressed: () => context.go(RouteConstants.home), child: Text(s.goHome)),
            ],
          ],
        ),
      ),
    );
  }
}
