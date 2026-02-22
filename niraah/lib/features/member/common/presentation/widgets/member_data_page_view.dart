import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/state/bloc_state_builder.dart';
import '../../../../../core/state/status.dart';
import '../../../../../design_system/widgets/app_scaffold.dart';
import '../bloc/member_data_state.dart';

class MemberDataPageView<TCubit extends Cubit<MemberDataState>> extends StatelessWidget {
  const MemberDataPageView({
    required this.title,
    required this.onRefresh,
    super.key,
    this.showScaffold = true,
  });

  final String title;
  final VoidCallback onRefresh;
  final bool showScaffold;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TCubit, MemberDataState>(
      builder: (BuildContext context, MemberDataState state) {
        final Widget content = BlocStateBuilder(
          status: state.status,
          errorMessage: state.message,
          onRetry: onRefresh,
          successBuilder: () {
            if (state.status == Status.initial) {
              return const SizedBox.shrink();
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Live data and updates from your care plan.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                ...state.payload.map(
                  (String value) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(value),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );

        if (!showScaffold) {
          return content;
        }

        return AppScaffold(
          title: title,
          actions: <Widget>[
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
          body: content,
        );
      },
    );
  }
}
