import '../../../../../core/network/api_service.dart';
import '../../../../../shared/helpers/result.dart';

class ProfileRepository {
  ProfileRepository(this._apiService);

  final ApiService _apiService;

  Future<Result<List<String>>> fetchProfile() async {
    try {
      final response = await _apiService.memberApi.memberProfileGet();
      return Success<List<String>>(<String>['Profile loaded', response.data.toString()]);
    } catch (error) {
      return FailureResult<List<String>>(error.toString());
    }
  }
}
