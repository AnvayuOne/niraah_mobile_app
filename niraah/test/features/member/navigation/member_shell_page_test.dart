import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:niraah/features/member/navigation/presentation/pages/member_shell_page.dart';
import 'package:niraah/shared/constants/route_constants.dart';

void main() {
  testWidgets('member shell switches tabs from bottom bar', (WidgetTester tester) async {
    final GoRouter router = GoRouter(
      initialLocation: RouteConstants.memberHome,
      routes: <RouteBase>[
        GoRoute(
          path: RouteConstants.memberHome,
          builder: (BuildContext context, GoRouterState state) =>
              const MemberShellPage(initialTabIndex: 0),
        ),
        GoRoute(
          path: RouteConstants.memberCare,
          builder: (BuildContext context, GoRouterState state) =>
              const MemberShellPage(initialTabIndex: 1),
        ),
        GoRoute(
          path: RouteConstants.memberPrograms,
          builder: (BuildContext context, GoRouterState state) =>
              const MemberShellPage(initialTabIndex: 2),
        ),
        GoRoute(
          path: RouteConstants.memberCommunity,
          builder: (BuildContext context, GoRouterState state) =>
              const MemberShellPage(initialTabIndex: 3),
        ),
        GoRoute(
          path: RouteConstants.profile,
          builder: (BuildContext context, GoRouterState state) =>
              const MemberShellPage(initialTabIndex: 4),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);

    await tester.tap(find.text('Care'));
    await tester.pumpAndSettle();

    expect(find.text('Symptom Tracker'), findsOneWidget);
  });
}
