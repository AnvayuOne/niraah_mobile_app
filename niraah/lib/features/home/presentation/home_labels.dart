import '../../../l10n/app_localizations.dart';
import '../../cycle/domain/cycle.dart';
import '../domain/home.dart';

/// Words for cycle and log values. Every predicted phase says "estimated"
/// elsewhere (spec 010 AC14); these are the bare names.
extension HomeLabels on S {
  String phaseName(Phase p) => switch (p) {
        Phase.menstrual => homePhaseMenstrual,
        Phase.follicular => homePhaseFollicular,
        Phase.ovulatory => homePhaseOvulatory,
        Phase.luteal => homePhaseLuteal,
      };

  String flowName(PeriodFlow f) => switch (f) {
        PeriodFlow.none => homeFlowNone,
        PeriodFlow.spotting => homeFlowSpotting,
        PeriodFlow.light => homeFlowLight,
        PeriodFlow.medium => homeFlowMedium,
        PeriodFlow.heavy => homeFlowHeavy,
      };

  String moodName(Mood m) => switch (m) {
        Mood.calm => homeMoodCalm,
        Mood.happy => homeMoodHappy,
        Mood.low => homeMoodLow,
        Mood.anxious => homeMoodAnxious,
        Mood.irritable => homeMoodIrritable,
      };

  String energyName(Energy e) => switch (e) {
        Energy.low => homeEnergyLow,
        Energy.okay => homeEnergyOkay,
        Energy.high => homeEnergyHigh,
      };

  String offReason(CycleMarker m) => switch (m) {
        CycleMarker.pregnant => homeOffPregnant,
        CycleMarker.hormonalContraception => homeOffHormonalContraception,
        CycleMarker.noPeriods => homeOffNoPeriods,
        CycleMarker.breastfeeding => homeOffBreastfeeding,
      };

  String areaName(Area a) => switch (a) {
        Area.home => navHome,
        Area.cycle => navCycle,
        Area.aiCare => navAiCare,
        Area.practice => navPractice,
        Area.me => navMe,
      };

  /// "Next period estimated in a to b days", or in one number when a == b.
  String nextIn((int, int) d) => d.$1 == d.$2 ? homeNextInSame(d.$1) : homeNextIn(d.$1, d.$2);

  /// Phase with "estimated", as spoken and as shown under the day.
  String phaseEstimated(Phase p) => '${phaseName(p)}, $homeEstimatedSuffix';

  String markerName(CycleMarker m) => switch (m) {
        CycleMarker.pregnant => cycleMarkerPregnant,
        CycleMarker.breastfeeding => cycleMarkerBreastfeeding,
        CycleMarker.hormonalContraception => cycleMarkerHormonalContraception,
        CycleMarker.noPeriods => cycleMarkerNoPeriods,
      };

  String periodError(PeriodError e) => switch (e) {
        PeriodError.endBeforeStart => cycleErrorEndBeforeStart,
        PeriodError.future => cycleErrorFuture,
        PeriodError.overlaps => cycleErrorOverlaps,
      };

  String rangeText((int, int) r) => r.$1 == r.$2 ? cycleRangeSame(r.$1) : cycleRange(r.$1, r.$2);

  String patternText(CyclePattern p) => p.min == p.max ? cyclePatternSame(p.count, p.min) : cyclePattern(p.count, p.min, p.max);
}
