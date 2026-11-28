import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/clinician_ui.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../assessment/domain/prescore.dart';
import '../domain/doctor.dart';
import 'doctor_shell.dart';

/// The pre-score review queue (spec 011 §4, spec 007 §7), mirroring
/// apps/web/src/app/(doctor)/doctor/queue/review-queue.tsx. Order: urgent, her
/// dedicated members, attention, then oldest.
class ReviewQueuePage extends StatefulWidget {
  const ReviewQueuePage({super.key, this.repository});

  final DoctorRepository? repository;

  @override
  State<ReviewQueuePage> createState() => _ReviewQueuePageState();
}

class _ReviewQueuePageState extends State<ReviewQueuePage> {
  late final DoctorRepository _repo = widget.repository ?? getIt<DoctorRepository>();
  late Future<List<QueueItem>> _queue = _repo.getQueue();

  void _reload() => setState(() => _queue = _repo.getQueue());

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return DoctorShell(
      index: 2,
      title: s.pvQueueTitle,
      body: FutureBuilder<List<QueueItem>>(
        future: _queue,
        builder: (BuildContext context, AsyncSnapshot<List<QueueItem>> snap) {
          if (snap.hasError) return ErrorView(message: s.commonLoadError, retryLabel: s.tryAgain, onRetry: _reload);
          final List<QueueItem>? items = snap.data;
          if (items == null) return LoadingView(label: s.loadCare, kind: NLoaderKind.care);
          final List<double> due = items.map((QueueItem q) => q.dueInHours).whereType<double>().toList();
          final double? oldest = due.isEmpty ? null : due.reduce(math.min);
          final int urgent = items.where((QueueItem q) => q.severity == FlagSeverity.urgent).length;
          final int mine = items.where((QueueItem q) => q.dedicatedToMe).length;
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl),
              children: <Widget>[
                CHero(
                  eyebrow: s.pvShellQueue,
                  title: s.pvQueueTitle,
                  subtitle: items.isEmpty ? s.pvQueueEmpty : s.pvQueuePick,
                  child: CStatGrid(
                    children: <Widget>[
                      CHeroStat(label: s.drAQueueWaiting, value: '${items.length}', icon: Icons.fact_check_outlined, note: oldest == null ? null : dueText(s, oldest)),
                      CHeroStat(label: s.pvQueueUrgent, value: '$urgent', icon: Icons.priority_high_rounded, alert: urgent > 0),
                      CHeroStat(label: s.pvQueueDedicated, value: '$mine', icon: Icons.favorite_border_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: NSpace.md),
                if (items.isEmpty)
                  CEntrance(
                    delayMs: 80,
                    child: CEmpty(icon: Icons.task_alt_rounded, title: s.pvQueueEmpty),
                  )
                else
                  for (int i = 0; i < items.length; i++)
                    CEntrance(
                      delayMs: 50 * i.clamp(0, 8),
                      child: _QueueCard(
                        item: items[i],
                        onTap: () async {
                          await context.push('/doctor/review/${items[i].id}');
                          if (mounted) _reload();
                        },
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String severityLabel(S s, FlagSeverity f) => switch (f) {
  FlagSeverity.urgent => s.pvQueueUrgent,
  FlagSeverity.attention => s.pvQueueAttention,
  FlagSeverity.information => s.pvQueueInfo,
};

/// A flag badge. Red is used only for true clinical red flags on clinician
/// screens (constitution §8.3), so only urgent flags are red.
class FlagBadge extends StatelessWidget {
  const FlagBadge({required this.flag, super.key});

  final QueueFlag flag;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final FlagSeverity severity = flag.severity ?? FlagSeverity.information;
    final (Color bg, Color fg) = switch (severity) {
      FlagSeverity.urgent => (NColors.statusClinicalRedFlagLight, NColors.statusClinicalRedFlag),
      FlagSeverity.attention => (NColors.statusWarningLight, NColors.statusWarningText),
      FlagSeverity.information => (NColors.statusInfoLight, NColors.statusInfo),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: NSpace.xs, vertical: NSpace.xxs / 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(NRadius.pill)),
      child: Text(
        flag.name.isEmpty ? severityLabel(s, severity) : '${severityLabel(s, severity)} · ${flag.name}',
        style: NType.label.copyWith(color: fg, fontWeight: FontWeight.w600, letterSpacing: 0),
      ),
    );
  }
}

/// Colours per severity: red only for urgent clinical flags (constitution §8.3).
(Color, Color) severityColors(FlagSeverity? f) => switch (f) {
  FlagSeverity.urgent => (NColors.statusClinicalRedFlagLight, NColors.statusClinicalRedFlag),
  FlagSeverity.attention => (NColors.brandApricotLight, NColors.statusWarningText),
  FlagSeverity.information => (NColors.brandLavenderLight, NColors.statusInfo),
  null => (NColors.brandSageLight, NColors.statusSuccess),
};

class _QueueCard extends StatelessWidget {
  const _QueueCard({required this.item, required this.onTap});

  final QueueItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool overdue = (item.dueInHours ?? 1) <= 0;
    final (Color tint, Color ink) = severityColors(item.severity);
    final String due = dueText(s, item.dueInHours);
    return Padding(
      padding: const EdgeInsets.only(bottom: NSpace.xs),
      child: Material(
        color: NColors.surfaceCard,
        borderRadius: BorderRadius.circular(NRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(NRadius.lg),
              border: Border.all(color: item.severity == FlagSeverity.urgent ? ink.withValues(alpha: 0.35) : NColors.lineDefault),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(width: 5, color: ink.withValues(alpha: item.severity == null ? 0.35 : 0.85)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(NSpace.sm, NSpace.sm, NSpace.xs, NSpace.sm),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(NRadius.md)),
                            child: Icon(item.severity == null ? Icons.check_rounded : Icons.flag_outlined, size: 20, color: ink),
                          ),
                          const SizedBox(width: NSpace.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item.flagCount == 0 ? s.pvQueueNoFlags : s.pvQueueFlags(item.flagCount),
                                  style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: NSpace.xxs),
                                Wrap(
                                  spacing: NSpace.xxs,
                                  runSpacing: NSpace.xxs,
                                  children: <Widget>[
                                    if (item.severity != null)
                                      FlagBadge(
                                        flag: QueueFlag(key: '', name: '', severity: item.severity),
                                      ),
                                    if (item.dedicatedToMe) CPill(s.pvQueueDedicated, tone: CTone.plum),
                                    if (item.claimedByMe) CPill(s.pvQueueOpenedByMe, tone: CTone.quiet),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (due.isNotEmpty) ...<Widget>[
                            const SizedBox(width: NSpace.xs),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[CPill(due, tone: overdue ? CTone.apricot : CTone.quiet)],
                            ),
                          ],
                          Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
                        ],
                      ),
                    ),
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

/// A score ring with the total in big tabular figures.
class ScoreRing extends StatelessWidget {
  const ScoreRing({required this.value, required this.max, super.key, this.size = 92});

  final double value;
  final double max;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      alignment: Alignment.center,
      children: <Widget>[
        SizedBox.expand(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: max <= 0 ? 0 : (value / max).clamp(0, 1)),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (BuildContext context, double v, _) =>
                CircularProgressIndicator(value: v, strokeWidth: 9, strokeCap: StrokeCap.round, color: NColors.brandRosewood, backgroundColor: NColors.brandBlushLight),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              value.round().toString(),
              style: NType.h2.copyWith(
                color: NColors.inkPrimary,
                fontFamily: NType.body.fontFamily,
                fontWeight: FontWeight.w800,
                height: 1,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
            Text('/ ${max.round()}', style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0)),
          ],
        ),
      ],
    ),
  );
}

/// One scoring dimension as a labelled bar with its points.
class DimensionBar extends StatelessWidget {
  const DimensionBar({required this.name, required this.points, required this.max, super.key, this.level});

  final String name;
  final num points;
  final num max;
  final String? level;

  String _n(num x) => x == x.roundToDouble() ? x.toInt().toString() : x.toString();

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Padding(
      padding: const EdgeInsets.only(bottom: NSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NType.bodySm.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
                ),
              ),
              if (level != null) ...<Widget>[CPill(level!, tone: CTone.quiet), const SizedBox(width: NSpace.xs)],
              Text(
                '${_n(points)}/${_n(max)}',
                style: NType.caption.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700, letterSpacing: 0, fontFeatures: const <FontFeature>[FontFeature.tabularFigures()]),
              ),
            ],
          ),
          const SizedBox(height: 6),
          CBar(value: max <= 0 ? 0 : points / max, color: NColors.brandRosewood),
        ],
      ),
    ),
  );
}
