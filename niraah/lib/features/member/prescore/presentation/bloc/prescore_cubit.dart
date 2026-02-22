import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/state/status.dart';
import '../../../../../shared/helpers/result.dart';
import '../../../common/presentation/bloc/member_data_state.dart';
import '../../data/repositories/prescore_repository.dart';

class PrescoreCubit extends Cubit<MemberDataState> {
  PrescoreCubit(this._repository) : super(const MemberDataState(title: 'Prescore'));

  final PrescoreRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: Status.loading, message: null));
    final Result<List<String>> result = await _repository.fetchPrescore();
    result.when(
      success: (List<String> data) =>
          emit(state.copyWith(status: Status.success, payload: data, title: 'Prescore')),
      failure: (String message) => emit(state.copyWith(status: Status.failure, message: message)),
    );
  }
}
