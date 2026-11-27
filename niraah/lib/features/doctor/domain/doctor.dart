import 'package:equatable/equatable.dart';

import '../../assessment/domain/prescore.dart';

/// The doctor workspace (spec 011), matching apps/web/src/features/doctor/types.ts.
/// Lists contain only members she has a care relationship with (AC1).

class QueueFlag extends Equatable {
  const QueueFlag({required this.key, required this.name, required this.severity});

  final String key;
  final String name;

  /// Null for a flag whose severity the server does not state.
  final FlagSeverity? severity;

  @override
  List<Object?> get props => <Object?>[key, name, severity];
}

/// Hours from [now] until [at], to one decimal; null without a time. Negative when overdue.
double? hoursUntil(DateTime? at, DateTime now) => at == null ? null : (at.difference(now).inMinutes / 6).round() / 10;

/// One waiting review. Before a claim the queue carries no member detail (spec 007 §7.2): only
/// what the order is built from.
class QueueItem extends Equatable {
  const QueueItem({
    required this.id,
    required this.severity,
    required this.flagCount,
    required this.dueAt,
    required this.dueInHours,
    required this.waitingSince,
    required this.dedicatedToMe,
    this.claimedByMe = false,
  });

  final String id;

  /// The worst flag's severity; null when there are no flags.
  final FlagSeverity? severity;
  final int flagCount;
  final DateTime? dueAt;
  final double? dueInHours;
  final DateTime waitingSince;
  final bool dedicatedToMe;

  /// This doctor already holds the claim on it.
  final bool claimedByMe;

  @override
  List<Object?> get props => <Object?>[id, severity, flagCount, dueAt, dueInHours, waitingSince, dedicatedToMe, claimedByMe];
}

class DimensionPoints extends Equatable {
  const DimensionPoints({required this.name, required this.points, required this.max, this.level});

  final String name;
  final int points;
  final int max;
  final String? level;

  @override
  List<Object?> get props => <Object?>[name, points, max, level];
}

/// An observation the member will see; edits keep the original beside them
/// (spec 007 §7.12).
class ReviewObservation extends Equatable {
  const ReviewObservation({required this.original, this.edited, this.removed = false});

  final String original;
  final String? edited;
  final bool removed;

  String get shown => edited ?? original;
  bool get changed => edited != null || removed;

  @override
  List<Object?> get props => <Object?>[original, edited, removed];
}

class ReviewAnswer extends Equatable {
  const ReviewAnswer({required this.q, required this.a});

  final String q;
  final String a;

  @override
  List<Object?> get props => <Object?>[q, a];
}

/// The review screen of a claimed review (spec 007 §7.6, §7.11). Member details exist only when the
/// server sends them; today it does not (the reviewer sees answers, scores, flags and the summary).
class ReviewDetail extends Equatable {
  const ReviewDetail({
    required this.id,
    required this.flags,
    required this.total,
    required this.maximum,
    required this.dimensions,
    required this.observations,
    required this.answers,
    required this.consent,
    required this.consentCategories,
    this.member,
    this.ageBand,
    this.plan,
    this.dueAt,
    this.dueInHours,
    this.band,
    this.summary,
  });

  final String id;
  final String? member;
  final String? ageBand;
  final String? plan;
  final DateTime? dueAt;
  final double? dueInHours;
  final List<QueueFlag> flags;
  final int total;
  final int maximum;
  final String? band;
  final List<DimensionPoints> dimensions;

  /// The AI's clinician summary (spec 007 §6). Leads the screen; null when none was made.
  final String? summary;
  final List<ReviewObservation> observations;
  final List<ReviewAnswer> answers;

  /// Categories she has consented to share, for the consent tags (spec 001).
  final List<String> consent;
  final List<String> consentCategories;

  @override
  List<Object?> get props => <Object?>[id, member, ageBand, plan, dueAt, dueInHours, flags, total, maximum, band, dimensions, summary, observations, answers, consent, consentCategories];
}

class NeedsMe extends Equatable {
  const NeedsMe({
    required this.urgentAlerts,
    required this.reviews,
    required this.carePlans,
    required this.labResults,
    required this.messages,
    required this.draftPrescriptions,
    this.oldestReviewDueInHours,
    this.clinicalReview,
  });

  final int urgentAlerts;
  final int reviews;
  final double? oldestReviewDueInHours;
  final int carePlans;
  final int labResults;
  final int messages;
  final int draftPrescriptions;

  /// Clinical reviewers only (spec 011 §13).
  final int? clinicalReview;

  @override
  List<Object?> get props => <Object?>[urgentAlerts, reviews, oldestReviewDueInHours, carePlans, labResults, messages, draftPrescriptions, clinicalReview];
}

class TodayAppointment extends Equatable {
  const TodayAppointment({required this.id, required this.startsAt, required this.joinable, this.member, this.reason});

  final String id;
  final DateTime startsAt;
  final String? member;
  final String? reason;

  /// Inside the join window (spec 014 §5 "Entering" 1).
  final bool joinable;

  @override
  List<Object?> get props => <Object?>[id, startsAt, member, reason, joinable];
}

class DoctorDashboard extends Equatable {
  const DoctorDashboard({required this.needsMe, required this.today, required this.onCall, this.name, this.speciality});

  final String? name;
  final String? speciality;

  /// Each count equals the items in the list it opens (spec 011 AC6).
  final NeedsMe needsMe;
  final List<TodayAppointment> today;

  /// On call now: marked so, or inside her reviews-and-on-call hours.
  final bool onCall;

  @override
  List<Object?> get props => <Object?>[name, speciality, needsMe, today, onCall];
}

enum ClaimFailure { holdingAnother, gone }

class ClaimResult {
  const ClaimResult.ok(ReviewDetail this.review) : failure = null;
  const ClaimResult.failed(ClaimFailure this.failure) : review = null;

  final ReviewDetail? review;
  final ClaimFailure? failure;
}

enum ReviewOutcome { verified, followUp }

class CompleteResult {
  const CompleteResult.ok(this.next) : noteRequired = false;
  const CompleteResult.noteRequired() : next = null, noteRequired = true;

  /// The next review to open, if any.
  final String? next;
  final bool noteRequired;
}

abstract interface class DoctorRepository {
  Future<DoctorDashboard> getDashboard();

  /// In spec 007's order: urgent, my dedicated members, attention, then oldest first.
  Future<List<QueueItem>> getQueue();

  /// Opening a review claims it; one claim at a time (spec 007 §7.3–7.5, AC38, AC47).
  Future<ClaimResult> claim(String id);

  Future<void> release(String id);

  /// Null text removes the observation. Score, band and flags cannot be
  /// changed: there is no call for it (spec 007 AC36).
  Future<ReviewDetail> editObservation(String id, int index, String? text);

  /// With [next], the next waiting review is claimed and its id returned ("Verify and next").
  Future<CompleteResult> complete(String id, ReviewOutcome outcome, String note, {bool next = false});

  Future<void> scoringConcern(String id, String note);
}
