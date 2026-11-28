import 'package:material_ui/material_ui.dart';

import '../../../design_system/tokens/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/meals.dart';

/// Shared pieces of the meal screens (spec 010 §6).

String formatNumber(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

String slotName(S s, MealSlot slot) => switch (slot) {
  MealSlot.breakfast => s.mealsSlotBreakfast,
  MealSlot.lunch => s.mealsSlotLunch,
  MealSlot.dinner => s.mealsSlotDinner,
  MealSlot.snack => s.mealsSlotSnack,
};

/// A sensible default from the time of day; she can change it.
MealSlot slotForNow(DateTime now) {
  final int h = now.hour;
  if (h >= 5 && h < 11) return MealSlot.breakfast;
  if (h >= 11 && h < 16) return MealSlot.lunch;
  if (h >= 19 || h < 2) return MealSlot.dinner;
  return MealSlot.snack;
}

String? tagName(S s, String tag) => switch (tag) {
  'low_gi' => s.mealsTagLowGi,
  'high_protein' => s.mealsTagHighProtein,
  'high_fibre' => s.mealsTagHighFibre,
  'pcos_friendly' => s.mealsTagPcosFriendly,
  'under_400_kcal' => s.mealsTagUnder400,
  _ => null,
};

class MealCard extends StatelessWidget {
  MealCard({required this.child, Color? color, super.key}) : color = color ?? NColors.surfaceCard;

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(NSpace.lg),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(NRadius.xl),
      border: Border.all(color: NColors.lineDefault),
      boxShadow: NShadow.xs,
    ),
    child: child,
  );
}

/// Calories (unless hidden for her), protein, carbohydrate, fat and fibre, all from the food table.
class NutrientRow extends StatelessWidget {
  const NutrientRow({required this.n, super.key});

  final Nutrients n;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<String> parts = <String>[
      if (n.energyKcal != null) s.mealsKcal(formatNumber(n.energyKcal!)),
      s.mealsProtein(formatNumber(n.proteinG)),
      s.mealsCarbs(formatNumber(n.carbohydrateG)),
      s.mealsFat(formatNumber(n.fatG)),
      s.mealsFibre(formatNumber(n.fibreG)),
    ];
    return Wrap(
      spacing: NSpace.xs,
      runSpacing: NSpace.xxs,
      children: <Widget>[
        for (String p in parts)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: NSpace.xxs),
            decoration: BoxDecoration(color: NColors.surfacePage, borderRadius: BorderRadius.circular(NRadius.pill)),
            child: Text(p, style: NType.caption.copyWith(color: NColors.inkSecondary)),
          ),
      ],
    );
  }
}

class TagChips extends StatelessWidget {
  const TagChips({required this.tags, super.key});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<String> names = <String>[for (String t in tags) ?tagName(s, t)];
    if (names.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: NSpace.xs,
      runSpacing: NSpace.xxs,
      children: <Widget>[
        for (String n in names)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: NSpace.xxs),
            decoration: BoxDecoration(color: NColors.brandSageLight, borderRadius: BorderRadius.circular(NRadius.pill)),
            child: Text(
              n,
              style: NType.caption.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}
