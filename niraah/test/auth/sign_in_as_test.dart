import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/design_system/theme/app_theme.dart';
import 'package:niraah/features/auth/data/api_auth_repository.dart';
import 'package:niraah/features/auth/domain/auth_repository.dart';
import 'package:niraah/features/auth/presentation/pages/sign_in_page.dart';
import 'package:niraah/l10n/app_localizations.dart';
import 'package:niraah/shared/constants/route_constants.dart';
import 'package:niraah/shared/helpers/result.dart';

import '../helpers/pump_app.dart';

// One sign-in for everyone (changed 2026-11-27 at the product owner's request, replacing "Sign in as"): what she types
// decides the path, and the account's workspace decides where she lands. Sign-up is for members only (a new number).

class FakeAuth implements AuthRepository {
  final List<String> codeRequests = <String>[];
  Result<void> answer = const Success<void>(null);

  @override
  Future<Result<void>> requestCode(String phoneE164) async {
    codeRequests.add(phoneE164);
    return answer;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The sign-in page inside a router, so Continue can go to the code or password step.
Future<GoRouter> pumpSignIn(WidgetTester tester) async {
  final GoRouter router = GoRouter(
    initialLocation: RouteConstants.signIn,
    routes: <RouteBase>[
      GoRoute(path: RouteConstants.signIn, builder: (_, _) => const SignInPage()),
      GoRoute(path: RouteConstants.signInCode, builder: (_, GoRouterState st) => Text('code step ${(st.extra! as PhoneInput).e164}')),
      GoRoute(path: RouteConstants.signInPassword, builder: (_, GoRouterState st) => Text('password step ${st.extra}')),
      GoRoute(path: RouteConstants.welcome, builder: (_, _) => const Text('welcome')),
    ],
  );
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(size: Size(390, 844)),
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pump();
  return router;
}

void main() {
  late FakeAuth auth;

  setUp(() {
    auth = FakeAuth();
    GetIt.instance.allowReassignment = true;
    GetIt.instance.registerSingleton<AuthRepository>(auth);
  });

  testWidgets('one field for everyone: no "Sign in as" choice, no number/email toggle', (WidgetTester tester) async {
    await tester.pumpApp(const SignInPage());
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.text('Sign in as'), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Mobile number or email'), findsOneWidget);
    expect(find.text('Sign in or create your account.'), findsOneWidget);
  });

  testWidgets('sign-up is for members (a new number); doctors and others keep the Apply link', (WidgetTester tester) async {
    await tester.pumpApp(const SignInPage());
    expect(find.text("New to Niraah? Just enter your mobile number and we'll set you up."), findsOneWidget);
    expect(find.text('Doctor, dietitian or yoga instructor? Apply to join'), findsOneWidget);
  });

  testWidgets('+91 shows only while she types a number', (WidgetTester tester) async {
    await tester.pumpApp(const SignInPage());
    expect(find.text('+91'), findsNothing);
    await tester.enterText(find.byType(TextField), '98765');
    await tester.pump();
    expect(find.text('+91'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'asha@');
    await tester.pump();
    expect(find.text('+91'), findsNothing);
  });

  testWidgets('a mobile number asks for a code and goes to the code step', (WidgetTester tester) async {
    await pumpSignIn(tester);
    await tester.enterText(find.byType(TextField), '98765 43210');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(auth.codeRequests, <String>['+919876543210']);
    expect(find.text('code step +919876543210'), findsOneWidget);
  });

  testWidgets('a staff demo number takes the same code path (the server decides she is a doctor)', (WidgetTester tester) async {
    await pumpSignIn(tester);
    await tester.enterText(find.byType(TextField), '9000000001');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(auth.codeRequests, <String>['+919000000001']);
  });

  testWidgets('an email goes to the password step, with no code sent', (WidgetTester tester) async {
    await pumpSignIn(tester);
    await tester.enterText(find.byType(TextField), 'dr.rao@clinic.in');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(auth.codeRequests, isEmpty);
    expect(find.text('password step dr.rao@clinic.in'), findsOneWidget);
  });

  testWidgets('something that is neither is refused on the screen without a server call', (WidgetTester tester) async {
    await tester.pumpApp(const SignInPage());
    await tester.enterText(find.byType(TextField), 'asha');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Enter a mobile number or an email'), findsOneWidget);
    expect(auth.codeRequests, isEmpty);
  });

  testWidgets('a short number is caught before sending', (WidgetTester tester) async {
    await tester.pumpApp(const SignInPage());
    await tester.enterText(find.byType(TextField), '98765');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Check the number: an Indian mobile number has 10 digits.'), findsOneWidget);
    expect(auth.codeRequests, isEmpty);
  });

  testWidgets("the server's refusal is shown in its own words", (WidgetTester tester) async {
    auth.answer = const FailureResult<void>('Complete the check to get a new code.');
    await tester.pumpApp(const SignInPage());
    await tester.enterText(find.byType(TextField), '9876543210');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Complete the check to get a new code.'), findsOneWidget);
  });

  test('after the code each account lands in its own place, never the suspended screen', () {
    final Map<String, String> expected = <String, String>{
      'member_new': RouteConstants.accountDetails,
      'assessment_gate': RouteConstants.assessmentStart,
      'member': '/home',
      'doctor': '/doctor',
      'dietitian': '/dietitian',
      'instructor': '/instructor',
      'admin': '/admin',
      'provider_status': '/provider/status',
      'second_check': RouteConstants.signInSecondCheck,
    };
    expected.forEach((String workspace, String route) {
      expect(routeForOutcome(ApiAuthRepository.outcomeFor(workspace)), route, reason: workspace);
    });
    expect(routeForOutcome(ApiAuthRepository.outcomeFor('suspended')), contains('state=suspended'));
  });
}
