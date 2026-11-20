import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../design_system/generated/niraah_assets.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../design_system/widgets/error_view.dart';
import '../../../../design_system/widgets/loading_view.dart';
import '../../../../design_system/widgets/n_button.dart';
import '../../../../design_system/widgets/n_illustration.dart';
import '../../../../design_system/widgets/n_page.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/constants/route_constants.dart';
import '../assessment_cubit.dart';

/// The assessment's opening screen (spec 007 §1): how long it takes, that
/// she can stop and resume, whether a doctor reviews it, and health-data
/// consent before the first question.
class AssessmentStartPage extends StatefulWidget {
  const AssessmentStartPage({super.key});

  @override
  State<AssessmentStartPage> createState() => _AssessmentStartPageState();
}

class _AssessmentStartPageState extends State<AssessmentStartPage> {
  bool _health = false;
  bool _review = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    context.read<AssessmentCubit>().load();
  }

  Future<void> _start() async {
    setState(() => _busy = true);
    final bool ok = await context.read<AssessmentCubit>().recordConsent(healthData: _health, doctorReview: _review);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) context.go(RouteConstants.assessment);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<AssessmentCubit, AssessmentState>(
      builder: (BuildContext context, AssessmentState st) {
        if (st.status == AssessmentStatus.failure) {
          return Scaffold(body: ErrorView(message: s.notConnectedYet));
        }
        if (st.session == null) return Scaffold(body: LoadingView(label: s.loadAssessment, kind: NLoaderKind.assessment));
        return NPage(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Center(child: NLottie(path: NLotties.companion, size: NSpace.xl3 * 3)),
              const SizedBox(height: NSpace.lg),
              Text(s.consentTitle, style: NType.h2.copyWith(color: NColors.inkPrimary)),
              const SizedBox(height: NSpace.xs),
              Text(s.consentBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
              const SizedBox(height: NSpace.md),
              _Fact(icon: Icons.schedule_rounded, text: s.consentDuration(st.session!.document.estimatedMinutes)),
              _Fact(icon: Icons.bookmark_border_rounded, text: s.consentResume),
              _Fact(icon: Icons.medical_services_outlined, text: s.consentReviewByPlan),
              const SizedBox(height: NSpace.md),
              _Check(value: _health, text: s.consentHealthData, onChanged: (bool v) => setState(() => _health = v)),
              _Check(value: _review, text: s.consentDoctorReview, onChanged: (bool v) => setState(() => _review = v)),
              Padding(
                padding: const EdgeInsets.only(left: NSpace.sm),
                child: Text(s.consentTextVersion(st.session!.consentTextVersion), style: NType.label.copyWith(color: NColors.inkMuted, letterSpacing: 0)),
              ),
            ],
          ),
          footer: NPrimaryButton(
            label: s.consentStart,
            inactiveHint: s.consentStartHint,
            loading: _busy,
            trailingArrow: true,
            onPressed: _health ? _start : null,
          ),
        );
      },
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: NSpace.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: NColors.actionLink),
            const SizedBox(width: NSpace.sm),
            Expanded(child: Text(text, style: NType.bodySm.copyWith(color: NColors.inkPrimary))),
          ],
        ),
      );
}

class _Check extends StatelessWidget {
  const _Check({required this.value, required this.text, required this.onChanged});

  final bool value;
  final String text;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => MergeSemantics(
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(NRadius.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Checkbox(value: value, onChanged: (bool? v) => onChanged(v ?? false)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: NSpace.sm, bottom: NSpace.sm),
                  child: Text(text, style: NType.bodySm.copyWith(color: NColors.inkPrimary)),
                ),
              ),
            ],
          ),
        ),
      );
}
