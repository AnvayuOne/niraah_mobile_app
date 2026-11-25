// SAMPLE ONLY. Implements niraah-platform/design/sample/chat-rules.md, line
// for line with apps/web/src/sample/chat.ts: fixed safety rules first, then
// canned answers tied to sample passages. No model is called (constitution §7).
// Shared cases: design/sample/chat-cases.json (copied to test/fixtures).

import 'dart:convert';

import '../features/chat/domain/chat.dart';
import '../features/cycle/domain/cycle.dart';
import 'sample_content.dart';

final Map<String, dynamic> _safety = jsonDecode(sampleChatSafetyJson) as Map<String, dynamic>;
final Map<String, dynamic> _knowledge = jsonDecode(sampleChatKnowledgeJson) as Map<String, dynamic>;

final Map<String, Passage> _passages = <String, Passage>{
  for (final dynamic d in _knowledge['documents'] as List<dynamic>)
    for (final dynamic p in (d as Map<String, dynamic>)['passages'] as List<dynamic>)
      (p as Map<String, dynamic>)['id'] as String: Passage(
        id: p['id'] as String,
        documentId: d['id'] as String,
        title: d['title'] as String,
        publisher: d['publisher'] as String,
        text: p['text'] as String,
      ),
};

Passage? samplePassage(String id) => _passages[id];

String get sampleChatFooter => _knowledge['footer'] as String;
String get sampleNotADoctor => _knowledge['notADoctor'] as String;

SafetyKind _kind(String k) => switch (k) {
      'crisis' => SafetyKind.crisis,
      'emergency' => SafetyKind.emergency,
      _ => SafetyKind.medicine,
    };

SafetyCard _card(Map<String, dynamic> c) => SafetyCard(
      kind: _kind(c['kind'] as String),
      title: c['title'] as String,
      text: c['text'] as String,
      actions: <SafetyAction>[
        for (final dynamic a in c['actions'] as List<dynamic>)
          SafetyAction(label: (a as Map<String, dynamic>)['label'] as String, href: a['href'] as String),
      ],
    );

sealed class ChatOutcome {
  const ChatOutcome();

  /// Only a delivered answer uses a message (spec 009 AC40).
  bool get usesMessage;
}

class SafetyOutcome extends ChatOutcome {
  const SafetyOutcome(this.card);

  final SafetyCard card;

  @override
  bool get usesMessage => false;
}

class LimitOutcome extends ChatOutcome {
  const LimitOutcome();

  @override
  bool get usesMessage => false;
}

class AnswerOutcome extends ChatOutcome {
  const AnswerOutcome({required this.intent, required this.sentences, required this.sources});

  final String? intent;
  final List<CitedSentence> sentences;
  final List<ChatSource> sources;

  @override
  bool get usesMessage => true;
}

String _phaseName(Phase p) => '${p.name} phase';

/// Rules 1 to 8 of chat-rules.md.
ChatOutcome answerMessage(String message, {required int remaining, required bool personalised, required Phase? phase}) {
  // Rule 1.
  final String text = message.toLowerCase().trim();

  // Rule 2: safety first, by fixed rules, in order.
  bool diagnosis = false;
  final Map<String, dynamic> rules = _safety['rules'] as Map<String, dynamic>;
  for (final dynamic key in _safety['order'] as List<dynamic>) {
    final Map<String, dynamic>? rule = rules[key] as Map<String, dynamic>?;
    if (rule == null || !(rule['patterns'] as List<dynamic>).any((dynamic p) => text.contains(p as String))) continue;
    if (rule['card'] != null) return SafetyOutcome(_card(rule['card'] as Map<String, dynamic>));
    if (key == 'diagnosis') {
      diagnosis = true;
      break;
    }
  }

  // Rule 3.
  if (remaining <= 0) return const LimitOutcome();

  // Rule 4.
  Map<String, dynamic>? intent;
  for (final dynamic i in _knowledge['intents'] as List<dynamic>) {
    final Map<String, dynamic> m = i as Map<String, dynamic>;
    if ((m['keywords'] as List<dynamic>).any((dynamic k) => text.contains(k as String))) {
      intent = m;
      break;
    }
  }

  // Rules 5 and 6.
  final List<CitedSentence> sentences = <CitedSentence>[];
  if (diagnosis) sentences.add(CitedSentence(text: _safety['diagnosisLine'] as String));
  if (intent == null) {
    sentences.add(CitedSentence(text: _knowledge['noSource'] as String));
  } else {
    for (final dynamic raw in intent['sentences'] as List<dynamic>) {
      final Map<String, dynamic> s = raw as Map<String, dynamic>;
      if (s['personal'] == true && !personalised) continue;
      if (s['needsPhase'] == true && phase == null) continue;
      final String t = s['text'] as String;
      sentences.add(CitedSentence(text: phase != null ? t.replaceFirst('{phase}', _phaseName(phase)) : t, passageId: s['cite'] as String?));
    }
  }
  sentences.add(CitedSentence(text: sampleChatFooter));

  final List<ChatSource> sources = <ChatSource>[];
  for (CitedSentence s in sentences) {
    final Passage? p = s.passageId == null ? null : _passages[s.passageId];
    if (p != null && !sources.any((ChatSource x) => x.id == p.documentId)) {
      sources.add(ChatSource(id: p.documentId, title: p.title, publisher: p.publisher));
    }
  }
  return AnswerOutcome(intent: intent?['key'] as String?, sentences: sentences, sources: sources);
}

/// Starter prompts from her phase and today's log (spec 010 §8.1).
List<String> chatStarters(Phase? phase, {String? energy, String? mood}) {
  final Map<String, dynamic> s = _knowledge['starters'] as Map<String, dynamic>;
  final Map<String, dynamic> byLog = s['byLog'] as Map<String, dynamic>;
  final List<String> out = <String>[(s['byPhase'] as Map<String, dynamic>)[phase?.name ?? 'none'] as String];
  if (energy == 'low' && byLog['energy:low'] != null) {
    out.add(byLog['energy:low'] as String);
  } else if (mood == 'anxious' && byLog['mood:anxious'] != null) {
    out.add(byLog['mood:anxious'] as String);
  }
  for (final dynamic a in s['always'] as List<dynamic>) {
    if (!out.contains(a)) out.add(a as String);
  }
  return out.take(3).toList();
}
