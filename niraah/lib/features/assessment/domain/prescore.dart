import 'package:equatable/equatable.dart';

/// A pre-score as the member receives it (spec 007 §5). It has each
/// dimension's name and level, never its points (spec 005 AC31).

enum FlagSeverity { information, attention, urgent }

FlagSeverity severityFrom(String raw) => switch (raw) {
      'urgent' => FlagSeverity.urgent,
      'attention' => FlagSeverity.attention,
      _ => FlagSeverity.information,
    };

enum ReviewState { notRequired, awaitingReview, verified, followUpRequested }

enum ObservationSource { ai, rules }

class Band extends Equatable {
  const Band({required this.label, required this.message, required this.colorToken});

  final String label;
  final String message;
  final String colorToken;

  @override
  List<Object?> get props => <Object?>[label, message, colorToken];
}

class DimensionLevel extends Equatable {
  const DimensionLevel({required this.name, required this.level});

  final String name;
  final String level;

  @override
  List<Object?> get props => <Object?>[name, level];
}

class RaisedFlag extends Equatable {
  const RaisedFlag({required this.key, required this.severity, this.careMessage});

  final String key;
  final FlagSeverity severity;

  /// Written by clinicians in the flag catalogue; shown above the score.
  final String? careMessage;

  @override
  List<Object?> get props => <Object?>[key, severity, careMessage];
}

class Reviewer extends Equatable {
  const Reviewer({required this.name, required this.speciality});

  final String name;
  final String speciality;

  @override
  List<Object?> get props => <Object?>[name, speciality];
}

class PreScore extends Equatable {
  const PreScore({
    required this.id,
    required this.total,
    required this.maximum,
    required this.band,
    required this.dimensions,
    required this.flags,
    required this.observations,
    required this.observationSource,
    required this.reviewState,
    required this.hasPaidPlan,
    this.plansIncludingReview = const <String>[],
    this.reviewTarget,
    this.reviewer,
    this.doctorNote,
    this.suggestedProgram,
  });

  final String id;
  final int total;
  final int maximum;
  final Band band;
  final List<DimensionLevel> dimensions;
  final List<RaisedFlag> flags;

  /// Up to four observations.
  final List<String> observations;
  final ObservationSource observationSource;
  final ReviewState reviewState;
  final bool hasPaidPlan;
  final List<String> plansIncludingReview;
  final String? reviewTarget;
  final Reviewer? reviewer;
  final String? doctorNote;
  final String? suggestedProgram;

  bool get hasUrgentFlag => flags.any((RaisedFlag f) => f.severity == FlagSeverity.urgent);

  PreScore withObservations(List<String> obs, ObservationSource source) => PreScore(
        id: id,
        total: total,
        maximum: maximum,
        band: band,
        dimensions: dimensions,
        flags: flags,
        observations: obs.take(4).toList(growable: false),
        observationSource: source,
        reviewState: reviewState,
        hasPaidPlan: hasPaidPlan,
        plansIncludingReview: plansIncludingReview,
        reviewTarget: reviewTarget,
        reviewer: reviewer,
        doctorNote: doctorNote,
        suggestedProgram: suggestedProgram,
      );

  @override
  List<Object?> get props => <Object?>[
        id, total, maximum, band, dimensions, flags, observations, observationSource, reviewState,
        hasPaidPlan, plansIncludingReview, reviewTarget, reviewer, doctorNote, suggestedProgram,
      ];
}

enum NextAction { bookDoctor, seePlans, goHome }

/// Exactly one primary action after the pre-score, in the order of spec 007 §8.
NextAction nextActionFor(PreScore p) {
  if (p.hasUrgentFlag) return NextAction.bookDoctor;
  if (p.reviewState == ReviewState.followUpRequested) return NextAction.bookDoctor;
  if (!p.hasPaidPlan) return NextAction.seePlans;
  return NextAction.goHome;
}
