import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../common/presentation/widgets/member_data_page_view.dart';
import '../bloc/progress_cubit.dart';

class ProgressDashboardPage extends StatelessWidget {
  const ProgressDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProgressCubit>(
      create: (_) => getIt<ProgressCubit>()..load(),
      child: MemberDataPageView<ProgressCubit>(
        title: 'Progress Dashboard',
        onRefresh: () => context.read<ProgressCubit>().load(),
      ),
    );
  }
}
