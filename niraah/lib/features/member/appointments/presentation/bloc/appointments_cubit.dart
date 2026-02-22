import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/state/status.dart';
import '../../../../../shared/helpers/result.dart';
import '../../../common/presentation/bloc/member_data_state.dart';
import '../../data/repositories/appointments_repository.dart';

class AppointmentsCubit extends Cubit<MemberDataState> {
  AppointmentsCubit(this._repository) : super(const MemberDataState(title: 'Appointments'));

  final AppointmentsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: Status.loading, message: null));
    final Result<List<String>> result = await _repository.fetchAppointments();
    result.when(
      success: (List<String> data) =>
          emit(state.copyWith(status: Status.success, payload: data, title: 'Appointments')),
      failure: (String message) => emit(state.copyWith(status: Status.failure, message: message)),
    );
  }
}
