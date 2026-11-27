// Live check that every member-workspace repository parses what a running niraah-platform returns:
// LIVE_API=<base> LIVE_TOKEN=<member access token> flutter test test/live/member_workspace_live_test.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/auth/session_store.dart';
import 'package:niraah/core/network/niraah_api.dart';
import 'package:niraah/features/care/data/api_care_repository.dart';
import 'package:niraah/features/community/data/api_community_repository.dart';
import 'package:niraah/features/cycle/data/api_cycle_repository.dart';
import 'package:niraah/features/cycle/domain/cycle.dart';
import 'package:niraah/features/diet_plan/data/api_diet_plan_repository.dart';
import 'package:niraah/features/home/data/api_home_repository.dart';
import 'package:niraah/features/labs/data/api_labs_repository.dart';
import 'package:niraah/features/me/data/api_me_repository.dart';
import 'package:niraah/features/meals/data/api_meals_repository.dart';
import 'package:niraah/features/messaging/messaging.dart';
import 'package:niraah/features/plans/data/api_plans_repository.dart';
import 'package:niraah/features/practice/data/api_practice_repository.dart';
import 'package:niraah/features/practice/domain/practice.dart';
import 'package:niraah/features/symptoms/data/api_symptoms_repository.dart';
import 'package:niraah/shared/area/area_access.dart';

final String? _base = Platform.environment['LIVE_API'];
final String? _token = Platform.environment['LIVE_TOKEN'];

/// A plan without the area answers with [AreaLocked]; that is a parsed, valid outcome.
Future<void> _orLocked(Future<Object?> f) async {
  try {
    await f;
  } on AreaLocked catch (e) {
    // ignore: avoid_print
    print('locked: ${e.message}');
  }
}

NiraahApi _api() {
  final MemorySessionStore store = MemorySessionStore()..tokens = SessionTokens(accessToken: _token!, refreshToken: 'unused');
  return NiraahApi(dio: Dio(BaseOptions(baseUrl: _base!, receiveTimeout: const Duration(seconds: 60))), store: store);
}

void main() {
  final Object skip = _base == null || _token == null ? 'set LIVE_API and LIVE_TOKEN' : false;
  void live(String name, Future<void> Function() body) => test(name, body, skip: skip, timeout: const Timeout(Duration(minutes: 2)));

  live('home', () async {
    final ApiHomeRepository repo = ApiHomeRepository(_api());
    await repo.getHome();
    await repo.saveTodayLog(const DailyLogPatch(mood: Mood.calm));
  });
  live('cycle', () async => ApiCycleRepository(_api()).getCycle());
  live('symptoms: read and log', () async {
    final ApiSymptomsRepository repo = ApiSymptomsRepository(_api());
    await repo.getSymptoms();
    await repo.logSymptom(date: IsoDates.format(DateTime.now()), symptom: 'fatigue', severity: 2);
  });
  live('plans', () async {
    final ApiPlansRepository repo = ApiPlansRepository(_api());
    final Object offer = await repo.offer();
    expect(offer.toString(), isNot(contains('Failure')), reason: offer.toString());
  });
  live('meals list', () async => ApiMealsRepository(_api()).today());
  live('diet plan food profile', () async {
    final ApiDietPlanRepository repo = ApiDietPlanRepository(_api());
    await repo.profile();
    await repo.foods();
  });
  live('practice', () async {
    final ApiPracticeRepository repo = ApiPracticeRepository(_api());
    await repo.today();
    final List<PracticeSession> lib = await repo.library(const PracticeFilters());
    if (lib.isNotEmpty) await repo.session(lib.first.id);
    await repo.history();
    await repo.liveClasses();
  });
  live('me / profile / privacy / notifications', () async {
    final ApiMeRepository repo = ApiMeRepository(_api());
    await repo.workspace();
    await repo.profile();
    await repo.currentPlan();
    await repo.privacy();
    await repo.exports();
    await repo.notificationSettings();
    // Reversible writes: switch a channel and personalised AI off and back on.
    await repo.setNotification('payments', 'email', false);
    await repo.setNotification('payments', 'email', true);
    await repo.setPersonalisedAi(false);
    await repo.setPersonalisedAi(true);
  });
  live('care: programs, plan, tasks, check-ins', () async {
    final ApiCareRepository repo = ApiCareRepository(_api());
    await _orLocked(repo.programs());
    await _orLocked(repo.carePlan());
    await _orLocked(repo.tasks());
    await _orLocked(repo.checkIns());
  });
  live('labs', () async {
    final ApiLabsRepository repo = ApiLabsRepository(_api());
    await _orLocked(repo.reports());
    await _orLocked(repo.collection());
    await _orLocked(repo.orders());
  });
  live('community', () async {
    final ApiCommunityRepository repo = ApiCommunityRepository(_api());
    await _orLocked(repo.circles());
  });
  live('messages', () async => _orLocked(ApiMessagingRepository(_api()).threads()));
}
