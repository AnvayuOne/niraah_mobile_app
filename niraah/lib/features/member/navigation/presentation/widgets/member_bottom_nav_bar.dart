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
      labelTextStyle: WidgetStateProperty.all(TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),

      // unselectedLabelTextStyle: WidgetStateProperty.all(TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(AppIcons.dashboard,color: ColorTokens.muted, size: 14,),
          selectedIcon: Icon(AppIcons.dashboard,color: ColorTokens.primary, size: 16),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(AppIcons.care,color: ColorTokens.muted, size: 14,),
          selectedIcon: Icon(AppIcons.care, color: ColorTokens.primary, size: 16),
          label: 'Care',
        ),
        NavigationDestination(
          icon: Icon(AppIcons.programs,color: ColorTokens.muted, size: 14,),
          selectedIcon: Icon(AppIcons.programs,color: ColorTokens.primary, size: 16),
          label: 'Programs',
        ),
        NavigationDestination(
          icon: Icon(AppIcons.community,color: ColorTokens.muted, size: 14,),
          selectedIcon: Icon(AppIcons.community,color: ColorTokens.primary, size: 16),
          label: 'Community',
        ),
        NavigationDestination(
          icon: Icon(AppIcons.profile,color: ColorTokens.muted, size: 14,),
          selectedIcon: Icon(AppIcons.profile,color: ColorTokens.primary, size: 16),
          label: 'Profile',
        ),
      ],
    );
  }
}
