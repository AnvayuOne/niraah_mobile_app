import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/home/domain/home.dart';
import '../shared/constants/route_constants.dart';

/// Moves between the five places of the member workspace (spec 010,
/// Navigation): Home, Cycle, AI Care, Practice and Me.
void goToArea(BuildContext context, Area area) {
  switch (area) {
    case Area.home:
      context.go(RouteConstants.home);
    case Area.cycle:
      context.go(RouteConstants.cycle);
    case Area.aiCare:
      context.go(RouteConstants.chat);
    case Area.practice:
      context.go(RouteConstants.practice);
    case Area.me:
      context.go(RouteConstants.me);
  }
}
