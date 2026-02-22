import 'package:built_collection/built_collection.dart';
import 'package:openapi/openapi.dart';

import '../../../../../core/network/api_service.dart';
import '../../../../../shared/helpers/result.dart';

class ChatAiRepository {
  ChatAiRepository(this._apiService);

  final ApiService _apiService;

  Future<Result<List<String>>> sendPrompt(String prompt) async {
    try {
      final AiChatPostRequestMessagesInner message = AiChatPostRequestMessagesInner(
        (AiChatPostRequestMessagesInnerBuilder b) => b
          ..role = AiChatPostRequestMessagesInnerRoleEnum.user
          ..content = prompt,
      );
      final AiChatPostRequest request = AiChatPostRequest(
        (AiChatPostRequestBuilder b) => b
          ..messages = ListBuilder<AiChatPostRequestMessagesInner>(<AiChatPostRequestMessagesInner>[
            message,
          ])
          ..isGuest = false,
      );
      final response = await _apiService.aiApi.aiChatPost(aiChatPostRequest: request);
      return Success<List<String>>(<String>[
        'AI response received',
        response.data.toString(),
      ]);
    } catch (error) {
      return FailureResult<List<String>>(error.toString());
    }
  }
}
