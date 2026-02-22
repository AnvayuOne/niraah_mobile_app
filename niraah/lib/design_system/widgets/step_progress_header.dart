import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';

class StepProgressHeader extends StatelessWidget {
  const StepProgressHeader({
    required this.currentStep,
    required this.totalSteps,
    super.key,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final double progress = totalSteps == 0 ? 0 : currentStep / totalSteps;
    final int percent = (progress * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Question $currentStep of $totalSteps',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ColorTokens.text,
                  ),
            ),
            Text(
              '$percent%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ColorTokens.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: ColorTokens.border,
            valueColor: const AlwaysStoppedAnimation<Color>(ColorTokens.primary),
          ),
        ),
      ],
    );
  }
}
