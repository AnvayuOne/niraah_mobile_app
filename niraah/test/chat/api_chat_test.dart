import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/features/chat/data/api_chat_repository.dart';
import 'package:niraah/features/chat/domain/chat.dart';

String frame(Map<String, dynamic> e) => 'event: ${e['type']}\ndata: ${jsonEncode(e)}\n\n';

void main() {
  test('keeps the medical-advice line as the last sentence (spec 009 AC28)', () {
    final List<CitedSentence> s = ApiChatRepository.sentences('Warm compresses can ease cramps. Rest helps.\n\nAI insights do not replace medical advice.');
    expect(s.map((CitedSentence x) => x.text), <String>['Warm compresses can ease cramps.', 'Rest helps.', 'AI insights do not replace medical advice.']);
  });

  test('groups cited passages by document for the source viewer', () {
    final List<ChatSource> s = ApiChatRepository.sources(<dynamic>[
      <String, dynamic>{'passageId': 'p1', 'title': 'Pain', 'publisher': 'FOGSI'},
      <String, dynamic>{'passageId': 'p2', 'title': 'Pain', 'publisher': 'FOGSI'},
    ]);
    expect(s.single.passageIds, <String>['p1', 'p2']);
    expect(s.single.title, 'Pain');
  });

  test('a safety message becomes a card with helplines and the no-alert note (spec 010 §8.4)', () {
    final SafetyCard c = ApiChatRepository.card(<String, dynamic>{'kind': 'self_harm', 'text': 'Please reach out now.', 'note': 'Niraah does not send this to a doctor on your plan.', 'actions': <String>['helplines']});
    expect(c.kind, SafetyKind.crisis);
    expect(c.text, contains('does not send this to a doctor'));
    expect(c.actions.map((SafetyAction a) => a.href), <String>['tel:14416', 'tel:112']);
  });

  test('stored messages map to member, answer and safety items', () {
    final ChatItem answer = ApiChatRepository.item(<String, dynamic>{
      'id': 'a', 'role': 'assistant', 'text': 'Rest helps.\n\nAI insights do not replace medical advice.', 'createdAt': '2026-11-16T10:00:00.000Z',
      'sources': <dynamic>[<String, dynamic>{'passageId': 'p1', 'title': 'Sleep', 'publisher': 'NHS'}], 'safetyCard': null, 'incomplete': true,
    });
    expect(answer, isA<AssistantAnswer>());
    expect((answer as AssistantAnswer).incomplete, isTrue);
    expect(answer.sources.single.passageIds, <String>['p1']);
  });

  test('reads server-sent events split anywhere across chunks', () async {
    final String text = frame(<String, dynamic>{'type': 'accepted', 'messageId': 'm'}) + frame(<String, dynamic>{'type': 'delta', 'text': 'Hello.'});
    final List<String> chunks = <String>[for (int i = 0; i < text.length; i += 5) text.substring(i, i + 5 > text.length ? text.length : i + 5)];
    final List<Map<String, dynamic>> out = await ApiChatRepository.events(Stream<String>.fromIterable(chunks)).toList();
    expect(out.map((Map<String, dynamic> e) => e['type']), <String>['accepted', 'delta']);
    expect(out.last['text'], 'Hello.');
  });
}
