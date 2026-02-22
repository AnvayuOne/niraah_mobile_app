import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../tokens/color_tokens.dart';
import '../tokens/elevation_tokens.dart';
import '../tokens/radius_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'theme_extensions.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    const ColorScheme scheme = ColorScheme(
      brightness: Brightness.light,
      primary: ColorTokens.primary,
      onPrimary: ColorTokens.background,
      secondary: ColorTokens.accent,
      onSecondary: ColorTokens.background,
      error: ColorTokens.error,
      onError: ColorTokens.background,
      surface: ColorTokens.surface,
      onSurface: ColorTokens.text,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ColorTokens.background,
      textTheme: GoogleFonts.latoTextTheme(TypographyTokens.textTheme()),
      extensions: const <ThemeExtension<dynamic>>[
        AppSemantics(
          success: ColorTokens.success,
          cardBackground: ColorTokens.surface,
          border: ColorTokens.border,
          mutedText: ColorTokens.muted,
          accent: ColorTokens.accent,
        ),
      ],
      cardTheme: CardThemeData(
        elevation: ElevationTokens.sm,
        color: ColorTokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
          side: const BorderSide(color: ColorTokens.border),
        ),
      ),
      dividerColor: ColorTokens.border,
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorTokens.background,
        foregroundColor: ColorTokens.text,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ColorTokens.primary,
          foregroundColor: ColorTokens.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.xl),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorTokens.text,
          side: const BorderSide(color: ColorTokens.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.xl),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorTokens.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: ColorTokens.muted),
        hintStyle: const TextStyle(color: ColorTokens.muted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
          borderSide: const BorderSide(color: ColorTokens.border),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
          borderSide: const BorderSide(color: ColorTokens.primary),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return lightTheme;
  }
}
