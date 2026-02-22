import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../common/presentation/widgets/member_data_page_view.dart';
import '../bloc/medical_records_cubit.dart';

class MedicalRecordsPage extends StatelessWidget {
  const MedicalRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MedicalRecordsCubit>(
      create: (_) => getIt<MedicalRecordsCubit>()..load(),
      child: MemberDataPageView<MedicalRecordsCubit>(
        title: 'Medical Records',
        onRefresh: () => context.read<MedicalRecordsCubit>().load(),
      ),
    );
  }
}
