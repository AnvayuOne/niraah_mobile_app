// Renders key screens to PNG for visual review. Runs only when
// SCREENSHOT_DIR is set:
//   SCREENSHOT_DIR=<dir> flutter test test/screenshots
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/design_system/theme/app_theme.dart';
import 'package:niraah/design_system/widgets/answer_card.dart';
import 'package:niraah/features/assessment/domain/assessment_repository.dart';
import 'package:niraah/features/assessment/domain/prescore.dart';
import 'package:niraah/features/assessment/domain/questionnaire.dart';
import 'package:niraah/features/assessment/presentation/assessment_cubit.dart';
import 'package:niraah/features/assessment/presentation/pages/prescore_page.dart';
import 'package:niraah/features/assessment/presentation/pages/question_page.dart';
import 'package:niraah/features/auth/presentation/pages/password_page.dart';
import 'package:niraah/features/auth/presentation/pages/sign_in_page.dart';
import 'package:niraah/features/chat/presentation/chat_cubits.dart';
import 'package:niraah/features/chat/presentation/chat_home_page.dart';
import 'package:niraah/features/chat/presentation/conversation_page.dart';
import 'package:niraah/features/cycle/domain/cycle.dart';
import 'package:niraah/features/cycle/presentation/cycle_cubit.dart';
import 'package:niraah/features/cycle/presentation/cycle_page.dart';
import 'package:niraah/features/doctor/presentation/doctor_dashboard_page.dart';
import 'package:niraah/features/doctor/presentation/review_page.dart';
import 'package:niraah/features/doctor/presentation/review_queue_page.dart';
import 'package:niraah/features/home/presentation/home_cubit.dart';
import 'package:niraah/features/home/presentation/home_page.dart';
import 'package:niraah/features/landing/landing_page.dart';
import 'package:niraah/features/onboarding/presentation/pages/welcome_page.dart';
import 'package:niraah/features/plans/domain/plan.dart';
import 'package:niraah/features/plans/presentation/plans_page.dart';
import 'package:niraah/features/provider_auth/domain/provider_auth.dart';
import 'package:niraah/features/provider_auth/presentation/authenticator_page.dart';
import 'package:niraah/features/provider_auth/presentation/provider_pages.dart';
import 'package:niraah/features/symptoms/presentation/symptoms_cubit.dart';
import 'package:niraah/features/symptoms/presentation/symptoms_page.dart';
import 'package:niraah/l10n/app_localizations.dart';
import 'package:niraah/sample/sample_backend.dart';
import 'package:niraah/sample/sample_chat_repository.dart';
import 'package:niraah/sample/sample_cycle_repository.dart';
import 'package:niraah/sample/sample_doctor.dart';
import 'package:niraah/sample/sample_home.dart';
import 'package:niraah/sample/sample_provider_auth.dart';
import 'package:niraah/sample/sample_store.dart';
import 'package:niraah/sample/sample_symptoms_repository.dart';

final String? _out = Platform.environment['SCREENSHOT_DIR'];
const GlobalObjectKey<State<StatefulWidget>> _boundary = GlobalObjectKey<State<StatefulWidget>>('shot');

Answer v(String value) => Answer.values(<String>[value]);

Future<void> _loadFonts() async {
  Future<ByteData> font(String file) async => ByteData.sublistView(File('assets/fonts/$file').readAsBytesSync());
  final FontLoader sans = FontLoader('PlusJakartaSans');
  for (final String w in <String>['400', '500', '600', '700', '800']) {
    sans.addFont(font('PlusJakartaSans-$w.ttf'));
  }
  await sans.load();
  final FontLoader display = FontLoader('CormorantGaramond');
  for (final String w in <String>['500', '600', '700', 'Italic-500']) {
    display.addFont(font('CormorantGaramond-$w.ttf'));
  }
  await display.load();
  final String root = Platform.environment['FLUTTER_ROOT'] ?? '';
  final File icons = File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    final FontLoader m = FontLoader('MaterialIcons')..addFont(Future<ByteData>.value(ByteData.sublistView(icons.readAsBytesSync())));
    await m.load();
  }
}

Widget _frame(Widget child, AssessmentCubit cubit) => RepaintBoundary(
      key: _boundary,
      child: BlocProvider<AssessmentCubit>.value(
        value: cubit,
        // A one-route router so pages that ask GoRouter (canPop, go) build as they do in the app.
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          routerConfig: GoRouter(routes: <RouteBase>[GoRoute(path: '/', builder: (_, _) => child)]),
        ),
      ),
    );

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    for (final Element e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final RenderRepaintBoundary rb = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image img = await rb.toImage(pixelRatio: 2);
    final ByteData? png = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory(_out!).createSync(recursive: true);
    File('${_out!}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(() async {
    await _loadFonts();
    final SampleBackend backend = SampleBackend();
    GetIt.instance
      ..registerSingleton<SampleBackend>(backend)
      ..registerSingleton<AssessmentRepository>(SampleAssessmentRepository(backend))
      ..registerSingleton<PlansRepository>(SamplePlansRepository(backend))
      ..registerSingleton<ProviderAuthRepository>(SampleProviderAuthRepository());
  });

  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  testWidgets('landing, phone full page', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_frame(const LandingPage(), AssessmentCubit(GetIt.instance<AssessmentRepository>())));
    await _shot(tester, '00-landing-phone');
  }, skip: _out == null);

  testWidgets('landing, phone slides', (WidgetTester tester) async {
    phone(tester);
    await tester.pumpWidget(_frame(const LandingPage(), AssessmentCubit(GetIt.instance<AssessmentRepository>())));
    for (int i = 1; i <= 4; i++) {
      await _shot(tester, '00-landing-phone-slide$i');
      if (i < 4) {
        await tester.tap(find.byTooltip('Next'));
        await tester.pumpAndSettle();
      }
    }
  }, skip: _out == null);

  testWidgets('landing, small phone fits without scrolling', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_frame(const LandingPage(), AssessmentCubit(GetIt.instance<AssessmentRepository>())));
    await _shot(tester, '00-landing-small-phone');
  }, skip: _out == null);

  testWidgets('landing, desktop full page', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 2500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_frame(const LandingPage(), AssessmentCubit(GetIt.instance<AssessmentRepository>())));
    await _shot(tester, '00-landing-desktop');
  }, skip: _out == null);

  testWidgets('welcome', (WidgetTester tester) async {
    phone(tester);
    await tester.pumpWidget(_frame(const WelcomePage(), AssessmentCubit(GetIt.instance<AssessmentRepository>())));
    await _shot(tester, '01-welcome');
  }, skip: _out == null);

  testWidgets('sign-in', (WidgetTester tester) async {
    phone(tester);
    await tester.pumpWidget(_frame(const SignInPage(), AssessmentCubit(GetIt.instance<AssessmentRepository>())));
    await _shot(tester, '02-sign-in');
  }, skip: _out == null);

  testWidgets('question', (WidgetTester tester) async {
    phone(tester);
    final AssessmentCubit cubit = AssessmentCubit(SampleAssessmentRepository(SampleBackend()));
    final Future<void> loading = cubit.load();
    await tester.pump(const Duration(seconds: 1));
    await loading;
    cubit.answer('date_of_birth', const Answer.text('1995-05-01'));
    await cubit.next();
    cubit.answer('cycle_regularity', v('irregular'));
    await cubit.next();
    cubit.answer('mood', v('tired'));
    await tester.pumpWidget(_frame(const QuestionPage(), cubit));
    await _shot(tester, '03-question');
  }, skip: _out == null);

  for (final (String name, List<(String, Answer)> before) in <(String, List<(String, Answer)>)>[
    ('03a-question-cycle', <(String, Answer)>[('date_of_birth', const Answer.text('1995-05-01'))]),
    ('03b-question-symptoms', <(String, Answer)>[('date_of_birth', const Answer.text('1995-05-01')), ('cycle_regularity', v('regular')), ('mood', v('tired'))]),
    ('03c-question-diet', <(String, Answer)>[('date_of_birth', const Answer.text('1995-05-01')), ('cycle_regularity', v('regular')), ('mood', v('tired')), ('symptoms', v('acne'))]),
  ]) {
    testWidgets(name, (WidgetTester tester) async {
      phone(tester);
      await tester.runAsync(NOptionImages.load);
      final AssessmentCubit cubit = AssessmentCubit(SampleAssessmentRepository(SampleBackend()));
      final Future<void> loading = cubit.load();
      await tester.pump(const Duration(seconds: 1));
      await loading;
      for (final (String k, Answer a) in before) {
        cubit.answer(k, a);
        await cubit.next();
      }
      await tester.pumpWidget(_frame(const QuestionPage(), cubit));
      await _shot(tester, name);
    }, skip: _out == null);
  }

  testWidgets('pre-score', (WidgetTester tester) async {
    phone(tester);
    final PreScore p = SampleBackend().submit(<String, Answer>{
      'cycle_regularity': v('irregular'),
      'mood': v('tired'),
      'symptoms': v('acne'),
      'diet': v('mostly_home'),
      'activity': v('3'),
      'stress': v('3'),
      'sleep': v('light'),
      'goal': v('pcos'),
    });
    await tester.pumpWidget(_frame(PreScoreView(preScore: p), AssessmentCubit(GetIt.instance<AssessmentRepository>())));
    await _shot(tester, '04-prescore');
  }, skip: _out == null);

  testWidgets('plans', (WidgetTester tester) async {
    phone(tester);
    GetIt.instance<SampleBackend>().submit(<String, Answer>{'cycle_regularity': v('irregular'), 'sleep': v('tired')});
    await tester.pumpWidget(_frame(const PlansPage(), AssessmentCubit(GetIt.instance<AssessmentRepository>())));
    await tester.pump();
    await _shot(tester, '05-plans');
  }, skip: _out == null);

  SampleHomeRepository homeRepo() {
    final SampleBackend b = SampleBackend();
    b.submit(<String, Answer>{'cycle_regularity': v('regular'), 'mood': v('tired'), 'sleep': v('light'), 'diet': v('mostly_home')});
    return SampleHomeRepository(b, name: () => 'Priya', today: () => '2026-11-14');
  }

  Future<void> pumpHome(WidgetTester tester, SampleHomeRepository repo) async {
    final HomeCubit cubit = HomeCubit(repo);
    await cubit.load();
    await tester.pumpWidget(_frame(HomePage(cubit: cubit), AssessmentCubit(GetIt.instance<AssessmentRepository>())));
  }

  testWidgets('home, no period logged', (WidgetTester tester) async {
    phone(tester);
    await pumpHome(tester, homeRepo());
    await _shot(tester, '06-home-nodata');
  }, skip: _out == null);

  testWidgets('home, regular history', (WidgetTester tester) async {
    phone(tester);
    // The "regular history" periods from design/sample/cycle-cases.json.
    final SampleHomeRepository repo = homeRepo()
      ..seedPeriods(const <Period>[
        Period(start: '2026-08-10', end: '2026-08-14'),
        Period(start: '2026-09-07', end: '2026-09-11'),
        Period(start: '2026-10-06', end: '2026-10-10'),
        Period(start: '2026-11-03', end: '2026-11-07'),
      ]);
    await repo.saveTodayLog(const DailyLogPatch(mood: Mood.calm));
    await pumpHome(tester, repo);
    await _shot(tester, '07-home-regular');
  }, skip: _out == null);

  testWidgets('home, flow quick-log sheet', (WidgetTester tester) async {
    phone(tester);
    final SampleHomeRepository repo = homeRepo()..seedPeriods(const <Period>[Period(start: '2026-11-12')]);
    await pumpHome(tester, repo);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Flow'), 200);
    await tester.tap(find.text('Flow'));
    await tester.pumpAndSettle();
    await _shot(tester, '08-home-flow-sheet');
  }, skip: _out == null);

  // ---------- Cycle and symptoms ----------

  (SampleCycleRepository, SampleSymptomsRepository) cycleRepos() {
    final SampleBackend b = SampleBackend()..submit(<String, Answer>{'cycle_regularity': v('regular')});
    final SampleStore store = SampleStore()
      ..periods.addAll(const <Period>[
        Period(start: '2026-08-10', end: '2026-08-14'),
        Period(start: '2026-09-07', end: '2026-09-11'),
        Period(start: '2026-10-06', end: '2026-10-10'),
        Period(start: '2026-11-03', end: '2026-11-07'),
      ]);
    return (
      SampleCycleRepository(store, b, today: () => '2026-11-14'),
      SampleSymptomsRepository(store, b, today: () => '2026-11-14'),
    );
  }

  Future<void> pumpCycle(WidgetTester tester, SampleCycleRepository repo) async {
    await repo.saveDailyLog('2026-11-12', const DailyLogPatch(mood: Mood.calm, energy: Energy.high));
    final CycleCubit cubit = CycleCubit(repo);
    await cubit.load();
    await tester.pumpWidget(_frame(CyclePage(cubit: cubit), AssessmentCubit(GetIt.instance<AssessmentRepository>())));
    await tester.pumpAndSettle();
  }

  testWidgets('cycle, regular history', (WidgetTester tester) async {
    phone(tester);
    await pumpCycle(tester, cycleRepos().$1);
    await _shot(tester, '09-cycle-top');
    // Bring the month heading to the top so the whole calendar is in view.
    await tester.scrollUntilVisible(find.text('November 2026'), 300);
    Scrollable.ensureVisible(tester.element(find.text('November 2026')));
    await tester.pumpAndSettle();
    await _shot(tester, '10-cycle-calendar');
    await tester.scrollUntilVisible(find.text('Your situation'), 300);
    await tester.pumpAndSettle();
    await _shot(tester, '11-cycle-history');
  }, skip: _out == null);

  testWidgets('cycle, day sheet', (WidgetTester tester) async {
    phone(tester);
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpCycle(tester, cycleRepos().$1);
    await tester.scrollUntilVisible(find.text('November 2026'), 300);
    Scrollable.ensureVisible(tester.element(find.text('November 2026')));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel(RegExp(r'^Thursday, 12 November')));
    await tester.pumpAndSettle();
    await _shot(tester, '12-cycle-day-sheet');
    handle.dispose();
  }, skip: _out == null);

  Future<SymptomsCubit> pumpSymptoms(WidgetTester tester, SampleSymptomsRepository repo) async {
    for (final (String k, int sev) in <(String, int)>[('cramps', 6), ('bloating', 4), ('cramps', 3), ('poor_sleep', 5)]) {
      await repo.logSymptom(date: '2026-11-13', symptom: k, severity: sev);
    }
    final SymptomsCubit cubit = SymptomsCubit(repo);
    await cubit.load();
    await tester.pumpWidget(_frame(SymptomsPage(cubit: cubit), AssessmentCubit(GetIt.instance<AssessmentRepository>())));
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets('symptoms', (WidgetTester tester) async {
    phone(tester);
    await pumpSymptoms(tester, cycleRepos().$2);
    await _shot(tester, '13-symptoms');
  }, skip: _out == null);

  testWidgets('symptoms, red-flag advice sheet', (WidgetTester tester) async {
    phone(tester);
    await pumpSymptoms(tester, cycleRepos().$2);
    await tester.tap(find.text('Severe pelvic pain'));
    await tester.pumpAndSettle();
    await _shot(tester, '14-symptom-sheet');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await _shot(tester, '15-symptom-red-flag');
  }, skip: _out == null);
  // ---------- AI Care chat ----------

  SampleChatRepository chatRepo(SampleStore store) => SampleChatRepository(
        store,
        SampleBackend()..submit(<String, Answer>{'cycle_regularity': v('regular')}),
        today: () => '2026-11-14',
        sentenceDelay: Duration.zero,
      );

  Future<ConversationCubit> pumpChat(WidgetTester tester, SampleChatRepository repo, List<String> messages) async {
    final String id = (await repo.createConversation()).id;
    final ConversationCubit cubit = ConversationCubit(repo, id);
    await tester.runAsync(() async {
      for (final String m in messages) {
        await repo.send(id, m).drain<void>();
      }
    });
    await cubit.load();
    await tester.pumpWidget(_frame(ConversationPage(conversationId: id, cubit: cubit), AssessmentCubit(GetIt.instance<AssessmentRepository>())));
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets('chat home with starters', (WidgetTester tester) async {
    phone(tester);
    final SampleStore store = SampleStore()..periods.add(const Period(start: '2026-11-03', end: '2026-11-07'));
    final SampleChatRepository repo = chatRepo(store);
    await tester.runAsync(() async {
      final String id = (await repo.createConversation()).id;
      await repo.send(id, 'How can I sleep better?').drain<void>();
    });
    final ChatHomeCubit cubit = ChatHomeCubit(repo);
    await cubit.load();
    await tester.pumpWidget(_frame(ChatHomePage(cubit: cubit), AssessmentCubit(GetIt.instance<AssessmentRepository>())));
    await tester.pumpAndSettle();
    await _shot(tester, '16-chat-home');
  }, skip: _out == null);

  testWidgets('chat, answered with sources, and the source sheet', (WidgetTester tester) async {
    phone(tester);
    await pumpChat(tester, chatRepo(SampleStore()), <String>['Is my cycle length normal?']);
    await _shot(tester, '17-chat-answer');
    await tester.tap(find.textContaining('Understanding your menstrual cycle'));
    await tester.pumpAndSettle();
    await _shot(tester, '18-chat-source-sheet');
  }, skip: _out == null);

  testWidgets('chat, crisis card', (WidgetTester tester) async {
    phone(tester);
    await pumpChat(tester, chatRepo(SampleStore()), <String>["I don't want to live anymore"]);
    await _shot(tester, '19-chat-crisis');
  }, skip: _out == null);

  testWidgets('chat, at the limit', (WidgetTester tester) async {
    phone(tester);
    final SampleStore store = SampleStore();
    final SampleChatRepository repo = chatRepo(store);
    await tester.runAsync(() async {
      store
        ..chatUseDate = '2026-11-14'
        ..chatUseCount = 9;
    });
    final ConversationCubit cubit = await pumpChat(tester, repo, <String>['How can I sleep better?', 'What should I eat for steady energy?']);
    expect(cubit.state.atLimit, isTrue);
    await _shot(tester, '20-chat-limit');
  }, skip: _out == null);
  // ---------- Provider sign-in and doctor workspace ----------

  testWidgets('provider password step with error', (WidgetTester tester) async {
    phone(tester);
    await tester.pumpWidget(_frame(const PasswordPage(email: 'doctor@sample.niraah.in'), AssessmentCubit(GetIt.instance<AssessmentRepository>())));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'not-the-password');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await _shot(tester, '21-provider-password-error');
  }, skip: _out == null);

  testWidgets('provider authenticator step', (WidgetTester tester) async {
    phone(tester);
    await tester.pumpWidget(_frame(const AuthenticatorPage(), AssessmentCubit(GetIt.instance<AssessmentRepository>())));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '482');
    await tester.pumpAndSettle();
    await _shot(tester, '22-provider-authenticator');
  }, skip: _out == null);

  testWidgets('doctor dashboard', (WidgetTester tester) async {
    phone(tester);
    await tester.pumpWidget(_frame(DoctorDashboardPage(repository: SampleDoctorRepository()), AssessmentCubit(GetIt.instance<AssessmentRepository>())));
    await tester.pumpAndSettle();
    await _shot(tester, '23-doctor-dashboard');
  }, skip: _out == null);

  testWidgets('doctor queue', (WidgetTester tester) async {
    phone(tester);
    await tester.pumpWidget(_frame(ReviewQueuePage(repository: SampleDoctorRepository()), AssessmentCubit(GetIt.instance<AssessmentRepository>())));
    await tester.pumpAndSettle();
    await _shot(tester, '24-doctor-queue');
  }, skip: _out == null);

  testWidgets('doctor review', (WidgetTester tester) async {
    phone(tester);
    await tester.pumpWidget(_frame(ReviewPage(reviewId: 'rev-1', repository: SampleDoctorRepository()), AssessmentCubit(GetIt.instance<AssessmentRepository>())));
    await tester.pumpAndSettle();
    await _shot(tester, '25-doctor-review');
  }, skip: _out == null);

  testWidgets('provider status page', (WidgetTester tester) async {
    phone(tester);
    final ProviderAuthRepository auth = GetIt.instance<ProviderAuthRepository>();
    await auth.checkPassword('pending@sample.niraah.in', 'niraah-sample-pass');
    await auth.verifySecondFactor('123456', SecondFactorKind.authenticator);
    await tester.pumpWidget(_frame(const ProviderStatusPage(), AssessmentCubit(GetIt.instance<AssessmentRepository>())));
    await tester.pumpAndSettle();
    await _shot(tester, '26-provider-status');
  }, skip: _out == null);
}