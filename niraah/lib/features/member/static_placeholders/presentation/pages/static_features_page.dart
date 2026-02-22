import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../design_system/widgets/app_scaffold.dart';
import '../bloc/static_feature_cubit.dart';
import '../bloc/static_feature_state.dart';

class StaticFeaturesPage extends StatelessWidget {
  const StaticFeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StaticFeatureCubit>(
      create: (_) => StaticFeatureCubit(),
      child: BlocBuilder<StaticFeatureCubit, StaticFeatureState>(
        builder: (BuildContext context, StaticFeatureState state) {
          return AppScaffold(
            title: 'Static Features',
            body: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int index) => ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(state.items[index]),
                subtitle: const Text('Coming soon'),
              ),
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 8),
              itemCount: state.items.length,
            ),
          );
        },
      ),
    );
  }
}
