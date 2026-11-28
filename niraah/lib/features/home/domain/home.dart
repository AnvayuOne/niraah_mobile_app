import 'package:equatable/equatable.dart';

import '../../cycle/domain/cycle.dart';

/// Home as the server returns it (spec 010 §2), matching
/// apps/web/src/features/home/types.ts. The server decides what appears; the
/// client only renders. Absent elements are null.

enum Area { home, cycle, aiCare, practice, me }

sealed class HomeDocument extends Equatable {
  const HomeDocument();
}

/// The assessment is not complete: Home shows the gate (spec 010 AC2).
class HomeGate extends HomeDocument {
  const HomeGate({required this.estimatedMinutes});

  /// The assessment's estimated length; null when the server has none, and the
  /// gate then leaves the "about N minutes" sentence out.
  final int? estimatedMinutes;

  @override
  List<Object?> get props => <Object?>[estimatedMinutes];
}

enum NoticeKind { paymentFailed, planRetiring, trialEnding }

class HomeNotice extends Equatable {
  const HomeNotice({required this.kind, required this.text});

  final NoticeKind kind;
  final String text;

  @override
  List<Object?> get props => <Object?>[kind, text];
}

enum SuggestionAuthor { model, rules }

class DailySuggestion extends Equatable {
  const DailySuggestion({required this.title, required this.text, required this.writtenBy});

  final String title;
  final String text;

  /// The AI mark shows only when a model wrote it (spec 009).
  final SuggestionAuthor writtenBy;

  @override
  List<Object?> get props => <Object?>[title, text, writtenBy];
}

class HomePreScore extends Equatable {
  const HomePreScore({required this.total, required this.maximum, required this.band, this.reviewTarget});

  final int total;
  final int maximum;
  final String band;

  /// Set while a doctor's review is awaited; null when no review is required.
  final String? reviewTarget;

  @override
  List<Object?> get props => <Object?>[total, maximum, band, reviewTarget];
}

class HomeTask extends Equatable {
  const HomeTask({required this.id, required this.title, required this.done});

  final String id;
  final String title;
  final bool done;

  @override
  List<Object?> get props => <Object?>[id, title, done];
}

/// Her next consult or live class (spec 010 §2; spec 014).
class HomeNext extends Equatable {
  const HomeNext({required this.isClass, required this.startsAt, this.withName, this.title});

  final bool isClass;
  final DateTime startsAt;
  final String? withName;
  final String? title;

  @override
  List<Object?> get props => <Object?>[isClass, startsAt, withName, title];
}

class HomeContent extends HomeDocument {
  const HomeContent({
    required this.today,
    required this.areas,
    required this.todayLog,
    this.suggestion,
    this.name,
    this.notice,
    this.cycle,
    this.preScore,
    this.tasks,
    this.next,
    this.checkInWeek,
  });

  final HomeNext? next;

  /// The week of a check-in that is due; it lapses quietly and is never "missed" (spec 010 §11 rule 3).
  final IsoDate? checkInWeek;

  final String? name;
  final IsoDate today;
  final List<Area> areas;

  /// At most one (spec 010 §2 rule 3).
  final HomeNotice? notice;

  /// Null when her plan lacks `cycle_tracking.access`.
  final CycleSummary? cycle;
  final DailyLog todayLog;
  /// Null when the server has none for today; Home then shows no suggestion card.
  final DailySuggestion? suggestion;
  final HomePreScore? preScore;

  /// Only with a signed care plan; never shown as overdue.
  final List<HomeTask>? tasks;

  @override
  List<Object?> get props => <Object?>[name, today, areas, notice, cycle, todayLog, suggestion, preScore, tasks, next, checkInWeek];
}

abstract interface class HomeRepository {
  Future<HomeDocument> getHome();

  Future<void> logPeriodStart(IsoDate date);

  /// Merges into today's log; a second save for the same date updates it.
  Future<DailyLog> saveTodayLog(DailyLogPatch patch);

  Future<void> hidePreScoreCard();
}
