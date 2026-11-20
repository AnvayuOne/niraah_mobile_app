// Live check of AI Care chat against a running niraah-platform with AI on:
// LIVE_API=<base> LIVE_TOKEN=<access token> flutter test test/live/chat_live_test.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/auth/session_store.dart';
import 'package:niraah/core/network/niraah_api.dart';
import 'package:niraah/features/chat/data/api_chat_repository.dart';
import 'package:niraah/features/chat/domain/chat.dart';

final String? _base = Platform.environment['LIVE_API'];
final String? _token = Platform.environment['LIVE_TOKEN'];

void main() {
  test('chat: home, new conversation, a streamed answer', () async {
    final MemorySessionStore store = MemorySessionStore()..tokens = SessionTokens(accessToken: _token!, refreshToken: 'unused');
    final ApiChatRepository repo = ApiChatRepository(NiraahApi(dio: Dio(BaseOptions(baseUrl: _base!, receiveTimeout: const Duration(seconds: 120))), store: store));
    final ChatHome home = await repo.getHome();
    // ignore: avoid_print
    print('home: $home');
    final Conversation c = await repo.createConversation();
    final List<ChatEvent> events = await repo.send(c.id, 'What should I eat for PCOS?').toList();
    // ignore: avoid_print
    print(events.map((ChatEvent e) => e is ChatSentenceEvent ? e.sentence.text : e.runtimeType.toString()).join('\n'));
    expect(events.last, isA<ChatDoneEvent>());
  }, timeout: const Timeout(Duration(minutes: 3)), skip: _base == null || _token == null ? 'set LIVE_API and LIVE_TOKEN' : false);
}
