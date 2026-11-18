import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../design_system/generated/niraah_assets.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../design_system/widgets/error_view.dart';
import '../../../../design_system/widgets/n_illustration.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/constants/route_constants.dart';
import '../assessment_cubit.dart';

/// Calm screen while the AI summary is prepared. The score is ready at once;
/// the wait for the summary is capped (spec 007 §4).
class ProcessingPage extends StatefulWidget {
  const ProcessingPage({super.key});

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> {
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final bool ok = await context.read<AssessmentCubit>().submitAndWait();
    if (!mounted) return;
    if (ok) {
      context.go(RouteConstants.preScore);
    } else {
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    if (_failed) {
      return Scaffold(
        body: ErrorView(
          message: s.somethingWentWrong,
          retryLabel: s.tryAgain,
          onRetry: () {
            setState(() => _failed = false);
            _run();
          },
        ),
      );
    }
    return Scaffold(
      backgroundColor: NColors.surfacePage,
      body: SafeArea(
        child: Center(
          child: Semantics(
            liveRegion: true,
            label: s.processingTitle,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                NLottie(path: NLotties.companion, size: NSpace.xl3 * 3),
                const SizedBox(height: NSpace.lg),
                ExcludeSemantics(child: Text(s.processingTitle, style: NType.h3.copyWith(color: NColors.inkPrimary))),
                const SizedBox(height: NSpace.xs),
                Text(s.processingBody, style: NType.body.copyWith(color: NColors.inkMuted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
