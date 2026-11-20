import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../design_system/generated/niraah_assets.dart';
import '../../design_system/tokens/tokens.dart';
import '../../design_system/widgets/n_illustration.dart';
import '../../design_system/widgets/n_living.dart';
import '../../design_system/widgets/n_responsive.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/constants/route_constants.dart';
import 'mobile_landing.dart';

/// Public landing page, shown first on the web build (and reachable at
/// /landing). Explains Niraah and leads to the free assessment or sign-in.
/// All copy lives in app_en.arb under `landing*`.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const double _wide = 900;
  static const double _phone = 600;

  @override
  Widget build(BuildContext context) {
    // Phones get the app-style landing; tablets and desktop get the website layout.
    // Phones (in either orientation) get the app-style landing; a landscape phone shows it in
    // the app column. Tablets and desktop get the website layout.
    if (MediaQuery.sizeOf(context).shortestSide < _phone) return const NResponsiveFrame(child: MobileLanding());
    final S s = S.of(context);
    return Scaffold(
      backgroundColor: NColors.surfacePage,
      body: NBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final bool wide = c.maxWidth >= _wide;
              return CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(child: _NavBar(wide: wide)),
                  SliverToBoxAdapter(child: _Hero(wide: wide)),
                  const SliverToBoxAdapter(child: _TrustStrip()),
                  SliverToBoxAdapter(
                    child: _Section(
                      eyebrow: s.landingProgramsEyebrow,
                      title: s.landingProgramsTitle,
                      child: _Programs(wide: wide),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _Section(
                      tint: NColors.brandApricotLight,
                      eyebrow: s.landingStepsEyebrow,
                      title: s.landingStepsTitle,
                      child: _Steps(wide: wide),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _Section(
                      eyebrow: s.landingTeamEyebrow,
                      title: s.landingTeamTitle,
                      child: _Team(wide: wide),
                    ),
                  ),
                  SliverToBoxAdapter(child: _Safety(wide: wide)),
                  SliverToBoxAdapter(child: _CtaBand(wide: wide)),
                  const SliverToBoxAdapter(child: _Footer()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Centered content column with the site's max width.
class _Wrap extends StatelessWidget {
  const _Wrap({required this.child, this.vertical = 0});
  final Widget child;
  final double vertical;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1180),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: NSpace.lg, vertical: vertical),
        child: child,
      ),
    ),
  );
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.wide});
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return _Wrap(
      vertical: NSpace.sm,
      child: Row(
        children: <Widget>[
          Image.asset(NImages.niraahLogo.path, height: 34, semanticLabel: s.appName),
          const SizedBox(width: NSpace.xs),
          Text(s.appName, style: NType.h3.copyWith(color: NColors.inkPrimary)),
          const Spacer(),
          if (wide) ...<Widget>[
            TextButton(onPressed: () => context.go(RouteConstants.signIn), child: Text(s.landingNavProfessionals)),
            const SizedBox(width: NSpace.xs),
          ],
          NPressable(
            child: FilledButton(
              key: const ValueKey<String>('landing-sign-in'),
              onPressed: () => context.go(RouteConstants.signIn),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: NSpace.lg),
              ),
              child: Text(s.landingNavSignIn),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.wide});
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final CrossAxisAlignment align = wide ? CrossAxisAlignment.start : CrossAxisAlignment.center;
    final TextAlign textAlign = wide ? TextAlign.start : TextAlign.center;
    final Widget copy = Column(
      crossAxisAlignment: align,
      children: nStagger(<Widget>[
        _Eyebrow(s.landingHeroEyebrow),
        Text(
          s.landingHeroTitle,
          textAlign: textAlign,
          style: (wide ? NType.display : NType.h1).copyWith(color: NColors.inkPrimary),
        ),
        const SizedBox(height: NSpace.md),
        Text(
          s.landingHeroBody,
          textAlign: textAlign,
          style: NType.bodyLg.copyWith(color: NColors.inkSecondary),
        ),
        const SizedBox(height: NSpace.lg),
        Wrap(
          spacing: NSpace.sm,
          runSpacing: NSpace.sm,
          alignment: wide ? WrapAlignment.start : WrapAlignment.center,
          children: <Widget>[
            NPressable(
              child: DecoratedBox(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(NRadius.pill), boxShadow: NShadow.brandGlow),
                child: FilledButton(
                  key: const ValueKey<String>('landing-start'),
                  onPressed: () => context.go(RouteConstants.welcome),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(s.landingHeroCta),
                      const SizedBox(width: NSpace.xs),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            NPressable(
              child: OutlinedButton(onPressed: () => context.go(RouteConstants.signIn), child: Text(s.landingHeroSecondary)),
            ),
          ],
        ),
        const SizedBox(height: NSpace.md),
        Wrap(
          spacing: NSpace.md,
          runSpacing: NSpace.xs,
          alignment: wide ? WrapAlignment.start : WrapAlignment.center,
          children: <Widget>[_Tick(s.landingTick1), _Tick(s.landingTick2), _Tick(s.landingTick3)],
        ),
      ]),
    );
    final Widget art = NFadeUp(
      delay: const Duration(milliseconds: 120),
      child: SizedBox(
        height: wide ? 460 : 340,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: <Widget>[
            CustomPaint(size: Size.square(wide ? 420 : 300), painter: _OrbitPainter()),
            NTilt(
              child: NHalo(
                size: wide ? 440 : 320,
                child: NIllustration(asset: NImages.i01OnboardingSanctuaryWoman, height: wide ? 380 : 270, entrance: NEntrance.float),
              ),
            ),
            Positioned(
              top: NSpace.lg,
              left: wide ? NSpace.lg : 0,
              child: NGlassChip(icon: Icons.verified_outlined, label: s.landingChipDoctors),
            ),
            Positioned(
              bottom: NSpace.xl,
              right: wide ? NSpace.md : 0,
              child: NGlassChip(icon: Icons.auto_awesome_outlined, label: s.landingChipAi),
            ),
            Positioned(
              bottom: 0,
              left: wide ? NSpace.xl : NSpace.md,
              child: NGlassChip(icon: Icons.self_improvement_rounded, label: s.landingChipYoga),
            ),
          ],
        ),
      ),
    );
    return _Wrap(
      vertical: wide ? NSpace.xl2 : NSpace.lg,
      child: wide
          ? Row(
              children: <Widget>[
                Expanded(flex: 11, child: copy),
                const SizedBox(width: NSpace.xl),
                Expanded(flex: 10, child: art),
              ],
            )
          : Column(
              children: <Widget>[
                art,
                const SizedBox(height: NSpace.lg),
                copy,
              ],
            ),
    );
  }
}

/// Two thin dashed rings behind the hero art. Static.
class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final Paint p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final (double r, Color col) in <(double, Color)>[
      (size.width / 2, NColors.brandLavender),
      (size.width / 2.6, NColors.brandBlush),
    ]) {
      p.color = col.withValues(alpha: 0.8);
      const int dashes = 60;
      for (int i = 0; i < dashes; i += 2) {
        canvas.drawArc(Rect.fromCircle(center: c, radius: r), i * 6.283 / dashes, 6.283 / dashes, false, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Tick extends StatelessWidget {
  const _Tick(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      const Icon(Icons.check_circle_rounded, size: 18, color: NColors.statusSuccess),
      const SizedBox(width: NSpace.xxs + 2),
      Text(text, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
    ],
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: NSpace.sm),
    child: Text(text.toUpperCase(), style: NType.caption.copyWith(color: NColors.brandTerracotta, letterSpacing: 2)),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.eyebrow, required this.title, required this.child, this.tint});
  final String eyebrow, title;
  final Widget child;
  final Color? tint;

  @override
  Widget build(BuildContext context) => Container(
    color: tint,
    child: _Wrap(
      vertical: NSpace.xl2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Eyebrow(eyebrow),
          Text(title, style: NType.h2.copyWith(color: NColors.inkPrimary)),
          const SizedBox(height: NSpace.lg),
          child,
        ],
      ),
    ),
  );
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<(IconData, String)> items = <(IconData, String)>[
      (Icons.verified_user_outlined, s.landingTrust1),
      (Icons.restaurant_outlined, s.landingTrust2),
      (Icons.lock_outline_rounded, s.landingTrust3),
      (Icons.currency_rupee_rounded, s.landingTrust4),
    ];
    return Container(
      color: NColors.brandPlum,
      child: _Wrap(
        vertical: NSpace.md,
        child: Wrap(
          alignment: WrapAlignment.spaceAround,
          spacing: NSpace.xl,
          runSpacing: NSpace.sm,
          children: <Widget>[
            for (final (IconData i, String t) in items)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(i, size: 18, color: NColors.brandBlush),
                  const SizedBox(width: NSpace.xs),
                  Text(t, style: NType.bodySm.copyWith(color: NColors.inkOnBrand)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Lays out cards in 1, 2 or 4 columns.
class _Grid extends StatelessWidget {
  const _Grid({required this.children, required this.wide});
  final List<Widget> children;
  final bool wide;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints c) {
      final int cols = wide ? 4 : (c.maxWidth >= 560 ? 2 : 1);
      final double w = (c.maxWidth - NSpace.md * (cols - 1)) / cols;
      return Wrap(
        spacing: NSpace.md,
        runSpacing: NSpace.md,
        children: nStagger(<Widget>[for (final Widget ch in children) SizedBox(width: w, child: ch)]),
      );
    },
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.color = NColors.surfaceCard});
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) => NTilt(
    maxAngle: 0.05,
    child: Container(
      padding: const EdgeInsets.all(NSpace.lg),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(NRadius.xl),
        border: Border.all(color: NColors.lineDefault),
        boxShadow: NShadow.sm,
      ),
      child: child,
    ),
  );
}

class _Programs extends StatelessWidget {
  const _Programs({required this.wide});
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<(NImageAsset, Color, String, String)> items = <(NImageAsset, Color, String, String)>[
      (NImages.programPcos, NColors.brandBlushLight, s.landingProgramPcos, s.landingProgramPcosBody),
      (NImages.programFertility, NColors.brandLavenderLight, s.landingProgramFertility, s.landingProgramFertilityBody),
      (NImages.programMetabolic, NColors.brandApricotLight, s.landingProgramMetabolic, s.landingProgramMetabolicBody),
      (NImages.programPregnancy, NColors.brandSageLight, s.landingProgramPregnancy, s.landingProgramPregnancyBody),
    ];
    return _Grid(
      wide: wide,
      children: <Widget>[
        for (final (NImageAsset img, Color tint, String t, String b) in items)
          _Card(
            color: tint,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(child: NIllustration(asset: img, height: 140)),
                const SizedBox(height: NSpace.md),
                Text(t, style: NType.h3.copyWith(color: NColors.inkPrimary)),
                const SizedBox(height: NSpace.xs),
                Text(b, style: NType.body.copyWith(color: NColors.inkSecondary)),
              ],
            ),
          ),
      ],
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.wide});
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<(IconData, String, String)> items = <(IconData, String, String)>[
      (Icons.assignment_outlined, s.landingStep1, s.landingStep1Body),
      (Icons.insights_outlined, s.landingStep2, s.landingStep2Body),
      (Icons.groups_2_outlined, s.landingStep3, s.landingStep3Body),
      (Icons.event_available_outlined, s.landingStep4, s.landingStep4Body),
    ];
    return _Grid(
      wide: wide,
      children: <Widget>[
        for (int i = 0; i < items.length; i++)
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    NSquircleIcon(icon: items[i].$1),
                    const Spacer(),
                    Text('${i + 1}', style: NType.h1.copyWith(color: NColors.brandBlush)),
                  ],
                ),
                const SizedBox(height: NSpace.md),
                Text(items[i].$2, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                const SizedBox(height: NSpace.xs),
                Text(items[i].$3, style: NType.body.copyWith(color: NColors.inkSecondary)),
              ],
            ),
          ),
      ],
    );
  }
}

class _Team extends StatelessWidget {
  const _Team({required this.wide});
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<(NImageAsset, Color, String, String)> items = <(NImageAsset, Color, String, String)>[
      (NImages.i03FemaleGynecologistClipboard, NColors.roleDoctor, s.landingTeamDoctor, s.landingTeamDoctorBody),
      (NImages.i05FemaleClinicalDietitianBowl, NColors.roleDietitian, s.landingTeamDietitian, s.landingTeamDietitianBody),
      (NImages.i02YogaPadmasanaBreathWoman, NColors.roleInstructor, s.landingTeamYoga, s.landingTeamYogaBody),
      (NImages.i04FemaleAiCompanionOrb, NColors.statusInfo, s.landingTeamAi, s.landingTeamAiBody),
    ];
    return _Grid(
      wide: wide,
      children: <Widget>[
        for (final (NImageAsset img, Color role, String t, String b) in items)
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: NHalo(
                    size: 170,
                    color: role.withValues(alpha: 0.35),
                    child: NIllustration(asset: img, height: 140),
                  ),
                ),
                const SizedBox(height: NSpace.md),
                Container(
                  width: NSpace.lg,
                  height: 3,
                  decoration: BoxDecoration(color: role, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: NSpace.sm),
                Text(t, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                const SizedBox(height: NSpace.xs),
                Text(b, style: NType.body.copyWith(color: NColors.inkSecondary)),
              ],
            ),
          ),
      ],
    );
  }
}

class _Safety extends StatelessWidget {
  const _Safety({required this.wide});
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return _Wrap(
      vertical: NSpace.lg,
      child: Container(
        padding: const EdgeInsets.all(NSpace.lg),
        decoration: BoxDecoration(color: NColors.brandSageLight, borderRadius: BorderRadius.circular(NRadius.xl)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const NSquircleIcon(icon: Icons.shield_outlined, tint: NColors.surfaceCard, color: NColors.statusSuccess),
            const SizedBox(width: NSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(s.landingSafetyTitle, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                  const SizedBox(height: NSpace.xs),
                  Text(s.landingSafetyBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CtaBand extends StatelessWidget {
  const _CtaBand({required this.wide});
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Widget text = Column(
      crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          s.landingCtaTitle,
          textAlign: wide ? TextAlign.start : TextAlign.center,
          style: NType.h2.copyWith(color: NColors.inkOnBrand),
        ),
        const SizedBox(height: NSpace.xs),
        Text(
          s.landingCtaBody,
          textAlign: wide ? TextAlign.start : TextAlign.center,
          style: NType.body.copyWith(color: NColors.brandBlushLight),
        ),
      ],
    );
    final Widget button = NPressable(
      child: FilledButton(
        onPressed: () => context.go(RouteConstants.welcome),
        style: FilledButton.styleFrom(backgroundColor: NColors.brandBlush, foregroundColor: NColors.inkPrimary),
        child: Text(s.landingHeroCta),
      ),
    );
    return _Wrap(
      vertical: NSpace.xl,
      child: Container(
        padding: const EdgeInsets.all(NSpace.xl),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(NRadius.xl + 4),
          gradient: const LinearGradient(colors: <Color>[NColors.brandPlum, NColors.brandRosewood]),
        ),
        child: wide
            ? Row(
                children: <Widget>[
                  Expanded(child: text),
                  const SizedBox(width: NSpace.lg),
                  button,
                ],
              )
            : Column(
                children: <Widget>[
                  text,
                  const SizedBox(height: NSpace.lg),
                  button,
                ],
              ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: NColors.lineDefault)),
      ),
      child: _Wrap(
        vertical: NSpace.lg,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: NSpace.xs,
          spacing: NSpace.lg,
          children: <Widget>[
            Text(s.landingFooter, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
            Text(s.landingEmergency, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
          ],
        ),
      ),
    );
  }
}
