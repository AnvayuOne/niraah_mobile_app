import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design_system/theme/app_theme.dart';
import 'app_router.dart';

class NiraahApp extends StatelessWidget {
  const NiraahApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = AppRouter.router;
    return MaterialApp.router(
      title: 'Niraah',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
