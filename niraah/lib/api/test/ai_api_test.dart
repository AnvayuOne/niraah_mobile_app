import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for AIApi
void main() {
  final instance = Openapi().getAIApi();

  group(AIApi, () {
    // Chat with Niraah AI
    //
    // Send messages to AI chatbot for health guidance and platform information
    //
    //Future<AiChatPost200Response> aiChatPost(AiChatPostRequest aiChatPostRequest) async
    test('test aiChatPost', () async {
      // TODO
    });

  });
}
