import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/di/service_locator.dart';
import '../../design_system/tokens/tokens.dart';
import '../../design_system/widgets/clinician_ui.dart';
import '../../design_system/widgets/n_button.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/area/area_access.dart';
import '../../shared/area/area_widgets.dart';
import '../doctor/presentation/patients_pages.dart';
import '../provider_work/domain/provider_work.dart';
import 'dietitian_pages.dart';
import 'dietitian_repository.dart';

const List<String> planSlots = <String>['early_morning', 'breakfast', 'mid_morning', 'lunch', 'evening_snack', 'dinner', 'bedtime'];
const List<String> planUnits = <String>['katori', 'piece', 'cup', 'plate', 'glass', 'tablespoon', 'teaspoon', 'slice', 'bowl', 'serving'];

String slotLabel(S s, String k) => switch (k) {
  'early_morning' => s.dtSlotEarly,
  'breakfast' => s.mealsSlotBreakfast,
  'mid_morning' => s.dtSlotMidMorning,
  'lunch' => s.mealsSlotLunch,
  'evening_snack' => s.dtSlotEvening,
  'dinner' => s.mealsSlotDinner,
  'bedtime' => s.dtSlotBedtime,
  _ => k,
};

String nutrientLine(S s, Json n) => <String>[
  if (n.number('energyKcal') != null) s.mealsKcal(n.number('energyKcal')!.toStringAsFixed(0)),
  s.mealsProtein(n.number('proteinG')?.toStringAsFixed(1) ?? '0'),
  s.mealsCarbs(n.number('carbohydrateG')?.toStringAsFixed(1) ?? '0'),
  s.mealsFat(n.number('fatG')?.toStringAsFixed(1) ?? '0'),
  s.mealsFibre(n.number('fibreG')?.toStringAsFixed(1) ?? '0'),
].join(' · ');

/// Protein, carbs and fat as shares of their energy in one split bar, with the computed figures beneath.
/// [compact] drops the big energy number.
class MacroSplit extends StatelessWidget {
  const MacroSplit({required this.nutrients, super.key, this.compact = false});

  final Json nutrients;
  final bool compact;

  static Color get protein => NColors.brandSage;
  static Color get carbs => NColors.brandApricot;
  static Color get fat => NColors.brandBlush;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final double p = (nutrients.number('proteinG') ?? 0).toDouble();
    final double c = (nutrients.number('carbohydrateG') ?? 0).toDouble();
    final double f = (nutrients.number('fatG') ?? 0).toDouble();
    final double total = p * 4 + c * 4 + f * 9;
    final num? kcal = nutrients.number('energyKcal');
    Widget key(Color col, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(width: 10, height: 10, decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label, style: NType.caption.copyWith(color: NColors.inkSecondary, letterSpacing: 0)),
      ],
    );
    return Semantics(
      label: nutrientLine(s, nutrients),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!compact && kcal != null) ...<Widget>[
            Text(
              s.mealsKcal(kcal.toStringAsFixed(0)),
              style: NType.h2.copyWith(color: NColors.inkPrimary, fontFamily: NType.body.fontFamily, fontWeight: FontWeight.w700, fontSize: 26, fontFeatures: const <FontFeature>[FontFeature.tabularFigures()]),
            ),
            const SizedBox(height: NSpace.xs),
          ],
          ClipRRect(
            borderRadius: BorderRadius.circular(NRadius.pill),
            child: SizedBox(
              height: compact ? 6 : 10,
              child: total <= 0
                  ? ColoredBox(color: NColors.surfaceBackdrop, child: SizedBox.expand())
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        for (final (double v, Color col) in <(double, Color)>[(p * 4, protein), (c * 4, carbs), (f * 9, fat)])
                          if (v > 0) Expanded(flex: (v * 10).round().clamp(1, 1 << 30), child: ColoredBox(color: col)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: NSpace.sm,
            runSpacing: 2,
            children: <Widget>[
              key(protein, s.mealsProtein(p.toStringAsFixed(1))),
              key(carbs, s.mealsCarbs(c.toStringAsFixed(1))),
              key(fat, s.mealsFat(f.toStringAsFixed(1))),
              if (!compact) key(NColors.surfaceBackdrop, s.mealsFibre(nutrients.number('fibreG')?.toStringAsFixed(1) ?? '0')),
              if (compact && kcal != null) Text(s.mealsKcal(kcal.toStringAsFixed(0)), style: NType.caption.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700, letterSpacing: 0)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Her meal plans and the clients waiting for one (spec 012 §1, §4).
class MealPlansPage extends StatefulWidget {
  const MealPlansPage({super.key, this.repository});

  final DietitianRepository? repository;

  @override
  State<MealPlansPage> createState() => _MealPlansPageState();
}

class _MealPlansPageState extends State<MealPlansPage> {
  late final DietitianRepository _repo = widget.repository ?? getIt<DietitianRepository>();
  late Future<(List<Json>, Json)> _data = _load();

  Future<(List<Json>, Json)> _load() async => (await _repo.plans(), await _repo.toBuild());

  Future<void> _start(String memberId) async {
    try {
      final Json p = await _repo.createPlan(memberId);
      if (!mounted) return;
      await context.push('/dietitian/meal-plans/${p.str('id')}');
      if (mounted) setState(() => _data = _load());
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.dtMealPlans,
      body: AsyncBody<(List<Json>, Json)>(
        future: _data,
        onRetry: () => setState(() => _data = _load()),
        builder: (BuildContext context, (List<Json>, Json) d) {
          final (List<Json> plans, Json build) = d;
          final List<Json> waiting = build.objs('needPlan');
          return ListView(
            padding: dtPagePadding,
            children: <Widget>[
              CHero(
                eyebrow: s.dtMealPlans,
                title: s.dtPlansCount(plans.length),
                subtitle: s.dtWaitingCount(waiting.length),
                child: CStatGrid(
                  children: <Widget>[
                    CHeroStat(label: s.dtNeedPlan, value: '${waiting.length}', icon: Icons.hourglass_top_rounded, alert: waiting.isNotEmpty),
                    CHeroStat(label: s.dtPlanActive, value: '${plans.where((Json p) => p.str('status') == 'active').length}', icon: Icons.check_circle_outline_rounded),
                    CHeroStat(label: s.dtPlanDraft, value: '${plans.where((Json p) => p.str('status') == 'draft').length}', icon: Icons.edit_note_rounded),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.md),
              CPanel(
                title: s.dtNeedPlan,
                icon: Icons.person_add_alt_outlined,
                child: waiting.isEmpty
                    ? CEmpty(icon: Icons.check_rounded, title: s.dtNobodyWaiting)
                    : Column(
                        children: <Widget>[
                          for (Json c in waiting)
                            Padding(
                              padding: const EdgeInsets.only(bottom: NSpace.xs),
                              child: Row(
                                children: <Widget>[
                                  CAvatar(name: c.str('member'), size: 36),
                                  const SizedBox(width: NSpace.sm),
                                  Expanded(
                                    child: Text(c.str('member') ?? s.drUnnamed, maxLines: 1, overflow: TextOverflow.ellipsis, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                                  ),
                                  TextButton.icon(onPressed: () => _start(c.str('memberId')!), icon: const Icon(Icons.add_rounded, size: 18), label: Text(s.dtNewPlan)),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
              CLabel(s.dtYourPlans),
              if (plans.isEmpty) CEmpty(icon: Icons.restaurant_rounded, title: s.dtNoPlans),
              for (int i = 0; i < plans.length; i++)
                CEntrance(
                  delayMs: 40 * i.clamp(0, 8),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: NSpace.xs),
                    child: CRow(
                      title: plans[i].str('member') ?? '',
                      subtitle: <String>[plans[i].str('title') ?? s.dtMealPlan, if (plans[i].str('endDate') != null) s.dtPlanUntil(shortDate(context, plans[i].str('endDate')!))].join(' · '),
                      leading: CAvatar(name: plans[i].str('member'), size: 40),
                      trailing: CPill(planStatusLabel(s, plans[i].str('status')), tone: planTone(plans[i].str('status'))),
                      onTap: () async {
                        await context.push('/dietitian/meal-plans/${plans[i].str('id')}');
                        if (mounted) setState(() => _data = _load());
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

String planStatusLabel(S s, String? st) => switch (st) {
  'draft' => s.dtPlanDraft,
  'scheduled' => s.dtPlanScheduled,
  'active' => s.dtPlanActive,
  'ended' => s.dtPlanEnded,
  _ => st ?? '',
};

/// The builder (spec 012 §4), one day at a time on a phone: slots with items from recipes or the food table,
/// portions in household units, computed totals against targets, warnings, confirmations, copy day, template,
/// publish; for an active plan, adjust from tomorrow or end. No figure is typed in and no AI drafts it.
class MealPlanBuilderPage extends StatefulWidget {
  const MealPlanBuilderPage({required this.planId, super.key, this.repository});

  final String planId;
  final DietitianRepository? repository;

  @override
  State<MealPlanBuilderPage> createState() => _MealPlanBuilderPageState();
}

class _MealPlanBuilderPageState extends State<MealPlanBuilderPage> {
  late final DietitianRepository _repo = widget.repository ?? getIt<DietitianRepository>();
  late String _id = widget.planId;
  late Future<Json> _plan = _repo.plan(_id);
  int _day = 0;
  bool _busy = false;

  Future<void> _apply(Future<Json> Function() f, {String? done}) async {
    setState(() => _busy = true);
    try {
      final Json p = await f();
      if (!mounted) return;
      setState(() {
        _id = p.str('id') ?? _id;
        _plan = Future<Json>.value(p);
      });
      if (done != null) showNote(context, done);
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addItem(String slot) async {
    final Json? pick = await showModalBottomSheet<Json>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DishPicker(repository: _repo),
    );
    if (pick == null || !mounted) return;
    if (pick.str('kind') == 'request') {
      // A requested food can be added once the nutrition team puts it in the table (§6 rule 6).
      showNote(context, S.of(context).dtRequested);
      return;
    }
    final (double, String)? portion = await _portion(pick.str('kind') == 'recipe' ? 'serving' : 'katori', 1);
    if (portion == null) return;
    await _apply(
      () => _repo.addItem(_id, <String, dynamic>{
        'dayIndex': _day,
        'slot': slot,
        if (pick.str('kind') == 'recipe') 'recipeId': pick.str('id') else 'foodId': pick.str('id'),
        'count': portion.$1,
        'unit': portion.$2,
      }),
    );
  }

  Future<(double, String)?> _portion(String unit, double count) async {
    final S s = S.of(context);
    final TextEditingController c = TextEditingController(text: count == count.roundToDouble() ? count.toStringAsFixed(0) : '$count');
    String u = unit;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext d) => StatefulBuilder(
        builder: (BuildContext d, StateSetter set) => AlertDialog(
          title: Text(s.dtPortion),
          content: Row(
            children: <Widget>[
              SizedBox(
                width: 72,
                child: TextField(controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              ),
              const SizedBox(width: NSpace.sm),
              Expanded(
                child: DropdownButton<String>(
                  value: u,
                  isExpanded: true,
                  items: <DropdownMenuItem<String>>[for (String x in planUnits) DropdownMenuItem<String>(value: x, child: Text(x))],
                  onChanged: (String? v) => set(() => u = v ?? u),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(s.commonCancel)),
            FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(s.drSave)),
          ],
        ),
      ),
    );
    final double? n = double.tryParse(c.text.trim());
    c.dispose();
    if (ok != true || n == null || n <= 0 || n > 20) return null;
    return (n, u);
  }

  Future<void> _targets(Json plan) async {
    final S s = S.of(context);
    final Json t = plan.obj('targets');
    final Map<String, (TextEditingController, TextEditingController)> f = <String, (TextEditingController, TextEditingController)>{
      for (String k in const <String>['energyKcal', 'proteinG', 'carbohydrateG', 'fatG', 'fibreG'])
        k: (TextEditingController(text: t.obj(k).number('min')?.toStringAsFixed(0) ?? ''), TextEditingController(text: t.obj(k).number('max')?.toStringAsFixed(0) ?? '')),
    };
    final Map<String, String> label = <String, String>{'energyKcal': s.dtEnergy, 'proteinG': s.dtProtein, 'carbohydrateG': s.dtCarbs, 'fatG': s.dtFat, 'fibreG': s.dtFibre};
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext d) => AlertDialog(
        title: Text(s.dtTargets),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (MapEntry<String, (TextEditingController, TextEditingController)> e in f.entries)
                Row(
                  children: <Widget>[
                    Expanded(flex: 2, child: Text(label[e.key]!)),
                    Expanded(
                      child: TextField(
                        controller: e.value.$1,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: s.dtMin),
                      ),
                    ),
                    const SizedBox(width: NSpace.xs),
                    Expanded(
                      child: TextField(
                        controller: e.value.$2,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: s.dtMax),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(s.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(s.drSave)),
        ],
      ),
    );
    final Json targets = <String, dynamic>{
      for (MapEntry<String, (TextEditingController, TextEditingController)> e in f.entries)
        if (double.tryParse(e.value.$1.text) != null || double.tryParse(e.value.$2.text) != null)
          e.key: <String, dynamic>{'min': double.tryParse(e.value.$1.text), 'max': double.tryParse(e.value.$2.text)},
    };
    for (final (TextEditingController, TextEditingController) c in f.values) {
      c.$1.dispose();
      c.$2.dispose();
    }
    if (ok == true) await _apply(() => _repo.updatePlan(_id, <String, dynamic>{'targets': targets}));
  }

  Future<void> _copyDay(int days) async {
    final S s = S.of(context);
    final Set<int> to = <int>{};
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext d) => StatefulBuilder(
        builder: (BuildContext d, StateSetter set) => AlertDialog(
          title: Text(s.dtCopyDayTo(_day + 1)),
          content: Wrap(
            spacing: NSpace.xs,
            children: <Widget>[
              for (int i = 0; i < days; i++)
                if (i != _day) FilterChip(label: Text(s.dtDayN(i + 1)), selected: to.contains(i), onSelected: (bool v) => set(() => v ? to.add(i) : to.remove(i))),
            ],
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(s.commonCancel)),
            FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(s.dtCopy)),
          ],
        ),
      ),
    );
    if (ok == true && to.isNotEmpty) await _apply(() => _repo.copyDay(_id, _day, to.toList()..sort()), done: s.dtCopied);
  }

  Future<void> _publish(Json plan) async {
    final S s = S.of(context);
    final DateTime now = DateTime.now();
    final DateTime? start = await showDatePicker(
      context: context,
      helpText: s.dtStartsOn,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 60)),
    );
    if (start == null || !mounted) return;
    String two(int v) => v.toString().padLeft(2, '0');
    final String date = '${start.year}-${two(start.month)}-${two(start.day)}';
    bool confirm = false;
    final Json care = plan.obj('carePlan');
    if (care.isNotEmpty && !care.flag('read')) {
      // She reads the signed care plan's nutrition section before her first publish for this member (§4 "Publishing" 7).
      final bool? ok = await showDialog<bool>(
        context: context,
        builder: (BuildContext d) => AlertDialog(
          title: Text(s.dtCarePlanTitle),
          content: SingleChildScrollView(child: Text(care.str('nutrition') ?? s.dtCarePlanNoNutrition)),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(s.commonCancel)),
            FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(s.dtCarePlanRead)),
          ],
        ),
      );
      if (ok != true) return;
      confirm = true;
    }
    await _apply(() => _repo.publish(_id, date, confirmCarePlanRead: confirm), done: s.dtPublished);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.dtMealPlan,
      body: AsyncBody<Json>(
        future: _plan,
        onRetry: () => setState(() => _plan = _repo.plan(_id)),
        builder: (BuildContext context, Json p) {
          final List<Json> days = p.objs('days');
          final bool draft = p.str('status') == 'draft';
          if (_day >= days.length) _day = 0;
          final Json day = days.isEmpty ? <String, dynamic>{} : days[_day];
          final Json warnings = p.obj('warnings');
          final Map<String, List<String>> conflicts = <String, List<String>>{for (Json c in p.objs('needsConfirmation')) c.str('itemId')!: c.strs('conflicts')};
          final CRole role = CRole.of(context);
          return ListView(
            padding: dtPagePadding,
            children: <Widget>[
              CHero(
                eyebrow: s.dtMealPlan,
                title: p.str('member') ?? '',
                subtitle: s.dtPlanDates(shortDate(context, p.str('startDate') ?? ''), p.str('endDate') == null ? '' : shortDate(context, p.str('endDate')!)),
                trailing: CPill(planStatusLabel(s, p.str('status')), tone: planTone(p.str('status'))),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      for (int i = 0; i < days.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: NSpace.xs),
                          child: ChoiceChip(
                            label: Text(s.dtDayN(i + 1)),
                            selected: i == _day,
                            showCheckmark: false,
                            labelStyle: NType.bodySm.copyWith(color: NColors.inkPrimary, fontWeight: i == _day ? FontWeight.w700 : FontWeight.w600),
                            selectedColor: role.light,
                            backgroundColor: NColors.surfaceCard,
                            side: BorderSide(color: i == _day ? role.accent : NColors.lineDefault),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NRadius.pill)),
                            onSelected: (_) => setState(() => _day = i),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (p.flag('suppressed')) ...<Widget>[const SizedBox(height: NSpace.sm), DtNotice(text: s.dtSuppressedPreview)],
              const SizedBox(height: NSpace.md),
              CPanel(
                title: s.dtDayN(_day + 1),
                note: s.dtDayTotals,
                icon: Icons.pie_chart_outline_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MacroSplit(nutrients: day.obj('totals')),
                    if (day.obj('againstTargets').isNotEmpty) ...<Widget>[
                      const SizedBox(height: NSpace.sm),
                      Wrap(
                        spacing: NSpace.xxs,
                        runSpacing: NSpace.xxs,
                        children: <Widget>[
                          for (MapEntry<String, dynamic> e in day.obj('againstTargets').entries)
                            CPill('${_target(s, e.key)}: ${_against(s, '${e.value}')}', tone: '${e.value}' == 'within' ? CTone.sage : CTone.apricot),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              for (Json slot in day.objs('slots')) ...<Widget>[
                const SizedBox(height: NSpace.sm),
                CEntrance(child: _slotCard(s, slot, draft, conflicts)),
              ],
              if ((warnings.objs('repeats')).isNotEmpty) ...<Widget>[
                const SizedBox(height: NSpace.sm),
                DtNotice(icon: Icons.repeat_rounded, text: s.dtRepeats(warnings.objs('repeats').map((Json r) => r.str('name')).join(', '))),
              ],
              const SizedBox(height: NSpace.lg),
              if (draft) ...<Widget>[
                Wrap(
                  spacing: NSpace.xs,
                  runSpacing: NSpace.xs,
                  children: <Widget>[
                    OutlinedButton.icon(onPressed: _busy ? null : () => _targets(p), icon: const Icon(Icons.track_changes_rounded, size: 18), label: Text(s.dtTargets)),
                    OutlinedButton.icon(onPressed: _busy ? null : () => _copyDay(days.length), icon: const Icon(Icons.copy_rounded, size: 18), label: Text(s.dtCopyDay)),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                      onPressed: _busy
                          ? null
                          : () async {
                              final String? t = await promptText(context, s.dtSaveTemplate, s.dtTemplateHint, maxLength: 120);
                              if (t == null) return;
                              try {
                                await _repo.saveTemplate(_id, t);
                                if (context.mounted) showNote(context, s.dtTemplateSaved);
                              } on Object catch (e) {
                                if (context.mounted) showNote(context, failureText(e, s.commonLoadError));
                              }
                            },
                      label: Text(s.dtSaveTemplate),
                    ),
                  ],
                ),
                const SizedBox(height: NSpace.md),
                NPrimaryButton(label: s.dtPublish, loading: _busy, inactiveHint: s.dtConfirmFirst, onPressed: p.objs('needsConfirmation').isEmpty ? () => _publish(p) : null),
                const SizedBox(height: NSpace.xs),
                Center(
                  child: TextButton(
                    onPressed: _busy
                        ? null
                        : () async {
                            await _repo.discardPlan(_id);
                            if (context.mounted) context.pop();
                          },
                    child: Text(s.dtDiscard),
                  ),
                ),
              ] else if (p.str('status') == 'active' || p.str('status') == 'scheduled') ...<Widget>[
                if (p.str('status') == 'active')
                  NSecondaryButton(
                    label: s.dtAdjust,
                    onPressed: _busy ? null : () => _apply(() => _repo.adjust(_id), done: s.dtAdjustStarted),
                  ),
                const SizedBox(height: NSpace.xs),
                Center(
                  child: TextButton(
                    onPressed: _busy ? null : () => _apply(() => _repo.endPlan(_id), done: s.dtEnded),
                    child: Text(s.dtEnd),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  IconData _slotIcon(String? k) => switch (k) {
    'early_morning' => Icons.wb_twilight_rounded,
    'breakfast' => Icons.free_breakfast_outlined,
    'mid_morning' => Icons.apple_outlined,
    'lunch' => Icons.lunch_dining_outlined,
    'evening_snack' => Icons.cookie_outlined,
    'dinner' => Icons.dinner_dining_outlined,
    'bedtime' => Icons.bedtime_outlined,
    _ => Icons.restaurant_outlined,
  };

  Widget _slotCard(S s, Json slot, bool draft, Map<String, List<String>> conflicts) {
    final num? kcal = slot.obj('totals').number('energyKcal');
    final List<Json> items = slot.objs('items');
    return Container(
      decoration: BoxDecoration(color: NColors.surfaceCard, borderRadius: BorderRadius.circular(NRadius.xl), border: Border.all(color: NColors.lineDefault), boxShadow: NShadow.xs),
      padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.sm, NSpace.sm, NSpace.xxs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              DtIconChip(icon: _slotIcon(slot.str('slot')), size: 34),
              const SizedBox(width: NSpace.sm),
              Expanded(
                child: Semantics(header: true, child: Text(slotLabel(s, slot.str('slot') ?? ''), style: NType.h4.copyWith(color: NColors.inkPrimary))),
              ),
              if (kcal != null) CPill(s.mealsKcal(kcal.toStringAsFixed(0))),
              const SizedBox(width: NSpace.xs),
            ],
          ),
          for (Json it in items) ...<Widget>[
            Divider(height: NSpace.md, color: NColors.lineDefault),
            _itemRow(s, it, draft, conflicts),
          ],
          if (draft)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(onPressed: _busy ? null : () => _addItem(slot.str('slot')!), icon: const Icon(Icons.add_rounded), label: Text(s.dtAddDish)),
            )
          else
            const SizedBox(height: NSpace.xs),
        ],
      ),
    );
  }

  Widget _itemRow(S s, Json it, bool draft, Map<String, List<String>> conflicts) {
    final String count = '${it.obj('portion').number('count')?.toString().replaceAll(RegExp(r'\.0$'), '')} ${it.obj('portion').str('unit')}';
    final List<String>? c = conflicts[it.str('id')];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${it.str('name')} · $count', style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(nutrientLine(s, it.obj('nutrients')), style: NType.caption.copyWith(color: NColors.inkSecondary, letterSpacing: 0)),
                  if (it.str('notes') != null) Text(it.str('notes')!, style: NType.caption.copyWith(color: NColors.inkSecondary, fontStyle: FontStyle.italic, letterSpacing: 0)),
                  if (it.strs('warnings').isNotEmpty) ...<Widget>[const SizedBox(height: 4), CPill(s.dtPreferenceWarning, tone: CTone.apricot)],
                ],
              ),
            ),
            if (draft)
              PopupMenuButton<String>(
                tooltip: s.communityMore,
                icon: Icon(Icons.more_vert_rounded, color: NColors.inkMuted),
                onSelected: (String a) async {
                  if (a == 'portion') {
                    final (double, String)? x = await _portion(it.obj('portion').str('unit') ?? 'serving', it.obj('portion').number('count') ?? 1);
                    if (x != null) await _apply(() => _repo.updateItem(_id, it.str('id')!, <String, dynamic>{'count': x.$1, 'unit': x.$2}));
                  } else if (a == 'note') {
                    if (!mounted) return;
                    final String? n = await promptText(context, s.dtSlotNote, s.dtSlotNoteHint, maxLength: 200);
                    if (n != null) await _apply(() => _repo.updateItem(_id, it.str('id')!, <String, dynamic>{'notes': n}));
                  } else {
                    await _apply(() => _repo.removeItem(_id, it.str('id')!));
                  }
                },
                itemBuilder: (_) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(value: 'portion', child: Text(s.dtPortion)),
                  PopupMenuItem<String>(value: 'note', child: Text(s.dtSlotNote)),
                  PopupMenuItem<String>(value: 'remove', child: Text(s.drRemoveLine)),
                ],
              ),
          ],
        ),
        if (c != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: NSpace.xs, right: NSpace.xs),
            padding: const EdgeInsets.fromLTRB(NSpace.sm, NSpace.xs, NSpace.xs, 0),
            decoration: BoxDecoration(color: NColors.statusWarningLight, borderRadius: BorderRadius.circular(NRadius.md)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  s.dtConflict(c.map((String x) => x == 'pregnancy' ? s.dtPregnancy : x.replaceFirst('allergy:', '')).join(', ')),
                  style: NType.bodySm.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
                ),
                if (draft) TextButton(onPressed: _busy ? null : () => _apply(() => _repo.confirmItem(_id, it.str('id')!)), child: Text(s.dtConfirmConflict)) else const SizedBox(height: NSpace.xs),
              ],
            ),
          ),
      ],
    );
  }

  String _target(S s, String k) => switch (k) {
    'energyKcal' => s.dtEnergy,
    'proteinG' => s.dtProtein,
    'carbohydrateG' => s.dtCarbs,
    'fatG' => s.dtFat,
    'fibreG' => s.dtFibre,
    _ => k,
  };

  String _against(S s, String v) => switch (v) {
    'within' => s.dtWithin,
    'below' => s.dtBelow,
    'above' => s.dtAbove,
    _ => v,
  };
}

/// Search the recipe library and the food table, with regional names (§4 "Building" 1). Nothing is typed in;
/// a missing food is requested from the nutrition team.
class DishPicker extends StatefulWidget {
  const DishPicker({required this.repository, super.key, this.foodsOnly = false});

  final DietitianRepository repository;
  final bool foodsOnly;

  @override
  State<DishPicker> createState() => _DishPickerState();
}

class _DishPickerState extends State<DishPicker> {
  final TextEditingController _q = TextEditingController();
  Future<List<Json>>? _results;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<List<Json>> _search(String q) async {
    final String recipeLabel = S.of(context).dtRecipe;
    final List<Json> foods = await widget.repository.searchFoods(q);
    final List<Json> recipes = widget.foodsOnly ? <Json>[] : await widget.repository.recipes(search: q);
    return <Json>[
      for (Json r in recipes.where((Json r) => r.str('status') == 'published')) <String, dynamic>{'kind': 'recipe', 'id': r.str('id'), 'name': r.str('title'), 'sub': recipeLabel},
      for (Json f in foods) <String, dynamic>{'kind': 'food', 'id': f.str('id'), 'name': f.str('name'), 'sub': f.strs('regionalNames').join(', ')},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, NSpace.lg, MediaQuery.of(context).viewInsets.bottom + NSpace.lg),
      child: SizedBox(
        height: 420,
        child: Column(
          children: <Widget>[
            TextField(
              controller: _q,
              autofocus: true,
              decoration: InputDecoration(labelText: s.dtSearchDish, prefixIcon: const Icon(Icons.search_rounded)),
              onSubmitted: (String v) => setState(() => _results = v.trim().length < 2 ? null : _search(v.trim())),
            ),
            Expanded(
              child: _results == null
                  ? Center(
                      child: Text(s.dtSearchHint, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
                    )
                  : FutureBuilder<List<Json>>(
                      future: _results,
                      builder: (BuildContext context, AsyncSnapshot<List<Json>> snap) {
                        if (!snap.hasData) return Center(child: Text(snap.hasError ? s.commonLoadError : s.loading));
                        final List<Json> rows = snap.data!;
                        return ListView(
                          children: <Widget>[
                            for (Json r in rows)
                              ListTile(
                                leading: DtIconChip(icon: r.str('kind') == 'recipe' ? Icons.menu_book_outlined : Icons.eco_outlined, size: 36),
                                title: Text(r.str('name') ?? '', style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                                subtitle: Text(r.str('sub') ?? '', style: NType.bodySm.copyWith(color: NColors.inkMuted)),
                                onTap: () => Navigator.of(context).pop(r),
                              ),
                            ListTile(
                              leading: const Icon(Icons.add_circle_outline_rounded),
                              title: Text(s.dtRequestFood(_q.text.trim())),
                              onTap: () async {
                                final String name = _q.text.trim();
                                if (name.isEmpty) return;
                                try {
                                  final Json r = await widget.repository.requestFood(name);
                                  if (context.mounted) Navigator.of(context).pop(<String, dynamic>{'kind': 'request', 'id': r.str('id'), 'name': name});
                                } on Object catch (e) {
                                  if (context.mounted) showNote(context, failureText(e, s.commonLoadError));
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
