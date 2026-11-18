import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/area_navigation.dart';
import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/bottom_nav.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
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
    return given != null
        ? BlocProvider<CycleCubit>.value(value: given, child: view)
        : BlocProvider<CycleCubit>(create: (_) => CycleCubit(getIt<CycleRepository>())..load(), child: view);
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
          body = LoadingView(label: s.loading);
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
    final Period? latest = doc.periods.isEmpty
        ? null
        : (List<Period>.of(doc.periods)..sort((Period a, Period b) => a.start.compareTo(b.start))).last;

    return ListView(
      padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, NSpace.lg, NSpace.xl),
      children: <Widget>[
        Semantics(header: true, child: Text(s.cycleTitle, style: NType.h2.copyWith(color: NColors.inkPrimary))),
        const SizedBox(height: NSpace.xxs),
        Text(doc.wellness, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
        const SizedBox(height: NSpace.lg),
        for (final AdviceCard a in doc.advice) ...<Widget>[AdviceCardView(card: a), const SizedBox(height: NSpace.md)],

        _Section(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CycleSummaryView(summary: doc.summary),
              if (doc.summary is CycleNoData)
                Text(s.homeInvitation, textAlign: TextAlign.center, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              const SizedBox(height: NSpace.lg),
              NPrimaryButton(label: s.cycleLogPeriod, onPressed: () => showPeriodSheet(context, cubit, doc.today)),
              const SizedBox(height: NSpace.sm),
              NSecondaryButton(label: s.cycleLogSymptoms, onPressed: () => context.push(RouteConstants.symptoms)),
              const SizedBox(height: NSpace.md),
              Text(doc.disclaimer, textAlign: TextAlign.center, style: NType.label.copyWith(color: NColors.inkMuted)),
            ],
          ),
        ),
        const SizedBox(height: NSpace.lg),

        _Section(
          child: CycleCalendar(
            doc: doc,
            year: _month!.$1,
            month: _month!.$2,
            onPrevious: () => _shift(-1),
            onNext: () => _shift(1),
            onDay: (IsoDate d) => showDaySheet(context, cubit, d),
          ),
        ),
        const SizedBox(height: NSpace.lg),

        Semantics(header: true, child: Text(s.cycleHistoryTitle, style: NType.h4.copyWith(color: NColors.inkPrimary))),
        const SizedBox(height: NSpace.sm),
        if (doc.pattern != null) ...<Widget>[
          Text(s.patternText(doc.pattern!), style: NType.body.copyWith(color: NColors.inkPrimary)),
          const SizedBox(height: NSpace.xs),
        ],
        if (doc.average != null && doc.range != null) ...<Widget>[
          Text('${s.cycleAverage(doc.average!)} · ${s.rangeText(doc.range!)}', style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
          const SizedBox(height: NSpace.sm),
        ],
        if (doc.history.isEmpty)
          Text(s.cycleHistoryEmpty, style: NType.bodySm.copyWith(color: NColors.inkMuted))
        else ...<Widget>[
          if (latest != null) _HistoryRow(left: short(latest.start), right: s.cycleCurrentCycle, current: true),
          for (final CycleHistoryRow h in doc.history.reversed)
            _HistoryRow(
              left: short(h.start),
              right: h.periodLength == null ? s.cycleHistoryRow(h.cycleLength) : '${s.cycleHistoryRow(h.cycleLength)} · ${s.cyclePeriodDays(h.periodLength!)}',
            ),
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
                    Text(
                      doc.markers.isEmpty ? s.cycleSituationNone : doc.markers.map(s.markerName).join(' · '),
                      style: NType.bodySm.copyWith(color: NColors.inkSecondary),
                    ),
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
        decoration: BoxDecoration(
          color: current ? NColors.surfaceWarm : NColors.surfaceCard,
          borderRadius: BorderRadius.circular(NRadius.lg),
          boxShadow: current ? null : NShadow.xs,
        ),
        child: MergeSemantics(
          child: Row(
            children: <Widget>[
              Text(left, style: NType.body.copyWith(color: NColors.inkPrimary)),
              const SizedBox(width: NSpace.md),
              Expanded(child: Text(right, textAlign: TextAlign.end, style: NType.bodySm.copyWith(color: NColors.inkSecondary))),
            ],
          ),
        ),
      );
}
