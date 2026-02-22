import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../common/presentation/widgets/member_data_page_view.dart';
import '../bloc/profile_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => getIt<ProfileCubit>()..load(),
      child: MemberDataPageView<ProfileCubit>(
        title: 'Profile',
        onRefresh: () => context.read<ProfileCubit>().load(),
        showScaffold: false,
      ),
    );
  }
}
