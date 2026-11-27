/// Daily practice and live classes as the server returns them (spec 010 §7), matching
/// packages/contracts/src/member.ts `PracticeSession`, `PracticeToday`, `PracticeHistory`, `LiveClasses`.
/// Sessions unsuitable for pregnancy are already removed by the server when her flags say so (AC28).
library;

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

/// The outcome of booking a place (spec 014): booked, or a fee to pay first.
enum BookingOutcome { booked, paymentNeeded }

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

  Future<BookingOutcome> book(String classId);
}
