import 'package:flutter/material.dart';

import 'color_tokens.dart';

class TypographyTokens {
  const TypographyTokens._();

  static TextTheme textTheme() {
    const Color textColor = ColorTokens.text;
    const Color mutedColor = ColorTokens.muted;
    return TextTheme(
      displaySmall: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontSize: 38,
        height: 1.15,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: mutedColor,
      ),
      labelLarge: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ColorTokens.background,
      ),
    );
  }
}
