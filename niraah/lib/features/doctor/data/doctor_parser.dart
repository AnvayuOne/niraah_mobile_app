import '../../assessment/domain/prescore.dart';
import '../domain/doctor.dart';

/// Reads `/doctor/dashboard` and the pre-score review endpoints (spec 011 §1, §4; spec 007 §7) into the
/// screen types, the way apps/web/src/api/doctor-repository.ts does. Nothing is invented: there is no
/// member detail before a claim, and none in the review today (spec 007 §7.2, §7.11).
abstract final class DoctorParser {
  /// The one consent category spec 007's review reads: her consent to a doctor's review.
  static const String reviewConsent = 'Doctor review';

  static DateTime? _time(Object? v) => v is String ? DateTime.tryParse(v) : null;
  static FlagSeverity? _severity(Object? v) => v is String ? severityFrom(v) : null;
  static int _int(Object? v) => v is num ? v.round() : 0;

  static DoctorDashboard dashboard(Map<String, dynamic> d, DateTime now) {
    final Map<dynamic, dynamic> doctor = (d['doctor'] as Map?) ?? const <String, dynamic>{};
    final Map<dynamic, dynamic> n = d['needsMe'] as Map;
    return DoctorDashboard(
      name: doctor['name'] as String?,
      speciality: doctor['speciality'] as String?,
      needsMe: NeedsMe(
        urgentAlerts: _int(n['urgentAlerts']),
        reviews: _int(n['reviews']),
        oldestReviewDueInHours: hoursUntil(_time(n['oldestReviewDueAt']), now),
        carePlans: _int(n['carePlans']),
        labResults: _int(n['labResults']),
        messages: _int(n['messages']),
        draftPrescriptions: _int(n['draftPrescriptions']),
        clinicalReview: n['clinicalReview'] is num ? _int(n['clinicalReview']) : null,
      ),
      today: <TodayAppointment>[
        for (final dynamic a in (d['today'] as List<dynamic>?) ?? const <dynamic>[])
          TodayAppointment(id: '${(a as Map)['id']}', startsAt: _time(a['startsAt']) ?? now, member: a['member'] as String?, reason: a['reason'] as String?, joinable: a['joinable'] == true),
      ],
      onCall: d['onCall'] == true,
    );
  }

  static QueueItem queueItem(Map<dynamic, dynamic> i, DateTime now) {
    final DateTime? due = _time(i['dueAt']);
    return QueueItem(
      id: '${i['id']}',
      severity: _severity(i['severity']),
      flagCount: _int(i['flagCount']),
      dueAt: due,
      dueInHours: hoursUntil(due, now),
      waitingSince: _time(i['waitingSince']) ?? now,
      dedicatedToMe: i['dedicated'] == true,
      claimedByMe: i['claimedByMe'] == true,
    );
  }

  static List<QueueItem> queue(Map<String, dynamic> q, DateTime now) => <QueueItem>[for (final dynamic i in (q['items'] as List<dynamic>?) ?? const <dynamic>[]) queueItem(i as Map, now)];

  static ReviewDetail review(Map<String, dynamic> r, DateTime now) {
    final DateTime? due = _time(r['dueAt']);
    return ReviewDetail(
      id: '${r['id']}',
      member: r['member'] as String?,
      ageBand: r['ageBand'] as String?,
      plan: r['plan'] as String?,
      dueAt: due,
      dueInHours: hoursUntil(due, now),
      flags: <QueueFlag>[for (final dynamic f in (r['flags'] as List<dynamic>?) ?? const <dynamic>[]) QueueFlag(key: '${(f as Map)['key']}', name: '${f['name']}', severity: _severity(f['severity']))],
      total: _int(r['total']),
      maximum: _int(r['maximum']),
      band: r['band'] as String?,
      dimensions: <DimensionPoints>[
        for (final dynamic d in (r['dimensions'] as List<dynamic>?) ?? const <dynamic>[]) DimensionPoints(name: '${(d as Map)['name']}', points: _int(d['points']), max: _int(d['maximum'])),
      ],
      summary: r['clinicianSummary'] as String?,
      // `text` is null once removed; `original` is set once edited (spec 007 §7.12).
      observations: <ReviewObservation>[
        for (final dynamic o in (r['observations'] as List<dynamic>?) ?? const <dynamic>[])
          () {
            final Map<dynamic, dynamic> m = o as Map;
            final String? text = m['text'] as String?;
            final String original = (m['original'] as String?) ?? text ?? '';
            final bool edited = m['edited'] == true;
            return ReviewObservation(original: original, edited: edited && text != null && text != original ? text : null, removed: edited && text == null);
          }(),
      ],
      answers: <ReviewAnswer>[
        for (final dynamic a in (r['answers'] as List<dynamic>?) ?? const <dynamic>[])
          ReviewAnswer(q: '${(a as Map)['question']}', a: ((a['answer'] as List<dynamic>?) ?? const <dynamic>[]).join(', ')),
      ],
      consent: r['consent'] == 'view' ? const <String>[reviewConsent] : const <String>[],
      consentCategories: const <String>[reviewConsent],
    );
  }
}
