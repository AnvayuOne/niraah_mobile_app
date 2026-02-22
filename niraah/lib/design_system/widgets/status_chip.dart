import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.label,
    super.key,
    this.isHighlighted = false,
  });

  final String label;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlighted ? ColorTokens.primary.withValues(alpha: 0.12) : ColorTokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorTokens.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isHighlighted ? ColorTokens.primary : ColorTokens.text,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
