import '../../../core/network/niraah_api.dart';
import '../../../shared/area/area_access.dart';
import '../domain/practice.dart';

/// Practice on `/api/v1` (spec 010 §7): `GET /me/practice/today`, `GET /me/practice`, `GET /me/practice/sessions/{id}`,
/// `POST /me/practice/sessions/{id}/complete`, `GET /me/practice/history`, `GET /me/live-classes`, `POST /classes/{id}/book`.
class ApiPracticeRepository implements PracticeRepository {
  ApiPracticeRepository(this._api);

  final NiraahApi _api;

  @override
  Future<PracticeToday> today() async {
    final Map<String, dynamic> r = (await _api.get('/me/practice/today')).orArea();
    return PracticeToday(phase: r['phase'] as String?, sessions: _sessions(r['sessions']));
  }

  @override
  Future<List<PracticeSession>> library(PracticeFilters f) async {
    final Map<String, String> q = <String, String>{
      if (f.maxMinutes != null) 'maxMinutes': '${f.maxMinutes}',
      if (f.focus != null) 'focus': f.focus!,
      if (f.phase != null) 'phase': f.phase!,
    };
    final String query = q.isEmpty ? '' : '?${Uri(queryParameters: q).query}';
    final Map<String, dynamic> r = (await _api.get('/me/practice$query')).orArea();
    return _sessions(r['items']);
  }

  @override
  Future<PracticeSession> session(String id) async => _session((await _api.get('/me/practice/sessions/${Uri.encodeComponent(id)}')).orArea());

  @override
  Future<void> complete(String id, {required int durationSeconds, required String clientId}) async {
    (await _api.post('/me/practice/sessions/${Uri.encodeComponent(id)}/complete', <String, dynamic>{'durationSeconds': durationSeconds, 'clientId': clientId})).orArea();
  }

  @override
  Future<List<PracticeWeek>> history() async {
    final Map<String, dynamic> r = (await _api.get('/me/practice/history')).orArea();
    return <PracticeWeek>[
      for (final dynamic w in r['weeks'] as List<dynamic>)
        PracticeWeek(
          weekOf: (w as Map<String, dynamic>)['weekOf'] as String,
          sessions: <PracticeDone>[
            for (final dynamic s in w['sessions'] as List<dynamic>)
              PracticeDone(title: (s as Map<String, dynamic>)['title'] as String?, minutes: (s['minutes'] as num).toInt(), date: s['date'] as String),
          ],
        ),
    ];
  }

  @override
  Future<LiveClasses> liveClasses() async {
    final Map<String, dynamic> r = (await _api.get('/me/live-classes')).orArea();
    return LiveClasses(
      access: switch (r['access']) {
        'included' => ClassAccess.included,
        'after_trial' => ClassAccess.afterTrial,
        _ => ClassAccess.notIncluded,
      },
      startsOn: r['startsOn'] as String?,
      classes: <LiveClass>[
        for (final dynamic c in r['classes'] as List<dynamic>)
          LiveClass(
            id: (c as Map<String, dynamic>)['id'] as String,
            title: c['title'] as String,
            level: c['level'] as String?,
            startsAt: DateTime.parse(c['startsAt'] as String).toLocal(),
            endsAt: DateTime.parse(c['endsAt'] as String).toLocal(),
            instructor: c['instructor'] as String?,
            placesLeft: (c['placesLeft'] as num).toInt(),
          ),
      ],
    );
  }

  @override
  Future<BookingOutcome> book(String classId) async {
    final Map<String, dynamic> r = (await _api.post('/classes/${Uri.encodeComponent(classId)}/book', <String, dynamic>{'payWith': 'included'})).orArea();
    return r['status'] == 'booked' ? BookingOutcome.booked : BookingOutcome.paymentNeeded;
  }

  static List<PracticeSession> _sessions(Object? list) => <PracticeSession>[for (final dynamic s in list as List<dynamic>) _session(s as Map<String, dynamic>)];

  static PracticeSession _session(Map<String, dynamic> s) => PracticeSession(
        id: s['id'] as String,
        title: s['title'] as String,
        description: s['description'] as String,
        minutes: (s['minutes'] as num).toInt(),
        level: s['level'] as String?,
        tags: (s['tags'] as List<dynamic>).cast<String>(),
        phases: (s['phases'] as List<dynamic>).cast<String>(),
        caution: s['caution'] as String?,
        captions: s['captions'] as bool,
        video: s['video'] as String?,
      );
}
