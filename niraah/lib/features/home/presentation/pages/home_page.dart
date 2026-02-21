import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/state/bloc_state_builder.dart';
import '../../../../core/state/status.dart';
import '../../../../design_system/widgets/app_scaffold.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/post_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.bloc});

  final HomeBloc? bloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (_) => (bloc ?? getIt<HomeBloc>())..add(const HomeStarted()),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (BuildContext context, HomeState state) {
          return AppScaffold(
            title: 'Niraah Feed',
            body: BlocStateBuilder(
              status: state.status,
              errorMessage: state.message,
              onRetry: () => context.read<HomeBloc>().add(const HomeRefreshed()),
              successBuilder: () {
                if (state.status == Status.initial) {
                  return const SizedBox.shrink();
                }
                return RefreshIndicator(
                  onRefresh: () async => context.read<HomeBloc>().add(const HomeRefreshed()),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: state.posts.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int index) {
                      return PostTile(post: state.posts[index]);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
