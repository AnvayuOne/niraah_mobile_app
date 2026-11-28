import 'package:material_ui/material_ui.dart';

import '../tokens/tokens.dart';

/// The Niraah theme, built only from generated tokens.
///
/// Light and dark: [NColors] switches palette, and this reads whichever is active.
class AppTheme {
  const AppTheme._();

  /// Kept for older call sites; same as [current].
  static ThemeData get lightTheme => current;

  static ThemeData get current {
    final ColorScheme scheme = (NColors.dark ? ColorScheme.dark : ColorScheme.light)(
      primary: NColors.actionPrimary,
      onPrimary: NColors.actionOnPrimary,
      primaryContainer: NColors.brandBlushLight,
      onPrimaryContainer: NColors.inkPrimary,
      secondary: NColors.brandTerracotta,
      onSecondary: NColors.inkOnBrand,
      surface: NColors.surfacePage,
      onSurface: NColors.inkPrimary,
      onSurfaceVariant: NColors.inkMuted,
      surfaceContainerLowest: NColors.surfaceCard,
      surfaceContainerLow: NColors.surfaceBackdrop,
      surfaceContainer: NColors.surfaceWarm,
      outline: NColors.lineStrong,
      outlineVariant: NColors.lineDefault,
      error: NColors.statusAttention,
      onError: NColors.actionOnPrimary,
      errorContainer: NColors.statusAttentionLight,
      onErrorContainer: NColors.statusAttention,
    );

    final TextTheme text = TextTheme(
      displayLarge: NType.display.copyWith(color: NColors.inkPrimary),
      displayMedium: NType.h1.copyWith(color: NColors.inkPrimary),
      displaySmall: NType.h2.copyWith(color: NColors.inkPrimary),
      headlineMedium: NType.h3.copyWith(color: NColors.inkPrimary),
      headlineSmall: NType.screenTitle.copyWith(color: NColors.inkPrimary),
      titleLarge: NType.h4.copyWith(color: NColors.inkPrimary),
      titleMedium: NType.bodyLg.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
      bodyLarge: NType.body.copyWith(color: NColors.inkSecondary),
      bodyMedium: NType.bodySm.copyWith(color: NColors.inkSecondary),
      labelLarge: NType.button,
      labelMedium: NType.label.copyWith(color: NColors.inkMuted),
      labelSmall: NType.caption.copyWith(color: NColors.inkMuted),
    );

    final RoundedRectangleBorder pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(NRadius.pill));
    const Size minButton = Size(NLayout.minTapTarget, NLayout.minTapTarget + NSpace.xs);

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(NRadius.md),
          borderSide: BorderSide(color: c, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: NColors.dark ? Brightness.dark : Brightness.light,
      fontFamily: NType.sansFamily,
      colorScheme: scheme,
      textTheme: text,
      scaffoldBackgroundColor: NColors.surfacePage,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: NColors.surfacePage,
        foregroundColor: NColors.inkPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: NColors.actionPrimary,
          foregroundColor: NColors.actionOnPrimary,
          disabledBackgroundColor: NColors.actionDisabled,
          disabledForegroundColor: NColors.actionOnDisabled,
          minimumSize: minButton,
          padding: const EdgeInsets.symmetric(horizontal: NSpace.lg, vertical: NSpace.md),
          textStyle: NType.button,
          shape: pill,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NColors.inkPrimary,
          backgroundColor: NColors.surfaceCard,
          minimumSize: minButton,
          padding: const EdgeInsets.symmetric(horizontal: NSpace.lg, vertical: NSpace.md),
          textStyle: NType.button,
          side: BorderSide(color: NColors.lineDefault),
          shape: pill,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NColors.actionLink,
          minimumSize: const Size(NLayout.minTapTarget, NLayout.minTapTarget),
          textStyle: NType.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NColors.surfaceInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: NSpace.md, vertical: NSpace.md),
        hintStyle: NType.body.copyWith(color: NColors.inkMuted),
        labelStyle: NType.bodySm.copyWith(color: NColors.inkSecondary),
        border: border(NColors.lineDefault),
        enabledBorder: border(NColors.lineDefault),
        focusedBorder: border(NColors.lineFocus, 2),
        errorBorder: border(NColors.statusAttention),
        focusedErrorBorder: border(NColors.statusAttention, 2),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) => s.contains(WidgetState.selected) ? NColors.actionPrimary : null,
        ),
        side: BorderSide(color: NColors.lineStrong, width: 2),
      ),
      dividerTheme: DividerThemeData(color: NColors.lineDefault, space: NSpace.lg),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: NColors.inkPrimary,
        contentTextStyle: NType.bodySm.copyWith(color: NColors.inkOnBrand),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
