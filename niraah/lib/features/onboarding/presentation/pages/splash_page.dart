import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/niraah_api.dart';
import '../../../../design_system/generated/niraah_assets.dart';
import '../../../../design_system/motion/motion.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../design_system/widgets/n_living.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/constants/route_constants.dart';
import '../../../auth/data/api_auth_repository.dart';
import '../../../auth/domain/auth_repository.dart';

/// Coral brand splash. If she is already signed in it opens her home or workspace straight away (her saved
/// session is checked while the logo shows); otherwise it moves on to the intro after a short pause.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.hold = const Duration(milliseconds: 700)});

  final Duration hold;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    // The logo's short pause and the session check run together, so a saved session adds no extra wait.
    final Future<String?> resume = _resumeRoute();
    await Future<void>.delayed(widget.hold);
    final String? home = await resume;
    if (!mounted) return;
    // The web build opens on the public landing page; apps go to the intro.
    context.go(home ?? (kIsWeb ? RouteConstants.landing : RouteConstants.intro));
  }

  /// Her workspace's home when a saved session is still good; null to sign in.
  Future<String?> _resumeRoute() async {
    if (kIsWeb || !getIt.isRegistered<NiraahApi>()) return null;
    try {
      final Map<String, dynamic>? session = await getIt<NiraahApi>().resumeSession().timeout(const Duration(seconds: 20));
      final Object? workspace = (session?['user'] as Map?)?['workspace'];
      if (workspace == null) return null;
      final CodeOutcome outcome = ApiAuthRepository.outcomeFor('$workspace');
      // A neutral account-status screen is not a place to resume to; she signs in and sees it there.
      if (outcome == CodeOutcome.suspended || outcome == CodeOutcome.paused || outcome == CodeOutcome.deletionPending) return null;
      return routeForOutcome(outcome);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Scaffold(
      backgroundColor: NColors.surfaceWarm,
      body: NBackdrop(
        base: NColors.surfaceWarm,
        child: Semantics(
          label: s.splashLabel,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: NMotionRules.duration(context, NMotion.slow),
              curve: NMotionRules.curve,
              builder: (BuildContext context, double t, Widget? child) => Opacity(opacity: t, child: child),
              child: ExcludeSemantics(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    NHalo(
                      size: NSpace.xl3 * 4,
                      color: NColors.brandBlush,
                      child: Container(
                        padding: const EdgeInsets.all(NSpace.md),
                        decoration: BoxDecoration(
                          color: NColors.surfaceCard,
                          borderRadius: BorderRadius.circular(NRadius.xl),
                          boxShadow: NShadow.lg,
                        ),
                        child: Image.asset(NImages.niraahLogo.path, width: NSpace.xl3 + NSpace.lg, excludeFromSemantics: true),
                      ),
                    ),
                    const SizedBox(height: NSpace.lg),
                    Text(s.appName.toLowerCase(), style: NType.h1.copyWith(color: NColors.inkPrimary)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
