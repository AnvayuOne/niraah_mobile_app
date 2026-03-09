import 'package:flutter/material.dart';

import '../../../../../../shared/config/app_content_config.dart';

class CommunityTabPage extends StatelessWidget {
  const CommunityTabPage({super.key});

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
                  AppContentConfig.communityTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  AppContentConfig.communitySubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'WhatsApp Group',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          'Doctor-led tips and peer support',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: FilledButton(
                                                onPressed: () {},
                                                child: const Text('Request Invite'),
                                              ),
                        ),
                      ],
                    ),
                    
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'In-app Group',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          'Coming soon — stay tuned',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Notify me'),
                    ),
                  ],
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
                  AppContentConfig.rewardsTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  AppContentConfig.rewardsSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                const Row(
                  children: <Widget>[
                    Expanded(child: _RewardTile(label: 'Points', value: '0')),
                    SizedBox(width: 8),
                    Expanded(child: _RewardTile(label: 'Streak', value: '0')),
                    SizedBox(width: 8),
                    Expanded(child: _RewardTile(label: 'Badges', value: '0')),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'How to earn',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                ...const <String>[
                  'Daily symptom or habit logs',
                  'Completing program tasks',
                  'Attending appointments',
                  'Helpful participation in community',
                ].map((String line) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '\u2022 $line',
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
