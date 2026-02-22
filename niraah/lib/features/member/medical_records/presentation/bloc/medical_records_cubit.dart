import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/state/status.dart';
import '../../../../../shared/helpers/result.dart';
import '../../../common/presentation/bloc/member_data_state.dart';
import '../../data/repositories/medical_records_repository.dart';

class MedicalRecordsCubit extends Cubit<MemberDataState> {
  MedicalRecordsCubit(this._repository) : super(const MemberDataState(title: 'Medical Records'));

  final MedicalRecordsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: Status.loading, message: null));
    final Result<List<String>> result = await _repository.fetchRecords();
    result.when(
      success: (List<String> data) =>
          emit(state.copyWith(status: Status.success, payload: data, title: 'Medical Records')),
      failure: (String message) => emit(state.copyWith(status: Status.failure, message: message)),
    );
  }
}
