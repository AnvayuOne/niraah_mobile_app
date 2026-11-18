import 'package:material_ui/material_ui.dart';

import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/cycle_ring.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/presentation/home_labels.dart';
import '../domain/cycle.dart';

/// The cycle ring and the lines under it, identical on Home and the Cycle
/// screen (spec 010 §2, §3). With no period logged it shows no day or phase
/// (AC8); every predicted date or phase says "estimated" (AC14).
class CycleSummaryView extends StatelessWidget {
  const CycleSummaryView({required this.summary, super.key, this.diameter = 200});

  final CycleSummary summary;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<String> spoken = <String>[s.homeRingLabel];
    final List<Widget> lines = <Widget>[];
    CycleRingData? ring;
    Widget center = const SizedBox.shrink();

    switch (summary) {
      case CycleNoData():
        break;
      case CycleOff(:final CycleMarker reason):
        spoken.add(s.offReason(reason));
        lines.add(_line(s.offReason(reason)));
      case final CycleEstimate e:
        ring = CycleRingData(
          dayOfCycle: e.dayOfCycle,
          ringLength: e.ringLength,
          periodDays: e.periodLength,
          fertileStart: e.fertileStart,
          fertileEnd: e.ovulationDay == null ? null : e.ovulationDay! + 1,
        );
        spoken.add(s.homeDay(e.dayOfCycle));
        if (e.phase != null) spoken.add(s.phaseEstimated(e.phase!));
        center = Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(s.homeDay(e.dayOfCycle), style: NType.h1.copyWith(color: NColors.inkPrimary)),
            if (e.phase != null) Text(s.phaseName(e.phase!), style: NType.bodySm.copyWith(color: NColors.inkSecondary, fontWeight: FontWeight.w600)),
            Text(s.homeEstimatedSuffix, style: NType.label.copyWith(color: NColors.inkMuted)),
          ],
        );
        if (e.late) {
          spoken.add(s.homeLate);
          lines.add(_line(s.homeLate));
        } else if (e.daysToNext != null) {
          spoken.add(s.nextIn(e.daysToNext!));
          lines.add(_line(s.nextIn(e.daysToNext!), strong: true));
        }
        if (e.windowStart == null) {
          spoken.add(s.homeNoWindow);
          lines.add(_line(s.homeNoWindow));
        } else if (e.basis == PredictionBasis.assessment) {
          spoken.add(s.homeFromAssessment);
          lines.add(_line(s.homeFromAssessment));
        }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(child: CycleRing(data: ring, center: center, semanticLabel: spoken.join('. '), diameter: diameter)),
        const SizedBox(height: NSpace.md),
        ...lines,
      ],
    );
  }

  static Widget _line(String text, {bool strong = false}) => Padding(
        padding: const EdgeInsets.only(bottom: NSpace.xs),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: (strong ? NType.body : NType.bodySm).copyWith(
            color: strong ? NColors.inkPrimary : NColors.inkSecondary,
            fontWeight: strong ? FontWeight.w600 : null,
          ),
        ),
      );
}
