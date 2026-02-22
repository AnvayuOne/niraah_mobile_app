import 'package:flutter/material.dart';

enum AppButtonVariant {
  primary,
  secondary,
}

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final Widget content = isLoading
        ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);

    if (variant == AppButtonVariant.secondary) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: content,
      );
    }

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: content,
    );
  }
}
