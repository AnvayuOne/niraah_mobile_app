import 'package:flutter/material.dart';

class TypographyTokens {
  const TypographyTokens._();

  static TextTheme textTheme(Brightness brightness) {
    final Color textColor =
        brightness == Brightness.light ? const Color(0xFF1A1E2A) : const Color(0xFFEAEFFF);
    return TextTheme(
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
    );
  }
}
