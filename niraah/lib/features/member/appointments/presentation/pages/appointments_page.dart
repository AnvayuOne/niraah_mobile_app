import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../common/presentation/widgets/member_data_page_view.dart';
import '../bloc/appointments_cubit.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppointmentsCubit>(
      create: (_) => getIt<AppointmentsCubit>()..load(),
      child: MemberDataPageView<AppointmentsCubit>(
        title: 'Appointments',
        onRefresh: () => context.read<AppointmentsCubit>().load(),
        showScaffold: false,
      ),
    );
  }
}
