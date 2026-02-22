import 'package:flutter/material.dart';

class AppSemantics extends ThemeExtension<AppSemantics> {
  const AppSemantics({
    required this.success,
    required this.cardBackground,
    required this.border,
    required this.mutedText,
    required this.accent,
  });

  final Color success;
  final Color cardBackground;
  final Color border;
  final Color mutedText;
  final Color accent;

  @override
  AppSemantics copyWith({
    Color? success,
    Color? cardBackground,
    Color? border,
    Color? mutedText,
    Color? accent,
  }) {
    return AppSemantics(
      success: success ?? this.success,
      cardBackground: cardBackground ?? this.cardBackground,
      border: border ?? this.border,
      mutedText: mutedText ?? this.mutedText,
      accent: accent ?? this.accent,
    );
  }

  @override
  ThemeExtension<AppSemantics> lerp(covariant ThemeExtension<AppSemantics>? other, double t) {
    if (other is! AppSemantics) {
      return this;
    }
    return AppSemantics(
      success: Color.lerp(success, other.success, t) ?? success,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t) ?? cardBackground,
      border: Color.lerp(border, other.border, t) ?? border,
      mutedText: Color.lerp(mutedText, other.mutedText, t) ?? mutedText,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
    );
  }
}
