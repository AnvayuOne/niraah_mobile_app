import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../common/presentation/widgets/member_data_page_view.dart';
import '../bloc/symptoms_cubit.dart';

class SymptomsPage extends StatelessWidget {
  const SymptomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SymptomsCubit>(
      create: (_) => getIt<SymptomsCubit>()..load(),
      child: MemberDataPageView<SymptomsCubit>(
        title: 'Symptoms',
        onRefresh: () => context.read<SymptomsCubit>().load(),
        showScaffold: false,
      ),
    );
  }
}
