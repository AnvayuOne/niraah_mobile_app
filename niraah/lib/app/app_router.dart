import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/member/auth/presentation/pages/auth_page.dart';
import '../features/member/auth/presentation/pages/otp_verify_page.dart';
import '../features/member/auth/presentation/pages/signup_mobile_page.dart';
import '../features/member/chat_ai/presentation/pages/chat_ai_page.dart';
import '../features/member/common/presentation/pages/permissions_page.dart';
import '../features/member/common/presentation/pages/splash_page.dart';
import '../features/member/logging_hub/presentation/pages/logging_hub_page.dart';
import '../features/member/medical_records/presentation/pages/medical_records_page.dart';
import '../features/member/navigation/presentation/pages/member_shell_page.dart';
import '../features/member/plans/presentation/pages/plans_page.dart';
import '../features/member/prescore/presentation/pages/prescore_page.dart';
import '../features/member/progress_dashboard/presentation/pages/progress_dashboard_page.dart';
import '../features/member/questionnaire/presentation/pages/questionnaire_page.dart';
import '../features/member/static_placeholders/presentation/pages/static_features_page.dart';
import '../shared/constants/route_constants.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteConstants.splash,
    routes: <RouteBase>[
      GoRoute(
        path: RouteConstants.splash,
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteConstants.auth,
        name: 'auth',
        builder: (BuildContext context, GoRouterState state) => const AuthPage(),
      ),
      GoRoute(
        path: RouteConstants.signup,
        name: 'signup',
        builder: (BuildContext context, GoRouterState state) => const SignupMobilePage(),
      ),
      GoRoute(
        path: RouteConstants.otpVerify,
        name: 'otpVerify',
        builder: (BuildContext context, GoRouterState state) => OtpVerifyPage(
          phone: state.uri.queryParameters['phone'] ?? '',
          flow: state.uri.queryParameters['flow'] ?? 'login',
        ),
      ),
      GoRoute(
        path: RouteConstants.permissions,
        name: 'permissions',
        builder: (BuildContext context, GoRouterState state) => const PermissionsPage(),
      ),
      GoRoute(
        path: RouteConstants.memberHome,
        name: 'memberHome',
        builder: (BuildContext context, GoRouterState state) =>
            const MemberShellPage(initialTabIndex: 0),
      ),
      GoRoute(
        path: RouteConstants.memberCare,
        name: 'memberCare',
        builder: (BuildContext context, GoRouterState state) =>
            const MemberShellPage(initialTabIndex: 1),
      ),
      GoRoute(
        path: RouteConstants.memberPrograms,
        name: 'memberPrograms',
        builder: (BuildContext context, GoRouterState state) =>
            const MemberShellPage(initialTabIndex: 2),
      ),
      GoRoute(
        path: RouteConstants.memberCommunity,
        name: 'memberCommunity',
        builder: (BuildContext context, GoRouterState state) =>
            const MemberShellPage(initialTabIndex: 3),
      ),
      GoRoute(
        path: RouteConstants.profile,
        name: 'profile',
        builder: (BuildContext context, GoRouterState state) =>
            const MemberShellPage(initialTabIndex: 4),
      ),
      GoRoute(
        path: RouteConstants.questionnaire,
        name: 'questionnaire',
        builder: (BuildContext context, GoRouterState state) => const QuestionnairePage(),
      ),
      GoRoute(
        path: RouteConstants.prescore,
        name: 'prescore',
        builder: (BuildContext context, GoRouterState state) => const PrescorePage(),
      ),
      GoRoute(
        path: RouteConstants.plans,
        name: 'plans',
        builder: (BuildContext context, GoRouterState state) => const PlansPage(),
      ),
      GoRoute(
        path: RouteConstants.records,
        name: 'records',
        builder: (BuildContext context, GoRouterState state) => const MedicalRecordsPage(),
      ),
      GoRoute(
        path: RouteConstants.chatAi,
        name: 'chatAi',
        builder: (BuildContext context, GoRouterState state) => const ChatAiPage(),
      ),
      GoRoute(
        path: RouteConstants.progressDashboard,
        name: 'progress',
        builder: (BuildContext context, GoRouterState state) => const ProgressDashboardPage(),
      ),
      GoRoute(
        path: RouteConstants.loggingHub,
        name: 'loggingHub',
        builder: (BuildContext context, GoRouterState state) => const LoggingHubPage(),
      ),
      GoRoute(
        path: RouteConstants.staticFeatures,
        name: 'staticFeatures',
        builder: (BuildContext context, GoRouterState state) => const StaticFeaturesPage(),
      ),
    ],
  );
}
