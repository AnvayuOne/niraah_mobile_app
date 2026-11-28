import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/generated/niraah_assets.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../design_system/widgets/n_illustration.dart';
import '../../../design_system/widgets/n_premium_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/constants/route_constants.dart';
import '../domain/meals.dart';
import 'meal_plan_pages.dart';
import 'meal_widgets.dart';
import 'today_plan_page.dart';

/// Today's meal log (spec 010 §6 rule 5): each meal with its dishes and the day's totals, all from the food table.
class MealsPage extends StatefulWidget {
  const MealsPage({super.key, this.repository});

  final MealsRepository? repository;

  @override
  State<MealsPage> createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  late final MealsRepository _repo = widget.repository ?? getIt<MealsRepository>();
  late Future<MealDay> _day = _repo.today();

  Future<void> _scan() async {
    await context.push<bool>(RouteConstants.mealScan);
    if (mounted) setState(() => _day = _repo.today());
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Scaffold(
      backgroundColor: NColors.surfacePage,
      appBar: AppBar(
        title: Text(s.mealsTitle),
        backgroundColor: NColors.surfacePage,
        actions: <Widget>[
          // Today's plan meals with "I ate this" (spec 010 §6b rule 4).
          IconButton(
            tooltip: s.todayPlanTitle,
            icon: const Icon(Icons.today_rounded),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => TodayPlanPage(repository: _repo))),
          ),
          // Her dietitian's plan and her history (spec 010 §6 rule 5; spec 012 §4).
          IconButton(
            tooltip: s.mealPlanTitle,
            icon: const Icon(Icons.restaurant_menu_rounded),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => MealPlanPage(repository: _repo))),
          ),
          IconButton(
            tooltip: s.mealsHistoryTitle,
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => MealHistoryPage(repository: _repo))),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _scan, icon: const Icon(Icons.photo_camera_rounded), label: Text(s.mealsScanAction)),
      body: SafeArea(
        child: FutureBuilder<MealDay>(
          future: _day,
          builder: (BuildContext context, AsyncSnapshot<MealDay> snap) {
            if (snap.hasError) return ErrorView(message: s.notConnectedYet, retryLabel: s.tryAgain, onRetry: () => setState(() => _day = _repo.today()));
            if (!snap.hasData) return LoadingView(label: s.loadMeals, kind: NLoaderKind.meals);
            final MealDay day = snap.data!;
            final String locale = Localizations.localeOf(context).toString();
            return RefreshIndicator(
              onRefresh: () async => setState(() => _day = _repo.today()),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, NSpace.lg, 96),
                children: <Widget>[
                  // The AI diet plan (spec 010 §6a), one tap from today's meals.
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(NRadius.xl),
                      onTap: () => context.push(RouteConstants.dietPlan),
                      child: Ink(
                        padding: const EdgeInsets.all(NSpace.lg),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[NColors.brandPlum, NColors.brandRosewood]),
                          borderRadius: BorderRadius.circular(NRadius.xl),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const NPremiumBadge(),
                                  const SizedBox(height: NSpace.sm),
                                  Text(s.dietEntryTitle, style: NType.h3.copyWith(color: Colors.white)),
                                  const SizedBox(height: NSpace.xxs),
                                  Text(s.dietEntryBody, style: NType.bodySm.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                                  const SizedBox(height: NSpace.sm),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        s.dietOpenCta,
                                        style: NType.label.copyWith(color: NColors.brandApricotLight, fontWeight: FontWeight.w700),
                                      ),
                                      Icon(Icons.arrow_forward_rounded, size: 16, color: NColors.brandApricotLight),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const NLottie(path: NLotties.nutrition, size: 96),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: NSpace.md),
                  if (day.meals.isEmpty) ...<Widget>[
                    MealCard(
                      color: NColors.brandApricotLight,
                      child: Text(s.mealsTodayEmpty, style: NType.body.copyWith(color: NColors.inkPrimary)),
                    ),
                    const SizedBox(height: NSpace.lg),
                    NPrimaryButton(label: s.mealsScanAction, onPressed: _scan),
                  ] else ...<Widget>[
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
                    const SizedBox(height: NSpace.md),
                    for (Meal m in day.meals) ...<Widget>[
                      MealCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(slotName(s, m.slot), style: NType.h4.copyWith(color: NColors.inkPrimary)),
                                ),
                                if (m.source == 'scan') Icon(Icons.photo_camera_rounded, size: 18, color: NColors.inkMuted),
                                const SizedBox(width: NSpace.xxs),
                                Text(DateFormat.jm(locale).format(m.eatenAt), style: NType.caption.copyWith(color: NColors.inkMuted)),
                              ],
                            ),
                            const SizedBox(height: NSpace.xs),
                            Text(m.items.map((LoggedItem i) => i.name).join(', '), style: NType.body.copyWith(color: NColors.inkSecondary)),
                            const SizedBox(height: NSpace.xs),
                            NutrientRow(n: m.totals),
                            if (m.tags.isNotEmpty) ...<Widget>[const SizedBox(height: NSpace.xs), TagChips(tags: m.tags)],
                          ],
                        ),
                      ),
                      const SizedBox(height: NSpace.sm),
                    ],
                  ],
                  if (day.privacyNote != null) ...<Widget>[const SizedBox(height: NSpace.sm), Text(day.privacyNote!, style: NType.caption.copyWith(color: NColors.inkMuted))],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
