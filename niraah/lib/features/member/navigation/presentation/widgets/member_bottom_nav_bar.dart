import 'package:flutter/material.dart';

import '../../../../../design_system/icons/app_icons.dart';
import '../../../../../design_system/tokens/color_tokens.dart';

class MemberBottomNavBar extends StatelessWidget {
  const MemberBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      indicatorColor: ColorTokens.primary.withValues(alpha: 0.16),
      backgroundColor: ColorTokens.surface,
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(AppIcons.dashboard),
          selectedIcon: Icon(AppIcons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(AppIcons.care),
          selectedIcon: Icon(AppIcons.care),
          label: 'Care',
        ),
        NavigationDestination(
          icon: Icon(AppIcons.programs),
          selectedIcon: Icon(AppIcons.programs),
          label: 'Programs',
        ),
        NavigationDestination(
          icon: Icon(AppIcons.community),
          selectedIcon: Icon(AppIcons.community),
          label: 'Community',
        ),
        NavigationDestination(
          icon: Icon(AppIcons.profile),
          selectedIcon: Icon(AppIcons.profile),
          label: 'Profile',
        ),
      ],
    );
  }
}
