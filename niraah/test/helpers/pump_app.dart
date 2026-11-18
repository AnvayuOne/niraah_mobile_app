import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/design_system/theme/app_theme.dart';
import 'package:niraah/l10n/app_localizations.dart';

/// Wraps [child] in the app theme and English strings.
Widget wrapApp(Widget child, {bool reducedMotion = false, Size size = const Size(390, 844)}) {
  return MediaQuery(
    data: MediaQueryData(size: size, disableAnimations: reducedMotion),
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      home: child,
    ),
  );
}

extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget child, {bool reducedMotion = false}) async {
    await pumpWidget(wrapApp(child, reducedMotion: reducedMotion));
    await pump();
  }
}
