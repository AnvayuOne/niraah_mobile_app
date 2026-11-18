import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/chat.dart';

enum ChatLoad { loading, ready, failure }

class ChatHomeState extends Equatable {
  const ChatHomeState({this.status = ChatLoad.loading, this.home});

  final ChatLoad status;
  final ChatHome? home;

  @override
  List<Object?> get props => <Object?>[status, home];
}

class ChatHomeCubit extends Cubit<ChatHomeState> {
  ChatHomeCubit(this._repo) : super(const ChatHomeState());

  final ChatRepository _repo;

  Future<void> load() async {
    try {
      emit(ChatHomeState(status: ChatLoad.ready, home: await _repo.getHome()));
    } on Exception {
      emit(const ChatHomeState(status: ChatLoad.failure));
    }
  }

  Future<String> newConversation() async => (await _repo.createConversation()).id;
}

class ConversationState extends Equatable {
  const ConversationState({
    this.status = ChatLoad.loading,
    this.home,
    this.conversation,
    this.sending = false,
    this.limitReached = false,
    this.failed = false,
    this.deleted = false,
  });

  final ChatLoad status;
  final ChatHome? home;
  final Conversation? conversation;

  /// A reply is on its way.
  final bool sending;

  /// The last ordinary message hit today's limit.
  final bool limitReached;

  /// The last reply stopped before it finished (spec 010 §8.8).
  final bool failed;
  final bool deleted;

  bool get atLimit => limitReached || (home?.allowance.remaining ?? 1) <= 0;

  ConversationState copyWith({ChatLoad? status, ChatHome? home, Conversation? conversation, bool? sending, bool? limitReached, bool? failed, bool? deleted}) =>
      ConversationState(
        status: status ?? this.status,
        home: home ?? this.home,
        conversation: conversation ?? this.conversation,
        sending: sending ?? this.sending,
        limitReached: limitReached ?? this.limitReached,
        failed: failed ?? this.failed,
        deleted: deleted ?? this.deleted,
      );

  @override
  List<Object?> get props => <Object?>[status, home, conversation, sending, limitReached, failed, deleted];
}

/// One conversation. The reply streams in; after every event the
/// conversation is read again, so what is shown is what is stored.
class ConversationCubit extends Cubit<ConversationState> {
  ConversationCubit(this._repo, this.conversationId) : super(const ConversationState());

  final ChatRepository _repo;
  final String conversationId;

  Future<void> load() async {
    try {
      final ChatHome home = await _repo.getHome();
      final Conversation? c = await _repo.getConversation(conversationId);
      emit(state.copyWith(status: c == null ? ChatLoad.failure : ChatLoad.ready, home: home, conversation: c));
    } on Exception {
      emit(state.copyWith(status: ChatLoad.failure));
    }
  }

  Future<void> _refresh() async {
    final Conversation? c = await _repo.getConversation(conversationId);
    if (c != null && !isClosed) emit(state.copyWith(conversation: c));
  }

  Future<void> _run(Stream<ChatEvent> events) async {
    emit(state.copyWith(sending: true, failed: false, limitReached: false));
    await _refresh();
    try {
      await for (final ChatEvent e in events) {
        if (isClosed) return;
        switch (e) {
          case ChatLimitEvent():
            emit(state.copyWith(limitReached: true));
          case ChatFailedEvent():
            emit(state.copyWith(failed: true));
          case ChatSafetyEvent() || ChatSentenceEvent() || ChatSourcesEvent() || ChatDoneEvent():
            break;
        }
        await _refresh();
      }
    } on Exception {
      if (!isClosed) emit(state.copyWith(failed: true));
    }
    if (isClosed) return;
    await _refresh();
    try {
      emit(state.copyWith(sending: false, home: await _repo.getHome()));
    } on Exception {
      emit(state.copyWith(sending: false));
    }
  }

  Future<void> send(String text) {
    final String t = text.trim();
    if (t.isEmpty || state.sending) return Future<void>.value();
    return _run(_repo.send(conversationId, t));
  }

  Future<void> retry() => _run(_repo.retry(conversationId));

  Future<void> rename(String title) async {
    await _repo.renameConversation(conversationId, title);
    await _refresh();
  }

  Future<void> delete() async {
    await _repo.deleteConversation(conversationId);
    emit(state.copyWith(deleted: true));
  }

  Future<List<Passage>> passagesFor(AssistantAnswer answer, ChatSource source) async {
    final List<Passage> out = <Passage>[];
    // A source that names its cited passages (the API) is looked up directly; otherwise through the sentences.
    if (source.passageIds.isNotEmpty) {
      for (final String id in source.passageIds) {
        final Passage? p = await _repo.getPassage(id);
        if (p != null) out.add(p);
      }
      return out;
    }
    for (final String id in answer.sentences.map((CitedSentence s) => s.passageId).whereType<String>().toSet()) {
      final Passage? p = await _repo.getPassage(id);
      if (p != null && p.documentId == source.id) out.add(p);
    }
    return out;
  }
}
