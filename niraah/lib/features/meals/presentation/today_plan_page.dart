import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../domain/meals.dart';
import 'meal_scan_page.dart';
import 'meal_widgets.dart';

/// Today's meals of her diet plan (spec 010 §6b rule 4): what a meal-time reminder opens. Each meal shows its dishes
/// with portions, "I ate this" and "Scan my meal". Either one is recorded against that plan meal and counts towards her
/// streak (AC73). The plan is her dietitian's when she has one, otherwise her AI plan, which keeps its caution
/// (spec 010 §6a rule 3). Nothing here mentions a missed meal or her streak (spec 010 §6b rule 6).
class TodayPlanPage extends StatefulWidget {
  const TodayPlanPage({super.key, this.repository, this.focusSlot, this.now});

  final MealsRepository? repository;

  /// The meal the reminder was for; otherwise the latest meal whose time has come.
  final String? focusSlot;

  /// For tests.
  final DateTime Function()? now;

  @override
  State<TodayPlanPage> createState() => _TodayPlanPageState();
}

class _Today {
  const _Today(this.times, this.meals);

  final MealTimes times;
  final List<PlanMealToday> meals;
}

class _TodayPlanPageState extends State<TodayPlanPage> {
  late final MealsRepository _repo = widget.repository ?? getIt<MealsRepository>();
  late Future<_Today> _today = _load();
  final Set<String> _logged = <String>{};
  String? _busy;

  Future<_Today> _load() async {
    final MealTimes times = await _repo.mealTimes();
    if (!times.hasPlan) return _Today(times, const <PlanMealToday>[]);
    final List<PlanMealToday> all = await Future.wait(<Future<PlanMealToday>>[for (final String slot in planMealSlots) _repo.planMealToday(slot)]);
    return _Today(times, <PlanMealToday>[for (final PlanMealToday m in all) if (m.dishes.isNotEmpty) m]);
  }

  /// The meal the page opens on: the reminder's, or the latest one whose time has come today.
  String? _focus(_Today t) {
    if (widget.focusSlot != null) return widget.focusSlot;
    final DateTime now = (widget.now ?? DateTime.now)();
    final int minutes = now.hour * 60 + now.minute;
    String? best;
    for (final PlanMealToday m in t.meals) {
      final String time = _timeOf(t, m.slot);
      if (int.parse(time.substring(0, 2)) * 60 + int.parse(time.substring(3, 5)) <= minutes) best = m.slot;
    }
    return best ?? (t.meals.isEmpty ? null : t.meals.first.slot);
  }

  String _timeOf(_Today t, String slot) => t.times.slots.firstWhere((MealTime x) => x.slot == slot, orElse: () => MealTime(slot: slot, name: slot, time: '00:00', enabled: false)).time;

  Future<void> _ateThis(PlanMealToday m) async {
    final S s = S.of(context);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: Text(s.todayPlanConfirmTitle(m.name)),
        content: Text(<String>[for (final PlanDish d in m.dishes) '${d.name} · ${formatNumber(d.count)} ${d.unit}'].join('\n')),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text(s.commonCancel)),
          TextButton(onPressed: () => Navigator.of(c).pop(true), child: Text(s.todayPlanAteThis)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = m.slot);
    try {
      await _repo.save(
        eatenAt: DateTime.now(),
        slot: m.logSlot,
        fromScan: false,
        items: <MealItemInput>[for (final PlanDish d in m.dishes) MealItemInput(foodId: d.foodId!, count: d.count, unit: d.unit)],
        planMeal: PlanMealRef(slot: m.slot, fromPlan: true),
      );
      if (!mounted) return;
      setState(() => _logged.add(m.slot));
      showNote(context, s.todayPlanLogged);
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _scan(PlanMealToday m) async {
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => MealScanPage(repository: _repo, planMeal: PlanMealRef(slot: m.slot), initialSlot: m.logSlot)),
    );
    if (saved == true && mounted) setState(() => _logged.add(m.slot));
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.todayPlanTitle,
      body: AsyncBody<_Today>(
        future: _today,
        onRetry: () => setState(() => _today = _load()),
        builder: (BuildContext context, _Today t) {
          if (t.meals.isEmpty) {
            return ListView(padding: const EdgeInsets.all(NSpace.lg), children: <Widget>[EmptyNote(text: t.times.hasPlan ? s.todayPlanNoMeals : s.todayPlanNone)]);
          }
          final String? focus = _focus(t);
          final String? caution = t.meals.first.caution;
          return ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              Text(t.times.planSource == 'ai' ? s.todayPlanFromAi : s.todayPlanFromDietitian, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              if (caution != null) ...<Widget>[
                const SizedBox(height: NSpace.xs),
                MealCard(color: NColors.brandApricotLight, child: Text(caution, style: NType.bodySm.copyWith(color: NColors.inkPrimary))),
              ],
              for (final PlanMealToday m in t.meals) ...<Widget>[
                const SizedBox(height: NSpace.sm),
                MealCard(
                  key: ValueKey<String>('plan-meal-${m.slot}'),
                  color: m.slot == focus ? NColors.brandBlushLight : NColors.surfaceCard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Semantics(
                        header: true,
                        child: Text('${m.name} · ${_timeOf(t, m.slot)}', style: NType.h4.copyWith(color: NColors.inkPrimary)),
                      ),
                      for (final PlanDish d in m.dishes)
                        Padding(
                          padding: const EdgeInsets.only(top: NSpace.xs),
                          child: Text('${d.name} · ${formatNumber(d.count)} ${d.unit}', style: NType.body.copyWith(color: NColors.inkPrimary)),
                        ),
                      const SizedBox(height: NSpace.sm),
                      if (_logged.contains(m.slot))
                        Text(s.todayPlanLogged, style: NType.bodySm.copyWith(color: NColors.statusSuccess, fontWeight: FontWeight.w600))
                      else ...<Widget>[
                        if (m.canLogAsPlanned)
                          NPrimaryButton(label: s.todayPlanAteThis, loading: _busy == m.slot, onPressed: _busy == null ? () => _ateThis(m) : null)
                        else
                          Text(s.todayPlanRecipeNote, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                        const SizedBox(height: NSpace.xs),
                        NSecondaryButton(label: s.todayPlanScan, onPressed: _busy == null ? () => _scan(m) : null),
                      ],
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
