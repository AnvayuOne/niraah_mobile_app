import '../../../../../core/network/api_service.dart';
import '../../../../../shared/helpers/result.dart';

class MemberHomeRepository {
  MemberHomeRepository(this._apiService);

  final ApiService _apiService;

  Future<Result<List<String>>> fetchSummary() async {
    try {
      final response = await _apiService.memberApi.memberSummaryGet();
      return Success<List<String>>(<String>[
        'Today summary loaded',
        response.data.toString(),
      ]);
    } catch (error) {
      return FailureResult<List<String>>(error.toString());
    }
  }
}
