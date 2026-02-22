import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../common/presentation/widgets/member_data_page_view.dart';
import '../bloc/prescore_cubit.dart';

class PrescorePage extends StatelessWidget {
  const PrescorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PrescoreCubit>(
      create: (_) => getIt<PrescoreCubit>()..load(),
      child: MemberDataPageView<PrescoreCubit>(
        title: 'Prescore',
        onRefresh: () => context.read<PrescoreCubit>().load(),
      ),
    );
  }
}
