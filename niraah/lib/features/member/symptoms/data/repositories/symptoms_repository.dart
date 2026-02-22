import '../../../../../core/network/api_service.dart';
import '../../../../../shared/helpers/result.dart';

class SymptomsRepository {
  SymptomsRepository(this._apiService);

  final ApiService _apiService;

  Future<Result<List<String>>> fetchSymptoms() async {
    try {
      final response = await _apiService.memberApi.memberSymptomsGet(limit: 10);
      return Success<List<String>>(<String>['Symptoms loaded', response.data.toString()]);
    } catch (error) {
      return FailureResult<List<String>>(error.toString());
    }
  }
}
