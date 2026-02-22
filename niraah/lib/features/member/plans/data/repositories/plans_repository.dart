import '../../../../../core/network/api_service.dart';
import '../../../../../shared/helpers/result.dart';

class PlansRepository {
  PlansRepository(this._apiService);

  final ApiService _apiService;

  Future<Result<List<String>>> fetchPlans() async {
    try {
      final response = await _apiService.plansApi.plansGet();
      return Success<List<String>>(<String>['Plans loaded', response.data.toString()]);
    } catch (error) {
      return FailureResult<List<String>>(error.toString());
    }
  }
}
