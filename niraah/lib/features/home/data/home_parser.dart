import '../../cycle/data/cycle_parser.dart';
import '../../cycle/domain/cycle.dart';
import '../domain/home.dart';

/// Reads `/me/workspace` and `/me/home` (packages/contracts/src/member.ts `Workspace`, `Home`) into the
/// Home document, the way apps/web/src/api/member-repositories.ts `toHomeDocument` does (spec 010 §2).
abstract final class HomeParser {
  /// The server's area keys the app has a destination for; the rest are left out until they do.
  static const Map<String, Area> areas = <String, Area>{'home': Area.home, 'cycle': Area.cycle, 'ai_care': Area.aiCare, 'practice': Area.practice, 'me': Area.me};

  /// Before the assessment is complete Home is the gate (spec 010 AC2); null means Home has content.
  static HomeGate? gate(Map<String, dynamic> workspace) {
    final Object? state = workspace['state'];
    if (state != 'member_new' && state != 'assessment_gate') return null;
    final Object? minutes = workspace['assessmentMinutes'];
    return HomeGate(estimatedMinutes: minutes is num ? minutes.round() : null);
  }

  static HomeContent content(Map<String, dynamic> h) {
    final IsoDate today = '${h['today']}';
    final Map<dynamic, dynamic>? notice = h['notice'] as Map?;
    final Map<dynamic, dynamic>? log = h['todayLog'] as Map?;
    final Map<dynamic, dynamic>? suggestion = h['suggestion'] as Map?;
    final Map<dynamic, dynamic>? cycle = h['cycle'] as Map?;
    final List<dynamic>? tasks = h['tasks'] as List<dynamic>?;
    return HomeContent(
      name: h['name'] as String?,
      today: today,
      areas: ((h['areas'] as List<dynamic>?) ?? const <dynamic>[]).map((dynamic a) => areas['$a']).whereType<Area>().toList(growable: false),
      notice: notice == null ? null : _notice(notice),
      // Null when her plan lacks `cycle_tracking.access`.
      cycle: cycle == null ? null : CycleParser.summary(cycle),
      // Without cycle tracking there is no log on Home; an empty day keeps the screen's shape.
      todayLog: log == null ? DailyLog(date: today) : CycleParser.dailyLog(log),
      suggestion: suggestion == null
          ? null
          : DailySuggestion(
              title: '${suggestion['title']}',
              text: '${suggestion['text']}',
              writtenBy: suggestion['writtenBy'] == 'model' ? SuggestionAuthor.model : SuggestionAuthor.rules,
            ),
      preScore: preScore(h['prescore'] as Map?),
      tasks: tasks?.map((dynamic t) {
        final Map<dynamic, dynamic> m = t as Map<dynamic, dynamic>;
        return HomeTask(id: '${m['id']}', title: '${m['title']}', done: m['done'] == true);
      }).toList(growable: false),
      next: _next(h['next'] as Map?),
      checkInWeek: (h['checkIn'] as Map?)?['weekStart'] as String?,
    );
  }

  static HomeNext? _next(Map<dynamic, dynamic>? n) {
    final DateTime? at = n == null ? null : DateTime.tryParse('${n['startsAt']}');
    if (n == null || at == null) return null;
    return HomeNext(isClass: n['kind'] == 'class', startsAt: at.toLocal(), withName: n['with'] as String?, title: n['title'] as String?);
  }

  /// The card until she hides it; the review line names a target only while a doctor's review is awaited.
  static HomePreScore? preScore(Map<dynamic, dynamic>? p) {
    if (p == null) return null;
    final Map<dynamic, dynamic> review = (p['review'] as Map?) ?? const <dynamic, dynamic>{};
    final Object? hours = review['targetHours'];
    return HomePreScore(
      total: (p['total'] as num).round(),
      maximum: (p['maximum'] as num).round(),
      band: (p['band'] as String?) ?? '',
      reviewTarget: review['state'] == 'awaiting_review' ? '${hours is num ? hours.round() : 24} hours' : null,
    );
  }

  /// At most one notice (spec 010 §2 rule 3); a kind the app does not know is not shown.
  static HomeNotice? _notice(Map<dynamic, dynamic> n) {
    final NoticeKind? kind = NoticeKind.values.asNameMap()[n['kind']];
    return kind == null ? null : HomeNotice(kind: kind, text: '${n['text']}');
  }
}
