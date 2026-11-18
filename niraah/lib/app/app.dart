import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/di/service_locator.dart';
import '../design_system/theme/app_theme.dart';
import '../features/assessment/domain/assessment_repository.dart';
import '../features/assessment/presentation/assessment_cubit.dart';
import '../l10n/app_localizations.dart';
import 'app_router.dart';

class NiraahApp extends StatefulWidget {
  const NiraahApp({super.key, this.initialLocation});

  /// For tests and screenshots.
  final String? initialLocation;

  @override
  State<NiraahApp> createState() => _NiraahAppState();
}

class _NiraahAppState extends State<NiraahApp> {
  late final GoRouter _router = widget.initialLocation == null ? AppRouter.create() : AppRouter.create(initialLocation: widget.initialLocation!);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AssessmentCubit>(
      create: (_) => AssessmentCubit(getIt<AssessmentRepository>()),
      child: MaterialApp.router(
        onGenerateTitle: (BuildContext context) => S.of(context).appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        routerConfig: _router,
      ),
    );
  }
}
