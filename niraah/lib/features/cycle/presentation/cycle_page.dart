import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/area_navigation.dart';
import '../../../core/di/service_locator.dart';
import '../../../design_system/generated/niraah_assets.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/bottom_nav.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_illustration.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/constants/route_constants.dart';
import '../../home/domain/home.dart';
import '../../home/presentation/home_labels.dart';
import '../domain/cycle.dart';
import 'advice_card_view.dart';
import 'cycle_calendar.dart';
import 'cycle_cubit.dart';
import 'cycle_sheets.dart';
import 'cycle_summary_view.dart';

/// The Cycle screen (spec 010 §3), mirroring
/// apps/web/src/app/(member)/cycle/cycle-screen.tsx. Every number and date
/// comes from the server's rules. No upsell on this screen.
class CyclePage extends StatelessWidget {
  const CyclePage({super.key, this.cubit, this.initialMonth});

  /// For tests and screenshots.
  final CycleCubit? cubit;
  final DateTime? initialMonth;

  @override
  Widget build(BuildContext context) {
    final Widget view = _CycleView(initialMonth: initialMonth);
    final CycleCubit? given = cubit;
    return given != null ? BlocProvider<CycleCubit>.value(value: given, child: view) : BlocProvider<CycleCubit>(create: (_) => CycleCubit(getIt<CycleRepository>())..load(), child: view);
  }
}

class _CycleView extends StatefulWidget {
  const _CycleView({this.initialMonth});

  final DateTime? initialMonth;

  @override
  State<_CycleView> createState() => _CycleViewState();
}

class _CycleViewState extends State<_CycleView> {
  (int, int)? _month;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<CycleCubit, CycleState>(
      builder: (BuildContext context, CycleState st) {
        final CycleDocument? doc = st.document;
        final Widget body;
        if (st.status == CycleStatus.failure) {
          body = ErrorView(message: s.commonLoadError, retryLabel: s.tryAgain, onRetry: context.read<CycleCubit>().load);
        } else if (doc == null) {
          body = LoadingView(label: s.loadCycle, kind: NLoaderKind.cycle);
        } else {
          final DateTime m = widget.initialMonth ?? IsoDates.toLocalDate(doc.today);
          final (int, int) month = _month ?? (m.year, m.month);
          body = _content(context, s, doc, month);
        }
        return Scaffold(
          backgroundColor: NColors.surfacePage,
          body: SafeArea(child: body),
          bottomNavigationBar: NBottomNav(
            labels: <String>[for (final Area a in Area.values) s.areaName(a)],
            index: 1,
            onSelected: (int i) {
              if (i != 1) goToArea(context, Area.values[i]);
            },
          ),
        );
      },
    );
  }

  void _shift(int delta) {
    final (int y, int m) = _month!;
    final DateTime d = DateTime(y, m + delta);
    setState(() => _month = (d.year, d.month));
  }

  Widget _content(BuildContext context, S s, CycleDocument doc, (int, int) month) {
    _month ??= month;
    final CycleCubit cubit = context.read<CycleCubit>();
    final String locale = Localizations.localeOf(context).toString();
    String short(IsoDate d) => DateFormat('d MMM', locale).format(IsoDates.toLocalDate(d));
    final Period? latest = doc.periods.isEmpty ? null : (List<Period>.of(doc.periods)..sort((Period a, Period b) => a.start.compareTo(b.start))).last;

    return ListView(
      padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, NSpace.lg, NSpace.xl),
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(s.cycleTitle, style: NType.h2.copyWith(color: NColors.inkPrimary)),
        ),
        const SizedBox(height: NSpace.xxs),
        Text(doc.wellness, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
        const SizedBox(height: NSpace.lg),
        for (final AdviceCard a in doc.advice) ...<Widget>[AdviceCardView(card: a), const SizedBox(height: NSpace.md)],

        Container(
          padding: const EdgeInsets.all(NSpace.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[_phaseTint(doc.summary), NColors.surfaceCard]),
            borderRadius: BorderRadius.circular(NRadius.xl),
            boxShadow: NShadow.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CycleSummaryView(summary: doc.summary, diameter: 220),
              if (doc.summary is CycleNoData) ...<Widget>[
                const Center(child: NLottie(path: NLotties.cycle, size: 120)),
                Text(
                  s.homeInvitation,
                  textAlign: TextAlign.center,
                  style: NType.bodySm.copyWith(color: NColors.inkSecondary),
                ),
              ],
              if (doc.summary case final CycleEstimate e when e.phase != null) ...<Widget>[const SizedBox(height: NSpace.md), _PhaseStrip(current: e.phase!)],
              const SizedBox(height: NSpace.md),
              const _Legend(),
              const SizedBox(height: NSpace.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _ActionTile(icon: Icons.water_drop_rounded, label: s.cycleLogPeriod, color: NColors.brandRosewood, filled: true, onTap: () => showPeriodSheet(context, cubit, doc.today)),
                  ),
                  const SizedBox(width: NSpace.sm),
                  Expanded(
                    child: _ActionTile(icon: Icons.favorite_border_rounded, label: s.cycleLogSymptoms, color: NColors.brandPlum, onTap: () => context.push(RouteConstants.symptoms)),
                  ),
                ],
              ),
              const SizedBox(height: NSpace.md),
              Text(
                doc.disclaimer,
                textAlign: TextAlign.center,
                style: NType.label.copyWith(color: NColors.inkMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: NSpace.lg),

        _Section(
          child: CycleCalendar(doc: doc, year: _month!.$1, month: _month!.$2, onPrevious: () => _shift(-1), onNext: () => _shift(1), onDay: (IsoDate d) => showDaySheet(context, cubit, d)),
        ),
        const SizedBox(height: NSpace.lg),

        Semantics(
          header: true,
          child: Text(s.cycleHistoryTitle, style: NType.h4.copyWith(color: NColors.inkPrimary)),
        ),
        const SizedBox(height: NSpace.sm),
        if (doc.pattern != null) ...<Widget>[Text(s.patternText(doc.pattern!), style: NType.body.copyWith(color: NColors.inkPrimary)), const SizedBox(height: NSpace.xs)],
        if (doc.average != null && doc.range != null) ...<Widget>[
          Text('${s.cycleAverage(doc.average!)} · ${s.rangeText(doc.range!)}', style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
          const SizedBox(height: NSpace.sm),
        ],
        if (doc.history.isEmpty)
          Text(s.cycleHistoryEmpty, style: NType.bodySm.copyWith(color: NColors.inkMuted))
        else ...<Widget>[
          if (latest != null) _HistoryRow(left: short(latest.start), right: s.cycleCurrentCycle, current: true),
          for (final CycleHistoryRow h in doc.history.reversed)
            _HistoryRow(left: short(h.start), right: h.periodLength == null ? s.cycleHistoryRow(h.cycleLength) : '${s.cycleHistoryRow(h.cycleLength)} · ${s.cyclePeriodDays(h.periodLength!)}'),
        ],
        const SizedBox(height: NSpace.lg),

        _Section(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(s.cycleSituationTitle, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                    const SizedBox(height: NSpace.xxs),
                    Text(doc.markers.isEmpty ? s.cycleSituationNone : doc.markers.map(s.markerName).join(' · '), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: NSpace.sm),
              OutlinedButton(onPressed: () => showMarkersSheet(context, cubit, doc.markers), child: Text(s.cycleEdit)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(NSpace.lg),
    decoration: BoxDecoration(
      color: NColors.surfaceCard,
      borderRadius: BorderRadius.circular(NRadius.xl),
      border: Border.all(color: NColors.lineDefault),
      boxShadow: NShadow.sm,
    ),
    child: child,
  );
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.left, required this.right, this.current = false});

  final String left;
  final String right;
  final bool current;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: NSpace.xs),
    padding: const EdgeInsets.symmetric(horizontal: NSpace.md, vertical: NSpace.sm),
    decoration: BoxDecoration(color: current ? NColors.surfaceWarm : NColors.surfaceCard, borderRadius: BorderRadius.circular(NRadius.lg), boxShadow: current ? null : NShadow.xs),
    child: MergeSemantics(
      child: Row(
        children: <Widget>[
          Text(left, style: NType.body.copyWith(color: NColors.inkPrimary)),
          const SizedBox(width: NSpace.md),
          Expanded(
            child: Text(
              right,
              textAlign: TextAlign.end,
              style: NType.bodySm.copyWith(color: NColors.inkSecondary),
            ),
          ),
        ],
      ),
    ),
  );
}

Color _phaseTint(CycleSummary summary) => switch (summary) {
  CycleEstimate(phase: Phase.menstrual) => NColors.brandBlushLight,
  CycleEstimate(phase: Phase.follicular) => NColors.brandSageLight,
  CycleEstimate(phase: Phase.ovulatory) => NColors.brandApricotLight,
  CycleEstimate(phase: Phase.luteal) => NColors.brandLavenderLight,
  _ => NColors.surfaceWarm,
};

/// The four phases in a row, the current one lifted and filled.
class _PhaseStrip extends StatelessWidget {
  const _PhaseStrip({required this.current});

  final Phase current;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    const List<(Phase, IconData, Color)> phases = <(Phase, IconData, Color)>[
      (Phase.menstrual, Icons.water_drop_rounded, NColors.brandRosewood),
      (Phase.follicular, Icons.eco_rounded, NColors.brandSage),
      (Phase.ovulatory, Icons.wb_sunny_rounded, NColors.brandApricot),
      (Phase.luteal, Icons.nightlight_round, NColors.brandLavender),
    ];
    return Row(
      children: <Widget>[
        for (final (Phase p, IconData icon, Color c) in phases)
          Expanded(
            child: AnimatedContainer(
              duration: NMotion.medium,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: NSpace.sm),
              decoration: BoxDecoration(
                color: p == current ? c : NColors.surfaceCard.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(NRadius.md),
                boxShadow: p == current ? NShadow.sm : null,
              ),
              child: Column(
                children: <Widget>[
                  Icon(icon, size: 18, color: p == current ? Colors.white : c),
                  const SizedBox(height: 2),
                  Text(
                    switch (p) {
                      Phase.menstrual => s.cyclePhaseShortPeriod,
                      Phase.follicular => s.cyclePhaseShortFollicular,
                      Phase.ovulatory => s.cyclePhaseShortOvulation,
                      Phase.luteal => s.cyclePhaseShortLuteal,
                    },
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NType.caption.copyWith(color: p == current ? Colors.white : NColors.inkSecondary, fontWeight: p == current ? FontWeight.w700 : null),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    Widget dot(Color c, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(child: Text(label, style: NType.caption.copyWith(color: NColors.inkSecondary))),
      ],
    );
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: NSpace.md,
      runSpacing: NSpace.xs,
      children: <Widget>[dot(NColors.brandRosewood, s.phaseName(Phase.menstrual)), dot(NColors.brandLavender, s.cycleFertileLegend), dot(NColors.inkPrimary, s.cycleTodayLegend)],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap, this.filled = false});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) => Material(
    color: filled ? color : NColors.surfaceCard,
    borderRadius: BorderRadius.circular(NRadius.lg),
    child: InkWell(
      borderRadius: BorderRadius.circular(NRadius.lg),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: NSpace.md, horizontal: NSpace.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(NRadius.lg),
          border: filled ? null : Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, color: filled ? Colors.white : color),
            const SizedBox(height: NSpace.xxs),
            Text(
              label,
              textAlign: TextAlign.center,
              style: NType.label.copyWith(color: filled ? Colors.white : NColors.inkPrimary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}
