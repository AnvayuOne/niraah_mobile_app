import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/auth/session_store.dart';
import 'package:niraah/core/network/niraah_api.dart';
import 'package:niraah/features/cycle/domain/cycle.dart';
import 'package:niraah/features/home/data/api_home_repository.dart';
import 'package:niraah/features/home/data/home_parser.dart';
import 'package:niraah/features/home/domain/home.dart';

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

Map<String, dynamic> workspace(String state, {Object? minutes}) => <String, dynamic>{'state': state, 'assessmentMinutes': minutes};

Map<String, dynamic> home({Object? prescore, Object? todayLog, Object? suggestion}) => <String, dynamic>{
      'name': 'Priya',
      'today': '2026-11-16',
      'areas': <String>['home', 'cycle', 'symptoms', 'ai_care', 'meals', 'practice', 'me'],
      'notice': null,
      'cycle': <String, dynamic>{'state': 'noData'},
      'todayLog': todayLog,
      'suggestion': suggestion,
      'prescore': prescore,
      'tasks': null,
      'next': null,
      'checkIn': null,
      'wellness': 'Wellness only.',
    };

void main() {
  late _Adapter adapter;
  late ApiHomeRepository repo;

  setUp(() {
    adapter = _Adapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://api.test/api/v1'))..httpClientAdapter = adapter;
    repo = ApiHomeRepository(NiraahApi(dio: dio, store: MemorySessionStore()), today: () => '2026-11-15');
  });

  group('the gate (spec 010 AC2)', () {
    test('before the assessment Home is the gate with its minutes, and /me/home is not asked', () async {
      adapter.replies.add((200, workspace('assessment_gate', minutes: 4)));
      expect(await repo.getHome(), const HomeGate(estimatedMinutes: 4));
      expect(adapter.requests.map((RequestOptions r) => r.path), <String>['/me/workspace']);
    });

    test('a new member with no estimate gets the gate without minutes', () async {
      adapter.replies.add((200, workspace('member_new')));
      expect(await repo.getHome(), const HomeGate(estimatedMinutes: null));
    });

    test('a member past the assessment is not gated', () {
      expect(HomeParser.gate(workspace('member', minutes: 4)), isNull);
    });
  });

  group('Home mapping (spec 010 §2)', () {
    test('areas: ai_care becomes aiCare and keys the app has no destination for are dropped', () {
      expect(HomeParser.content(home()).areas, <Area>[Area.home, Area.cycle, Area.aiCare, Area.practice, Area.me]);
    });

    test('no log today gives an empty log for the server\'s today; no suggestion is null', () {
      final HomeContent c = HomeParser.content(home());
      expect(c.todayLog, const DailyLog(date: '2026-11-16'));
      expect(c.suggestion, isNull);
      expect(c.cycle, const CycleNoData());
    });

    test('a logged day and a rules-written suggestion are copied', () {
      final HomeContent c = HomeParser.content(home(
        todayLog: <String, dynamic>{'date': '2026-11-16', 'flow': 'light', 'mood': 'calm'},
        suggestion: <String, dynamic>{'title': 'Rest', 'text': 'Go gently.', 'writtenBy': 'rules'},
      ));
      expect(c.todayLog, const DailyLog(date: '2026-11-16', flow: PeriodFlow.light, mood: Mood.calm));
      expect(c.suggestion, const DailySuggestion(title: 'Rest', text: 'Go gently.', writtenBy: SuggestionAuthor.rules));
    });

    test('pre-score: a null band is empty; awaiting review names its target in hours', () {
      final HomePreScore? p = HomeParser.preScore(<String, dynamic>{
        'id': 'p1', 'total': 12, 'maximum': 40, 'band': null, 'review': <String, dynamic>{'state': 'awaiting_review', 'targetHours': 48},
      });
      expect(p, const HomePreScore(total: 12, maximum: 40, band: '', reviewTarget: '48 hours'));
      expect(HomeParser.preScore(<String, dynamic>{'id': 'p1', 'total': 1, 'maximum': 2, 'band': 'Low', 'review': <String, dynamic>{'state': 'awaiting_review'}})!.reviewTarget, '24 hours');
      expect(HomeParser.preScore(<String, dynamic>{'id': 'p1', 'total': 1, 'maximum': 2, 'band': 'Low', 'review': <String, dynamic>{'state': 'not_required'}})!.reviewTarget, isNull);
    });
  });

  group('changes from Home', () {
    test('hiding the pre-score card sends the id Home showed', () async {
      adapter.replies
        ..add((200, workspace('member')))
        ..add((200, home(prescore: <String, dynamic>{'id': 'ps-7', 'total': 1, 'maximum': 2, 'band': 'Low', 'review': <String, dynamic>{'state': 'not_required'}})))
        ..add((200, <String, dynamic>{'dismissed': true}));
      await repo.getHome();
      await repo.hidePreScoreCard();
      expect(adapter.requests.last.path, '/me/home/prescore-card/dismiss');
      expect(adapter.requests.last.method, 'POST');
      expect(adapter.requests.last.data, <String, dynamic>{'prescoreId': 'ps-7'});
    });

    test('hiding does nothing when no pre-score was shown', () async {
      await repo.hidePreScoreCard();
      expect(adapter.requests, isEmpty);
    });

    test("today's log is saved under the server's today, with only the changed fields (AC9)", () async {
      adapter.replies
        ..add((200, workspace('member')))
        ..add((200, home()))
        ..add((200, <String, dynamic>{'date': '2026-11-16', 'mood': 'happy'}));
      await repo.getHome();
      final DailyLog saved = await repo.saveTodayLog(const DailyLogPatch(mood: Mood.happy));
      expect(adapter.requests.last.method, 'PUT');
      expect(adapter.requests.last.path, '/me/cycle/logs/2026-11-16');
      expect(adapter.requests.last.data, <String, dynamic>{'mood': 'happy'});
      expect(saved, const DailyLog(date: '2026-11-16', mood: Mood.happy));
    });

    test('logging a period start posts the date', () async {
      adapter.replies.add((200, <String, dynamic>{'ok': true}));
      await repo.logPeriodStart('2026-11-14');
      expect(adapter.requests.single.path, '/me/cycle/periods');
      expect(adapter.requests.single.data, <String, dynamic>{'start': '2026-11-14'});
    });

    test('a server failure is an exception the cubit shows as a failure', () async {
      adapter.replies.add((500, <String, dynamic>{'error': <String, dynamic>{'code': 'server_error', 'message': 'Something went wrong.'}}));
      expect(repo.getHome(), throwsA(isA<Exception>()));
    });
  });
}
