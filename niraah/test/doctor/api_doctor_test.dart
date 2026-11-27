import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/auth/session_store.dart';
import 'package:niraah/core/network/niraah_api.dart';
import 'package:niraah/features/assessment/domain/prescore.dart';
import 'package:niraah/features/doctor/data/api_doctor_repository.dart';
import 'package:niraah/features/doctor/data/doctor_parser.dart';
import 'package:niraah/features/doctor/domain/doctor.dart';

/// Answers requests from a script and records what was sent.
class _Adapter implements HttpClientAdapter {
  final List<(int, Object)> replies = <(int, Object)>[];
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final (int status, Object body) = replies.removeAt(0);
    return ResponseBody.fromString(jsonEncode(body), status, headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

final DateTime now = DateTime.utc(2026, 11, 17, 9);

Map<String, dynamic> error(String code, String message, {String? field}) => <String, dynamic>{
      'error': <String, dynamic>{'code': code, 'message': message, 'field': ?field},
      'requestId': 'r',
    };

Map<String, dynamic> review({Object? summary = 'Sleep and stress are the themes.'}) => <String, dynamic>{
      'id': 'p1',
      'consent': 'view',
      'clinicianSummary': summary,
      'flags': <Object>[
        <String, dynamic>{'key': 'pregnant', 'name': 'Pregnant', 'severity': 'attention'},
      ],
      'total': 62,
      'maximum': 100,
      'band': null,
      'dimensions': <Object>[
        <String, dynamic>{'name': 'Sleep', 'points': 12, 'maximum': 20},
      ],
      'observations': <Object>[
        <String, dynamic>{'index': 0, 'text': 'Kept.', 'original': null, 'edited': false},
        <String, dynamic>{'index': 1, 'text': 'Changed.', 'original': 'Was this.', 'edited': true},
        <String, dynamic>{'index': 2, 'text': null, 'original': 'Removed one.', 'edited': true},
      ],
      'answers': <Object>[
        <String, dynamic>{'question': 'How do you sleep?', 'answer': <String>['Poorly', 'Wake at night']},
      ],
      'dueAt': '2026-11-17T12:00:00.000Z',
    };

void main() {
  late _Adapter adapter;
  late ApiDoctorRepository repo;

  setUp(() {
    adapter = _Adapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://api.test/api/v1'))..httpClientAdapter = adapter;
    repo = ApiDoctorRepository(NiraahApi(dio: dio, store: MemorySessionStore()), clock: () => now);
  });

  test('the dashboard: counts, the oldest review in hours, today with join, on call as a yes or no (spec 011 §1)', () async {
    adapter.replies.add((200, <String, dynamic>{
      'doctor': <String, dynamic>{'name': 'Dr Kavya Iyer', 'speciality': null},
      'needsMe': <String, dynamic>{'urgentAlerts': 1, 'reviews': 2, 'oldestReviewDueAt': '2026-11-17T12:00:00.000Z', 'carePlans': 0, 'oldestCarePlanDueAt': null, 'labResults': 3, 'messages': 4, 'draftPrescriptions': 0},
      'today': <Object>[
        <String, dynamic>{'id': 'a1', 'startsAt': '2026-11-17T09:05:00.000Z', 'member': 'Asha', 'reason': null, 'status': 'confirmed', 'joinable': true},
      ],
      'onCall': true,
    }));
    final DoctorDashboard d = await repo.getDashboard();
    expect(d.name, 'Dr Kavya Iyer');
    expect(d.speciality, isNull);
    expect(d.needsMe.oldestReviewDueInHours, 3.0);
    expect(d.needsMe.clinicalReview, isNull);
    expect(d.today.single.joinable, isTrue);
    expect(d.today.single.reason, isNull);
    expect(d.onCall, isTrue);
  });

  test('the queue carries no member detail before a claim (spec 007 §7.2)', () async {
    adapter.replies.add((200, <String, dynamic>{
      'items': <Object>[
        <String, dynamic>{'id': 'p1', 'severity': 'urgent', 'flagCount': 2, 'dedicated': true, 'dueAt': '2026-11-17T08:00:00.000Z', 'waitingSince': '2026-11-16T09:00:00.000Z', 'claimedByMe': false},
        <String, dynamic>{'id': 'p2', 'severity': null, 'flagCount': 0, 'dedicated': false, 'dueAt': null, 'waitingSince': '2026-11-17T08:00:00.000Z', 'claimedByMe': true},
      ],
    }));
    final List<QueueItem> q = await repo.getQueue();
    expect(q.first.severity, FlagSeverity.urgent);
    expect(q.first.dueInHours, -1.0);
    expect(q.first.dedicatedToMe, isTrue);
    expect(q.last.severity, isNull);
    expect(q.last.dueInHours, isNull);
    expect(q.last.claimedByMe, isTrue);
  });

  test('a claim opens the review: no name, consent as one tag, edits and removals kept beside the original', () async {
    adapter.replies.add((200, review()));
    final ReviewDetail r = (await repo.claim('p1')).review!;
    expect(r.member, isNull);
    expect(r.band, isNull);
    expect(r.consent, <String>[DoctorParser.reviewConsent]);
    expect(r.observations, const <ReviewObservation>[
      ReviewObservation(original: 'Kept.'),
      ReviewObservation(original: 'Was this.', edited: 'Changed.'),
      ReviewObservation(original: 'Removed one.', removed: true),
    ]);
    expect(r.answers.single.a, 'Poorly, Wake at night');
    expect(r.dimensions.single.max, 20);
    expect(adapter.requests.single.path, '/doctor/reviews/p1/claim');
  });

  test('a claim refused: holding another (409) or gone (410, 404); no summary hides the block', () async {
    adapter.replies.addAll(<(int, Object)>[(409, error('conflict', 'Finish first.')), (410, error('gone', 'Taken.')), (404, error('not_found', 'Not found.'))]);
    expect((await repo.claim('p1')).failure, ClaimFailure.holdingAnother);
    expect((await repo.claim('p1')).failure, ClaimFailure.gone);
    expect((await repo.claim('p1')).failure, ClaimFailure.gone);
    expect(DoctorParser.review(review(summary: null), now).summary, isNull);
  });

  test('only "Verify and next" asks for the next review; a follow-up needs a note', () async {
    expect((await repo.complete('p1', ReviewOutcome.followUp, '  ')).noteRequired, isTrue);
    adapter.replies.addAll(<(int, Object)>[(200, <String, dynamic>{'next': null}), (200, <String, dynamic>{'next': 'p2'})]);
    await repo.complete('p1', ReviewOutcome.verified, '');
    final CompleteResult r = await repo.complete('p1', ReviewOutcome.verified, 'Looks right.', next: true);
    expect(r.next, 'p2');
    expect(adapter.requests.map((RequestOptions o) => o.data), <Object>[
      <String, dynamic>{'outcome': 'verify'},
      <String, dynamic>{'outcome': 'verify', 'note': 'Looks right.', 'next': true},
    ]);
  });
}
