// SAMPLE ONLY (constitution §2 rule 6). The doctor workspace (spec 011) over
// design/sample/doctor.json, mirroring apps/web/src/sample/doctor-repository.ts.
// Queue order, claims and review rules follow spec 007 §7.

import 'dart:convert';
import 'dart:math' as math;

import '../features/assessment/domain/prescore.dart';
import '../features/doctor/domain/doctor.dart';
import 'sample_content.dart';
import 'sample_provider_auth.dart';

final Map<String, dynamic> _data = jsonDecode(sampleDoctorJson) as Map<String, dynamic>;

List<Map<String, dynamic>> get _reviews => (_data['reviews'] as List<dynamic>).cast<Map<String, dynamic>>();

int _rank(String severity) => switch (severity) {
      'urgent' => 0,
      'attention' => 1,
      'information' => 2,
      _ => 3,
    };

int _worst(Map<String, dynamic> r) =>
    (r['flags'] as List<dynamic>).fold<int>(3, (int m, dynamic f) => math.min(m, _rank((f as Map<String, dynamic>)['severity'] as String)));

double _targetHours(Map<String, dynamic> r) {
  final Map<String, dynamic> t = _data['reviewTargetHours'] as Map<String, dynamic>;
  return ((_worst(r) == 0 ? t['urgent'] : t['default']) as num).toDouble();
}

/// Spec 007 §7.2: urgent flags first, then my dedicated members, then
/// attention flags, then oldest first.
List<Map<String, dynamic>> queueOrder(List<Map<String, dynamic>> reviews) {
  int group(Map<String, dynamic> r) => _worst(r) == 0 ? 0 : (r['dedicatedToMe'] == true ? 1 : (_worst(r) == 1 ? 2 : 3));
  return List<Map<String, dynamic>>.of(reviews)
    ..sort((Map<String, dynamic> a, Map<String, dynamic> b) {
      final int g = group(a) - group(b);
      return g != 0 ? g : (b['submittedHoursAgo'] as num).compareTo(a['submittedHoursAgo'] as num);
    });
}

class SampleDoctorRepository implements DoctorRepository {
  SampleDoctorRepository({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  final Set<String> done = <String>{};
  (String, DateTime)? _claim;
  final Map<String, Map<int, String?>> _edits = <String, Map<int, String?>>{};
  final List<(String, String)> concerns = <(String, String)>[];

  int get _claimMinutes => _data['claimMinutes'] as int;

  List<Map<String, dynamic>> get _waiting => queueOrder(_reviews.where((Map<String, dynamic> r) => !done.contains(r['id'])).toList());

  List<QueueFlag> _flags(Map<String, dynamic> r) => <QueueFlag>[
        for (final dynamic f in r['flags'] as List<dynamic>)
          QueueFlag(key: (f as Map<String, dynamic>)['key'] as String, name: f['name'] as String, severity: severityFrom(f['severity'] as String)),
      ];

  /// As the server gives it: no member detail before a claim (spec 007 §7.2).
  QueueItem _item(Map<String, dynamic> r) {
    final double hours = _targetHours(r) - (r['submittedHoursAgo'] as num).toDouble();
    final int worst = _worst(r);
    return QueueItem(
      id: r['id'] as String,
      severity: worst == 0 ? FlagSeverity.urgent : worst == 1 ? FlagSeverity.attention : worst == 2 ? FlagSeverity.information : null,
      flagCount: (r['flags'] as List<dynamic>).length,
      dueAt: _clock().add(Duration(minutes: (hours * 60).round())),
      dueInHours: (hours * 10).round() / 10,
      waitingSince: _clock().subtract(Duration(minutes: ((r['submittedHoursAgo'] as num) * 60).round())),
      dedicatedToMe: r['dedicatedToMe'] == true,
      claimedByMe: _claim?.$1 == r['id'],
    );
  }

  ReviewDetail _detail(Map<String, dynamic> r) {
    final Map<int, String?> edits = _edits[r['id']] ?? const <int, String?>{};
    final List<dynamic> obs = r['observations'] as List<dynamic>;
    final QueueItem item = _item(r);
    return ReviewDetail(
      id: item.id,
      dueAt: item.dueAt,
      dueInHours: item.dueInHours,
      flags: _flags(r),
      total: r['total'] as int,
      maximum: 100,
      band: r['band'] as String,
      dimensions: <DimensionPoints>[
        for (final dynamic d in r['dimensions'] as List<dynamic>)
          DimensionPoints(
            name: (d as Map<String, dynamic>)['name'] as String,
            points: d['points'] as int,
            max: d['max'] as int,
            level: d['level'] as String,
          ),
      ],
      summary: r['summary'] as String,
      observations: <ReviewObservation>[
        for (int i = 0; i < obs.length; i++)
          ReviewObservation(
            original: obs[i] as String,
            edited: edits.containsKey(i) ? edits[i] : null,
            removed: edits.containsKey(i) && edits[i] == null,
          ),
      ],
      answers: <ReviewAnswer>[
        for (final dynamic a in r['answers'] as List<dynamic>) ReviewAnswer(q: (a as Map<String, dynamic>)['q'] as String, a: a['a'] as String),
      ],
      consent: (r['consent'] as List<dynamic>).cast<String>(),
      consentCategories: (_data['consentCategories'] as List<dynamic>).cast<String>(),
    );
  }

  @override
  Future<DoctorDashboard> getDashboard() async {
    final Map<String, dynamic> doctor = (sampleProviders['accounts'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .firstWhere((Map<String, dynamic> a) => a['role'] == 'doctor' && a['status'] == 'active');
    final List<Map<String, dynamic>> w = _waiting;
    final Map<String, dynamic> onCall = _data['onCall'] as Map<String, dynamic>;
    final DateTime now = _clock();
    return DoctorDashboard(
      name: doctor['name'] as String,
      speciality: doctor['speciality'] as String,
      // Only lists that exist in the sample have items, so every count equals its list (AC6).
      needsMe: NeedsMe(
        urgentAlerts: 0,
        reviews: w.length,
        oldestReviewDueInHours: w.isEmpty ? null : w.map((Map<String, dynamic> r) => _item(r).dueInHours!).reduce(math.min),
        carePlans: 0,
        labResults: 0,
        messages: 0,
        draftPrescriptions: 0,
      ),
      today: <TodayAppointment>[
        for (final dynamic a in _data['appointments'] as List<dynamic>)
          TodayAppointment(
            id: (a as Map<String, dynamic>)['id'] as String,
            startsAt: _at(now, a['time'] as String),
            member: a['member'] as String,
            reason: a['reason'] as String,
            joinable: false,
          ),
      ],
      onCall: onCall['now'] as bool,
    );
  }

  @override
  Future<List<QueueItem>> getQueue() async => _waiting.map(_item).toList();

  @override
  Future<ClaimResult> claim(String id) async {
    final Map<String, dynamic>? r = _reviews.where((Map<String, dynamic> x) => x['id'] == id).firstOrNull;
    if (r == null || done.contains(id)) return const ClaimResult.failed(ClaimFailure.gone);
    final (String, DateTime)? active = _claim != null && _claim!.$2.isAfter(_clock()) ? _claim : null;
    // One claim at a time (AC47); reopening her own claim is fine.
    if (active != null && active.$1 != id) return const ClaimResult.failed(ClaimFailure.holdingAnother);
    _claim = (id, active?.$2 ?? _clock().add(Duration(minutes: _claimMinutes)));
    return ClaimResult.ok(_detail(r));
  }

  @override
  Future<void> release(String id) async {
    if (_claim?.$1 == id) _claim = null;
  }

  @override
  Future<ReviewDetail> editObservation(String id, int index, String? text) async {
    final Map<String, dynamic> r = _reviews.firstWhere((Map<String, dynamic> x) => x['id'] == id);
    final String original = (r['observations'] as List<dynamic>)[index] as String;
    // Saving the original text again restores it (no edit is kept).
    if (text != null && text.trim() == original) {
      _edits[id]?.remove(index);
    } else {
      (_edits[id] ??= <int, String?>{})[index] = text;
    }
    return _detail(r);
  }

  @override
  Future<CompleteResult> complete(String id, ReviewOutcome outcome, String note, {bool next = false}) async {
    if (outcome == ReviewOutcome.followUp && note.trim().isEmpty) return const CompleteResult.noteRequired();
    done.add(id);
    _claim = null;
    // As on the server: only "Verify and next" claims the next review.
    final List<Map<String, dynamic>> w = _waiting;
    return CompleteResult.ok(!next || w.isEmpty ? null : w.first['id'] as String);
  }

  /// Today's time "HH:mm" from the sample, as a moment.
  static DateTime _at(DateTime now, String hhmm) {
    final List<String> p = hhmm.split(':');
    return DateTime(now.year, now.month, now.day, int.tryParse(p.first) ?? 9, p.length > 1 ? int.tryParse(p[1]) ?? 0 : 0);
  }

  @override
  Future<void> scoringConcern(String id, String note) async => concerns.add((id, note));
}
