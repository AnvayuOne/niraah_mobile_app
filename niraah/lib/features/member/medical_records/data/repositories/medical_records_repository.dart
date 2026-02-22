import '../../../../../core/network/api_service.dart';
import '../../../../../shared/helpers/result.dart';

class MedicalRecordsRepository {
  MedicalRecordsRepository(this._apiService);

  final ApiService _apiService;

  Future<Result<List<String>>> fetchRecords() async {
    try {
      final response = await _apiService.memberApi.memberTestsGet();
      return Success<List<String>>(<String>[
        'Medical records loaded',
        response.data.toString(),
      ]);
    } catch (error) {
      return FailureResult<List<String>>(error.toString());
    }
  }
}
