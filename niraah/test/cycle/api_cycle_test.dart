import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/auth/session_store.dart';
import 'package:niraah/core/network/niraah_api.dart';
import 'package:niraah/features/cycle/data/api_cycle_repository.dart';
import 'package:niraah/features/cycle/data/cycle_parser.dart';
import 'package:niraah/features/cycle/domain/cycle.dart';

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

Map<String, dynamic> refusal(String reason) => <String, dynamic>{
      'error': <String, dynamic>{'code': 'invalid_request', 'message': 'That period cannot be saved.', 'field': 'start', 'details': <String, dynamic>{'reason': reason}},
      'requestId': 'r',
    };

void main() {
  late _Adapter adapter;
  late ApiCycleRepository repo;

  setUp(() {
    adapter = _Adapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://api.test/api/v1'))..httpClientAdapter = adapter;
    repo = ApiCycleRepository(NiraahApi(dio: dio, store: MemorySessionStore()));
  });

  test('reads the server\'s summary, logs, history and advice as given (spec 010 AC10)', () async {
    adapter.replies.add((200, <String, dynamic>{
      'today': '2026-11-16',
      'summary': <String, dynamic>{
        'state': 'estimate', 'basis': 'logs', 'dayOfCycle': 14, 'ringLength': 28, 'meanLength': 28, 'halfWidth': 2,
        'windowStart': '2026-11-29', 'windowEnd': '2026-12-03', 'daysToNext': <int>[13, 17], 'periodLength': 5,
        'fertileStart': 10, 'ovulationDay': 14, 'phase': 'ovulatory', 'late': false,
      },
      'periods': <Map<String, dynamic>>[<String, dynamic>{'start': '2026-11-03', 'end': '2026-11-07'}, <String, dynamic>{'start': '2026-10-06'}],
      'markers': <String>['hormonal_contraception'],
      'logs': <String, dynamic>{'2026-11-16': <String, dynamic>{'date': '2026-11-16', 'flow': 'none', 'energy': 'high', 'note': 'ok'}},
      'history': <Map<String, dynamic>>[<String, dynamic>{'start': '2026-10-06', 'cycleLength': 28, 'periodLength': null}],
      'average': 28,
      'range': <int>[27, 29],
      'pattern': null,
      'advice': <Map<String, dynamic>>[<String, dynamic>{'key': 'long_cycles', 'title': 'Long cycles', 'text': 'Talk to a doctor.', 'notPassedOn': 'Niraah has not passed this on.'}],
      'disclaimer': 'Estimates only.',
      'wellness': 'Wellness only.',
    }));
    final CycleDocument d = await repo.getCycle();
    expect(adapter.requests.single.path, '/me/cycle');
    final CycleEstimate s = d.summary as CycleEstimate;
    expect(s.phase, Phase.ovulatory);
    expect(s.daysToNext, (13, 17));
    expect(s.basis, PredictionBasis.logs);
    expect(d.periods, const <Period>[Period(start: '2026-11-03', end: '2026-11-07'), Period(start: '2026-10-06')]);
    expect(d.markers, <CycleMarker>[CycleMarker.hormonalContraception]);
    expect(d.logs['2026-11-16'], const DailyLog(date: '2026-11-16', flow: PeriodFlow.none, energy: Energy.high, note: 'ok'));
    expect(d.history.single, const CycleHistoryRow(start: '2026-10-06', cycleLength: 28));
    expect(d.range, (27, 29));
    expect(d.pattern, isNull);
    expect(d.advice.single.notPassedOn, 'Niraah has not passed this on.');
  });

  test('summaries with no data or paused predictions', () {
    expect(CycleParser.summary(<String, dynamic>{'state': 'noData'}), const CycleNoData());
    expect(CycleParser.summary(<String, dynamic>{'state': 'off', 'reason': 'pregnant'}), const CycleOff(CycleMarker.pregnant));
  });

  group('period edits (AC15)', () {
    test('a saved period sends start, end and the period it replaces', () async {
      adapter.replies.add((200, <String, dynamic>{'ok': true}));
      final PeriodSaveResult r = await repo.savePeriod(const Period(start: '2026-11-04', end: '2026-11-08'), replacing: '2026-11-03');
      expect(r.ok, isTrue);
      expect(adapter.requests.single.path, '/me/cycle/periods');
      expect(adapter.requests.single.data, <String, dynamic>{'start': '2026-11-04', 'end': '2026-11-08', 'replacing': '2026-11-03'});
    });

    test('each refusal reason from the server comes back as the refused result', () async {
      for (final (String reason, PeriodError error) in <(String, PeriodError)>[
        ('future', PeriodError.future),
        ('endBeforeStart', PeriodError.endBeforeStart),
        ('overlaps', PeriodError.overlaps),
      ]) {
        adapter.replies.add((400, refusal(reason)));
        expect((await repo.savePeriod(const Period(start: '2026-12-01'))).error, error);
      }
    });

    test('any other failure throws', () async {
      adapter.replies.add((500, <String, dynamic>{'error': <String, dynamic>{'code': 'server_error', 'message': 'Something went wrong.'}}));
      expect(repo.savePeriod(const Period(start: '2026-11-01')), throwsA(isA<Exception>()));
    });

    test('deleting a period names its start', () async {
      adapter.replies.add((200, <String, dynamic>{'deleted': true}));
      await repo.deletePeriod('2026-11-03');
      expect(adapter.requests.single.method, 'DELETE');
      expect(adapter.requests.single.path, '/me/cycle/periods/2026-11-03');
    });
  });

  test('markers are sent with the server\'s keys', () async {
    adapter.replies.add((200, <String, dynamic>{'markers': <String>['no_periods', 'breastfeeding']}));
    await repo.setMarkers(const <CycleMarker>[CycleMarker.noPeriods, CycleMarker.breastfeeding]);
    expect(adapter.requests.single.method, 'PUT');
    expect(adapter.requests.single.data, <String, dynamic>{'markers': <String>['no_periods', 'breastfeeding']});
  });

  test('a daily log sends only the changed fields and returns the merged day (AC9)', () async {
    adapter.replies.add((200, <String, dynamic>{'date': '2026-11-10', 'flow': 'heavy', 'mood': 'low'}));
    final DailyLog log = await repo.saveDailyLog('2026-11-10', const DailyLogPatch(flow: PeriodFlow.heavy));
    expect(adapter.requests.single.path, '/me/cycle/logs/2026-11-10');
    expect(adapter.requests.single.data, <String, dynamic>{'flow': 'heavy'});
    expect(log, const DailyLog(date: '2026-11-10', flow: PeriodFlow.heavy, mood: Mood.low));
  });
}
