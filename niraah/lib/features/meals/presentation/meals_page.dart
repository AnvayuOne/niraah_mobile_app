import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/constants/route_constants.dart';
import '../domain/meals.dart';
import 'meal_widgets.dart';

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
      appBar: AppBar(title: Text(s.mealsTitle), backgroundColor: NColors.surfacePage),
      floatingActionButton: FloatingActionButton.extended(onPressed: _scan, icon: const Icon(Icons.photo_camera_rounded), label: Text(s.mealsScanAction)),
      body: SafeArea(
        child: FutureBuilder<MealDay>(
          future: _day,
          builder: (BuildContext context, AsyncSnapshot<MealDay> snap) {
            if (snap.hasError) return ErrorView(message: s.notConnectedYet, retryLabel: s.tryAgain, onRetry: () => setState(() => _day = _repo.today()));
            if (!snap.hasData) return LoadingView(label: s.loading);
            final MealDay day = snap.data!;
            final String locale = Localizations.localeOf(context).toString();
            return RefreshIndicator(
              onRefresh: () async => setState(() => _day = _repo.today()),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, NSpace.lg, 96),
                children: <Widget>[
                  if (day.meals.isEmpty) ...<Widget>[
                    MealCard(color: NColors.brandApricotLight, child: Text(s.mealsTodayEmpty, style: NType.body.copyWith(color: NColors.inkPrimary))),
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
                    for (final Meal m in day.meals) ...<Widget>[
                      MealCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(child: Text(slotName(s, m.slot), style: NType.h4.copyWith(color: NColors.inkPrimary))),
                                if (m.source == 'scan') const Icon(Icons.photo_camera_rounded, size: 18, color: NColors.inkMuted),
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
                  if (day.privacyNote != null) ...<Widget>[
                    const SizedBox(height: NSpace.sm),
                    Text(day.privacyNote!, style: NType.caption.copyWith(color: NColors.inkMuted)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
