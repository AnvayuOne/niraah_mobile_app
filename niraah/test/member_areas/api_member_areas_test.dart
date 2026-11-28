import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/features/care/data/api_care_repository.dart';
import 'package:niraah/features/care/domain/care.dart';
import 'package:niraah/features/community/data/api_community_repository.dart';
import 'package:niraah/features/community/domain/community.dart';
import 'package:niraah/features/labs/data/api_labs_repository.dart';
import 'package:niraah/features/labs/domain/labs.dart';
import 'package:niraah/features/me/data/api_me_repository.dart';
import 'package:niraah/features/me/domain/me.dart';
import 'package:niraah/features/practice/data/api_practice_repository.dart';
import 'package:niraah/features/practice/domain/practice.dart';
import 'package:niraah/shared/area/area_access.dart';

import '../helpers/fake_api.dart';

Map<String, dynamic> session(String id) => <String, dynamic>{
      'id': id,
      'title': 'Gentle flow',
      'description': 'Slow stretches.',
      'minutes': 15,
      'level': 'Beginner',
      'tags': <String>['calm'],
      'phases': <String>['menstrual'],
      'caution': 'Skip inversions during your period.',
      'captions': true,
      'video': null,
    };

Map<String, dynamic> author({bool anonymous = false, bool mine = false, String? name = 'Asha'}) =>
    <String, dynamic>{'anonymous': anonymous, 'mine': mine, 'name': name, 'expert': false, 'title': null};

void main() {
  late FakeAdapter adapter;

  setUp(() => adapter = FakeAdapter());

  group('Practice (spec 010 §7)', () {
    test('a completion sends the device-made id, so a resend logs once (AC27)', () async {
      final ApiPracticeRepository repo = ApiPracticeRepository(fakeApi(adapter));
      adapter
        ..reply(<String, dynamic>{'logged': true})
        ..reply(<String, dynamic>{'logged': true});
      await repo.complete('s1', durationSeconds: 900, clientId: 'c-1');
      await repo.complete('s1', durationSeconds: 900, clientId: 'c-1');
      expect(adapter.requests.map((r) => r.path), everyElement('/me/practice/sessions/s1/complete'));
      expect(adapter.requests.map((r) => r.data['clientId']), <String>['c-1', 'c-1']);
      expect(adapter.lastBody['durationSeconds'], 900);
    });

    test('the library sends only the filters chosen and reads what the server kept (AC28: the server removes unsuitable sessions)', () async {
      final ApiPracticeRepository repo = ApiPracticeRepository(fakeApi(adapter));
      adapter.reply(<String, dynamic>{'items': <Object>[session('a')]});
      final List<PracticeSession> items = await repo.library(const PracticeFilters(maxMinutes: 20, phase: 'luteal'));
      expect(adapter.last.uri.queryParameters, <String, String>{'maxMinutes': '20', 'phase': 'luteal'});
      expect(items.single.caution, 'Skip inversions during your period.');
    });

    test('live classes during the trial read as starting after payment', () async {
      final ApiPracticeRepository repo = ApiPracticeRepository(fakeApi(adapter));
      adapter.reply(<String, dynamic>{'access': 'after_trial', 'startsOn': '2026-12-01', 'classes': <Object>[]});
      final LiveClasses c = await repo.liveClasses();
      expect(c.access, ClassAccess.afterTrial);
      expect(c.startsOn, '2026-12-01');
    });

    test('an area not on her plan becomes AreaLocked with the plans that include it, and no data (AC48)', () async {
      final ApiPracticeRepository repo = ApiPracticeRepository(fakeApi(adapter));
      adapter.reply(lockedBody('practice'), 403);
      await expectLater(
        repo.today(),
        throwsA(isA<AreaLocked>().having((AreaLocked e) => e.plans, 'plans', <String>['Essential', 'Complete']).having((AreaLocked e) => e.locked, 'locked', isTrue)),
      );
    });
  });

  group('Me and privacy (spec 010 §13)', () {
    test('the workspace lists areas as the server decides them, locked ones with their plans (AC1, AC4)', () async {
      final ApiMeRepository repo = ApiMeRepository(fakeApi(adapter));
      adapter.reply(<String, dynamic>{
        'state': 'member',
        'assessmentMinutes': null,
        'accountKind': 'adult',
        'onboarding': 'complete',
        'displayName': 'Meera',
        'areas': <Object>[
          <String, dynamic>{'key': 'labs', 'name': 'Lab tests', 'status': 'available'},
          <String, dynamic>{'key': 'community', 'name': 'Community', 'status': 'locked', 'description': 'Circles.', 'plans': <String>['Complete']},
        ],
        'entitlements': <Object>[],
      });
      final Workspace w = await repo.workspace();
      expect(w.area('labs')!.available, isTrue);
      expect(w.area('community')!.plans, <String>['Complete']);
      expect(w.area('meals'), isNull);
    });

    test('withdrawing a consent is a DELETE and the screen takes the server\'s new list at once (AC44)', () async {
      final ApiMeRepository repo = ApiMeRepository(fakeApi(adapter));
      adapter.reply(<String, dynamic>{'consents': <Object>[], 'staffAccess': <Object>[], 'personalisedAi': true, 'accountKind': 'adult'});
      final PrivacyDocument p = await repo.withdrawConsent('c9');
      expect(adapter.last.method, 'DELETE');
      expect(adapter.last.path, '/me/consents/c9');
      expect(p.consents, isEmpty);
    });

    test('deleting the account and opening an export both carry the fresh-check proof (AC45, AC46)', () async {
      final ApiMeRepository repo = ApiMeRepository(fakeApi(adapter));
      adapter
        ..reply(<String, dynamic>{'status': 'code_sent'})
        ..reply(<String, dynamic>{'proofId': 'p-1'})
        ..reply(<String, dynamic>{'deletesOn': '2026-12-17'})
        ..reply(<String, dynamic>{'profile': <String, dynamic>{}});
      await repo.requestFreshCode();
      final String proof = await repo.verifyFreshCode('123456');
      expect(await repo.requestDeletion(proof), '2026-12-17');
      expect(adapter.lastBody, <String, dynamic>{'proofId': 'p-1'});
      await repo.downloadExport('e1', proof);
      expect(adapter.last.path, '/me/exports/e1/download');
      expect(adapter.lastBody, <String, dynamic>{'proofId': 'p-1'});
    });

    test('a plan without data.export leaves the rest of privacy working: exports refuse as AreaLocked', () async {
      final ApiMeRepository repo = ApiMeRepository(fakeApi(adapter));
      adapter.reply(lockedBody('me'), 403);
      await expectLater(repo.exports(), throwsA(isA<AreaLocked>()));
    });

    test('no plan yet is null, not an error', () async {
      final ApiMeRepository repo = ApiMeRepository(fakeApi(adapter));
      adapter.reply(<String, dynamic>{'error': <String, dynamic>{'code': 'not_found', 'message': 'Not found.'}}, 404);
      expect(await repo.currentPlan(), isNull);
    });
  });

  group('Labs, care and community (spec 010 §9-§12)', () {
    test('a result outside the report\'s range keeps the server\'s neutral label and its range (AC34)', () async {
      final ApiLabsRepository repo = ApiLabsRepository(fakeApi(adapter));
      adapter.reply(<String, dynamic>{
        'items': <Object>[
          <String, dynamic>{
            'id': 'r1',
            'testDate': '2026-11-01',
            'reportDate': null,
            'orderId': null,
            'hasFile': false,
            'clinicianComment': null,
            'note': 'Your doctor can explain these results.',
            'results': <Object>[
              <String, dynamic>{'id': 'x', 'name': 'TSH', 'value': 6.2, 'unit': 'mIU/L', 'range': <String, dynamic>{'low': 0.4, 'high': 4.0}, 'outsideRange': true, 'label': "Outside the lab's range"},
            ],
          },
        ],
      });
      final LabResult r = (await repo.reports()).single.results.single;
      expect(r.outsideRange, isTrue);
      expect(r.label, "Outside the lab's range");
      expect(r.high, 4.0);
    });

    test('a report can be added with results and their printed range (AC33)', () async {
      final ApiLabsRepository repo = ApiLabsRepository(fakeApi(adapter));
      adapter.reply(<String, dynamic>{'id': 'r2', 'testDate': '2026-11-10', 'reportDate': null, 'orderId': null, 'hasFile': false, 'clinicianComment': null, 'note': '', 'results': <Object>[]});
      await repo.addReport(testDate: '2026-11-10', results: const <ResultInput>[ResultInput(name: 'Hb', value: 11.2, unit: 'g/dL', low: 12, high: 15)]);
      expect(adapter.lastBody['testDate'], '2026-11-10');
      expect((adapter.lastBody['results'] as List<dynamic>).single, <String, dynamic>{'name': 'Hb', 'value': 11.2, 'unit': 'g/dL', 'referenceLow': 12, 'referenceHigh': 15});
    });

    test('a second program is refused with the server\'s words (AC37)', () async {
      final ApiCareRepository repo = ApiCareRepository(fakeApi(adapter));
      adapter.reply(<String, dynamic>{'error': <String, dynamic>{'code': 'conflict', 'message': 'You are already in a program.'}}, 409);
      await expectLater(repo.enrol('p2'), throwsA(predicate((Object e) => failureText(e, '') == 'You are already in a program.')));
    });

    test('tasks read her week as what she did, never what she missed (AC36)', () async {
      final ApiCareRepository repo = ApiCareRepository(fakeApi(adapter));
      adapter.reply(<String, dynamic>{
        'today': <Object>[<String, dynamic>{'id': 't1', 'title': 'Walk 20 minutes', 'done': false}],
        'week': <Object>[<String, dynamic>{'date': '2026-11-16', 'done': 2}],
      });
      final CareTasks t = await repo.tasks();
      expect(t.today!.single.done, isFalse);
      expect(t.week.single.done, 2);
    });

    test('an anonymous post carries no name for others, and her own is marked as hers (AC39)', () async {
      final ApiCommunityRepository repo = ApiCommunityRepository(fakeApi(adapter));
      adapter.reply(<String, dynamic>{
        'items': <Object>[
          <String, dynamic>{'id': 'p1', 'circleId': 'c', 'body': 'Hi', 'author': author(anonymous: true, name: null), 'beingReviewed': false, 'edited': false, 'comments': 0, 'createdAt': '2026-11-17T10:00:00Z'},
          <String, dynamic>{'id': 'p2', 'circleId': 'c', 'body': 'Me', 'author': author(mine: true), 'beingReviewed': true, 'edited': false, 'comments': 0, 'createdAt': '2026-11-17T10:00:00Z'},
        ],
      });
      final List<Post> posts = await repo.feed('c');
      expect(posts.first.author.name, isNull);
      expect(posts.last.beingReviewed, isTrue);
    });

    test('posting sends the anonymous choice and reads the review note and resources (rules 2, 4, 8)', () async {
      final ApiCommunityRepository repo = ApiCommunityRepository(fakeApi(adapter));
      adapter.reply(<String, dynamic>{'id': 'p3', 'beingReviewed': 'Your post is being reviewed', 'resources': 'Call a helpline'});
      final Posted p = await repo.post('c', 'Feeling low', anonymous: true);
      expect(adapter.lastBody, <String, dynamic>{'body': 'Feeling low', 'anonymous': true});
      expect(p.resources, 'Call a helpline');
    });
  });
}
