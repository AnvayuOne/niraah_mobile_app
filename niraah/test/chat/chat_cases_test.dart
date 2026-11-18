import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/features/chat/domain/chat.dart';
import 'package:niraah/features/cycle/domain/cycle.dart';
import 'package:niraah/sample/sample_chat.dart';

/// chat-rules.md cases, shared with web. test/fixtures/chat-cases.json is a
/// copy of niraah-platform/design/sample/chat-cases.json.
void main() {
  final Map<String, dynamic> file = jsonDecode(File('test/fixtures/chat-cases.json').readAsStringSync()) as Map<String, dynamic>;
  Phase? phaseOf(Object? raw) => raw == null ? null : Phase.values.byName(raw as String);

  group('answers', () {
    for (final dynamic raw in file['cases'] as List<dynamic>) {
      final Map<String, dynamic> c = raw as Map<String, dynamic>;
      test(c['name'] as String, () {
        final ChatOutcome o = answerMessage(
          c['message'] as String,
          remaining: c['remaining'] as int,
          personalised: c['personalised'] as bool,
          phase: phaseOf(c['phase']),
        );
        final Map<String, dynamic> want = c['expect'] as Map<String, dynamic>;
        final String kind = switch (o) {
          SafetyOutcome() => 'safety',
          LimitOutcome() => 'limit',
          AnswerOutcome() => 'answer',
        };
        expect(kind, want['kind']);
        if (want.containsKey('usesMessage')) expect(o.usesMessage, want['usesMessage']);
        if (o is SafetyOutcome) expect(o.card.kind.name, want['card']);
        if (o is AnswerOutcome) {
          final List<String> texts = o.sentences.map((CitedSentence s) => s.text).toList();
          if (want.containsKey('intent')) expect(o.intent, want['intent']);
          if (want.containsKey('sentences')) expect(texts.length, want['sentences']);
          if (want.containsKey('lastSentence')) expect(texts.last, want['lastSentence']);
          if (want.containsKey('firstSentence')) expect(texts.first, want['firstSentence']);
          if (want.containsKey('contains')) expect(texts.any((String t) => t.contains(want['contains'] as String)), isTrue);
          if (want.containsKey('sources')) expect(o.sources.map((ChatSource s) => s.id).toList(), want['sources']);
          // The medical-advice line ends every answer (spec 009 AC28).
          expect(texts.last, 'AI insights do not replace medical advice.');
        }
      });
    }
  });

  group('starters', () {
    for (final dynamic raw in file['starterCases'] as List<dynamic>) {
      final Map<String, dynamic> c = raw as Map<String, dynamic>;
      test(c['name'] as String, () {
        final Map<String, dynamic> log = c['todayLog'] as Map<String, dynamic>;
        expect(chatStarters(phaseOf(c['phase']), energy: log['energy'] as String?, mood: log['mood'] as String?), c['expect']);
      });
    }
  });
}
