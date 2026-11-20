import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../design_system/generated/niraah_assets.dart';
import '../../../../design_system/motion/motion.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../design_system/widgets/n_living.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/constants/route_constants.dart';

/// Coral brand splash. Moves on by itself after a short pause.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.hold = const Duration(milliseconds: 1600)});

  final Duration hold;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.hold, () {
      // The web build opens on the public landing page; apps go to the intro.
      if (mounted) context.go(kIsWeb ? RouteConstants.landing : RouteConstants.intro);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
