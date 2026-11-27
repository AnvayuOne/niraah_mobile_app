import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../design_system/generated/niraah_assets.dart';
import '../../../../design_system/motion/motion.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../design_system/widgets/n_button.dart';
import '../../../../design_system/widgets/n_illustration.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/constants/route_constants.dart';

/// Three short slides before the welcome screen.
class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _pages = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == 2) {
      context.go(RouteConstants.welcome);
      return;
    }
    _pages.nextPage(duration: NMotionRules.duration(context, NMotion.medium), curve: NMotionRules.curve);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<(NImageAsset, String, String, String)> slides = <(NImageAsset, String, String, String)>[
      (NImages.onb01SanctuaryWelcome, NLotties.cycle, s.introTitle1, s.introBody1),
      (NImages.onb02PcosHormones, NLotties.nutrition, s.introTitle2, s.introBody2),
      (NImages.onb06DoctorVerifiedCare, NLotties.doctor, s.introTitle3, s.introBody3),
    ];
    return Scaffold(
      backgroundColor: NColors.surfacePage,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(NSpace.xs),
                child: TextButton(onPressed: () => context.go(RouteConstants.welcome), child: Text(s.skip)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: slides.length,
                onPageChanged: (int i) => setState(() => _index = i),
                itemBuilder: (BuildContext context, int i) {
                  final (NImageAsset image, String lottie, String title, String body) = slides[i];
                  return Semantics(
                    label: s.introSlideLabel(i + 1, slides.length),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: NSpace.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Center(
                              child: NIllustration(asset: image, height: NSpace.xl3 * 4.5, entrance: NEntrance.breathe),
                            ),
                          ),
                          Text(title, style: NType.h2.copyWith(color: NColors.inkPrimary)),
                          const SizedBox(height: NSpace.sm),
                          Text(body, style: NType.bodyLg.copyWith(color: NColors.inkSecondary)),
                          const SizedBox(height: NSpace.lg),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ExcludeSemantics(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (int i = 0; i < slides.length; i++)
                    AnimatedContainer(
                      duration: NMotionRules.duration(context, NMotion.fast),
                      margin: const EdgeInsets.symmetric(horizontal: NSpace.xxs),
                      width: i == _index ? NSpace.lg : NSpace.xs,
                      height: NSpace.xs,
                      decoration: BoxDecoration(
                        color: i == _index ? NColors.actionLink : NColors.lineStrong,
                        borderRadius: BorderRadius.circular(NRadius.pill),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(NSpace.lg),
              child: NPrimaryButton(label: s.next, onPressed: _next),
            ),
          ],
        ),
      ),
    );
  }
}
