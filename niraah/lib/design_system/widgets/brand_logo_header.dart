import 'package:flutter/material.dart';
import 'package:niraah/shared/constants/asset_constants.dart';

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
        Image.asset('assets/logo/niraah_mono.png'),
        // if (showMenu)
        //   IconButton(
        //     onPressed: onMenuTap,
        //     icon: const Icon(AppIcons.menu, color: ColorTokens.text, size: 20),
        //   ),
      ],
    );
  }
}
