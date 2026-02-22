import '../../../../../core/network/api_service.dart';
import '../../../../../shared/helpers/result.dart';

class ProgressRepository {
  ProgressRepository(this._apiService);

  final ApiService _apiService;

  Future<Result<List<String>>> fetchProgressSnapshot() async {
    try {
      final response = await _apiService.memberApi.memberSummaryGet();
      return Success<List<String>>(<String>[
        'Progress snapshot loaded',
        response.data.toString(),
      ]);
    } catch (error) {
      return FailureResult<List<String>>(error.toString());
    }
  }
}
