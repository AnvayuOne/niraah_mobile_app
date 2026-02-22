import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/state/status.dart';
import '../../../../../shared/helpers/result.dart';
import '../../../common/presentation/bloc/member_data_state.dart';
import '../../data/repositories/progress_repository.dart';

class ProgressCubit extends Cubit<MemberDataState> {
  ProgressCubit(this._repository) : super(const MemberDataState(title: 'Progress Dashboard'));

  final ProgressRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: Status.loading, message: null));
    final Result<List<String>> result = await _repository.fetchProgressSnapshot();
    result.when(
      success: (List<String> data) => emit(
        state.copyWith(
          status: Status.success,
          payload: data,
          title: 'Progress Dashboard',
        ),
      ),
      failure: (String message) => emit(state.copyWith(status: Status.failure, message: message)),
    );
  }
}
