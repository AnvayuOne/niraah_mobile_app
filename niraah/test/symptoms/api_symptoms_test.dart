import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/auth/session_store.dart';
import 'package:niraah/core/network/niraah_api.dart';
import 'package:niraah/features/cycle/domain/cycle.dart';
import 'package:niraah/features/symptoms/data/api_symptoms_repository.dart';
import 'package:niraah/features/symptoms/domain/symptoms.dart';

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

Map<String, dynamic> invalid(String field) => <String, dynamic>{
      'error': <String, dynamic>{'code': 'invalid_request', 'message': 'Check this and try again.', 'field': field},
      'requestId': 'r',
    };

void main() {
  late _Adapter adapter;
  late ApiSymptomsRepository repo;

  setUp(() {
    adapter = _Adapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://api.test/api/v1'))..httpClientAdapter = adapter;
    repo = ApiSymptomsRepository(NiraahApi(dio: dio, store: MemorySessionStore()));
  });

  test('reads the catalogue, frequent symptoms, scale words and history with phase (spec 010 §4)', () async {
    adapter.replies.add((200, <String, dynamic>{
      'today': '2026-11-16',
      'categories': <Map<String, dynamic>>[
        <String, dynamic>{'key': 'pain', 'name': 'Pain', 'symptoms': <Map<String, dynamic>>[<String, dynamic>{'key': 'cramps', 'name': 'Cramps'}]},
      ],
      'frequent': <Map<String, dynamic>>[<String, dynamic>{'key': 'cramps', 'name': 'Cramps'}],
      'severityWords': <String, dynamic>{'low': 'Mild', 'high': 'Severe'},
      'history': <Map<String, dynamic>>[
        <String, dynamic>{'id': 'h1', 'date': '2026-11-15', 'symptom': <String, dynamic>{'key': 'cramps', 'name': 'Cramps'}, 'severity': 6, 'note': 'after lunch', 'phase': 'luteal'},
        <String, dynamic>{'id': 'h2', 'date': '2026-11-14', 'symptom': <String, dynamic>{'key': 'cramps', 'name': 'Cramps'}, 'severity': 3, 'phase': null},
      ],
    }));
    final SymptomsDocument d = await repo.getSymptoms();
    expect(adapter.requests.single.path, '/me/symptoms');
    expect(d.categories.single.symptoms.single, const SymptomRef(key: 'cramps', name: 'Cramps'));
    expect(d.frequent.single.key, 'cramps');
    expect((d.severityLow, d.severityHigh), ('Mild', 'Severe'));
    expect(d.history.first.phase, Phase.luteal);
    expect(d.history.first.note, 'after lunch');
    expect(d.history.last.phase, isNull);
  });

  test('a red-flag symptom returns its advice at once (AC17)', () async {
    adapter.replies.add((200, <String, dynamic>{
      'advice': <String, dynamic>{'key': 'heavy_bleeding', 'title': 'Heavy bleeding', 'text': 'Please see a doctor soon.', 'notPassedOn': 'Niraah has not passed this on to a clinician.'},
    }));
    final SymptomLogResult r = await repo.logSymptom(date: '2026-11-16', symptom: 'heavy_bleeding', severity: 9, note: 'since morning');
    expect(r.ok, isTrue);
    expect(r.advice, const AdviceCard(key: 'heavy_bleeding', title: 'Heavy bleeding', text: 'Please see a doctor soon.', notPassedOn: 'Niraah has not passed this on to a clinician.'));
    expect(adapter.requests.single.path, '/me/symptoms/logs');
    expect(adapter.requests.single.data, <String, dynamic>{'date': '2026-11-16', 'symptom': 'heavy_bleeding', 'severity': 9, 'note': 'since morning'});
  });

  test('an entry with no red flag saves with no advice', () async {
    adapter.replies.add((200, <String, dynamic>{'advice': null}));
    final SymptomLogResult r = await repo.logSymptom(date: '2026-11-16', symptom: 'cramps', severity: 4);
    expect(r.ok, isTrue);
    expect(r.advice, isNull);
  });

  test('severity outside 1 to 10 and unknown symptoms are refused by field (AC18)', () async {
    adapter.replies.add((400, invalid('severity')));
    expect((await repo.logSymptom(date: '2026-11-16', symptom: 'cramps', severity: 11)).error, SymptomLogError.severity);
    adapter.replies.add((400, invalid('symptom')));
    expect((await repo.logSymptom(date: '2026-11-16', symptom: 'nope', severity: 3)).error, SymptomLogError.unknownSymptom);
  });

  test('any other failure throws', () async {
    adapter.replies.add((500, <String, dynamic>{'error': <String, dynamic>{'code': 'server_error', 'message': 'Something went wrong.'}}));
    expect(repo.logSymptom(date: '2026-11-16', symptom: 'cramps', severity: 3), throwsA(isA<Exception>()));
  });
}
