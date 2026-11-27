import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../theme/theme_controller.dart';
import '../tokens/tokens.dart';

/// Light or dark: one row of two choices, used in Me and in each expert's More. Until she picks one the app
/// follows the phone, and the row shows whichever look is on screen.
class NAppearanceCard extends StatelessWidget {
  const NAppearanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (!NThemeController.darkModeEnabled) return const SizedBox.shrink();
    final S s = S.of(context);
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: NThemeController.instance,
      builder: (BuildContext context, ThemeMode mode, _) => Container(
        padding: const EdgeInsets.all(NSpace.md),
        decoration: BoxDecoration(
          color: NColors.surfaceCard,
          borderRadius: BorderRadius.circular(NRadius.lg),
          border: Border.all(color: NColors.lineDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.dark_mode_outlined, color: NColors.inkSecondary),
                const SizedBox(width: NSpace.sm),
                Text(
                  s.appearanceTitle,
                  style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: NSpace.xxs),
            Text(s.appearanceHint, style: NType.caption.copyWith(color: NColors.inkMuted)),
            const SizedBox(height: NSpace.sm),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: <ButtonSegment<ThemeMode>>[
                  ButtonSegment<ThemeMode>(value: ThemeMode.light, label: Text(s.appearanceLight), icon: const Icon(Icons.light_mode_outlined, size: 18)),
                  ButtonSegment<ThemeMode>(value: ThemeMode.dark, label: Text(s.appearanceDark), icon: const Icon(Icons.dark_mode_outlined, size: 18)),
                ],
                selected: <ThemeMode>{NThemeController.instance.isDark ? ThemeMode.dark : ThemeMode.light},
                onSelectionChanged: (Set<ThemeMode> v) => NThemeController.instance.set(v.first),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The light/dark switch at the top of the main screens: a small pill with a sun and a moon. The chosen side is
/// filled; tapping the other side switches the whole app at once and the choice is saved on the phone.
class NThemeToggle extends StatelessWidget {
  const NThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    if (!NThemeController.darkModeEnabled) return const SizedBox.shrink();
    final S s = S.of(context);
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: NThemeController.instance,
      builder: (BuildContext context, ThemeMode _, _) {
        final bool dark = NThemeController.instance.isDark;
        return Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: NColors.surfaceCard,
            borderRadius: BorderRadius.circular(NRadius.pill),
            border: Border.all(color: NColors.lineDefault),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.35 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _Side(
                key: const Key('theme-light'),
                icon: Icons.light_mode_rounded,
                label: s.appearanceLight,
                on: !dark,
                onTap: () => NThemeController.instance.set(ThemeMode.light),
              ),
              _Side(
                key: const Key('theme-dark'),
                icon: Icons.dark_mode_rounded,
                label: s.appearanceDark,
                on: dark,
                onTap: () => NThemeController.instance.set(ThemeMode.dark),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({required this.icon, required this.label, required this.on, required this.onTap, super.key});

  final IconData icon;
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: on,
    label: label,
    excludeSemantics: true,
    // No Tooltip: the switch sits above the app's Navigator, where there is no Overlay for one.
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: on ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: 40,
        height: 34,
        decoration: BoxDecoration(color: on ? NColors.brandBlushLight : Colors.transparent, borderRadius: BorderRadius.circular(NRadius.pill)),
        child: Icon(icon, size: 18, color: on ? NColors.inkPrimary : NColors.inkMuted),
      ),
    ),
  );
}
