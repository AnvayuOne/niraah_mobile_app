import 'package:equatable/equatable.dart';

import '../../cycle/domain/cycle.dart';

/// AI Care chat as the server offers it (spec 010 §8, spec 009 "Chat"),
/// matching apps/web/src/features/chat/types.ts.

class ChatSource extends Equatable {
  const ChatSource({required this.id, required this.title, required this.publisher, this.passageIds = const <String>[]});

  final String id;
  final String title;
  final String publisher;

  /// From the API: the passages the answer cited, for the source viewer.
  final List<String> passageIds;

  @override
  List<Object?> get props => <Object?>[id, title, publisher, passageIds];
}

class CitedSentence extends Equatable {
  const CitedSentence({required this.text, this.passageId});

  final String text;
  final String? passageId;

  @override
  List<Object?> get props => <Object?>[text, passageId];
}

enum SafetyKind { crisis, emergency, medicine }

class SafetyAction extends Equatable {
  const SafetyAction({required this.label, required this.href});

  final String label;

  /// `tel:` links, or an app path such as `/home`.
  final String href;

  @override
  List<Object?> get props => <Object?>[label, href];
}

/// A fixed safety message, shown as a card, never as a chat bubble
/// (spec 010 §8.4, spec 009 "Chat safety").
class SafetyCard extends Equatable {
  const SafetyCard({required this.kind, required this.title, required this.text, required this.actions});

  final SafetyKind kind;
  final String title;
  final String text;
  final List<SafetyAction> actions;

  @override
  List<Object?> get props => <Object?>[kind, title, text, actions];
}

sealed class ChatItem extends Equatable {
  const ChatItem({required this.id, required this.at});

  final String id;
  final DateTime at;
}

class MemberMessage extends ChatItem {
  const MemberMessage({required super.id, required super.at, required this.text});

  final String text;

  @override
  List<Object?> get props => <Object?>[id, at, text];
}

class AssistantAnswer extends ChatItem {
  const AssistantAnswer({
    required super.id,
    required super.at,
    required this.sentences,
    required this.sources,
    required this.streaming,
    required this.incomplete,
  });

  final List<CitedSentence> sentences;
  final List<ChatSource> sources;

  /// True while sentences are still arriving.
  final bool streaming;

  /// Stopped part-way: shown as incomplete with "Try again" (spec 010 §8.8).
  final bool incomplete;

  AssistantAnswer copyWith({List<CitedSentence>? sentences, List<ChatSource>? sources, bool? streaming, bool? incomplete}) =>
      AssistantAnswer(
        id: id,
        at: at,
        sentences: sentences ?? this.sentences,
        sources: sources ?? this.sources,
        streaming: streaming ?? this.streaming,
        incomplete: incomplete ?? this.incomplete,
      );

  @override
  List<Object?> get props => <Object?>[id, at, sentences, sources, streaming, incomplete];
}

class SafetyItem extends ChatItem {
  const SafetyItem({required super.id, required super.at, required this.card});

  final SafetyCard card;

  @override
  List<Object?> get props => <Object?>[id, at, card];
}

class Conversation extends Equatable {
  const Conversation({required this.id, required this.title, required this.lastMessageAt, required this.items});

  final String id;
  final String title;
  final DateTime lastMessageAt;
  final List<ChatItem> items;

  @override
  List<Object?> get props => <Object?>[id, title, lastMessageAt, items];
}

class ConversationSummary extends Equatable {
  const ConversationSummary({required this.id, required this.title, required this.lastMessageAt});

  final String id;
  final String title;
  final DateTime lastMessageAt;

  @override
  List<Object?> get props => <Object?>[id, title, lastMessageAt];
}

class ChatAllowance extends Equatable {
  const ChatAllowance({required this.limit, required this.remaining, required this.resetsAt, required this.showRemaining});

  final int limit;
  final int remaining;
  final IsoDate resetsAt;

  /// Shown when few are left (spec 010 §8.7).
  final bool showRemaining;

  @override
  List<Object?> get props => <Object?>[limit, remaining, resetsAt, showRemaining];
}

class ChatHome extends Equatable {
  const ChatHome({
    required this.conversations,
    required this.starters,
    required this.personalised,
    required this.allowance,
    required this.plansWithMore,
    required this.notADoctor,
    required this.footer,
    required this.canShareWithDoctor,
  });

  /// Newest first.
  final List<ConversationSummary> conversations;
  final List<String> starters;
  final bool personalised;
  final ChatAllowance allowance;

  /// Plans that give more messages, for the limit state.
  final List<String> plansWithMore;
  final String notADoctor;
  final String footer;

  /// True only when her plan and payment allow it (spec 010 §8.5, AC29).
  final bool canShareWithDoctor;

  @override
  List<Object?> get props => <Object?>[conversations, starters, personalised, allowance, plansWithMore, notADoctor, footer, canShareWithDoctor];
}

/// Events while a reply arrives, sentence by sentence (spec 009 "Streamed answers").
sealed class ChatEvent {
  const ChatEvent();
}

class ChatSafetyEvent extends ChatEvent {
  const ChatSafetyEvent(this.card);

  final SafetyCard card;
}

class ChatLimitEvent extends ChatEvent {
  const ChatLimitEvent();
}

class ChatSentenceEvent extends ChatEvent {
  const ChatSentenceEvent(this.sentence);

  final CitedSentence sentence;
}

class ChatSourcesEvent extends ChatEvent {
  const ChatSourcesEvent(this.sources);

  final List<ChatSource> sources;
}

class ChatDoneEvent extends ChatEvent {
  const ChatDoneEvent();
}

class ChatFailedEvent extends ChatEvent {
  const ChatFailedEvent();
}

class Passage extends Equatable {
  const Passage({required this.id, required this.documentId, required this.title, required this.publisher, required this.text});

  final String id;
  final String documentId;
  final String title;
  final String publisher;
  final String text;

  @override
  List<Object?> get props => <Object?>[id, documentId, title, publisher, text];
}

abstract interface class ChatRepository {
  Future<ChatHome> getHome();

  Future<Conversation?> getConversation(String id);

  Future<Conversation> createConversation();

  Future<void> renameConversation(String id, String title);

  Future<void> deleteConversation(String id);

  /// Stores her message before anything else (spec 010 §8.8), then streams the reply.
  Stream<ChatEvent> send(String conversationId, String text);

  /// Drops an incomplete answer and answers her last message again.
  Stream<ChatEvent> retry(String conversationId);

  Future<Passage?> getPassage(String id);
}
