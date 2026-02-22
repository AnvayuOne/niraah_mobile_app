import 'package:flutter/material.dart';

import '../../../../../../shared/config/app_static_data_config.dart';

class ProgramsTabPage extends StatelessWidget {
  const ProgramsTabPage({super.key});

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
                  'Your Programs',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Access structured programs tailored to you.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                ...AppStaticDataConfig.programs.map(
                  (StaticProgram program) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              program.title,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(program.subtitle, style: Theme.of(context).textTheme.bodyLarge),
                            const SizedBox(height: 10),
                            FilledButton(
                              onPressed: () {},
                              child: Text(program.actionLabel),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
