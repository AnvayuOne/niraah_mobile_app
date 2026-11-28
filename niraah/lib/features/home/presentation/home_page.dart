import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/area_navigation.dart';
import '../../../core/di/service_locator.dart';
import '../../../design_system/motion/motion.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/bottom_nav.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../../shared/constants/route_constants.dart';
import '../../care/domain/care.dart';
import '../../cycle/domain/cycle.dart';
import '../../cycle/presentation/cycle_summary_view.dart';
import '../../devices/domain/device_auto_sync.dart';
import '../domain/home.dart';
import 'home_cubit.dart';
import 'home_labels.dart';
import 'quick_log_sheet.dart';

/// Home (spec 010 §2): the cycle ring first, today's quick log, one daily
/// suggestion, and the pre-score card until she hides it. No streaks,
/// overdue counts or upsells.
class HomePage extends StatelessWidget {
  const HomePage({super.key, this.cubit});

  /// For tests and screenshots; otherwise built from the registered repository.
  final HomeCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final HomeCubit? given = cubit;
    return given != null
        ? BlocProvider<HomeCubit>.value(value: given, child: const _HomeView())
        : BlocProvider<HomeCubit>(
            create: (_) {
              // Her connected device syncs when the app opens (spec 016 §2.1); quietly, and once per run.
              DeviceAutoSync.once();
              return HomeCubit(getIt<HomeRepository>())..load();
            },
            child: const _HomeView(),
          );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (BuildContext context, HomeState st) {
        final HomeDocument? doc = st.document;
        final Widget body = switch ((st.status, doc)) {
          (HomeStatus.failure, _) => ErrorView(message: s.notConnectedYet, retryLabel: s.tryAgain, onRetry: context.read<HomeCubit>().load),
          (_, final HomeGate g) => _Gate(minutes: g.estimatedMinutes),
          (_, final HomeContent c) => _Content(home: c),
          _ => LoadingView(label: s.loading),
        };
        return Scaffold(
          backgroundColor: NColors.surfacePage,
          body: SafeArea(child: body),
          bottomNavigationBar: doc is HomeContent
              ? NBottomNav(
                  labels: <String>[for (final Area a in Area.values) s.areaName(a)],
                  index: 0,
                  onSelected: (int i) {
                    if (i != 0) goToArea(context, Area.values[i]);
                  },
                )
              : null,
        );
      },
    );
  }
}

/// Shown until the assessment is complete (spec 010 AC2).
class _Gate extends StatelessWidget {
  const _Gate({required this.minutes});

  /// Null drops the "about N minutes" sentence.
  final int? minutes;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final int? m = minutes;
    return Padding(
      padding: const EdgeInsets.all(NSpace.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(header: true, child: Text(s.homeGateTitle, style: NType.h2.copyWith(color: NColors.inkPrimary))),
          const SizedBox(height: NSpace.sm),
          Text(m == null ? s.homeGateBodyNoTime : s.homeGateBody(m), style: NType.body.copyWith(color: NColors.inkSecondary)),
          const SizedBox(height: NSpace.xl),
          NPrimaryButton(label: s.homeGateAction, trailingArrow: true, onPressed: () => context.go(RouteConstants.assessmentStart)),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.home});

  final HomeContent home;

  static String _part(S s, int hour) => hour < 12 ? s.homePartMorning : (hour < 17 ? s.homePartAfternoon : s.homePartEvening);

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String part = _part(s, DateTime.now().hour);
    final String locale = Localizations.localeOf(context).toString();
    final String date = DateFormat('EEEE, d MMMM', locale).format(IsoDates.toLocalDate(home.today));
    final List<Widget> sections = <Widget>[
      Semantics(
        header: true,
        child: Text(home.name == null ? s.homeGreetingNoName(part) : s.homeGreeting(part, home.name!), style: NType.h2.copyWith(color: NColors.inkPrimary)),
      ),
      const SizedBox(height: NSpace.xxs),
      Text(date, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
      const SizedBox(height: NSpace.lg),
      // At most one notice, at the top (spec 010 §2 rule 3).
      if (home.notice != null) ...<Widget>[_NoticeCard(notice: home.notice!), const SizedBox(height: NSpace.md)],
      if (home.cycle != null) ...<Widget>[_CycleCard(cycle: home.cycle!, today: home.today), const SizedBox(height: NSpace.md)],
      _QuickLog(log: home.todayLog),
      const SizedBox(height: NSpace.md),
      if (home.tasks != null) ...<Widget>[_TasksCard(tasks: home.tasks!), const SizedBox(height: NSpace.md)],
      if (home.next != null) ...<Widget>[_NextCard(next: home.next!), const SizedBox(height: NSpace.md)],
      if (home.checkInWeek != null) ...<Widget>[_CheckInCard(week: home.checkInWeek!), const SizedBox(height: NSpace.md)],
      const _MealsCard(),
      if (home.suggestion != null) ...<Widget>[const SizedBox(height: NSpace.md), _SuggestionCard(suggestion: home.suggestion!)],
      if (home.preScore != null) ...<Widget>[const SizedBox(height: NSpace.md), _PreScoreCard(p: home.preScore!)],
    ];
    final Widget list = ListView(padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, NSpace.lg, NSpace.xl), children: sections);
    if (NMotionRules.reduced(context)) return list;
    // One-time entrance; nothing loops.
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: NMotion.slow,
      curve: NMotionRules.curve,
      child: list,
      builder: (BuildContext context, double t, Widget? child) =>
          Opacity(opacity: t, child: Transform.translate(offset: Offset(0, NSpace.sm * (1 - t)), child: child)),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.color = NColors.surfaceCard});

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

class _CycleCard extends StatefulWidget {
  const _CycleCard({required this.cycle, required this.today});

  final CycleSummary cycle;
  final IsoDate today;

  @override
  State<_CycleCard> createState() => _CycleCardState();
}

class _CycleCardState extends State<_CycleCard> {
  DateTime? _start;

  Future<void> _pick() async {
    final DateTime today = IsoDates.toLocalDate(widget.today);
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: _start ?? today,
      firstDate: today.subtract(const Duration(days: 365)),
      lastDate: today,
      helpText: S.of(context).homeInvitationLabel,
    );
    if (d != null) setState(() => _start = d);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool noData = widget.cycle is CycleNoData;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(s.homeRingLabel, style: NType.h4.copyWith(color: NColors.inkPrimary)),
          const SizedBox(height: NSpace.md),
          CycleSummaryView(summary: widget.cycle),
          if (noData) ...<Widget>[
            Text(s.homeInvitation, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: NSpace.sm),
            OutlinedButton.icon(
              onPressed: _pick,
              icon: const Icon(Icons.calendar_today_rounded, color: NColors.actionLink),
              label: Text(_start == null ? s.homeInvitationLabel : DateFormat('d MMMM yyyy', Localizations.localeOf(context).toString()).format(_start!)),
            ),
            const SizedBox(height: NSpace.sm),
            NPrimaryButton(
              label: s.homeSave,
              inactiveHint: s.homeSaveInactive,
              onPressed: _start == null ? null : () => context.read<HomeCubit>().logPeriodStart(IsoDates.format(_start!)),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickLog extends StatelessWidget {
  const _QuickLog({required this.log});

  final DailyLog log;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final HomeCubit cubit = context.read<HomeCubit>();
    Widget chip(String field, String? value, VoidCallback onTap) => _LogChip(label: field, value: value ?? s.homeNotLogged, logged: value != null, onTap: onTap);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(s.homeLogTitle, style: NType.h4.copyWith(color: NColors.inkPrimary)),
          const SizedBox(height: NSpace.sm),
          // Two rows of two; each chip grows with its text, so large text sizes never clip.
          _pair(
            chip(s.homeLogFlow, log.flow == null ? null : s.flowName(log.flow!), () {
              showQuickLogSheet<PeriodFlow>(context, title: s.homePickerTitle(s.homeLogFlow), options: PeriodFlow.values, label: s.flowName, selected: log.flow, onPick: (PeriodFlow v) => cubit.saveLog(DailyLogPatch(flow: v)));
            }),
            chip(s.homeLogMood, log.mood == null ? null : s.moodName(log.mood!), () {
              showQuickLogSheet<Mood>(context, title: s.homePickerTitle(s.homeLogMood), options: Mood.values, label: s.moodName, selected: log.mood, onPick: (Mood v) => cubit.saveLog(DailyLogPatch(mood: v)));
            }),
          ),
          const SizedBox(height: NSpace.xs),
          _pair(
            chip(s.homeLogEnergy, log.energy == null ? null : s.energyName(log.energy!), () {
              showQuickLogSheet<Energy>(context, title: s.homePickerTitle(s.homeLogEnergy), options: Energy.values, label: s.energyName, selected: log.energy, onPick: (Energy v) => cubit.saveLog(DailyLogPatch(energy: v)));
            }),
            chip(s.homeLogSymptoms, null, () => context.push(RouteConstants.symptoms)),
          ),
        ],
      ),
    );
  }

  static Widget _pair(Widget a, Widget b) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[Expanded(child: a), const SizedBox(width: NSpace.xs), Expanded(child: b)],
        ),
      );
}

/// Opens the meal scanner and log (spec 010 §6).
class _MealsCard extends StatelessWidget {
  const _MealsCard();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return _Card(
      color: NColors.brandApricotLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.restaurant_rounded, color: NColors.brandTerracotta),
              const SizedBox(width: NSpace.xs),
              Expanded(child: Text(s.mealsHomeTitle, style: NType.h4.copyWith(color: NColors.inkPrimary))),
            ],
          ),
          const SizedBox(height: NSpace.xs),
          Text(s.mealsHomeBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
          const SizedBox(height: NSpace.md),
          NPrimaryButton(label: s.mealsScanAction, onPressed: () => context.push(RouteConstants.mealScan)),
          const SizedBox(height: NSpace.xs),
          NSecondaryButton(label: s.mealsTitle, onPressed: () => context.push(RouteConstants.meals)),
        ],
      ),
    );
  }
}

class _LogChip extends StatelessWidget {
  const _LogChip({required this.label, required this.value, required this.logged, required this.onTap});

  final String label;
  final String value;
  final bool logged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label: $value',
      child: ExcludeSemantics(
        child: Material(
          color: logged ? NColors.brandLavenderLight : NColors.surfacePage,
          borderRadius: BorderRadius.circular(NRadius.lg),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(NRadius.lg),
            child: Container(
              constraints: const BoxConstraints(minHeight: NLayout.minTapTarget),
              padding: const EdgeInsets.symmetric(horizontal: NSpace.md, vertical: NSpace.xs),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(NRadius.lg), border: Border.all(color: NColors.lineDefault)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(label, style: NType.label.copyWith(color: NColors.inkMuted)),
                  Row(
                    children: <Widget>[
                      if (!logged) const Icon(Icons.add_rounded, size: NSpace.md, color: NColors.actionLink),
                      if (!logged) const SizedBox(width: NSpace.xxs),
                      Flexible(
                        child: Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                          style: NType.body.copyWith(color: logged ? NColors.inkPrimary : NColors.actionLink, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.suggestion});

  final DailySuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return _Card(
      color: NColors.brandSageLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(s.homeSuggestionTitle.toUpperCase(), style: NType.caption.copyWith(color: NColors.inkSecondary))),
              if (suggestion.writtenBy == SuggestionAuthor.model)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: NSpace.xs, vertical: NSpace.xxs / 2),
                  decoration: BoxDecoration(color: NColors.surfaceCard, borderRadius: BorderRadius.circular(NRadius.pill)),
                  child: Text(s.homeAiMark, style: NType.label.copyWith(color: NColors.inkPrimary)),
                ),
            ],
          ),
          const SizedBox(height: NSpace.xs),
          Text(suggestion.title, style: NType.h3.copyWith(color: NColors.inkPrimary)),
          const SizedBox(height: NSpace.xxs),
          Text(suggestion.text, style: NType.body.copyWith(color: NColors.inkSecondary)),
          if (suggestion.writtenBy == SuggestionAuthor.rules) ...<Widget>[
            const SizedBox(height: NSpace.sm),
            Text(s.homeFromLibrary, style: NType.label.copyWith(color: NColors.inkMuted)),
          ],
        ],
      ),
    );
  }
}

class _PreScoreCard extends StatelessWidget {
  const _PreScoreCard({required this.p});

  final HomePreScore p;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return _Card(
      color: NColors.brandBlushLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(s.homePrescoreTitle, style: NType.h4.copyWith(color: NColors.inkPrimary)),
          const SizedBox(height: NSpace.xxs),
          Text(s.homePrescoreLine(p.total, p.maximum, p.band), style: NType.h3.copyWith(color: NColors.inkPrimary)),
          const SizedBox(height: NSpace.xxs),
          Text(p.reviewTarget == null ? s.homeReviewNotRequired : s.homeReviewAwaiting(p.reviewTarget!), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
          const SizedBox(height: NSpace.sm),
          Row(
            children: <Widget>[
              TextButton(onPressed: () => context.push(RouteConstants.preScore), child: Text(s.homeViewResult)),
              const Spacer(),
              Semantics(
                button: true,
                label: s.homeHidePrescore,
                excludeSemantics: true,
                child: TextButton(onPressed: context.read<HomeCubit>().hidePreScore, child: Text(s.homeHide)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
/// The one notice at the top: payment failed, plan retiring or trial ending (spec 010 §2 rule 3), with the way to
/// manage her plan.
class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.notice});

  final HomeNotice notice;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return _Card(
      color: NColors.statusWarningLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(notice.text, style: NType.body.copyWith(color: NColors.inkPrimary)),
          TextButton(onPressed: () => context.push(RouteConstants.plans), child: Text(s.homeManagePlan)),
        ],
      ),
    );
  }
}

/// Today's tasks from her signed care plan, ticked here or in the care plan (spec 010 §10 "Daily tasks"). A task
/// not done is simply not ticked; nothing is overdue (AC36).
class _TasksCard extends StatelessWidget {
  const _TasksCard({required this.tasks});

  final List<HomeTask> tasks;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return _Card(
      color: NColors.brandSageLight,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(s.careTodayTasks, style: NType.h4.copyWith(color: NColors.inkPrimary)),
            for (final HomeTask t in tasks)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: t.done,
                title: Text(t.title, style: NType.body.copyWith(color: NColors.inkPrimary)),
                onChanged: (bool? v) async {
                  final HomeCubit cubit = context.read<HomeCubit>();
                  try {
                    await getIt<CareRepository>().tick(t.id, v ?? false);
                  } on Object catch (e) {
                    if (context.mounted) showNote(context, failureText(e, s.commonLoadError));
                  }
                  await cubit.load();
                },
              ),
            TextButton(onPressed: () => context.push(RouteConstants.carePlan), child: Text(s.homeOpenCarePlan)),
          ],
        ),
      ),
    );
  }
}

/// Her next consult or class, in her time zone (spec 010 §2; spec 014).
class _NextCard extends StatelessWidget {
  const _NextCard({required this.next});

  final HomeNext next;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String when = DateFormat('EEE d MMM, h:mm a', Localizations.localeOf(context).toString()).format(next.startsAt);
    final String what = next.isClass ? (next.title ?? s.homeNextClass) : (next.withName == null ? s.homeNextConsult : s.homeNextConsultWith(next.withName!));
    final Widget card = _Card(
      child: Row(
        children: <Widget>[
          Icon(next.isClass ? Icons.self_improvement_rounded : Icons.event_rounded, color: NColors.inkSecondary),
          const SizedBox(width: NSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(s.homeNextTitle, style: NType.caption.copyWith(color: NColors.inkMuted)),
                Text(what, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                Text(when, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              ],
            ),
          ),
          if (!next.isClass) const Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
        ],
      ),
    );
    if (next.isClass) return card;
    // A consult opens her appointments (spec 010 §9.3; spec 014).
    return Semantics(
      button: true,
      label: '$what, $when',
      child: Material(
        color: Colors.transparent,
        child: InkWell(borderRadius: BorderRadius.circular(NRadius.xl), onTap: () => context.push(RouteConstants.appointments), child: card),
      ),
    );
  }
}

/// A due weekly check-in (spec 010 §11 rule 3): offered for a few days, then it lapses quietly.
class _CheckInCard extends StatelessWidget {
  const _CheckInCard({required this.week});

  final IsoDate week;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return _Card(
      color: NColors.brandLavenderLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(s.homeCheckInTitle, style: NType.h4.copyWith(color: NColors.inkPrimary)),
          const SizedBox(height: NSpace.xxs),
          Text(s.homeCheckInBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
          TextButton(onPressed: () => context.push(RouteConstants.checkIns), child: Text(s.homeCheckInAction)),
        ],
      ),
    );
  }
}
