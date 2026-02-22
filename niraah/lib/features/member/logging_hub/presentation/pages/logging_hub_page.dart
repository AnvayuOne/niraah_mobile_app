import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../design_system/widgets/app_button.dart';
import '../../../../../design_system/widgets/app_scaffold.dart';
import '../../../../../shared/constants/route_constants.dart';

class LoggingHubPage extends StatelessWidget {
  const LoggingHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Logging Hub',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'Track your health data daily',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Log Symptoms',
            onPressed: () => context.go(RouteConstants.symptoms),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Upload Medical Record',
            onPressed: () => context.go(RouteConstants.records),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Open AI Chat',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go(RouteConstants.chatAi),
          ),
          const SizedBox(height: 12),
          const ListTile(
            title: Text(
              'Meal logging and cycle logging will be enhanced as APIs become available.',
            ),
          ),
        ],
      ),
    );
  }
}
