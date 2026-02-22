import 'package:built_value/json_object.dart';

import '../../../../../core/network/api_service.dart';
import '../../../../../shared/helpers/result.dart';

class QuestionnaireRepository {
  QuestionnaireRepository(this._apiService);

  final ApiService _apiService;

  Future<Result<List<String>>> submitSampleQuestionnaire() async {
    try {
      final response = await _apiService.memberApi.memberQuestionnaireSubmitPost(
        body: JsonObject(<String, dynamic>{
          'sleepHours': 7,
          'stressLevel': 3,
          'cycleRegular': false,
        }),
      );
      return Success<List<String>>(<String>[
        'Questionnaire submitted',
        response.data.toString(),
      ]);
    } catch (error) {
      return FailureResult<List<String>>(error.toString());
    }
  }
}
