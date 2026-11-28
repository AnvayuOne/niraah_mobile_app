// Live walk of every member area with the real API repositories, so a parse crash or a refused
// request shows up against a running niraah-platform in local test mode (fixed code 123456).
// Runs only when LIVE_API is set: LIVE_API=http://<host>:3001/api/v1 flutter test test/live
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/auth/session_store.dart';
import 'package:niraah/core/network/niraah_api.dart';
import 'package:niraah/features/assessment/data/api_assessment_repository.dart';
import 'package:niraah/features/assessment/domain/assessment_repository.dart';
import 'package:niraah/features/assessment/domain/questionnaire.dart';
import 'package:niraah/features/auth/data/api_auth_repository.dart';
import 'package:niraah/features/auth/domain/auth_repository.dart';
import 'package:niraah/features/auth/presentation/pages/account_details_page.dart';
import 'package:niraah/features/care/data/api_care_repository.dart';
import 'package:niraah/features/chat/data/api_chat_repository.dart';
import 'package:niraah/features/chat/domain/chat.dart';
import 'package:niraah/features/community/data/api_community_repository.dart';
import 'package:niraah/features/community/domain/community.dart';
import 'package:niraah/features/cycle/data/api_cycle_repository.dart';
import 'package:niraah/features/cycle/domain/cycle.dart';
import 'package:niraah/features/diet_plan/data/api_diet_plan_repository.dart';
import 'package:niraah/features/home/data/api_home_repository.dart';
import 'package:niraah/features/labs/data/api_labs_repository.dart';
import 'package:niraah/features/labs/domain/labs.dart';
import 'package:niraah/features/me/data/api_me_repository.dart';
import 'package:niraah/features/meals/data/api_meals_repository.dart';
import 'package:niraah/features/meals/domain/meals.dart';
import 'package:niraah/features/messaging/messaging.dart';
import 'package:niraah/features/plans/data/api_plans_repository.dart';
import 'package:niraah/features/practice/data/api_practice_repository.dart';
import 'package:niraah/features/practice/domain/practice.dart';
import 'package:niraah/features/symptoms/data/api_symptoms_repository.dart';
import 'package:niraah/shared/area/area_access.dart';
import 'package:niraah/shared/helpers/result.dart';

final String? _base = Platform.environment['LIVE_API'];

void main() {
  test('new member walks every area without a parse crash', () async {
    final MemorySessionStore store = MemorySessionStore();
    final NiraahApi api = NiraahApi(dio: Dio(BaseOptions(baseUrl: _base!)), store: store);
    final List<String> problems = <String>[];
    Future<Object?> step(String name, Future<Object?> Function() f) async {
      try {
        final Object? r = await f();
        if (r is FailureResult) problems.add('$name: failure ${r.message}');
        return r;
      } catch (e, st) {
        problems.add('$name: ${e.runtimeType} $e\n${st.toString().split('\n').take(4).join('\n')}');
        return null;
      }
    }

    final ApiAuthRepository auth = ApiAuthRepository(api);
    final String phone = '+9197${10000000 + Random().nextInt(89999999)}';
    await auth.requestCode(phone);
    final Result<CodeOutcome> v = await auth.verifyCode(phone, '123456');
    expect((v as Success<CodeOutcome>).data, CodeOutcome.newAccount);
    await step('account', () => auth.saveAccountDetails(
        displayName: 'Walk', termsVersion: AccountDetailsPage.termsVersion, privacyVersion: AccountDetailsPage.privacyVersion));

    // Assessment, in the app's order: consent, then the questions.
    final AssessmentRepository a = ApiAssessmentRepository(api);
    // Before consent the server refuses to start; the app must read that as "ask for consent".
    final Result<AssessmentSession> early = await a.startOrResume();
    expect(early, isA<FailureResult<AssessmentSession>>());
    expect((early as FailureResult<AssessmentSession>).message, kConsentRequired);
    final Object? consent = await step('consent', () => a.recordConsent(healthData: true, doctorReview: true, textVersion: ApiAssessmentRepository.consentTextVersion));
    expect(consent, isA<Success<void>>());
    final Result<AssessmentSession> s = await a.startOrResume();
    final AssessmentSession session = (s as Success<AssessmentSession>).data;
    for (Question q in session.document.questions) {
      if (q.displayCondition != null) continue;
      final Answer ans = switch (q.type) {
        QuestionType.date => const Answer.text('1995-01-01'),
        QuestionType.shortText || QuestionType.number => const Answer.text('ok'),
        _ => Answer.values(<String>[q.options.length > 1 ? q.options[1].value : q.options.first.value]),
      };
      await step('answer ${q.key}', () => a.saveAnswer(session.assessmentId, q.key, ans));
    }
    await step('submit', () => a.submit(session.assessmentId, const <String, Answer>{}));

    final ApiPlansRepository plans = ApiPlansRepository(api);
    await step('plans.offer', plans.offer);

    final ApiHomeRepository home = ApiHomeRepository(api);
    await step('home.get', home.getHome);
    final String today = IsoDates.format(DateTime.now());
    await step('home.saveTodayLog', () => home.saveTodayLog(const DailyLogPatch(mood: Mood.calm, energy: Energy.okay)));
    await step('home.logPeriodStart', () => home.logPeriodStart(IsoDates.addDays(today, -3)));
    await step('home.get again', home.getHome);

    final ApiCycleRepository cycle = ApiCycleRepository(api);
    await step('cycle.get', cycle.getCycle);
    await step('cycle.saveDailyLog', () => cycle.saveDailyLog(today, const DailyLogPatch(flow: PeriodFlow.light, note: 'x')));
    await step('cycle.savePeriod', () => cycle.savePeriod(Period(start: IsoDates.addDays(today, -40), end: IsoDates.addDays(today, -36))));
    await step('cycle.setMarkers', () => cycle.setMarkers(const <CycleMarker>[]));
    await step('cycle.get again', cycle.getCycle);

    final ApiSymptomsRepository sym = ApiSymptomsRepository(api);
    await step('symptoms.get', sym.getSymptoms);
    await step('symptoms.log', () => sym.logSymptom(date: today, symptom: 'cramps', severity: 2));

    final ApiMealsRepository meals = ApiMealsRepository(api);
    await step('meals.today', meals.today);
    final Object? foods = await step('meals.searchFoods', () => meals.searchFoods('rice'));
    if (foods is List<FoodOption> && foods.isNotEmpty) {
      await step('meals.save', () => meals.save(
          eatenAt: DateTime.now(), slot: MealSlot.lunch, fromScan: false, items: <MealItemInput>[MealItemInput(foodId: foods.first.id, count: 1, unit: 'bowl')]));
      await step('meals.today again', meals.today);
    }

    final ApiDietPlanRepository diet = ApiDietPlanRepository(api);
    await step('diet.profile', diet.profile);
    await step('diet.foods', diet.foods);
    await step('diet.open', diet.open);

    final ApiChatRepository chat = ApiChatRepository(api);
    await step('chat.home', chat.getHome);
    final Object? conv = await step('chat.create', chat.createConversation);
    if (conv is Conversation) {
      await step('chat.get', () => chat.getConversation(conv.id));
      final Object? ev = await step('chat.send', () => chat.send(conv.id, 'What is PCOS?').toList());
      // ignore: avoid_print
      print('chat events: $ev');
      await step('chat.get after send', () => chat.getConversation(conv.id));
      await step('chat.rename', () => chat.renameConversation(conv.id, 'Renamed'));
      await step('chat.home again', chat.getHome);
    }

    final ApiCareRepository care = ApiCareRepository(api);
    await step('care.checkIns', care.checkIns);
    // Programs, care plan and tasks are locked on the free plan (AreaLocked is the expected answer), and
    // with no check-in due the server answers 409; neither is a crash.
    await expectLater(care.programs(), throwsA(isA<AreaLocked>()));
    await expectLater(care.carePlan(), throwsA(isA<AreaLocked>()));
    await expectLater(care.tasks(), throwsA(isA<AreaLocked>()));

    final ApiLabsRepository labs = ApiLabsRepository(api);
    await step('labs.reports', labs.reports);
    await step('labs.collection', labs.collection);
    await step('labs.orders', labs.orders);
    await step('labs.addReport', () => labs.addReport(testDate: IsoDates.addDays(today, -2), results: const <ResultInput>[ResultInput(name: 'TSH', value: 2.1, unit: 'mIU/L')]));

    final ApiCommunityRepository com = ApiCommunityRepository(api);
    final Object? circles = await step('community.circles', com.circles);
    if (circles is Circles && circles.circles.isNotEmpty) {
      if (circles.rules != null) await step('community.acceptRules', () => com.acceptRules(circles.rules!.version));
      final String cid = circles.circles.first.id;
      await step('community.join', () => com.setJoined(cid, true));
      await step('community.feed', () => com.feed(cid));
      final Object? posted = await step('community.post', () => com.post(cid, 'Hello everyone, first post here.', anonymous: false));
      final Object? feed = await step('community.feed again', () => com.feed(cid));
      if (feed is List<Post> && feed.isNotEmpty) await step('community.thread', () => com.thread(feed.first.id));
      expect(posted, isNotNull);
    }

    final ApiMeRepository me = ApiMeRepository(api);
    await step('me.workspace', me.workspace);
    await step('me.profile', me.profile);
    await step('me.updateProfile', () => me.updateProfile(displayName: 'Walk Two', heightCm: 160, goals: const <String>['understand_cycle']));
    await step('me.currentPlan', me.currentPlan);
    await step('me.privacy', me.privacy);
    await step('me.exports', me.exports);
    await step('me.notificationSettings', me.notificationSettings);

    final ApiMessagingRepository msg = ApiMessagingRepository(api);
    await step('messaging.threads', msg.threads);

    final ApiPracticeRepository pr = ApiPracticeRepository(api);
    await step('practice.today', pr.today);
    final Object? lib = await step('practice.library', () => pr.library(const PracticeFilters()));
    if (lib is List<PracticeSession> && lib.isNotEmpty) {
      await step('practice.session', () => pr.session(lib.first.id));
      await step('practice.complete', () => pr.complete(lib.first.id, durationSeconds: 300, clientId: 'c-${DateTime.now().millisecondsSinceEpoch}'));
    }
    await step('practice.history', pr.history);
    await step('practice.liveClasses', pr.liveClasses);

    // ignore: avoid_print
    print(problems.isEmpty ? 'ALL OK' : 'PROBLEMS:\n${problems.join('\n\n')}');
    expect(problems, isEmpty);
  }, timeout: const Timeout(Duration(minutes: 3)), skip: _base == null ? 'set LIVE_API' : false);
}
