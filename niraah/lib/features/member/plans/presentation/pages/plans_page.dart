import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../design_system/widgets/app_button.dart';
import '../../../../../design_system/widgets/app_scaffold.dart';
import '../../../../../design_system/widgets/brand_logo_header.dart';
import '../../../../../design_system/widgets/status_chip.dart';
import '../../../../../shared/constants/route_constants.dart';

class PlansPage extends StatelessWidget {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const BrandLogoHeader(showMenu: true),
            const SizedBox(height: 14),
            Text(
              'Program Selection',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Based on your questionnaire, these plans can help your goals.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _PlanCard(
              title: 'Metabolic Balance Program',
              subtitle: '8 weeks • Nutrition + activity guidance',
              badges: const <String>['Recommended', 'Beginner Friendly'],
            ),
            const SizedBox(height: 12),
            _PlanCard(
              title: 'Cycle Support Program',
              subtitle: '6 weeks • Symptom-led interventions',
              badges: const <String>['Hormonal Health'],
            ),
            const SizedBox(height: 12),
            _PlanCard(
              title: 'Weight & Energy Program',
              subtitle: '10 weeks • Structured habits',
              badges: const <String>['Fatigue Support'],
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Continue to Home',
              onPressed: () => context.go(RouteConstants.memberHome),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.badges,
  });

  final String title;
  final String subtitle;
  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18)),
            const SizedBox(height: 6),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: badges.map((String e) => StatusChip(label: e, isHighlighted: true)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
