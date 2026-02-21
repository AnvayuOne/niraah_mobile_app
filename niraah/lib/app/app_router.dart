import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/pages/home_page.dart';
import '../shared/constants/route_constants.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteConstants.home,
    routes: <RouteBase>[
      GoRoute(
        path: RouteConstants.home,
        name: 'home',
        builder: (BuildContext context, GoRouterState state) => const HomePage(),
      ),
    ],
  );
}
