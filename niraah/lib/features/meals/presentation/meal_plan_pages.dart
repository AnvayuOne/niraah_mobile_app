import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_widgets.dart';
import '../domain/meals.dart';
import 'meal_widgets.dart';

/// Her meal history (spec 010 §6 rule 5): the days she logged meals in the last 30 days, as what she did. No missed days
/// are counted (spec 010 §6 rule 10).
class MealHistoryPage extends StatefulWidget {
  const MealHistoryPage({super.key, this.repository});

  final MealsRepository? repository;

  @override
  State<MealHistoryPage> createState() => _MealHistoryPageState();
}

class _MealHistoryPageState extends State<MealHistoryPage> {
  late final MealsRepository _repo = widget.repository ?? getIt<MealsRepository>();
  late Future<List<MealHistoryDay>> _days = _repo.history();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.mealsHistoryTitle,
      body: AsyncBody<List<MealHistoryDay>>(
        future: _days,
        onRetry: () => setState(() => _days = _repo.history()),
        builder: (BuildContext context, List<MealHistoryDay> days) => ListView(
          padding: const EdgeInsets.all(NSpace.lg),
          children: <Widget>[
            if (days.isEmpty) EmptyNote(text: s.mealsHistoryEmpty),
            for (final MealHistoryDay d in days) ...<Widget>[
              NCard(
                child: MergeSemantics(
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Text(shortDate(context, d.day), style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600))),
                      Text(s.mealsHistoryCount(d.meals), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: NSpace.xs),
            ],
          ],
        ),
      ),
    );
  }
}

String _slotName(S s, String slot) => switch (slot) {
      'early_morning' => s.mealPlanSlotEarly,
      'breakfast' => s.mealsSlotBreakfast,
      'mid_morning' => s.mealPlanSlotMidMorning,
      'lunch' => s.mealsSlotLunch,
      'evening_snack' => s.mealPlanSlotEvening,
      'dinner' => s.mealsSlotDinner,
      'bedtime' => s.mealPlanSlotBedtime,
      _ => slot,
    };

/// Her meal plan from her dietitian (spec 012 §4 "Publishing" 2; spec 010 §6 rule 5): one day at a time, each meal's
/// dishes with portions in household units, the dietitian's notes and alternatives, and day totals from the food table.
class MealPlanPage extends StatefulWidget {
  const MealPlanPage({super.key, this.repository});

  final MealsRepository? repository;

  @override
  State<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  late final MealsRepository _repo = widget.repository ?? getIt<MealsRepository>();
  late Future<MealPlan?> _plan = _repo.mealPlan();
  int? _day;

  /// Today's day of the plan, when the plan covers today.
  int _initialDay(MealPlan p) {
    final DateTime now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final String today = '${now.year}-${two(now.month)}-${two(now.day)}';
    final int i = p.days.indexWhere((MealPlanDay d) => d.date == today);
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.mealPlanTitle,
      body: AsyncBody<MealPlan?>(
        future: _plan,
        onRetry: () => setState(() => _plan = _repo.mealPlan()),
        builder: (BuildContext context, MealPlan? p) {
          if (p == null || p.days.isEmpty) {
            return ListView(padding: const EdgeInsets.all(NSpace.lg), children: <Widget>[EmptyNote(text: s.mealPlanNone)]);
          }
          final int index = (_day ?? _initialDay(p)).clamp(0, p.days.length - 1);
          final MealPlanDay day = p.days[index];
          return ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              if (p.title != null) Semantics(header: true, child: Text(p.title!, style: NType.h3.copyWith(color: NColors.inkPrimary))),
              if (p.dietitian != null) Text(s.mealPlanBy(p.dietitian!), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              const SizedBox(height: NSpace.sm),
              Row(
                children: <Widget>[
                  IconButton(tooltip: s.mealPlanPrevDay, onPressed: index == 0 ? null : () => setState(() => _day = index - 1), icon: const Icon(Icons.chevron_left_rounded)),
                  Expanded(
                    child: Text(s.mealPlanDay(index + 1, shortDate(context, day.date)), textAlign: TextAlign.center, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                  ),
                  IconButton(tooltip: s.mealPlanNextDay, onPressed: index >= p.days.length - 1 ? null : () => setState(() => _day = index + 1), icon: const Icon(Icons.chevron_right_rounded)),
                ],
              ),
              if (day.note != null) Text(day.note!, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              const SizedBox(height: NSpace.sm),
              MealCard(
                color: NColors.brandSageLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(s.mealsDayTotals, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                    const SizedBox(height: NSpace.xs),
                    NutrientRow(n: day.totals),
                  ],
                ),
              ),
              for (final MealPlanSlot slot in day.slots) ...<Widget>[
                const SizedBox(height: NSpace.sm),
                MealCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(_slotName(s, slot.slot), style: NType.h4.copyWith(color: NColors.inkPrimary)),
                      for (final MealPlanItem i in slot.items)
                        Padding(
                          padding: const EdgeInsets.only(top: NSpace.xs),
                          child: MergeSemantics(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('${i.name} · ${formatNumber(i.count)} ${i.unit}', style: NType.body.copyWith(color: NColors.inkPrimary)),
                                if (i.notes != null) Text(i.notes!, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                                if (i.alternatives.isNotEmpty) Text(s.mealPlanOr(i.alternatives.join(', ')), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: NSpace.xs),
                      NutrientRow(n: slot.totals),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
