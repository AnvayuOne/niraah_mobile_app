import 'package:flutter/material.dart';

import '../icons/app_icons.dart';
import '../tokens/color_tokens.dart';

class BrandLogoHeader extends StatelessWidget {
  const BrandLogoHeader({
    super.key,
    this.showMenu = false,
    this.onMenuTap,
  });

  final bool showMenu;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const CircleAvatar(
          radius: 18,
          backgroundColor: ColorTokens.surface,
          child: Icon(Icons.spa, color: ColorTokens.primary, size: 20),
        ),
        if (showMenu)
          IconButton(
            onPressed: onMenuTap,
            icon: const Icon(AppIcons.menu, color: ColorTokens.text, size: 20),
          ),
      ],
    );
  }
}
