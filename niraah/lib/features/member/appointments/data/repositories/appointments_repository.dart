import '../../../../../core/network/api_service.dart';
import '../../../../../shared/helpers/result.dart';

class AppointmentsRepository {
  AppointmentsRepository(this._apiService);

  final ApiService _apiService;

  Future<Result<List<String>>> fetchAppointments() async {
    try {
      final response = await _apiService.memberApi.memberAppointmentsGet();
      return Success<List<String>>(<String>[
        'Appointments loaded',
        response.data.toString(),
      ]);
    } catch (error) {
      return FailureResult<List<String>>(error.toString());
    }
  }
}
