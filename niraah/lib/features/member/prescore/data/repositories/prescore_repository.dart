import '../../../../../core/network/api_service.dart';
import '../../../../../shared/helpers/result.dart';

class PrescoreRepository {
  PrescoreRepository(this._apiService);

  final ApiService _apiService;

  Future<Result<List<String>>> fetchPrescore() async {
    try {
      final response = await _apiService.memberApi.memberAiPrescoreGet();
      return Success<List<String>>(<String>['AI prescore loaded', response.data.toString()]);
    } catch (error) {
      return FailureResult<List<String>>(error.toString());
    }
  }
}
