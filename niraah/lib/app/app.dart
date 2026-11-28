import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/di/service_locator.dart';
import '../design_system/theme/app_theme.dart';
import '../design_system/theme/theme_controller.dart';
import '../design_system/tokens/tokens.dart';
import '../design_system/widgets/n_appearance.dart';
import '../design_system/widgets/n_responsive.dart';
import '../features/assessment/domain/assessment_repository.dart';
import '../features/assessment/presentation/assessment_cubit.dart';
import '../l10n/app_localizations.dart';
import '../shared/constants/route_constants.dart';
import 'app_router.dart';

class NiraahApp extends StatefulWidget {
  const NiraahApp({super.key, this.initialLocation});

  /// For tests and screenshots.
  final String? initialLocation;

  @override
  State<NiraahApp> createState() => _NiraahAppState();
}

class _NiraahAppState extends State<NiraahApp> with WidgetsBindingObserver {
  /// Routes that lay themselves out for wide screens.
  static const Set<String> _fullWidth = <String>{RouteConstants.landing};

  late final GoRouter _router = widget.initialLocation == null ? AppRouter.create() : AppRouter.create(initialLocation: widget.initialLocation!);

  /// Whether the current route sits in the app column. Updated after the frame in
  /// which the route changed, never during a build.
  final ValueNotifier<bool> _framed = ValueNotifier<bool>(true);

  /// The member's five main screens, which carry the light/dark switch at the top. Expert workspaces have it in
  /// their top bar instead.
  static const Set<String> _withThemeToggle = <String>{
    RouteConstants.home,
    RouteConstants.cycle,
    RouteConstants.chat,
    RouteConstants.practice,
    RouteConstants.me,
  };

  /// Whether the current route shows the light/dark switch.
  final ValueNotifier<bool> _toggle = ValueNotifier<bool>(false);

  void _onRoute() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    final String path = _router.routerDelegate.currentConfiguration.uri.path;
    _framed.value = !_fullWidth.contains(path);
    _toggle.value = NThemeController.darkModeEnabled && _withThemeToggle.contains(path);
  });

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NThemeController.instance.addListener(_onTheme);
    _router.routerDelegate.addListener(_onRoute);
    _onRoute();
  }

  /// The phone switched between light and dark (only matters when following the phone).
  @override
  void didChangePlatformBrightness() => _onTheme();

  void _onTheme() {
    if (mounted) setState(() {});
  }

  bool get _dark => NThemeController.darkModeEnabled && switch (NThemeController.instance.value) {
        ThemeMode.dark => true,
        ThemeMode.light => false,
        ThemeMode.system => WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark,
      };

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NThemeController.instance.removeListener(_onTheme);
    _router.routerDelegate.removeListener(_onRoute);
    _framed.dispose();
    _toggle.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = _dark;
    // Widgets read NColors directly, so the palette flips before anything builds and the screens below
    // are rebuilt from scratch (the KeyedSubtree) when it changes.
    NColors.dark = dark;
    return BlocProvider<AssessmentCubit>(
      create: (_) => AssessmentCubit(getIt<AssessmentRepository>()),
      child: MaterialApp.router(
        onGenerateTitle: (BuildContext context) => S.of(context).appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.current,
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        routerConfig: _router,
        // One responsive rule for every screen: phones as designed, larger screens in a
        // centered app column. The landing page has its own wide layout.
        builder: (BuildContext context, Widget? child) => ValueListenableBuilder<bool>(
          valueListenable: _framed,
          builder: (BuildContext context, bool framed, _) => AnnotatedRegion<SystemUiOverlayStyle>(
            value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            child: KeyedSubtree(
              key: ValueKey<bool>(dark),
              child: ColoredBox(
                color: NColors.surfacePage,
                child: NResponsiveFrame(
                  enabled: framed,
                  // On the member's main screens the light/dark switch gets its own row at the very top, so it
                  // never covers a heading; the screen below starts under it.
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _toggle,
                    builder: (BuildContext context, bool show, _) {
                      // Always the same two children, so the screens below keep their state when the row comes and goes.
                      return Column(
                        children: <Widget>[
                          if (show)
                            SafeArea(
                              bottom: false,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, 0),
                                child: const Align(alignment: Alignment.centerRight, child: NThemeToggle()),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          Expanded(child: MediaQuery.removePadding(context: context, removeTop: show, child: child ?? const SizedBox.shrink())),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
