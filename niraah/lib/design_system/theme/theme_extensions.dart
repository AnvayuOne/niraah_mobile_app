import 'package:flutter/material.dart';

class AppSemantics extends ThemeExtension<AppSemantics> {
  const AppSemantics({
    required this.success,
    required this.warning,
    required this.cardBackground,
  });

  final Color success;
  final Color warning;
  final Color cardBackground;

  @override
  AppSemantics copyWith({
    Color? success,
    Color? warning,
    Color? cardBackground,
  }) {
    return AppSemantics(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      cardBackground: cardBackground ?? this.cardBackground,
    );
  }

  @override
  ThemeExtension<AppSemantics> lerp(covariant ThemeExtension<AppSemantics>? other, double t) {
    if (other is! AppSemantics) {
      return this;
    }
    return AppSemantics(
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t) ?? cardBackground,
    );
  }
}
