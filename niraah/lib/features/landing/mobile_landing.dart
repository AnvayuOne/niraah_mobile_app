import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../design_system/generated/niraah_assets.dart';
import '../../design_system/motion/motion.dart';
import '../../design_system/tokens/tokens.dart';
import '../../design_system/widgets/n_button.dart';
import '../../design_system/widgets/n_illustration.dart';
import '../../design_system/widgets/n_living.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/constants/route_constants.dart';

/// Phone landing, in the format of mobile health apps: one full screen that
/// never scrolls. Four swipeable slides (art on a tinted stage, a title and
/// one line), page dots with a next button, and the two actions pinned at the
/// bottom. Everything sizes from the screen height, so it fits small phones.
class MobileLanding extends StatefulWidget {
  const MobileLanding({super.key});

  @override
  State<MobileLanding> createState() => _MobileLandingState();
}

class _MobileLandingState extends State<MobileLanding> {
  final PageController _pages = PageController();
  int _index = 0;

  static List<(Color, Color)> get _stages => <(Color, Color)>[
    (NColors.brandBlushLight, NColors.brandLavenderLight),
    (NColors.brandApricotLight, NColors.brandBlushLight),
    (NColors.brandSageLight, NColors.brandApricotLight),
    (NColors.brandLavenderLight, NColors.brandSageLight),
  ];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() => _pages.nextPage(duration: NMotionRules.duration(context, NMotion.medium), curve: NMotionRules.curve);

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<_Slide> slides = <_Slide>[
      _Slide(art: const _WelcomeArt(), title: s.landingHeroTitle, body: s.landingMobileHeroBody),
      _Slide(art: const _ProgramsArt(), title: s.landingProgramsTitle, body: s.landingMobileProgramsBody),
      _Slide(art: const _DailyArt(), title: s.landingMobileDailyTitle, body: s.landingMobileDailyBody),
      _Slide(art: const _TeamArt(), title: s.landingTeamTitle, body: s.landingMobileTeamBody),
    ];
    final (Color top, Color bottom) = _stages[_index];
    final bool last = _index == slides.length - 1;

    return Scaffold(
      backgroundColor: NColors.surfacePage,
      body: AnimatedContainer(
        duration: NMotionRules.duration(context, NMotion.medium),
        curve: NMotionRules.curve,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const <double>[0, 0.55, 0.56],
            colors: <Color>[top, bottom, NColors.surfacePage],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.xs, NSpace.xs, 0),
                child: Row(
                  children: <Widget>[
                    Image.asset(NImages.niraahLogo.path, height: 28, semanticLabel: s.appName),
                    const SizedBox(width: NSpace.xs),
                    Text(s.appName, style: NType.h3.copyWith(color: NColors.inkPrimary, fontSize: 24)),
                    const Spacer(),
                    TextButton(
                      key: const ValueKey<String>('landing-sign-in'),
                      onPressed: () => context.go(RouteConstants.signIn),
                      child: Text(s.landingNavSignIn),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pages,
                  itemCount: slides.length,
                  onPageChanged: (int i) => setState(() => _index = i),
                  itemBuilder: (BuildContext context, int i) => _SlideView(slide: slides[i], active: i == _index),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(NSpace.lg, 0, NSpace.lg, NSpace.sm),
                child: Row(
                  children: <Widget>[
                    Semantics(
                      label: s.introSlideLabel(_index + 1, slides.length),
                      child: Row(
                        children: <Widget>[
                          for (int i = 0; i < slides.length; i++)
                            AnimatedContainer(
                              duration: NMotionRules.duration(context, NMotion.fast),
                              margin: const EdgeInsets.only(right: 6),
                              width: i == _index ? 22 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: i == _index ? NColors.brandPlum : NColors.lineStrong,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    AnimatedOpacity(
                      opacity: last ? 0 : 1,
                      duration: NMotionRules.duration(context, NMotion.fast),
                      child: NPressable(
                        enabled: !last,
                        child: IconButton.filledTonal(
                          tooltip: s.next,
                          onPressed: last ? null : _next,
                          style: IconButton.styleFrom(backgroundColor: NColors.brandBlushLight, fixedSize: const Size.square(48)),
                          icon: Icon(Icons.arrow_forward_rounded, color: NColors.inkPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(NSpace.lg, 0, NSpace.lg, NSpace.xs),
                child: Column(
                  children: <Widget>[
                    NPrimaryButton(
                      key: const ValueKey<String>('landing-start'),
                      label: s.landingHeroCta,
                      trailingArrow: true,
                      onPressed: () => context.go(RouteConstants.welcome),
                    ),
                    TextButton(onPressed: () => context.go(RouteConstants.signIn), child: Text(s.landingMobileHaveAccount)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({required this.art, required this.title, required this.body});
  final Widget art;
  final String title, body;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide, required this.active});
  final _Slide slide;
  final bool active;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints c) => c.maxWidth > c.maxHeight * 1.6
        // Landscape: art beside the words, so both stay large.
        ? Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(NSpace.sm),
                  child: Center(child: slide.art),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: NSpace.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        slide.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: NType.h3.copyWith(color: NColors.inkPrimary),
                      ),
                      const SizedBox(height: NSpace.xs),
                      Text(
                        slide.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: NType.bodySm.copyWith(color: NColors.inkSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : Column(
            children: <Widget>[
              // The art stage takes what the text leaves, so nothing ever scrolls.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: NSpace.lg),
                  child: Center(child: slide.art),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.md, NSpace.lg, NSpace.md),
                child: AnimatedOpacity(
                  opacity: active ? 1 : 0.4,
                  duration: NMotionRules.duration(context, NMotion.fast),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          slide.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: NType.h2.copyWith(color: NColors.inkPrimary, fontSize: c.maxHeight < 460 ? 26 : 31),
                        ),
                        const SizedBox(height: NSpace.xs),
                        Text(
                          slide.body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: NType.body.copyWith(color: NColors.inkSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
  );
}

/// Each slide's art is drawn on a 340 x 340 stage and scaled to fit.
class _Fit extends StatelessWidget {
  const _Fit({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.contain,
    child: SizedBox(width: 340, height: 340, child: child),
  );
}

class _WelcomeArt extends StatelessWidget {
  const _WelcomeArt();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return _Fit(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: <Widget>[
          NHalo(
            size: 340,
            color: NColors.surfaceCard,
            child: NIllustration(asset: NImages.i01OnboardingSanctuaryWoman, height: 300, entrance: NEntrance.float),
          ),
          Positioned(
            top: 10,
            left: 0,
            child: NGlassChip(icon: Icons.verified_outlined, label: s.landingChipDoctors),
          ),
          Positioned(
            bottom: 18,
            right: 0,
            child: NGlassChip(icon: Icons.lock_outline_rounded, label: s.welcomeChipPrivate),
          ),
        ],
      ),
    );
  }
}

class _ProgramsArt extends StatelessWidget {
  const _ProgramsArt();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<(NImageAsset, Color, String)> items = <(NImageAsset, Color, String)>[
      (NImages.programPcos, NColors.brandBlushLight, s.landingProgramPcos),
      (NImages.programFertility, NColors.brandLavenderLight, s.landingProgramFertility),
      (NImages.programMetabolic, NColors.brandApricotLight, s.landingProgramMetabolic),
      (NImages.programPregnancy, NColors.brandSageLight, s.landingProgramPregnancy),
    ];
    return _Fit(
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          for (final (NImageAsset img, Color tint, String label) in items)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: NColors.surfaceCard, borderRadius: BorderRadius.circular(NRadius.lg), boxShadow: NShadow.sm),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(NRadius.md)),
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(img.path, fit: BoxFit.contain, excludeFromSemantics: true),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NType.label.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DailyArt extends StatelessWidget {
  const _DailyArt();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    Widget row(IconData icon, Color tint, String title, String sub) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: NColors.surfaceCard, borderRadius: BorderRadius.circular(NRadius.lg), boxShadow: NShadow.sm),
      child: Row(
        children: <Widget>[
          NSquircleIcon(icon: icon, tint: tint, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: NType.label.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
                ),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NType.bodySm.copyWith(color: NColors.inkMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded, color: NColors.statusSuccess, size: 20),
        ],
      ),
    );
    return _Fit(
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            right: -6,
            top: 0,
            child: NHalo(
              size: 210,
              color: NColors.surfaceCard,
              child: NIllustration(asset: NImages.i02YogaPadmasanaBreathWoman, height: 170),
            ),
          ),
          Positioned(
            left: 0,
            right: 30,
            bottom: 0,
            child: Column(
              children: <Widget>[
                row(Icons.water_drop_outlined, NColors.brandBlushLight, s.landingMobileBenefit1, s.landingMobileBenefit1Body),
                const SizedBox(height: 10),
                row(Icons.restaurant_outlined, NColors.brandApricotLight, s.landingMobileBenefit2, s.landingMobileBenefit2Body),
                const SizedBox(height: 10),
                row(Icons.self_improvement_rounded, NColors.brandSageLight, s.landingMobileBenefit3, s.landingMobileBenefit3Body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamArt extends StatelessWidget {
  const _TeamArt();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    Widget member(NImageAsset img, Color ring, String label) => Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 92,
          height: 92,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: NColors.surfaceCard,
            shape: BoxShape.circle,
            border: Border.all(color: ring, width: 2.5),
            boxShadow: NShadow.sm,
          ),
          child: ClipOval(child: Image.asset(img.path, fit: BoxFit.cover, excludeFromSemantics: true)),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(color: NColors.surfaceCard, borderRadius: BorderRadius.circular(NRadius.pill)),
          child: Text(
            label,
            style: NType.label.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
    return _Fit(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          NHalo(
            size: 220,
            color: NColors.surfaceCard,
            child: NIllustration(asset: NImages.i04FemaleAiCompanionOrb, height: 150),
          ),
          Positioned(top: 0, left: 10, child: member(NImages.i03FemaleGynecologistClipboard, NColors.roleDoctor, s.landingTeamDoctor)),
          Positioned(
            top: 0,
            right: 10,
            child: member(NImages.i05FemaleClinicalDietitianBowl, NColors.roleDietitian, s.landingTeamDietitian),
          ),
          Positioned(
            bottom: 0,
            left: 10,
            child: member(NImages.i02YogaPadmasanaBreathWoman, NColors.roleInstructor, s.landingMobileTeamYoga),
          ),
          Positioned(
            bottom: 0,
            right: 10,
            child: member(NImages.i08EnergeticBalancedWoman, NColors.brandTerracotta, s.landingMobileTeamYou),
          ),
        ],
      ),
    );
  }
}
