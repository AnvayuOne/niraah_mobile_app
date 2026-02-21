import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';
import '../tokens/elevation_tokens.dart';
import '../tokens/radius_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'theme_extensions.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: ColorTokens.brand,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(error: ColorTokens.error),
      scaffoldBackgroundColor: ColorTokens.lightBackground,
      textTheme: TypographyTokens.textTheme(Brightness.light),
      extensions: const <ThemeExtension<dynamic>>[
        AppSemantics(
          success: ColorTokens.success,
          warning: ColorTokens.warning,
          cardBackground: Colors.white,
        ),
      ],
      cardTheme: CardThemeData(
        elevation: ElevationTokens.sm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: ColorTokens.brandDark,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(error: ColorTokens.error),
      scaffoldBackgroundColor: ColorTokens.darkBackground,
      textTheme: TypographyTokens.textTheme(Brightness.dark),
      extensions: const <ThemeExtension<dynamic>>[
        AppSemantics(
          success: ColorTokens.success,
          warning: ColorTokens.warning,
          cardBackground: Color(0xFF171A2B),
        ),
      ],
      cardTheme: CardThemeData(
        elevation: ElevationTokens.none,
        color: const Color(0xFF171A2B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
      ),
    );
  }
}
