// SAMPLE ONLY (constitution §2 rule 6, §7: no model is called). Mirrors
// apps/web/src/sample/chat-repository.ts. Real chat goes through the AI
// module (spec 009) via /api/v1.

import 'dart:async';
import 'dart:convert';

import '../features/chat/domain/chat.dart';
import '../features/cycle/domain/cycle.dart';
import 'sample_backend.dart';
import 'sample_chat.dart';
import 'sample_content.dart';
import 'sample_cycle.dart';
import 'sample_store.dart';

const String _newTitle = 'New conversation';

class SampleChatRepository implements ChatRepository {
  SampleChatRepository(
    this._store,
    this._backend, {
    IsoDate Function()? today,
    DateTime Function()? clock,
    this.sentenceDelay = const Duration(milliseconds: 350),
  })  : _today = today ?? IsoDates.localToday,
        _clock = clock ?? DateTime.now;

  final SampleStore _store;
  final SampleBackend _backend;
  final IsoDate Function() _today;
  final DateTime Function() _clock;

  /// Sentences are released about this far apart (chat-rules.md rule 7).
  final Duration sentenceDelay;

  final Map<String, dynamic> _plans = jsonDecode(samplePlansJson) as Map<String, dynamic>;

  /// The free plan's `ai_chat.messages` (design/sample/plans.json).
  int get dailyLimit {
    for (final dynamic p in _plans['plans'] as List<dynamic>) {
      final Map<String, dynamic> m = p as Map<String, dynamic>;
      if (m['isFree'] != true) continue;
      for (final dynamic f in m['features'] as List<dynamic>) {
        final Map<String, dynamic> fm = f as Map<String, dynamic>;
        if (fm['key'] == 'ai_chat.messages') return ((fm['value'] as Map<String, dynamic>)['limit'] as int?) ?? 10;
      }
    }
    return 10;
  }

  int get _used => _store.chatUseDate == _today() ? _store.chatUseCount : 0;

  Phase? get _phase => switch (summariseCycle(
        today: _today(),
        periods: _store.periods,
        markers: _store.markers,
        regularity: _backend.answerValue('cycle_regularity'),
      )) {
        final CycleEstimate e => e.phase,
        _ => null,
      };

  Conversation? _find(String id) => _store.conversations.where((Conversation c) => c.id == id).firstOrNull;

  void _update(String id, Conversation Function(Conversation c) fn) {
    final int i = _store.conversations.indexWhere((Conversation c) => c.id == id);
    if (i < 0) return;
    final Conversation next = fn(_store.conversations[i]);
    _store.conversations[i] = Conversation(id: next.id, title: next.title, lastMessageAt: _clock(), items: next.items);
  }

  Conversation _withItems(Conversation c, List<ChatItem> items, {String? title}) =>
      Conversation(id: c.id, title: title ?? c.title, lastMessageAt: c.lastMessageAt, items: items);

  Stream<ChatEvent> _reply(String convId, String text) async* {
    final ChatOutcome outcome = answerMessage(text, remaining: dailyLimit - _used, personalised: _store.personalisedAi, phase: _phase);

    switch (outcome) {
      case SafetyOutcome(:SafetyCard card):
        _update(convId, (Conversation c) => _withItems(c, <ChatItem>[...c.items, SafetyItem(id: _store.newId(), at: _clock(), card: card)]));
        yield ChatSafetyEvent(card);
        return;
      case LimitOutcome():
        yield const ChatLimitEvent();
        return;
      case AnswerOutcome(:List<CitedSentence> sentences, :List<ChatSource> sources):
        String answerId = _store.newId();
        AssistantAnswer item = AssistantAnswer(id: answerId, at: _clock(), sentences: const <CitedSentence>[], sources: const <ChatSource>[], streaming: true, incomplete: false);
        void put(AssistantAnswer a) => _update(
              convId,
              (Conversation c) => _withItems(c, <ChatItem>[for (ChatItem i in c.items) i.id == answerId ? a : i, if (!c.items.any((ChatItem i) => i.id == answerId)) a]),
            );
        put(item);
        for (CitedSentence s in sentences) {
          await Future<void>.delayed(sentenceDelay);
          item = item.copyWith(sentences: <CitedSentence>[...item.sentences, s]);
          put(item);
          yield ChatSentenceEvent(s);
        }
        put(item.copyWith(sources: sources, streaming: false));
        yield ChatSourcesEvent(sources);
        // A delivered answer uses one message (spec 009 AC40).
        final int used = _used;
        _store
          ..chatUseDate = _today()
          ..chatUseCount = used + 1;
        yield const ChatDoneEvent();
    }
  }

  @override
  Future<ChatHome> getHome() async {
    final int limit = dailyLimit;
    final int remaining = (limit - _used).clamp(0, limit);
    final DailyLog? log = _store.dailyLogs[_today()];
    final List<Conversation> sorted = List<Conversation>.of(_store.conversations)
      ..sort((Conversation a, Conversation b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return ChatHome(
      conversations: <ConversationSummary>[
        for (Conversation c in sorted) ConversationSummary(id: c.id, title: c.title, lastMessageAt: c.lastMessageAt),
      ],
      starters: chatStarters(_phase, energy: log?.energy?.name, mood: log?.mood?.name),
      personalised: _store.personalisedAi,
      allowance: ChatAllowance(limit: limit, remaining: remaining, resetsAt: IsoDates.addDays(_today(), 1), showRemaining: remaining <= 3),
      plansWithMore: <String>[
        for (final dynamic p in _plans['plans'] as List<dynamic>)
          if ((p as Map<String, dynamic>)['isFree'] != true) p['name'] as String,
      ],
      notADoctor: sampleNotADoctor,
      footer: sampleChatFooter,
      // Free plan: no `messaging.care_team`, no dedicated doctor (spec 010 §8.5, AC29).
      canShareWithDoctor: false,
    );
  }

  @override
  Future<Conversation?> getConversation(String id) async => _find(id);

  @override
  Future<Conversation> createConversation() async {
    final Conversation c = Conversation(id: _store.newId(), title: _newTitle, lastMessageAt: _clock(), items: const <ChatItem>[]);
    _store.conversations.add(c);
    return c;
  }

  @override
  Future<void> renameConversation(String id, String title) async =>
      _update(id, (Conversation c) => _withItems(c, c.items, title: title.trim().isEmpty ? c.title : title.trim()));

  @override
  Future<void> deleteConversation(String id) async => _store.conversations.removeWhere((Conversation c) => c.id == id);

  @override
  Stream<ChatEvent> send(String conversationId, String text) async* {
    // Her message is stored before anything else, so it is never lost (spec 010 §8.8).
    _update(conversationId, (Conversation c) {
      final String? title = c.title == _newTitle ? (text.length > 40 ? '${text.substring(0, 40)}…' : text) : null;
      return _withItems(c, <ChatItem>[...c.items, MemberMessage(id: _store.newId(), at: _clock(), text: text)], title: title);
    });
    yield* _reply(conversationId, text);
  }

  @override
  Stream<ChatEvent> retry(String conversationId) async* {
    final Conversation? c = _find(conversationId);
    if (c == null) return;
    final MemberMessage? last = c.items.whereType<MemberMessage>().lastOrNull;
    // Drop an incomplete answer, then answer her last message again.
    _update(
      conversationId,
      (Conversation conv) => _withItems(conv, <ChatItem>[
        for (ChatItem i in conv.items)
          if (!(i is AssistantAnswer && (i.incomplete || i.streaming))) i,
      ]),
    );
    if (last != null) yield* _reply(conversationId, last.text);
  }

  @override
  Future<Passage?> getPassage(String id) async => samplePassage(id);
}
