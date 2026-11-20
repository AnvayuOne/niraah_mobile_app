import 'package:material_ui/material_ui.dart';

import '../motion/motion.dart';
import '../tokens/tokens.dart';

/// The clinician look in the app: the member app's warm style (cream page, white rounded cards, serif
/// headings, painterly illustrations) with one role colour — violet for doctors, amber for dietitians,
/// sage for instructors — so a provider always knows which workspace she is in.

/// The role colours for the workspace below it. Set once by each workspace shell.
class CRole extends InheritedWidget {
  const CRole({required this.accent, required this.light, required this.illustration, required super.child, super.key});

  const CRole.doctor({required Widget child, Key? key}) : this(accent: NColors.roleDoctor, light: NColors.brandLavenderLight, illustration: 'assets/images/03_female_gynecologist_clipboard.webp', child: child, key: key);
  const CRole.dietitian({required Widget child, Key? key}) : this(accent: NColors.roleDietitian, light: NColors.brandApricotLight, illustration: 'assets/images/05_female_clinical_dietitian_bowl.webp', child: child, key: key);
  const CRole.instructor({required Widget child, Key? key}) : this(accent: NColors.roleInstructor, light: NColors.brandSageLight, illustration: 'assets/images/02_yoga_padmasana_breath_woman.webp', child: child, key: key);

  /// The role's strong colour (icons, active chips, numbers that need attention).
  final Color accent;

  /// The role's soft tint (hero wash, icon chips).
  final Color light;

  /// A painterly illustration from the asset set, shown on the hero.
  final String illustration;

  /// The last workspace shell shown, for pages pushed above it (full-screen details).
  static CRole fallback = const CRole.doctor(child: SizedBox.shrink());

  static CRole of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<CRole>() ?? fallback;

  @override
  bool updateShouldNotify(CRole old) => old.accent != accent || old.illustration != illustration;
}

/// The warm header card: role-tinted wash over cream, serif title and a painterly illustration.
/// Put [CHeroStat] tiles or any content in [child].
class CHero extends StatelessWidget {
  const CHero({required this.eyebrow, required this.title, super.key, this.subtitle, this.trailing, this.child, this.illustration = true});

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? child;
  final bool illustration;

  @override
  Widget build(BuildContext context) {
    final CRole role = CRole.of(context);
    return CEntrance(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(NRadius.xl),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[role.light, NColors.brandBlushLight, NColors.surfaceCard]),
            border: Border.all(color: NColors.lineDefault),
          ),
          child: Stack(
            children: <Widget>[
              Positioned(top: -50, right: -30, child: _Glow(size: 180, color: role.accent, opacity: 0.16)),
              Positioned(bottom: -60, left: 40, child: _Glow(size: 160, color: NColors.brandApricot, opacity: 0.22)),
              if (illustration)
                Positioned(
                  right: -6,
                  top: 6,
                  child: Opacity(opacity: 0.95, child: Image.asset(role.illustration, height: 96, fit: BoxFit.contain, excludeFromSemantics: true, errorBuilder: (_, _, _) => const SizedBox.shrink())),
                ),
              Padding(
                padding: const EdgeInsets.all(NSpace.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: illustration ? 70 : 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(eyebrow.toUpperCase(), style: NType.label.copyWith(color: role.accent, letterSpacing: 1.6, fontWeight: FontWeight.w700)),
                                const SizedBox(height: NSpace.xxs),
                                Semantics(header: true, child: Text(title, style: NType.h2.copyWith(color: NColors.inkPrimary, height: 1.15))),
                                if (subtitle != null) ...<Widget>[
                                  const SizedBox(height: NSpace.xxs),
                                  Text(subtitle!, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                                ],
                                if (trailing != null) ...<Widget>[const SizedBox(height: NSpace.sm), trailing!],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (child != null) ...<Widget>[const SizedBox(height: NSpace.md), child!],
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

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color, required this.opacity});

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: <Color>[color.withValues(alpha: opacity), color.withValues(alpha: 0)]),
          ),
        ),
      );
}

/// A white number tile on a [CHero], with the role colour on its icon chip.
class CHeroStat extends StatelessWidget {
  const CHeroStat({required this.label, required this.value, required this.icon, super.key, this.note, this.onTap, this.alert = false});

  final String label;
  final String value;
  final IconData icon;
  final String? note;
  final VoidCallback? onTap;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final CRole role = CRole.of(context);
    final Color c = alert ? NColors.statusAttention : role.accent;
    return Semantics(
      button: onTap != null,
      label: '$label: $value${note == null ? '' : '. $note'}',
      excludeSemantics: true,
      child: Material(
        color: NColors.surfaceCard.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(NRadius.lg),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(NRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(NSpace.xs + 2),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(NRadius.lg), border: Border.all(color: alert ? NColors.statusAttention.withValues(alpha: 0.4) : NColors.lineDefault), boxShadow: NShadow.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(NRadius.md)),
                      child: Icon(icon, size: 16, color: c),
                    ),
                    const Spacer(),
                    if (alert) Container(width: 8, height: 8, decoration: const BoxDecoration(color: NColors.statusAttention, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: NSpace.xs),
                Text(value, style: NType.h3.copyWith(color: alert ? NColors.statusAttention : NColors.inkPrimary, fontFamily: NType.body.fontFamily, fontSize: 24, fontWeight: FontWeight.w700, height: 1, fontFeatures: const <FontFeature>[FontFeature.tabularFigures()])),
                const SizedBox(height: 2),
                Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: NType.caption.copyWith(color: NColors.inkSecondary, letterSpacing: 0, height: 1.2)),
                if (note != null) Text(note!, maxLines: 1, overflow: TextOverflow.ellipsis, style: NType.caption.copyWith(color: role.accent, fontWeight: FontWeight.w700, letterSpacing: 0)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lays [CHeroStat] tiles out two or three across.
class CStatGrid extends StatelessWidget {
  const CStatGrid({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final int cols = c.maxWidth > 560 ? 4 : (c.maxWidth > 300 ? 3 : 2);
          final double w = (c.maxWidth - NSpace.xs * (cols - 1)) / cols;
          return Wrap(spacing: NSpace.xs, runSpacing: NSpace.xs, children: <Widget>[for (final Widget t in children) SizedBox(width: w, child: t)]);
        },
      );
}

/// A white panel with an icon, title and optional action.
class CPanel extends StatelessWidget {
  const CPanel({required this.title, required this.child, super.key, this.icon, this.note, this.action, this.padding = const EdgeInsets.all(NSpace.md)});

  final String title;
  final Widget child;
  final IconData? icon;
  final String? note;
  final Widget? action;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => CEntrance(
        child: Container(
          padding: padding,
          decoration: BoxDecoration(color: NColors.surfaceCard, borderRadius: BorderRadius.circular(NRadius.xl), border: Border.all(color: NColors.lineDefault), boxShadow: NShadow.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(color: CRole.of(context).light, borderRadius: BorderRadius.circular(NRadius.md)),
                      child: Icon(icon, size: 18, color: CRole.of(context).accent),
                    ),
                    const SizedBox(width: NSpace.sm),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Semantics(header: true, child: Text(title, style: NType.h4.copyWith(color: NColors.inkPrimary))),
                        if (note != null) Text(note!, style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0)),
                      ],
                    ),
                  ),
                  ?action,
                ],
              ),
              const SizedBox(height: NSpace.sm),
              child,
            ],
          ),
        ),
      );
}

enum CTone { plum, rose, apricot, sage, lavender, red, quiet }

/// A small status pill.
class CPill extends StatelessWidget {
  const CPill(this.text, {super.key, this.tone = CTone.quiet});

  final String text;
  final CTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (tone) {
      CTone.plum => (Color.lerp(CRole.of(context).accent, NColors.inkPrimary, 0.3)!, Colors.white),
      CTone.rose => (NColors.brandBlushLight, NColors.brandRosewood),
      CTone.apricot => (NColors.brandApricotLight, NColors.statusWarningText),
      CTone.sage => (NColors.brandSageLight, NColors.statusSuccess),
      CTone.lavender => (NColors.brandLavenderLight, NColors.statusInfo),
      CTone.red => (NColors.statusClinicalRedFlagLight, NColors.statusClinicalRedFlag),
      CTone.quiet => (NColors.surfaceBackdrop, NColors.inkSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(NRadius.pill)),
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: NType.caption.copyWith(color: fg, fontWeight: FontWeight.w700, letterSpacing: 0)),
    );
  }
}

/// Initials in a soft tinted circle.
class CAvatar extends StatelessWidget {
  const CAvatar({required this.name, super.key, this.size = 40});

  final String? name;
  final double size;

  static const List<Color> _tints = <Color>[NColors.brandBlush, NColors.brandApricot, NColors.brandLavender, NColors.brandSage, NColors.brandBlushLight];

  @override
  Widget build(BuildContext context) {
    final String n = (name == null || name!.trim().isEmpty) ? '?' : name!.trim();
    final String initials = n.split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).take(2).map((String w) => w[0].toUpperCase()).join();
    final Color tint = _tints[n.codeUnits.fold<int>(0, (int a, int c) => a + c) % _tints.length];
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
        child: Text(initials, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700, fontSize: size * 0.36)),
      ),
    );
  }
}

/// A calm empty state with an icon.
class CEmpty extends StatelessWidget {
  const CEmpty({required this.icon, required this.title, super.key, this.body, this.action});

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: NSpace.md, vertical: NSpace.lg),
        decoration: BoxDecoration(color: NColors.surfacePage, borderRadius: BorderRadius.circular(NRadius.lg), border: Border.all(color: NColors.lineStrong.withValues(alpha: 0.6))),
        child: Column(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: NColors.brandBlushLight, shape: BoxShape.circle),
              child: Icon(icon, color: NColors.brandRosewood),
            ),
            const SizedBox(height: NSpace.xs),
            Text(title, textAlign: TextAlign.center, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
            if (body != null) ...<Widget>[
              const SizedBox(height: NSpace.xxs),
              Text(body!, textAlign: TextAlign.center, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
            ],
            if (action != null) ...<Widget>[const SizedBox(height: NSpace.sm), action!],
          ],
        ),
      );
}

/// A list row card: avatar or icon, title, subtitle, trailing.
class CRow extends StatelessWidget {
  const CRow({required this.title, super.key, this.subtitle, this.leading, this.trailing, this.onTap, this.highlight = false});

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Material(
        color: highlight ? NColors.brandBlushLight : NColors.surfaceCard,
        borderRadius: BorderRadius.circular(NRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(NRadius.lg),
          child: Container(
            constraints: const BoxConstraints(minHeight: NLayout.minTapTarget + NSpace.sm),
            padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: NSpace.sm),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(NRadius.lg), border: Border.all(color: highlight ? NColors.brandBlush : NColors.lineDefault)),
            child: Row(
              children: <Widget>[
                if (leading != null) ...<Widget>[leading!, const SizedBox(width: NSpace.sm)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                      if (subtitle != null) Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
                    ],
                  ),
                ),
                if (trailing != null) ...<Widget>[const SizedBox(width: NSpace.xs), trailing!],
                if (onTap != null) const Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
              ],
            ),
          ),
        ),
      );
}

/// A small icon tile used in hubs ("More").
class CHubTile extends StatelessWidget {
  const CHubTile({required this.icon, required this.title, required this.onTap, super.key, this.subtitle, this.badge});

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => CRow(
        title: title,
        subtitle: subtitle,
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: CRole.of(context).light, borderRadius: BorderRadius.circular(NRadius.md)),
          child: Icon(icon, color: CRole.of(context).accent),
        ),
        trailing: badge == null ? null : CPill(badge!, tone: CTone.apricot),
      );
}

/// Fades and lifts its child in once (respects reduced motion).
class CEntrance extends StatelessWidget {
  const CEntrance({required this.child, super.key, this.delayMs = 0});

  final Widget child;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    if (NMotionRules.reduced(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delayMs),
      curve: Interval(delayMs / (420 + delayMs), 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (BuildContext context, double t, Widget? c) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 10 * (1 - t)), child: c)),
    );
  }
}

/// A horizontal progress bar in a brand colour.
class CBar extends StatelessWidget {
  const CBar({required this.value, super.key, this.color = NColors.brandRosewood, this.height = 8});

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(NRadius.pill),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: NMotionRules.reduced(context) ? value : 0, end: value.clamp(0, 1)),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (BuildContext context, double v, _) => LinearProgressIndicator(value: v, minHeight: height, color: color, backgroundColor: NColors.surfaceBackdrop),
        ),
      );
}

/// Section label in small caps above a group of rows.
class CLabel extends StatelessWidget {
  const CLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: NSpace.sm, bottom: NSpace.xs),
        child: Text(text.toUpperCase(), style: NType.label.copyWith(color: NColors.inkMuted, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
      );
}
