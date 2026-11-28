import '../../home/data/unavailable_home_repository.dart';
import '../domain/chat.dart';

/// Used by `main.dart` until the AI module (spec 009) and its endpoints exist.
class UnavailableChatRepository implements ChatRepository {
  const UnavailableChatRepository();

  @override
  Future<ChatHome> getHome() async => throw const HomeNotConnected();

  @override
  Future<Conversation?> getConversation(String id) async => throw const HomeNotConnected();

  @override
  Future<Conversation> createConversation() async => throw const HomeNotConnected();

  @override
  Future<void> renameConversation(String id, String title) async => throw const HomeNotConnected();

  @override
  Future<void> deleteConversation(String id) async => throw const HomeNotConnected();

  @override
  Stream<ChatEvent> send(String conversationId, String text) => Stream<ChatEvent>.error(const HomeNotConnected());

  @override
  Stream<ChatEvent> retry(String conversationId) => Stream<ChatEvent>.error(const HomeNotConnected());

  @override
  Future<Passage?> getPassage(String id) async => throw const HomeNotConnected();
}
