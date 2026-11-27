import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/auth/session_store.dart';
import 'package:niraah/core/network/niraah_api.dart';
import 'package:niraah/features/assessment/data/api_assessment_repository.dart';
import 'package:niraah/features/assessment/domain/assessment_repository.dart';
import 'package:niraah/features/assessment/domain/prescore.dart';
import 'package:niraah/features/assessment/domain/questionnaire.dart';
import 'package:niraah/shared/helpers/result.dart';

class _Adapter implements HttpClientAdapter {
  final List<(int, Object)> replies = <(int, Object)>[];
  final List<Object?> bodies = <Object?>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    bodies.add(options.data);
    final (int status, Object body) = replies.removeAt(0);
    return ResponseBody.fromString(jsonEncode(body), status, headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> settings() => <String, dynamic>{'maxSelections': null, 'maxLength': null, 'unit': null, 'min': null, 'max': null, 'isDateOfBirth': false};

void main() {
  late _Adapter adapter;
  late ApiAssessmentRepository repo;

  setUp(() {
    adapter = _Adapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://api.test/api/v1'))..httpClientAdapter = adapter;
    repo = ApiAssessmentRepository(NiraahApi(dio: dio, store: MemorySessionStore()));
  });

  test('reads the API document (text per language) and resumes with earlier answers (spec 007 AC7)', () async {
    adapter.replies.add((200, <String, dynamic>{
      'assessmentId': 'a1',
      'answers': <String, dynamic>{'cycle': <String>['regular']},
      'document': <String, dynamic>{
        'questionnaireKey': 'onboarding', 'purpose': 'onboarding', 'versionId': 'v', 'versionNumber': 2, 'estimatedMinutes': 3, 'scored': true,
        'questions': <Map<String, dynamic>>[
          <String, dynamic>{
            'key': 'cycle', 'type': 'single_choice', 'required': true, 'text': <String, String>{'en': 'How regular is your cycle?'}, 'helpText': null,
            'illustration': 'q02_cycle', 'illustrationAlt': 'A calendar', 'motion': 'breathe', 'displayCondition': null, 'settings': settings(),
            'options': <Map<String, dynamic>>[
              <String, dynamic>{'value': 'regular', 'label': <String, String>{'en': 'Like clockwork'}, 'color': 'mint', 'icon': null, 'exclusive': false},
            ],
          },
        ],
      },
    }));
    final AssessmentSession s = (await repo.startOrResume() as Success<AssessmentSession>).data;
    expect(s.document.versionNumber, 2);
    expect(s.document.questions.single.text, 'How regular is your cycle?');
    expect(s.document.questions.single.options.single.label, 'Like clockwork');
    expect(s.answers['cycle'], const Answer.values(<String>['regular']));
  });

  test('a missing required answer names the question (spec 007 AC14)', () async {
    adapter.replies.add((400, <String, dynamic>{
      'error': <String, dynamic>{'code': 'invalid_request', 'message': 'Please answer this question.', 'field': 'sleep'},
      'requestId': 'r',
    }));
    expect((await repo.submit('a1', <String, Answer>{}) as FailureResult<PreScore>).message, 'missing:sleep');
  });

  test('the pre-score carries names and levels, the care message, and the review card', () {
    final PreScore p = ApiAssessmentRepository.preScoreFrom(<String, dynamic>{
      'id': 'p1', 'total': 56, 'maximum': 100, 'versionNumber': 1,
      'band': <String, dynamic>{'label': 'Building', 'message': 'One step at a time.', 'color': 'peach'},
      'dimensions': <Map<String, String>>[<String, String>{'name': 'Cycle', 'level': 'Strong'}],
      'observations': <Map<String, String>>[<String, String>{'text': 'Some areas could use support.', 'source': 'rules'}],
      'careMessage': <String, dynamic>{'message': 'Please see a doctor soon.', 'notPassedOn': 'Niraah has not passed this to a doctor.'},
      'notDiagnosis': 'This is not a diagnosis.', 'suggestedProgram': null,
      'clinician': <String, dynamic>{'state': 'awaiting_review', 'targetHours': 2},
      'nextStep': 'book_doctor', 'createdAt': '2026-11-15T09:00:00.000Z',
    });
    expect(p.dimensions.single.level, 'Strong');
    expect(p.hasUrgentFlag, isTrue);
    expect(p.flags.single.careMessage, contains('has not passed this'));
    expect(p.reviewState, ReviewState.awaitingReview);
    expect(p.reviewTarget, '2 hours');
    expect(nextActionFor(p), NextAction.bookDoctor);
  });
}
