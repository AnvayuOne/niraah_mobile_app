import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';

class SectionTabChip extends StatelessWidget {
  const SectionTabChip({
    required this.label,
    super.key,
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ColorTokens.primary.withValues(alpha: 0.12) : ColorTokens.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? ColorTokens.primary : ColorTokens.border,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isSelected ? ColorTokens.primary : ColorTokens.text,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
