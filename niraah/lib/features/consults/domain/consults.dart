/// Consults from the member's side (spec 014 §2-§6; spec 010 §9 "Find a specialist and appointments"), matching
/// what packages/core/src/consults returns over `/api/v1`: `Directory.list`/`profile`, `Booking.slots`/`hold`/`confirm`/
/// `view`, `Changes.*`, `Rooms.token`/`rate`. The server decides every fee, slot, state and outcome; the app shows them.
library;

import 'package:equatable/equatable.dart';

import '../../../core/payments/payment_checkout.dart';

/// `doctor` or `dietitian`.
typedef ProviderType = String;

/// A clinician in "Find a specialist" (spec 014 §2.1, §2.2, §2.7).
class Specialist extends Equatable {
  const Specialist({
    required this.id,
    required this.type,
    required this.name,
    required this.title,
    required this.hasPhoto,
    required this.specialities,
    required this.languages,
    required this.yearsExperience,
    required this.bio,
    required this.nextSlot,
    required this.feePaise,
    required this.ratingAverage,
    required this.ratingCount,
    required this.registrationNumber,
    required this.registrationCouncil,
    required this.dedicated,
    required this.label,
    this.available = true,
    this.horizonDays,
  });

  final String id;
  final ProviderType type;
  final String? name;
  final String title;
  final bool hasPhoto;
  final List<String> specialities;
  final List<String> languages;
  final int? yearsExperience;
  final String? bio;
  final DateTime? nextSlot;

  /// Includes GST (spec 010 §9.1). Null when no fee is set, which means she is not bookable.
  final int? feePaise;
  final double? ratingAverage;
  final int ratingCount;

  /// A doctor's registration (§2.2, AC6); null for a dietitian.
  final String? registrationNumber;
  final String? registrationCouncil;

  /// Her dedicated clinician, shown first and labelled "Your doctor" or "Your dietitian" by the server (§2.7).
  final bool dedicated;
  final String? label;

  /// From a profile only: false shows "no times available" (§2.4).
  final bool available;

  /// From a profile only: the booking horizon in days.
  final int? horizonDays;

  bool get isDoctor => type == 'doctor';

  @override
  List<Object?> get props => <Object?>[id, type, name, nextSlot, feePaise, dedicated, available];
}

/// Filters for the list (§2.3). Empty fields are not sent.
class DirectoryFilters extends Equatable {
  const DirectoryFilters({this.type, this.speciality, this.language, this.day});

  final ProviderType? type;
  final String? speciality;
  final String? language;

  /// `YYYY-MM-DD`.
  final String? day;

  bool get isEmpty => type == null && speciality == null && language == null && day == null;

  @override
  List<Object?> get props => <Object?>[type, speciality, language, day];
}

class Slot extends Equatable {
  const Slot({required this.startsAt, this.endsAt});

  final DateTime startsAt;
  final DateTime? endsAt;

  @override
  List<Object?> get props => <Object?>[startsAt, endsAt];
}

/// Bookable times for a clinician, or for a type when the clinician is assigned (§3 "Pooled assignment" 1).
class SlotList extends Equatable {
  const SlotList({required this.slots, required this.feePaise, required this.included, this.fallbackReason, this.fallbackType});

  final List<Slot> slots;

  /// The fee for this clinician; null for pooled times.
  final int? feePaise;

  /// True when this booking will use an included consult from her plan.
  final bool included;

  /// Her dedicated clinician has no time soon: she may see another clinician as an included consult (§3 "Dedicated" 2, AC14).
  final String? fallbackReason;
  final ProviderType? fallbackType;

  @override
  List<Object?> get props => <Object?>[slots, feePaise, included, fallbackReason, fallbackType];
}

/// One appointment as `GET /appointments/{id}` returns it to the member (core `Booking.view`).
class Appointment extends Equatable {
  const Appointment({
    required this.id,
    required this.status,
    required this.kind,
    required this.providerType,
    required this.startsAt,
    required this.endsAt,
    required this.feePaise,
    required this.holdExpiresAt,
    required this.clinicianId,
    required this.clinicianName,
    required this.pooled,
    required this.reschedulesLeft,
    required this.roomOpensAt,
    required this.recording,
    this.recordMode = 'off',
    this.askTranscriptConsent = false,
    this.transcript,
  });

  final String id;

  /// `held`, `confirmed`, `in_progress`, `completed`, `cancelled`, `no_show` or `expired` (spec 014 §3 "States").
  final String status;

  /// `included` or `paid`.
  final String kind;
  final ProviderType? providerType;
  final DateTime startsAt;
  final DateTime endsAt;
  final int feePaise;
  final DateTime? holdExpiresAt;
  final String clinicianId;
  final String? clinicianName;
  final bool pooled;
  final int reschedulesLeft;
  final DateTime roomOpensAt;

  /// The recording mark (§5 "Recording" 5, AC51).
  final bool recording;

  /// The platform's consult record mode: `off`, `recording` or `transcript` (§5 "Recording" 1).
  final String recordMode;

  /// The server asks for transcript consent at booking (`recordConsentDraft`; §5 "Recording" 3): the speech service is
  /// on and the mode is transcript. Its wording is a draft until legal approves it (014-Q15).
  final bool askTranscriptConsent;

  /// Where this consult's transcript stands: `pending`, `ready` or `failed`; null when it has none (§5 "Reading a
  /// transcript" 8).
  final String? transcript;

  bool get held => status == 'held';
  bool get confirmed => status == 'confirmed';
  bool get live => status == 'confirmed' || status == 'in_progress';
  bool get included => kind == 'included';

  /// Upcoming: not finished and not yet past its end.
  bool upcoming(DateTime now) => (status == 'held' || live) && endsAt.isAfter(now);

  @override
  List<Object?> get props => <Object?>[id, status, kind, startsAt, endsAt, feePaise, holdExpiresAt, clinicianName, reschedulesLeft, recording, recordMode, askTranscriptConsent, transcript];
}

/// One stretch of a consult transcript. Speakers by role (`member`, `doctor` or `dietitian`), never by name (AC62).
class TranscriptLine extends Equatable {
  const TranscriptLine({required this.speaker, required this.startSeconds, required this.text});

  final String speaker;
  final double? startSeconds;
  final String text;

  @override
  List<Object?> get props => <Object?>[speaker, startSeconds, text];
}

/// A consult transcript as `GET /appointments/{id}/transcript` returns it (spec 014 §5 "Reading a transcript"): text
/// only, machine-made and unverified, never a file to download.
class ConsultTranscript extends Equatable {
  const ConsultTranscript({required this.status, required this.partial, required this.missing, required this.lines});

  /// `none`, `pending`, `ready` or `failed`.
  final String status;

  /// The member stopped the recording part-way.
  final bool partial;

  /// Roles whose audio could not be transcribed.
  final List<String> missing;
  final List<TranscriptLine> lines;

  @override
  List<Object?> get props => <Object?>[status, partial, missing, lines];
}

/// What confirming a hold did (§3 "Steps" 4).
sealed class ConfirmOutcome {
  const ConfirmOutcome();
}

/// Included consult (or no fee): confirmed at once, the unit taken (AC11).
class Confirmed extends ConfirmOutcome {
  const Confirmed(this.appointment);
  final Appointment appointment;
}

/// A paid consult: the server opened a gateway order for the fee kept on the hold (AC18). The appointment is confirmed
/// only when the server has the verified payment (AC11). [checkout] is null if the server sent none to open.
class PaymentNeeded extends ConfirmOutcome {
  const PaymentNeeded(this.amountPaise, [this.checkout]);
  final int amountPaise;
  final Checkout? checkout;
}

/// The data categories a clinician may see, each agreed or declined per booking (§3 "Steps" 2; contracts `Confirm`).
const List<String> consultCategories = <String>['health_data', 'assessment', 'cycle_symptoms', 'meals', 'lab_reports', 'messages'];

/// After "the call did not work" (§6 "Technical failure"): she chooses rebooking or a refund herself, or it waits for an admin.
class FailureReport extends Equatable {
  const FailureReport({required this.memberChoice, required this.options});

  final bool memberChoice;

  /// `rebook`, `refund`.
  final List<String> options;

  @override
  List<Object?> get props => <Object?>[memberChoice, options];
}

/// The room token answer (§5 "Tokens", AC20, AC21).
sealed class RoomAccess {
  const RoomAccess();
}

class RoomReady extends RoomAccess {
  const RoomReady({required this.appId, required this.channel, required this.uid, required this.token, required this.expiresAt, required this.closesAt, required this.recording});

  final String appId;
  final String channel;
  final int uid;
  final String token;
  final DateTime expiresAt;
  final DateTime? closesAt;
  final bool recording;
}

/// Too early: the room opens at [opensAt].
class RoomNotOpen extends RoomAccess {
  const RoomNotOpen({required this.opensAt, required this.message});
  final DateTime? opensAt;
  final String message;
}

/// The room has closed, or the appointment is not open for joining.
class RoomClosed extends RoomAccess {
  const RoomClosed(this.message);
  final String message;
}

/// Not hers (404) or anything else the server refused.
class RoomUnavailable extends RoomAccess {
  const RoomUnavailable(this.message);
  final String message;
}

/// Her included consults of one type, from `/me/entitlements` (spec 010 §9.2: "how many remain").
class IncludedConsults extends Equatable {
  const IncludedConsults({required this.type, required this.remaining, required this.allowance, required this.refillsAt});

  final ProviderType type;

  /// Null when unlimited.
  final int? remaining;
  final int? allowance;
  final String? refillsAt;

  bool get usable => remaining == null || remaining! > 0;

  @override
  List<Object?> get props => <Object?>[type, remaining, allowance, refillsAt];
}

/// The AI specialist guide (spec 009 `specialist_guide`; spec 014 §2.5, AC7): kinds of specialist, never a named person.
class SpecialistGuide extends Equatable {
  const SpecialistGuide({required this.suggestions, required this.note, required this.madeByModel});

  final List<({String kind, String reason})> suggestions;
  final String note;
  final bool madeByModel;

  @override
  List<Object?> get props => <Object?>[suggestions, note, madeByModel];
}

abstract class ConsultsRepository {
  /// `GET /specialists`: soonest first, her dedicated clinician first (§2, AC6).
  Future<List<Specialist>> specialists(DirectoryFilters filters);

  /// `GET /specialists/{id}`.
  Future<Specialist> specialist(String id);

  /// `GET /me/consult-slots` for a clinician ([providerId]) or a type ([type], pooled).
  Future<SlotList> slots({String? providerId, ProviderType? type, required DateTime from, required DateTime to});

  /// `POST /me/appointments`: holds the time; it is gone for everyone else (§3 "Steps" 1, AC8).
  Future<Appointment> hold({String? providerId, ProviderType? type, required DateTime startsAt, bool includedOnly = false});

  /// `POST /appointments/{id}/confirm` with the categories she agreed to and her reason (AC15), and her answer to the
  /// transcript consent when she was asked (§5 "Recording" 3).
  Future<ConfirmOutcome> confirm(String id, {required List<String> consents, String? reason, bool? recordConsent});

  /// `GET /appointments`.
  Future<List<Appointment>> appointments();

  Future<Appointment> appointment(String id);

  /// Returns `released`, `refunded`, `unit_returned` or `kept` (AC35).
  Future<String> cancel(String id);

  Future<Appointment> reschedule(String id, DateTime startsAt);

  Future<Appointment> acceptProposal(String id);

  /// After a clinician no-show or a failed call: her money or unit back. Returns `refunded`, `unit_returned` or null.
  Future<String?> declineOffer(String id);

  /// Another time, carrying over what was paid or used. [providerId] null lets the server assign one.
  Future<Appointment> rebook(String id, DateTime startsAt, {String? providerId});

  Future<FailureReport> reportFailure(String id);

  /// 1 to 5, once per appointment (§5 "Ending and completion" 4, AC33).
  Future<void> rate(String id, int rating, String? comment);

  Future<RoomAccess> roomToken(String id);

  /// She stops the recording; what was kept is marked partial (§5 "Recording" 5, AC52).
  Future<void> stopRecording(String id);

  /// `GET /appointments/{id}/transcript`: her consult's transcript as text (§5 "Reading a transcript" 1, 5).
  Future<ConsultTranscript> transcript(String id);

  /// Her included doctor and dietitian consults, only those her plan includes.
  Future<List<IncludedConsults>> included();

  Future<SpecialistGuide> guide(String concern);
}
