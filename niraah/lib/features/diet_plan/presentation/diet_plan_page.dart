import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/errors/api_exception.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../design_system/widgets/n_living.dart';
import '../../../design_system/widgets/n_loaders.dart';
import '../../../design_system/widgets/n_premium_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/constants/route_constants.dart';
import '../domain/diet_plan.dart';

/// The AI diet plan (spec 010 §6a): food profile first, then a week of Indian meals with reasons and
/// swaps, the cautions always on screen, and a new week once a day. AC61, AC64, AC65.
class DietPlanPage extends StatefulWidget {
  const DietPlanPage({super.key, this.repository});

  final DietPlanRepository? repository;

  @override
  State<DietPlanPage> createState() => _DietPlanPageState();
}

class _DietPlanPageState extends State<DietPlanPage> {
  late final DietPlanRepository _repo = widget.repository ?? getIt<DietPlanRepository>();
  late Future<DietPlanState> _state = _repo.open();
  bool _editing = false;
  int _day = 0;
  bool _busy = false;

  /// A new week is being made: the whole page shows the cooking animation (it can take up to a minute).
  bool _cooking = false;

  void _reload() => setState(() {
    _editing = false;
    _state = _repo.open();
  });

  Future<void> _run(Future<DietPlanState> Function() f) async {
    setState(() => _busy = true);
    try {
      final DietPlanState next = await f();
      if (mounted) setState(() => _state = Future<DietPlanState>.value(next));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _newWeek() async {
    setState(() => _cooking = true);
    await _run(_repo.newWeek);
    if (mounted) setState(() => _cooking = false);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Scaffold(
      backgroundColor: NColors.surfacePage,
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[Text(s.dietTitle), const SizedBox(width: NSpace.sm), const NPremiumBadge()]),
        backgroundColor: NColors.surfacePage,
        actions: <Widget>[if (!_editing) IconButton(tooltip: s.dietEditPreferences, onPressed: () => setState(() => _editing = true), icon: const Icon(Icons.tune_rounded))],
      ),
      body: SafeArea(
        child: FutureBuilder<DietPlanState>(
          future: _state,
          builder: (BuildContext context, AsyncSnapshot<DietPlanState> snap) {
            if (snap.hasError) {
              final Object e = snap.error!;
              return ErrorView(message: e is ApiException ? e.message : s.notConnectedYet, retryLabel: s.tryAgain, onRetry: _reload);
            }
            if (!snap.hasData || _cooking) return const DietCookingView();
            final DietPlanState st = snap.data!;
            if (_editing || st is DietNeedsProfile) {
              return _ProfileForm(repo: _repo, onSaved: _reload, firstTime: st is DietNeedsProfile);
            }
            return switch (st) {
              DietLocked(:final List<String> plans) => _Message(
                icon: Icons.lock_outline_rounded,
                title: s.dietLockedTitle,
                body: plans.isEmpty ? s.dietLockedBody : s.dietLockedPlans(plans.join(', ')),
                action: NPrimaryButton(label: s.dietSeePlans, onPressed: () => context.push(RouteConstants.plans)),
              ),
              DietNeedsDietitian(:final String message) => _Message(icon: Icons.health_and_safety_outlined, title: s.dietNeedsDietitianTitle, body: message),
              DietDietitianPlan() => _Message(icon: Icons.restaurant_menu_rounded, title: s.dietDietitianPlanTitle, body: s.dietDietitianPlanBody),
              DietUnavailable(:final String message) => _Message(
                icon: Icons.cloud_off_rounded,
                title: s.dietUnavailableTitle,
                body: message,
                action: NSecondaryButton(label: s.tryAgain, onPressed: _reload),
              ),
              DietReady() => _plan(context, st),
              DietNeedsProfile() => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  Widget _plan(BuildContext context, DietReady p) {
    final S s = S.of(context);
    final String locale = Localizations.localeOf(context).toString();
    final int day = _day.clamp(0, p.days.length - 1);
    final DietDay d = p.days[day];
    return ListView(
      padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.sm, NSpace.lg, NSpace.xl2),
      children: nStagger(<Widget>[
        // AC61: the cautions sit at the top and cannot be dismissed.
        Container(
          padding: const EdgeInsets.all(NSpace.md),
          decoration: BoxDecoration(color: NColors.statusWarningLight, borderRadius: BorderRadius.circular(NRadius.lg)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.info_outline_rounded, size: 18, color: NColors.statusWarningText),
                  const SizedBox(width: NSpace.xs),
                  Expanded(
                    child: Text(
                      p.madeByModel ? s.dietMadeByAi : s.dietMadeByRules,
                      style: NType.label.copyWith(color: NColors.statusWarningText, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NSpace.xs),
              for (final String c in p.cautions)
                Padding(
                  padding: const EdgeInsets.only(top: NSpace.xxs),
                  child: Text('• $c', style: NType.bodySm.copyWith(color: NColors.inkPrimary)),
                ),
              if (p.starterDataNote != null) ...<Widget>[
                const SizedBox(height: NSpace.xs),
                Text(
                  p.starterDataNote!,
                  style: NType.bodySm.copyWith(color: NColors.inkSecondary, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: NSpace.md),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: p.days.length,
            separatorBuilder: (_, _) => const SizedBox(width: NSpace.xs),
            itemBuilder: (BuildContext context, int i) {
              final bool on = i == day;
              final DateTime date = p.days[i].date;
              return NPressable(
                child: InkWell(
                  borderRadius: BorderRadius.circular(NRadius.lg),
                  onTap: () => setState(() => _day = i),
                  child: AnimatedContainer(
                    duration: NMotion.fast,
                    width: 56,
                    decoration: BoxDecoration(
                      color: on ? NColors.brandPlum : NColors.surfaceCard,
                      borderRadius: BorderRadius.circular(NRadius.lg),
                      border: Border.all(color: on ? NColors.brandPlum : NColors.lineDefault),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(DateFormat.E(locale).format(date), style: NType.label.copyWith(color: on ? NColors.inkOnBrand : NColors.inkMuted)),
                        Text('${date.day}', style: NType.h4.copyWith(color: on ? NColors.inkOnBrand : NColors.inkPrimary)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: NSpace.sm),
        Text(p.shortCaution, style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0.4)),
        const SizedBox(height: NSpace.sm),
        for (final DietMeal m in d.meals) ...<Widget>[
          _MealCard(meal: m, busy: _busy, onSwap: (DietItem item, String? foodId) => _run(() => _repo.swap(item.id, foodId))),
          const SizedBox(height: NSpace.sm),
        ],
        _Totals(n: d.totals, caloriesHidden: p.caloriesHidden),
        const SizedBox(height: NSpace.lg),
        NSecondaryButton(label: p.canMakeNewWeek ? s.dietNewWeek : s.dietNewWeekTomorrow, onPressed: p.canMakeNewWeek && !_busy ? _newWeek : null),
      ]),
    );
  }
}

String dietSlotName(S s, String slot) => switch (slot) {
  'breakfast' => s.dietSlotBreakfast,
  'mid_morning' => s.dietSlotMidMorning,
  'lunch' => s.dietSlotLunch,
  'evening_snack' => s.dietSlotEveningSnack,
  _ => s.dietSlotDinner,
};

String _portion(double count, String unit) {
  final String n = count == count.roundToDouble() ? count.toInt().toString() : count.toString();
  return '$n ${unit.replaceAll('_', ' ')}';
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, required this.onSwap, required this.busy});

  final DietMeal meal;
  final bool busy;
  final void Function(DietItem item, String? foodId) onSwap;

  static const Map<String, Color> _tints = <String, Color>{
    'breakfast': NColors.brandApricotLight,
    'mid_morning': NColors.brandSageLight,
    'lunch': NColors.brandBlushLight,
    'evening_snack': NColors.brandLavenderLight,
    'dinner': NColors.answerPeach,
  };

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Container(
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
              NSquircleIcon(icon: Icons.restaurant_rounded, size: 36, tint: _tints[meal.slot] ?? NColors.brandBlushLight),
              const SizedBox(width: NSpace.sm),
              Expanded(
                child: Text(dietSlotName(s, meal.slot), style: NType.h4.copyWith(color: NColors.inkPrimary)),
              ),
            ],
          ),
          if (meal.reason != null) ...<Widget>[const SizedBox(height: NSpace.xs), Text(meal.reason!, style: NType.bodySm.copyWith(color: NColors.inkSecondary))],
          const SizedBox(height: NSpace.xs),
          for (final DietItem i in meal.items)
            Padding(
              padding: const EdgeInsets.only(top: NSpace.xxs),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: i.food.name,
                            style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: '  ·  ${_portion(i.count, i.unit)}',
                            style: NType.bodySm.copyWith(color: NColors.inkMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i.swaps.isNotEmpty) TextButton.icon(onPressed: busy ? null : () => _pickSwap(context, i), icon: const Icon(Icons.swap_horiz_rounded, size: 18), label: Text(s.dietSwap)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickSwap(BuildContext context, DietItem i) async {
    final S s = S.of(context);
    final DietOption? pick = await showModalBottomSheet<DietOption>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(NSpace.lg, 0, NSpace.lg, NSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(s.dietSwapTitle(i.food.name), style: NType.h3.copyWith(color: NColors.inkPrimary)),
              const SizedBox(height: NSpace.xs),
              Text(s.dietSwapBody, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              const SizedBox(height: NSpace.md),
              for (final DietOption o in i.swaps)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const NSquircleIcon(icon: Icons.restaurant_menu_rounded, size: 40),
                  title: Text(o.name, style: NType.body.copyWith(color: NColors.inkPrimary)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).pop(o),
                ),
            ],
          ),
        ),
      ),
    );
    if (pick != null) onSwap(i, pick.id);
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.n, required this.caloriesHidden});

  final DietNutrients n;
  final bool caloriesHidden;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    Widget cell(String label, String value) => Expanded(
      child: Column(
        children: <Widget>[
          Text(value, style: NType.h4.copyWith(color: NColors.inkPrimary)),
          Text(label, style: NType.label.copyWith(color: NColors.inkMuted)),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: NSpace.md, horizontal: NSpace.sm),
      decoration: BoxDecoration(color: NColors.brandSageLight, borderRadius: BorderRadius.circular(NRadius.lg)),
      child: Column(
        children: <Widget>[
          Text(
            s.dietDayTotals,
            style: NType.label.copyWith(color: NColors.inkSecondary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: NSpace.xs),
          Row(
            children: <Widget>[
              if (!caloriesHidden && n.energyKcal != null) cell(s.dietKcal, n.energyKcal!.round().toString()),
              cell(s.dietProtein, '${n.proteinG.round()} g'),
              cell(s.dietFibre, '${n.fibreG.round()} g'),
              cell(s.dietCarbs, '${n.carbohydrateG.round()} g'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, required this.body, this.action});

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(NSpace.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          NSquircleIcon(icon: icon, size: 64),
          const SizedBox(height: NSpace.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: NType.h3.copyWith(color: NColors.inkPrimary),
          ),
          const SizedBox(height: NSpace.xs),
          Text(
            body,
            textAlign: TextAlign.center,
            style: NType.body.copyWith(color: NColors.inkSecondary),
          ),
          if (action != null) ...<Widget>[const SizedBox(height: NSpace.lg), action!],
        ],
      ),
    ),
  );
}

/// Food choice, allergies (with an explicit "No allergies"), cuisine, fasting days and avoided foods (AC64).
class _ProfileForm extends StatefulWidget {
  const _ProfileForm({required this.repo, required this.onSaved, required this.firstTime});

  final DietPlanRepository repo;
  final VoidCallback onSaved;
  final bool firstTime;

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  String? _choice;
  final Set<String> _allergens = <String>{};
  bool _noAllergies = false;
  String _cuisine = 'pan_indian';
  final Set<int> _fasting = <int>{};
  final Set<String> _avoided = <String>{};
  List<DietOption> _foods = const <DietOption>[];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    () async {
      try {
        final FoodProfile? p = await widget.repo.profile();
        final List<DietOption> foods = await widget.repo.foods();
        if (!mounted) return;
        setState(() {
          _foods = foods;
          if (p != null) {
            _choice = p.foodChoice;
            _allergens.addAll(p.allergens);
            _noAllergies = p.noAllergies;
            _cuisine = p.cuisine;
            _fasting.addAll(p.fastingDays);
            _avoided.addAll(p.avoidedFoodIds);
          }
          _loading = false;
        });
      } catch (_) {
        if (mounted) setState(() => _loading = false);
      }
    }();
  }

  bool get _ready => _choice != null && (_noAllergies || _allergens.isNotEmpty);

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repo.saveProfile(
        FoodProfile(
          foodChoice: _choice!,
          allergens: _noAllergies ? <String>[] : _allergens.toList(),
          noAllergies: _noAllergies,
          avoidedFoodIds: _avoided.toList(),
          cuisine: _cuisine,
          fastingDays: _fasting.toList()..sort(),
        ),
      );
      widget.onSaved();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    if (_loading) return const DietCookingView(preparing: true);
    Widget title(String t) => Padding(
      padding: const EdgeInsets.only(top: NSpace.lg, bottom: NSpace.xs),
      child: Text(t, style: NType.h4.copyWith(color: NColors.inkPrimary)),
    );
    Widget chip(String label, bool on, VoidCallback tap) => FilterChip(label: Text(label), selected: on, onSelected: (_) => tap());
    final List<String> days = <String>[s.dietSun, s.dietMon, s.dietTue, s.dietWed, s.dietThu, s.dietFri, s.dietSat];
    return ListView(
      padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.sm, NSpace.lg, NSpace.xl2),
      children: <Widget>[
        Text(widget.firstTime ? s.dietProfileTitle : s.dietEditPreferences, style: NType.h2.copyWith(color: NColors.inkPrimary)),
        const SizedBox(height: NSpace.xs),
        Text(s.dietProfileBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
        title(s.dietFoodChoice),
        Wrap(
          spacing: NSpace.xs,
          runSpacing: NSpace.xs,
          children: <Widget>[for (final String c in FoodProfile.foodChoices) chip(dietChoiceName(s, c), _choice == c, () => setState(() => _choice = c))],
        ),
        title(s.dietAllergies),
        Wrap(
          spacing: NSpace.xs,
          runSpacing: NSpace.xs,
          children: <Widget>[
            chip(
              s.dietNoAllergies,
              _noAllergies,
              () => setState(() {
                _noAllergies = !_noAllergies;
                if (_noAllergies) _allergens.clear();
              }),
            ),
            for (final String a in FoodProfile.allAllergens)
              chip(
                dietAllergenName(s, a),
                _allergens.contains(a),
                () => setState(() {
                  _noAllergies = false;
                  _allergens.contains(a) ? _allergens.remove(a) : _allergens.add(a);
                }),
              ),
          ],
        ),
        title(s.dietCuisine),
        Wrap(
          spacing: NSpace.xs,
          runSpacing: NSpace.xs,
          children: <Widget>[for (final String c in FoodProfile.cuisines) chip(dietCuisineName(s, c), _cuisine == c, () => setState(() => _cuisine = c))],
        ),
        title(s.dietFastingDays),
        Wrap(
          spacing: NSpace.xs,
          runSpacing: NSpace.xs,
          children: <Widget>[
            for (final int d in <int>[1, 2, 3, 4, 5, 6, 0]) chip(days[d], _fasting.contains(d), () => setState(() => _fasting.contains(d) ? _fasting.remove(d) : _fasting.add(d))),
          ],
        ),
        title(s.dietAvoided),
        OutlinedButton.icon(
          onPressed: _foods.isEmpty ? null : _pickAvoided,
          icon: const Icon(Icons.no_food_outlined),
          label: Text(_avoided.isEmpty ? s.dietAvoidedNone : s.dietAvoidedCount(_avoided.length)),
        ),
        if (_error != null) ...<Widget>[const SizedBox(height: NSpace.md), Text(_error!, style: NType.bodySm.copyWith(color: NColors.statusAttention))],
        const SizedBox(height: NSpace.xl),
        NPrimaryButton(label: s.dietSaveAndMake, inactiveHint: s.dietProfileHint, loading: _saving, onPressed: _ready ? _save : null),
      ],
    );
  }

  Future<void> _pickAvoided() async {
    final S s = S.of(context);
    final Set<String> picked = <String>{..._avoided};
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter set) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.7,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(NSpace.md),
                  child: Text(s.dietAvoided, style: NType.h3.copyWith(color: NColors.inkPrimary)),
                ),
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      for (final DietOption f in _foods)
                        CheckboxListTile(value: picked.contains(f.id), title: Text(f.name), onChanged: (bool? v) => set(() => v == true ? picked.add(f.id) : picked.remove(f.id))),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(NSpace.md),
                  child: NPrimaryButton(label: s.dietDone, onPressed: () => Navigator.of(context).pop()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    setState(
      () => _avoided
        ..clear()
        ..addAll(picked),
    );
  }
}

String dietChoiceName(S s, String c) => switch (c) {
  'vegetarian' => s.dietVegetarian,
  'eggetarian' => s.dietEggetarian,
  'non_vegetarian' => s.dietNonVegetarian,
  'vegan' => s.dietVegan,
  _ => s.dietJain,
};

String dietCuisineName(S s, String c) => switch (c) {
  'north_indian' => s.dietNorthIndian,
  'south_indian' => s.dietSouthIndian,
  'east_indian' => s.dietEastIndian,
  'west_indian' => s.dietWestIndian,
  _ => s.dietPanIndian,
};

String dietAllergenName(S s, String a) => switch (a) {
  'peanut' => s.dietPeanut,
  'tree_nut' => s.dietTreeNut,
  'gluten' => s.dietGluten,
  'milk' => s.dietMilk,
  'egg' => s.dietEgg,
  'soy' => s.dietSoy,
  'sesame' => s.dietSesame,
  'mustard' => s.dietMustard,
  'fish' => s.dietFish,
  _ => s.dietShellfish,
};

/// The wait while a plan is cooked: the kadhai animation, "Cooking your plan…" and what is happening now.
class DietCookingView extends StatelessWidget {
  const DietCookingView({super.key, this.preparing = false});

  /// Opening the food preferences: a shorter wait, so no steps.
  final bool preparing;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(NSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const NCookingAnimation(),
            const SizedBox(height: NSpace.md),
            Text(preparing ? s.dietPreparing : s.dietCooking, textAlign: TextAlign.center, style: NType.h3.copyWith(color: NColors.inkPrimary)),
            if (!preparing) ...<Widget>[
              const SizedBox(height: NSpace.sm),
              NRotatingStatus(lines: <String>[s.dietCook1, s.dietCook2, s.dietCook3, s.dietCook4, s.dietCook5]),
              const SizedBox(height: NSpace.lg),
              Text(s.dietMakingHint, textAlign: TextAlign.center, style: NType.caption.copyWith(color: NColors.inkMuted)),
            ],
          ],
        ),
      ),
    );
  }
}
