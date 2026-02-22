import 'package:flutter/material.dart';

import '../../../../../../design_system/icons/app_icons.dart';
import '../../../../../../design_system/tokens/color_tokens.dart';
import '../../../../../../shared/config/app_content_config.dart';
import '../../../../../../shared/config/app_static_data_config.dart';

class CareTabPage extends StatelessWidget {
  const CareTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppContentConfig.symptomTrackerTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  AppContentConfig.symptomTrackerSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                const _InputLike(label: 'Symptom', hint: 'e.g. cramps, fatigue'),
                const SizedBox(height: 10),
                const _InputLike(label: 'Intensity', hint: 'Mild'),
                const SizedBox(height: 10),
                const _InputLike(label: 'Notes', hint: 'Optional details', maxLines: 3),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(AppIcons.plus, size: 14),
                  label: const Text('Add Entry'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Recent Entries',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                ...AppStaticDataConfig.recentSymptoms.map(
                  (StaticSymptomEntry entry) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorTokens.backgroundAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorTokens.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(entry.title, style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 3),
                        Text(
                          '${entry.date} • ${entry.severity}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppContentConfig.appointmentsTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  AppContentConfig.appointmentsSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppContentConfig.wellnessTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  AppContentConfig.wellnessSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InputLike extends StatelessWidget {
  const _InputLike({
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
