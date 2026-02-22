import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/state/status.dart';
import '../../../../../shared/helpers/result.dart';
import '../../../common/presentation/bloc/member_data_state.dart';
import '../../data/repositories/member_home_repository.dart';

class MemberHomeCubit extends Cubit<MemberDataState> {
  MemberHomeCubit(this._repository) : super(const MemberDataState(title: 'Member Home'));

  final MemberHomeRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: Status.loading, message: null));
    final Result<List<String>> result = await _repository.fetchSummary();
    result.when(
      success: (List<String> data) =>
          emit(state.copyWith(status: Status.success, payload: data, title: 'Member Home')),
      failure: (String message) => emit(state.copyWith(status: Status.failure, message: message)),
    );
  }
}
