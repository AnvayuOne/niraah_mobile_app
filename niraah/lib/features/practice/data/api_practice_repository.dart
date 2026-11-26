import '../../../core/network/niraah_api.dart';
import '../../../core/payments/payment_checkout.dart';
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
    // No `payWith`: the server uses a unit when she has one, else holds the place with an order for the fee (core
    // `Classes.book`), and refuses when there is neither.
    final Map<String, dynamic> r = (await _api.post('/classes/${Uri.encodeComponent(classId)}/book', <String, dynamic>{})).orArea();
    if (r['status'] == 'booked') return const ClassBooked();
    final Checkout? checkout = Checkout.fromJson(r['checkout']);
    return ClassPaymentNeeded(bookingId: '${r['bookingId']}', amountPaise: checkout?.amountPaise ?? 0, checkout: checkout);
  }

  @override
  Future<List<ClassBooking>> classBookings() async {
    final Map<String, dynamic> r = (await _api.get('/me/class-bookings')).orArea();
    return <ClassBooking>[
      for (final dynamic b in r['bookings'] as List<dynamic>)
        ClassBooking(
          id: '${(b as Map<String, dynamic>)['id']}',
          classId: '${b['classId']}',
          status: '${b['status']}',
          title: '${b['title']}',
          startsAt: DateTime.parse(b['startsAt'] as String).toLocal(),
          endsAt: DateTime.parse(b['endsAt'] as String).toLocal(),
        ),
    ];
  }

  @override
  Future<String> cancelBooking(String bookingId) async => '${(await _api.post('/class-bookings/${Uri.encodeComponent(bookingId)}/cancel')).orArea()['outcome']}';

  @override
  Future<ClassRoomAccess> roomToken(String classId) async => ClassRoomAccess.from(await _api.post('/classes/${Uri.encodeComponent(classId)}/room-token'));

  @override
  Future<ChannelToken> cameraToken(String classId) async => ChannelToken.parse((await _api.post('/classes/${Uri.encodeComponent(classId)}/camera-token')).orThrow());

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
