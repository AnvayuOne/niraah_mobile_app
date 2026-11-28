import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/core/errors/api_exception.dart';
import 'package:niraah/features/care/domain/care.dart';
import 'package:niraah/features/care/presentation/care_pages.dart';
import 'package:niraah/features/community/domain/community.dart';
import 'package:niraah/features/community/presentation/community_pages.dart';
import 'package:niraah/features/labs/domain/labs.dart';
import 'package:niraah/features/labs/presentation/labs_pages.dart';
import 'package:niraah/features/me/domain/me.dart';
import 'package:niraah/features/me/presentation/me_page.dart';
import 'package:niraah/features/me/presentation/privacy_page.dart';
import 'package:niraah/features/practice/domain/practice.dart';
import 'package:niraah/features/practice/presentation/practice_page.dart';
import 'package:niraah/features/practice/presentation/practice_pages.dart';
import 'package:niraah/shared/area/area_access.dart';

import '../helpers/pump_app.dart';

const PracticeSession gentle = PracticeSession(
  id: 's1',
  title: 'Gentle flow',
  description: 'Slow stretches for a heavy day.',
  minutes: 15,
  level: 'Beginner',
  tags: <String>[],
  phases: <String>['menstrual'],
  caution: 'Skip inversions during your period.',
  captions: true,
  video: null,
);

class FakePractice implements PracticeRepository {
  Future<PracticeToday> Function() onToday = () async => const PracticeToday(phase: 'menstrual', sessions: <PracticeSession>[gentle]);
  final List<String> completions = <String>[];

  @override
  Future<PracticeToday> today() => onToday();

  @override
  Future<LiveClasses> liveClasses() async => const LiveClasses(access: ClassAccess.afterTrial, startsOn: null, classes: <LiveClass>[]);

  @override
  Future<PracticeSession> session(String id) async => gentle;

  @override
  Future<void> complete(String id, {required int durationSeconds, required String clientId}) async => completions.add(clientId);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeMe implements MeRepository {
  FakeMe({this.teen = false});

  final bool teen;

  @override
  Future<Workspace> workspace() async => Workspace(
        displayName: 'Meera',
        accountKind: teen ? 'teen' : 'adult',
        areas: <AreaState>[
          const AreaState(key: 'labs', name: 'Lab tests', status: 'available'),
          const AreaState(key: 'community', name: 'Community', status: 'locked', description: 'Circles.', plans: <String>['Complete']),
        ],
      );

  @override
  Future<CurrentPlan?> currentPlan() async => const CurrentPlan(name: 'Essential', status: 'active', priceDisplay: '₹999 incl. GST', renewsAt: null, endsAt: null, cancelled: false, retired: false);

  @override
  Future<PrivacyDocument> privacy() async => PrivacyDocument(
        consents: const <Consent>[Consent(id: 'c1', who: 'Dr Rao', role: 'Doctor', kind: 'care', category: 'Cycle', purpose: 'Care', givenOn: '2026-11-01')],
        staffAccess: const <StaffAccess>[StaffAccess(on: '2026-11-05', reason: 'Support request')],
        personalisedAi: true,
        accountKind: teen ? 'teen' : 'adult',
      );

  @override
  Future<List<DataExport>> exports() async => const <DataExport>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeLabs implements LabsRepository {
  @override
  Future<List<LabReport>> reports() async => const <LabReport>[
        LabReport(
          id: 'r1',
          testDate: '2026-11-01',
          hasFile: false,
          clinicianComment: null,
          note: 'Your doctor can explain these results.',
          results: <LabResult>[LabResult(name: 'TSH', value: 6.2, unit: 'mIU/L', low: 0.4, high: 4, outsideRange: true, label: "Outside the lab's range")],
        ),
      ];

  @override
  Future<LabCollection> collection() async => const LabCollection(access: 'not_included', tests: <LabTest>[], partners: <({String id, String name})>[]);

  @override
  Future<List<LabOrder>> orders() async => const <LabOrder>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCommunity implements CommunityRepository {
  @override
  Future<Circles> circles() async => const Circles(
        circles: <Circle>[Circle(id: 'c1', name: 'PCOS circle', rules: null, joined: false)],
        rules: CommunityRules(version: 2, text: 'Be kind.', accepted: false),
        composeReminder: "Don't share contact details.",
      );

  @override
  Future<List<Post>> feed(String circleId) async => const <Post>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCare implements CareRepository {
  @override
  Future<CarePlanDocument> carePlan() async => const CarePlanDocument(plan: null, waiting: 'Your doctor is preparing your care plan.', history: <({String doctor, String signedOn})>[]);

  @override
  Future<CareTasks> tasks() async => const CareTasks(today: <CareTask>[CareTask(id: 't1', title: 'Walk 20 minutes', done: false)], week: <({String date, int done})>[]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> settle(WidgetTester tester) async {
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('Practice tab (spec 010 §7)', () {
    testWidgets('loading, then today\'s sessions for her estimated phase (AC3, AC14)', (WidgetTester tester) async {
      final FakePractice repo = FakePractice();
      final Completer<PracticeToday> later = Completer<PracticeToday>();
      repo.onToday = () => later.future;
      await tester.pumpApp(PracticePage(repository: repo));
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
      later.complete(const PracticeToday(phase: 'menstrual', sessions: <PracticeSession>[gentle]));
      await settle(tester);
      expect(find.text('Gentle flow'), findsOneWidget);
      expect(find.textContaining('estimated'), findsOneWidget);
      expect(find.text('Live classes start with your first payment.'), findsOneWidget);
    });

    testWidgets('an error offers "Try again" and keeps no blame (AC3)', (WidgetTester tester) async {
      final FakePractice repo = FakePractice()..onToday = () async => throw ApiException(message: 'boom');
      await tester.pumpApp(PracticePage(repository: repo));
      await settle(tester);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.textContaining('boom'), findsNothing);
    });

    testWidgets('not on her plan: the description, the plans that include it and "See plans" (AC48)', (WidgetTester tester) async {
      final FakePractice repo = FakePractice()
        ..onToday = () async => throw const AreaLocked(message: "Practice isn't on your plan.", status: 'locked', description: 'Yoga sessions.', plans: <String>['Essential']);
      await tester.pumpApp(PracticePage(repository: repo));
      await settle(tester);
      expect(find.text('Yoga sessions.'), findsOneWidget);
      expect(find.text('Included in: Essential'), findsOneWidget);
      expect(find.text('See plans'), findsOneWidget);
    });

    testWidgets('a session shows its level and caution; finishing logs once however often she taps (AC27)', (WidgetTester tester) async {
      final FakePractice repo = FakePractice();
      await tester.pumpApp(PracticeSessionPage(sessionId: 's1', repository: repo));
      await settle(tester);
      expect(find.text('Skip inversions during your period.'), findsOneWidget);
      expect(find.textContaining('Level: Beginner'), findsOneWidget);
      await tester.tap(find.text("I've finished this session"));
      await settle(tester);
      await tester.tap(find.text('Saved to what you did').first, warnIfMissed: false);
      await settle(tester);
      expect(repo.completions, hasLength(1));
    });
  });

  group('Me tab (spec 010 Navigation, §13)', () {
    testWidgets('lists her plan and areas; a locked area keeps a quiet lock, an absent one is not listed (rule 3)', (WidgetTester tester) async {
      await tester.pumpApp(MePage(repository: FakeMe()));
      await settle(tester);
      expect(find.text('Meera'), findsOneWidget);
      expect(find.text('Essential'), findsOneWidget);
      expect(find.text('Lab tests'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('^Community, not on your plan')), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
      expect(find.text('Meals'), findsNothing);
    });

    testWidgets('a teen account sees no plan or price (spec 010 "Teen accounts", AC54)', (WidgetTester tester) async {
      await tester.pumpApp(MePage(repository: FakeMe(teen: true)));
      await settle(tester);
      expect(find.text('Your plan'), findsNothing);
      expect(find.textContaining('₹'), findsNothing);
    });

    testWidgets('privacy lists every consent and every staff access (AC43)', (WidgetTester tester) async {
      await tester.pumpApp(PrivacyPage(repository: FakeMe()));
      await settle(tester);
      expect(find.text('Dr Rao · Doctor'), findsOneWidget);
      expect(find.textContaining('Support request'), findsOneWidget);
      expect(find.text('Use my data to personalise AI answers'), findsOneWidget);
    });

    testWidgets('a teen account has no personalised AI switch (spec 010 "Teen accounts" 1)', (WidgetTester tester) async {
      await tester.pumpApp(PrivacyPage(repository: FakeMe(teen: true)));
      await settle(tester);
      expect(find.text('Use my data to personalise AI answers'), findsNothing);
    });
  });

  group('Areas reached from Me (spec 010 §9-§12)', () {
    testWidgets('a result outside the range is marked in neutral words with no interpretation (AC34)', (WidgetTester tester) async {
      await tester.pumpApp(LabsPage(repository: FakeLabs()));
      await settle(tester);
      expect(find.text("Outside the lab's range"), findsOneWidget);
      expect(find.text("Lab's range 0.4 to 4"), findsOneWidget);
      expect(find.textContaining(RegExp('high|low|thyroid', caseSensitive: false)), findsNothing);
      expect(find.text("Home collection isn't on your plan. You can still add your own reports."), findsOneWidget);
    });

    testWidgets('rules come first: before she accepts them there is an accept card (AC40)', (WidgetTester tester) async {
      await tester.pumpApp(CommunityPage(repository: FakeCommunity()));
      await settle(tester);
      expect(find.text('Be kind.'), findsOneWidget);
      expect(find.text('I agree to the rules'), findsOneWidget);
    });

    testWidgets('a circle offers no new post until the rules are accepted (AC40)', (WidgetTester tester) async {
      await tester.pumpApp(CirclePage(repository: FakeCommunity(), circle: const Circle(id: 'c1', name: 'PCOS circle', rules: null, joined: true), canPost: false, reminder: ''));
      await settle(tester);
      expect(find.text('New post'), findsNothing);
      expect(find.text('Agree to the community rules to post.'), findsOneWidget);
    });

    testWidgets('no signed plan: the waiting line, never a draft; unticked tasks are not overdue (AC35, AC36)', (WidgetTester tester) async {
      await tester.pumpApp(CarePlanPage(repository: FakeCare()));
      await settle(tester);
      expect(find.text('Your doctor is preparing your care plan.'), findsOneWidget);
      expect(find.text('Walk 20 minutes'), findsOneWidget);
      expect(find.textContaining(RegExp('overdue|missed', caseSensitive: false)), findsNothing);
    });
  });
}
