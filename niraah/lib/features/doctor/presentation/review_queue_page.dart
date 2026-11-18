import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
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
          if (items == null) return LoadingView(label: s.loading);
          return ListView(
            padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.sm, NSpace.lg, NSpace.xl),
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(s.pvQueueTitle, style: NType.h2.copyWith(color: NColors.inkPrimary)),
              ),
              const SizedBox(height: NSpace.xxs),
              Text(items.isEmpty ? s.pvQueueEmpty : s.pvQueuePick, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
              const SizedBox(height: NSpace.md),
              for (final QueueItem q in items)
                _QueueCard(
                  item: q,
                  onTap: () async {
                    await context.push('/doctor/review/${q.id}');
                    if (mounted) _reload();
                  },
                ),
            ],
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

class _QueueCard extends StatelessWidget {
  const _QueueCard({required this.item, required this.onTap});

  final QueueItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool overdue = (item.dueInHours ?? 1) <= 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: NSpace.xs),
      child: Material(
        color: NColors.surfaceCard,
        borderRadius: BorderRadius.circular(NRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(NRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(NSpace.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(NRadius.lg),
              border: Border.all(color: NColors.lineDefault),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.flagCount == 0 ? s.pvQueueNoFlags : s.pvQueueFlags(item.flagCount),
                        style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(dueText(s, item.dueInHours), style: NType.label.copyWith(color: overdue ? NColors.statusAttention : NColors.inkSecondary, letterSpacing: 0)),
                  ],
                ),
                const SizedBox(height: NSpace.xs),
                Wrap(
                  spacing: NSpace.xs,
                  runSpacing: NSpace.xxs,
                  children: <Widget>[
                    if (item.dedicatedToMe)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: NSpace.xs, vertical: NSpace.xxs / 2),
                        decoration: BoxDecoration(color: NColors.brandSageLight, borderRadius: BorderRadius.circular(NRadius.pill)),
                        child: Text(
                          s.pvQueueDedicated,
                          style: NType.label.copyWith(color: NColors.statusSuccess, fontWeight: FontWeight.w600, letterSpacing: 0),
                        ),
                      ),
                    if (item.severity != null)
                      FlagBadge(
                        flag: QueueFlag(key: '', name: '', severity: item.severity),
                      ),
                    if (item.claimedByMe) Text(s.pvQueueOpenedByMe, style: NType.label.copyWith(color: NColors.inkSecondary, letterSpacing: 0)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
