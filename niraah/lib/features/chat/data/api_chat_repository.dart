import 'dart:async';
import 'dart:convert';

import '../../../core/network/niraah_api.dart';
import '../domain/chat.dart';

/// AI Care chat on `/api/v1` (spec 009, spec 010 §8), matching apps/web/src/api/chat-repository.ts. Answers
/// stream as server-sent events; the answer being written is kept here until the server has stored it.
class ApiChatRepository implements ChatRepository {
  ApiChatRepository(this._api, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final NiraahApi _api;
  final DateTime Function() _clock;
  final Map<String, AssistantAnswer> _pending = <String, AssistantAnswer>{};
  final Map<String, MemberMessage> _optimistic = <String, MemberMessage>{};

  // Fixed wording around the clinician-written card text, matching the web copy (apps/web/src/copy/en.ts).
  static const String footer = 'AI insights do not replace medical advice.';
  static const String notADoctor = 'AI Care is not a doctor. It shares general wellness information from sources our clinicians have approved.';
  static const List<String> starters = <String>['What helps with period cramps?', 'How can I sleep better before my period?', 'What should I eat for more energy?'];

  /// Splits answer text into sentences; the medical-advice line stays the last one (spec 009 AC28).
  static List<CitedSentence> sentences(String text) {
    final bool hasFooter = text.endsWith(footer);
    final String body = (hasFooter ? text.substring(0, text.length - footer.length) : text).trim();
    final List<CitedSentence> out = RegExp(r'[^.!?\n]+(?:[.!?]+|$)')
        .allMatches(body)
        .map((RegExpMatch m) => m.group(0)!.trim())
        .where((String s) => s.isNotEmpty)
        .map((String s) => CitedSentence(text: s))
        .toList();
    if (hasFooter) out.add(const CitedSentence(text: footer));
    return out;
  }

  /// Groups cited passages by document, so each source names the passages the answer cited.
  static List<ChatSource> sources(List<dynamic> raw) {
    final Map<String, ChatSource> out = <String, ChatSource>{};
    for (final dynamic r in raw) {
      final Map<dynamic, dynamic> s = r as Map<dynamic, dynamic>;
      final String key = '${s['title']}|${s['publisher']}';
      final ChatSource? existing = out[key];
      out[key] = existing == null
          ? ChatSource(id: '${s['passageId']}', title: '${s['title']}', publisher: '${s['publisher']}', passageIds: <String>['${s['passageId']}'])
          : ChatSource(id: existing.id, title: existing.title, publisher: existing.publisher, passageIds: <String>[...existing.passageIds, '${s['passageId']}']);
    }
    return out.values.toList(growable: false);
  }

  /// A fixed safety message as a card with its actions (spec 010 §8.4).
  static SafetyCard card(Map<dynamic, dynamic> c) {
    final String kind = '${c['kind']}';
    final List<SafetyAction> actions = <SafetyAction>[];
    for (final dynamic a in (c['actions'] as List<dynamic>? ?? const <dynamic>[])) {
      if (a == 'helplines') actions.addAll(const <SafetyAction>[SafetyAction(label: 'Call Tele-MANAS 14416 (free, 24 hours)', href: 'tel:14416'), SafetyAction(label: 'Emergency: call 112', href: 'tel:112')]);
      if (a == 'seek_care') actions.add(const SafetyAction(label: 'Call 112', href: 'tel:112'));
      if (a == 'book_doctor') actions.add(const SafetyAction(label: 'Book a doctor', href: '/specialists'));
    }
    final String text = c['note'] == null ? '${c['text']}' : '${c['text']} ${c['note']}';
    return switch (kind) {
      'self_harm' => SafetyCard(kind: SafetyKind.crisis, title: "You don't have to go through this alone", text: text, actions: actions),
      'emergency' => SafetyCard(kind: SafetyKind.emergency, title: 'Please seek care now', text: text, actions: actions),
      _ => SafetyCard(kind: SafetyKind.medicine, title: "Niraah AI can't advise on medicines", text: text, actions: actions),
    };
  }

  static ChatItem item(Map<dynamic, dynamic> m) {
    final DateTime at = DateTime.parse('${m['createdAt']}');
    final String role = '${m['role']}';
    if (role == 'member') return MemberMessage(id: '${m['id']}', at: at, text: '${m['text']}');
    if (role == 'safety' && m['safetyCard'] is Map) return SafetyItem(id: '${m['id']}', at: at, card: card(m['safetyCard'] as Map<dynamic, dynamic>));
    return AssistantAnswer(id: '${m['id']}', at: at, sentences: sentences('${m['text']}'), sources: sources(m['sources'] as List<dynamic>), streaming: false, incomplete: m['incomplete'] == true);
  }

  /// Parses server-sent event text, which may arrive split anywhere, into each event's data.
  static Stream<Map<String, dynamic>> events(Stream<String> text) async* {
    String buffer = '';
    await for (final String chunk in text) {
      buffer += chunk;
      int cut;
      while ((cut = buffer.indexOf('\n\n')) >= 0) {
        final String frame = buffer.substring(0, cut);
        buffer = buffer.substring(cut + 2);
        final RegExpMatch? data = RegExp(r'^data: (.*)$', multiLine: true).firstMatch(frame);
        if (data != null) yield Map<String, dynamic>.from(jsonDecode(data.group(1)!) as Map);
      }
    }
  }

  @override
  Future<ChatHome> getHome() async {
    final ApiResult<Map<String, dynamic>> list = await _api.get('/me/chat/conversations');
    if (list is ApiFail<Map<String, dynamic>>) throw StateError(list.error.message);
    final Map<String, dynamic> data = (list as ApiOk<Map<String, dynamic>>).data;
    final ApiResult<Map<String, dynamic>> ents = await _api.get('/me/entitlements');
    final ApiResult<Map<String, dynamic>> plans = await _api.get('/me/plans');
    final Map<dynamic, dynamic>? chat = ents is ApiOk<Map<String, dynamic>>
        ? (ents.data['features'] as List<dynamic>).cast<Map<dynamic, dynamic>>().where((Map<dynamic, dynamic> f) => f['key'] == 'ai_chat.messages').firstOrNull
        : null;
    final bool unlimited = chat != null && chat['allowance'] == null;
    final int limit = (chat?['allowance'] as int?) ?? 0;
    final int remaining = unlimited ? 1 << 30 : ((chat?['remaining'] as int?) ?? 0);
    final String resets = '${chat?['refillsAt'] ?? _clock().toIso8601String()}'.substring(0, 10);
    return ChatHome(
      conversations: (data['items'] as List<dynamic>)
          .cast<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> c) => ConversationSummary(id: '${c['id']}', title: '${c['title']}', lastMessageAt: DateTime.parse('${c['lastMessageAt']}')))
          .toList(growable: false),
      starters: starters,
      personalised: data['personalised'] == true,
      allowance: ChatAllowance(limit: limit, remaining: remaining, resetsAt: resets, showRemaining: !unlimited && remaining <= 3),
      plansWithMore: plans is ApiOk<Map<String, dynamic>>
          ? (plans.data['plans'] as List<dynamic>)
              .cast<Map<dynamic, dynamic>>()
              .where((Map<dynamic, dynamic> p) => p['isFree'] != true && (p['features'] as List<dynamic>).any((dynamic f) => (f as Map<dynamic, dynamic>)['key'] == 'ai_chat.messages'))
              .map((Map<dynamic, dynamic> p) => '${p['name']}')
              .toList(growable: false)
          : const <String>[],
      notADoctor: notADoctor,
      footer: footer,
      canShareWithDoctor: data['canShare'] == true,
    );
  }

  @override
  Future<Conversation?> getConversation(String id) async {
    final ApiResult<Map<String, dynamic>> r = await _api.get('/me/chat/conversations/$id');
    if (r is! ApiOk<Map<String, dynamic>>) return null;
    final List<dynamic> messages = r.data['messages'] as List<dynamic>;
    final List<ChatItem> items = <ChatItem>[
      ...messages.cast<Map<dynamic, dynamic>>().map(item),
      if (_optimistic[id] != null) _optimistic[id]!,
      if (_pending[id] != null) _pending[id]!,
    ];
    final DateTime last = messages.isEmpty ? _clock() : DateTime.parse('${(messages.last as Map<dynamic, dynamic>)['createdAt']}');
    return Conversation(id: '${r.data['id']}', title: '${r.data['title']}', lastMessageAt: last, items: items);
  }

  @override
  Future<Conversation> createConversation() async {
    final ApiResult<Map<String, dynamic>> r = await _api.post('/me/chat/conversations');
    if (r is ApiFail<Map<String, dynamic>>) throw StateError(r.error.message);
    final Map<String, dynamic> d = (r as ApiOk<Map<String, dynamic>>).data;
    return Conversation(id: '${d['id']}', title: '${d['title']}', lastMessageAt: _clock(), items: const <ChatItem>[]);
  }

  @override
  Future<void> renameConversation(String id, String title) async => _api.patch('/me/chat/conversations/$id', <String, dynamic>{'title': title});

  @override
  Future<void> deleteConversation(String id) async => _api.delete('/me/chat/conversations/$id');

  @override
  Stream<ChatEvent> send(String conversationId, String text) => _stream(conversationId, text);

  @override
  Stream<ChatEvent> retry(String conversationId) async* {
    // Her message is already stored; asking again sends it as a new turn.
    final ApiResult<Map<String, dynamic>> r = await _api.get('/me/chat/conversations/$conversationId');
    if (r is! ApiOk<Map<String, dynamic>>) return;
    final Map<dynamic, dynamic>? last = (r.data['messages'] as List<dynamic>).cast<Map<dynamic, dynamic>>().where((Map<dynamic, dynamic> m) => m['role'] == 'member').lastOrNull;
    if (last != null) yield* _stream(conversationId, '${last['text']}');
  }

  Stream<ChatEvent> _stream(String conversationId, String text) async* {
    final DateTime now = _clock();
    _optimistic[conversationId] = MemberMessage(id: 'local-${now.microsecondsSinceEpoch}', at: now, text: text);
    try {
      final ApiResult<Stream<String>> r = await _api.postStream('/me/chat/conversations/$conversationId/messages', <String, dynamic>{'text': text});
      if (r is ApiFail<Stream<String>>) {
        yield const ChatFailedEvent();
        return;
      }
      String released = '';
      await for (final Map<String, dynamic> e in events((r as ApiOk<Stream<String>>).data)) {
        switch (e['type']) {
          case 'accepted':
            _optimistic.remove(conversationId);
          case 'safety':
            yield ChatSafetyEvent(card(e['card'] as Map<dynamic, dynamic>));
          case 'limit':
            yield const ChatLimitEvent();
          case 'delta':
            released += '${e['text']}';
            final List<CitedSentence> s = sentences(released);
            _pending[conversationId] = AssistantAnswer(id: 'pending', at: now, sentences: s, sources: const <ChatSource>[], streaming: true, incomplete: false);
            if (s.isNotEmpty) yield ChatSentenceEvent(s.last);
          case 'done':
            _pending.remove(conversationId);
            yield ChatSourcesEvent(sources(e['sources'] as List<dynamic>));
            yield e['incomplete'] == true ? const ChatFailedEvent() : const ChatDoneEvent();
          case 'error':
            _pending.remove(conversationId);
            yield const ChatFailedEvent();
        }
      }
    } finally {
      _pending.remove(conversationId);
      _optimistic.remove(conversationId);
    }
  }

  @override
  Future<Passage?> getPassage(String id) async {
    final ApiResult<Map<String, dynamic>> r = await _api.get('/knowledge/passages/$id');
    if (r is! ApiOk<Map<String, dynamic>>) return null;
    return Passage(id: '${r.data['id']}', documentId: '${r.data['id']}', title: '${r.data['title']}', publisher: '${r.data['publisher']}', text: '${r.data['text']}');
  }
}
