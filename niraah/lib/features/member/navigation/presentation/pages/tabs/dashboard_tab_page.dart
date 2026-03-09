import 'package:flutter/material.dart';

import '../../../../../../design_system/icons/app_icons.dart';
import '../../../../../../design_system/tokens/color_tokens.dart';
import '../../../../../../design_system/widgets/health_score_card.dart';
import '../../../../../../shared/config/app_content_config.dart';
import '../../../../../../shared/config/app_static_data_config.dart';

class DashboardTabPage extends StatelessWidget {
  const DashboardTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: <Widget>[
        Text(
          AppContentConfig.homeGreeting,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          DateTime.now().toString(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            _PillAction(label: 'Log Symptom'),
            const SizedBox(width: 8),
            _PillAction(label: 'Book Appointment'),
          ],
        ),
        const SizedBox(height: 14),
        HealthScoreCard(
          score: AppStaticDataConfig.healthScore,
          riskBand: AppStaticDataConfig.riskBand,
          bmiText: AppStaticDataConfig.bmi,
          attentionItems: AppStaticDataConfig.attentionNeeded,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Insights',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: ColorTokens.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                ...AppStaticDataConfig.insights.map(
                  (String insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '\u2022 $insight',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ColorTokens.text,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _StatCard(
          title: 'Current Streak',
          value: '0',
          subtitle: 'days',
          footer: 'You\'re doing great! Keep it up.',
        ),
        const SizedBox(height: 10),
        const _StatCard(
          title: 'Plan Adherence',
          value: '14%',
          subtitle: '',
          footer: 'Based on your last 7 days activity.',
        ),
      ],
    );
  }
}

class _PillAction extends StatelessWidget {
  const _PillAction({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: ColorTokens.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(AppIcons.plus, size: 12, color: ColorTokens.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ColorTokens.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.footer,
  });

  final String title;
  final String value;
  final String subtitle;
  final String footer;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: const LinearProgressIndicator(
                value: 0.3,
                minHeight: 6,
                color: ColorTokens.primary,
                backgroundColor: ColorTokens.border,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              footer,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
