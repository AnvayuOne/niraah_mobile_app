/// Daily practice and live classes as the server returns them (spec 010 §7), matching
/// packages/contracts/src/member.ts `PracticeSession`, `PracticeToday`, `PracticeHistory`, `LiveClasses`.
/// Sessions unsuitable for pregnancy are already removed by the server when her flags say so (AC28).
library;

import '../../../core/payments/payment_checkout.dart';
import '../../../core/video/channel_token.dart';

export '../../../core/video/channel_token.dart' show ChannelToken, ClassRoomAccess, ClassRoomReady, ClassRoomShut;

class PracticeSession {
  const PracticeSession({
    required this.id,
    required this.title,
    required this.description,
    required this.minutes,
    required this.level,
    required this.tags,
    required this.phases,
    required this.caution,
    required this.captions,
    required this.video,
  });

  final String id;
  final String title;
  final String description;
  final int minutes;
  final String? level;
  final List<String> tags;
  final List<String> phases;

  /// Written by the instructor; shown with the session (spec 010 §7 rule 4).
  final String? caution;
  final bool captions;
  final String? video;
}

class PracticeToday {
  const PracticeToday({required this.phase, required this.sessions});

  /// Her estimated phase today, or null when it is not known.
  final String? phase;
  final List<PracticeSession> sessions;
}

class PracticeDone {
  const PracticeDone({required this.title, required this.minutes, required this.date});

  final String? title;
  final int minutes;
  final String date;
}

class PracticeWeek {
  const PracticeWeek({required this.weekOf, required this.sessions});

  final String weekOf;
  final List<PracticeDone> sessions;
}

enum ClassAccess { included, afterTrial, notIncluded }

class LiveClass {
  const LiveClass({required this.id, required this.title, required this.level, required this.startsAt, required this.endsAt, required this.instructor, required this.placesLeft});

  final String id;
  final String title;
  final String? level;
  final DateTime startsAt;
  final DateTime endsAt;
  final String? instructor;
  final int placesLeft;
}

class LiveClasses {
  const LiveClasses({required this.access, required this.startsOn, required this.classes});

  final ClassAccess access;
  final String? startsOn;
  final List<LiveClass> classes;
}

/// The outcome of booking a place (spec 014 §8 "Booking" 2, 4): booked against her allowance (or free), or held while
/// she pays the class fee the server set.
sealed class BookingOutcome {
  const BookingOutcome();
}

class ClassBooked extends BookingOutcome {
  const ClassBooked();
}

class ClassPaymentNeeded extends BookingOutcome {
  const ClassPaymentNeeded({required this.bookingId, required this.amountPaise, this.checkout});
  final String bookingId;
  final int amountPaise;
  final Checkout? checkout;
}

/// One of her class bookings (`GET /me/class-bookings`).
class ClassBooking {
  const ClassBooking({required this.id, required this.classId, required this.status, required this.title, required this.startsAt, required this.endsAt});

  final String id;
  final String classId;

  /// `held`, `booked` or `cancelled`.
  final String status;
  final String title;
  final DateTime startsAt;
  final DateTime endsAt;

  bool get booked => status == 'booked';
}

class PracticeFilters {
  const PracticeFilters({this.maxMinutes, this.focus, this.phase});

  final int? maxMinutes;
  final String? focus;
  final String? phase;
}

abstract class PracticeRepository {
  Future<PracticeToday> today();

  Future<List<PracticeSession>> library(PracticeFilters filters);

  Future<PracticeSession> session(String id);

  /// Records one completion; sending the same [clientId] again records nothing new (AC27).
  Future<void> complete(String id, {required int durationSeconds, required String clientId});

  Future<List<PracticeWeek>> history();

  Future<LiveClasses> liveClasses();

  /// The server takes a `yoga.live_classes` unit when she has one, or holds the place and opens an order for the fee
  /// (AC42). With neither, it refuses.
  Future<BookingOutcome> book(String classId);

  Future<List<ClassBooking>> classBookings();

  /// A held place is released; a booked one is refunded or the unit returned before the cut-off (§8 "Booking" 6).
  Future<String> cancelBooking(String bookingId);

  /// `POST /classes/{id}/room-token`: audience on the main channel (AC43).
  Future<ClassRoomAccess> roomToken(String classId);

  /// `POST /classes/{id}/camera-token`: her private camera channel to the instructor (AC43).
  Future<ChannelToken> cameraToken(String classId);
}
