import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';
import 'status_chip.dart';

class HealthScoreCard extends StatelessWidget {
  const HealthScoreCard({
    required this.score,
    required this.riskBand,
    required this.bmiText,
    required this.attentionItems,
    super.key,
  });

  final int score;
  final String riskBand;
  final String bmiText;
  final List<String> attentionItems;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Your Health Score',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ColorTokens.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.width * 0.5,
                width: MediaQuery.of(context).size.width * 0.5,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox(
                height: MediaQuery.of(context).size.width * 0.4,
                width: MediaQuery.of(context).size.width * 0.4,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 16,
                        backgroundColor: ColorTokens.border,
                        color: ColorTokens.primary,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '$score',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: ColorTokens.text,
                              ),
                        ),
                        Text(
                          'OUT OF 100',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _MetricRow(
              title: 'Risk Band',
              trailing: StatusChip(label: riskBand, isHighlighted: true),
            ),
            const SizedBox(height: 10),
            _MetricRow(
              title: 'BMI',
              trailing: Text(
                bmiText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ATTENTION NEEDED',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ColorTokens.muted,
                    letterSpacing: 0.8,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: attentionItems
                  .map(
                    (String item) => StatusChip(
                      label: item,
                      isHighlighted: item == attentionItems.first,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.title,
    required this.trailing,
  });

  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: ColorTokens.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.bodyLarge),
          trailing,
        ],
      ),
    );
  }
}
