import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:niraah/features/chat/domain/chat.dart';
import 'package:niraah/features/chat/presentation/chat_cubits.dart';
import 'package:niraah/features/chat/presentation/conversation_page.dart';
import 'package:niraah/features/cycle/domain/cycle.dart';
import 'package:niraah/sample/sample_backend.dart';
import 'package:niraah/sample/sample_chat_repository.dart';
import 'package:niraah/sample/sample_store.dart';

import '../helpers/pump_app.dart';

const IsoDate today = '2026-11-14';

SampleChatRepository repoWith(SampleStore store) =>
    SampleChatRepository(store, SampleBackend(), today: () => today, sentenceDelay: Duration.zero);

/// Stores her message, then fails part-way through the reply.
class FailingChatRepository implements ChatRepository {
  FailingChatRepository(this.inner);

  final SampleChatRepository inner;

  @override
  Stream<ChatEvent> send(String conversationId, String text) async* {
    await for (final ChatEvent e in inner.send(conversationId, text)) {
      if (e is ChatSentenceEvent) throw Exception('connection lost');
      yield e;
    }
  }

  @override
  Stream<ChatEvent> retry(String conversationId) => inner.retry(conversationId);
  @override
  Future<ChatHome> getHome() => inner.getHome();
  @override
  Future<Conversation?> getConversation(String id) => inner.getConversation(id);
  @override
  Future<Conversation> createConversation() => inner.createConversation();
  @override
  Future<void> renameConversation(String id, String title) => inner.renameConversation(id, title);
  @override
  Future<void> deleteConversation(String id) => inner.deleteConversation(id);
  @override
  Future<Passage?> getPassage(String id) => inner.getPassage(id);
}

Future<ConversationCubit> pumpConversation(WidgetTester tester, ChatRepository repo) async {
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final String id = (await repo.createConversation()).id;
  final ConversationCubit cubit = ConversationCubit(repo, id);
  await cubit.load();
  await tester.pumpWidget(wrapApp(ConversationPage(conversationId: id, cubit: cubit), reducedMotion: true, size: const Size(390, 1600)));
  await tester.pumpAndSettle();
  return cubit;
}

void main() {
  late SampleStore store;
  late SampleChatRepository repo;

  setUp(() {
    store = SampleStore();
    repo = repoWith(store);
  });

  group('allowance (spec 009 AC40)', () {
    test('a delivered answer uses one message; safety cards and the limit use none', () async {
      final String id = (await repo.createConversation()).id;
      await repo.send(id, 'I want to end my life').drain<void>();
      expect((await repo.getHome()).allowance.remaining, 10);
      await repo.send(id, 'How can I sleep better?').drain<void>();
      expect((await repo.getHome()).allowance.remaining, 9);
      store
        ..chatUseDate = today
        ..chatUseCount = 10;
      final List<ChatEvent> events = await repo.send(id, 'How can I sleep better?').toList();
      expect(events.single, isA<ChatLimitEvent>());
      expect(store.chatUseCount, 10);
      expect((await repo.getHome()).allowance.showRemaining, isTrue);
    });

    test('title comes from her first message, 40 characters and an ellipsis', () async {
      final String id = (await repo.createConversation()).id;
      await repo.send(id, 'Why do I feel so tired before my period every single month?').drain<void>();
      expect((await repo.getConversation(id))!.title, 'Why do I feel so tired before my period …');
    });
  });

  testWidgets('a finished answer shows sources, the footer last, and no Share with Doctor (AC29)', (WidgetTester tester) async {
    final ConversationCubit cubit = await pumpConversation(tester, repo);
    expect(cubit.state.home!.canShareWithDoctor, isFalse);
    await tester.enterText(find.byType(TextField), 'Is my cycle length normal?');
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();
    expect(find.text('Sources'), findsOneWidget);
    expect(find.text('Understanding your menstrual cycle (sample document) · Niraah sample library'), findsOneWidget);
    expect(find.text('AI insights do not replace medical advice.'), findsOneWidget);
    expect(find.textContaining('Share'), findsNothing);
    final AssistantAnswer a = cubit.state.conversation!.items.whereType<AssistantAnswer>().single;
    expect(a.sentences.last.text, 'AI insights do not replace medical advice.');

    await tester.tap(find.textContaining('Understanding your menstrual cycle'));
    await tester.pumpAndSettle();
    expect(find.text('SOURCE'), findsOneWidget);
    expect(find.textContaining('A menstrual cycle is counted from the first day'), findsOneWidget);
  });

  testWidgets('AC30/AC32: with no messages left, a crisis message still gets the crisis card', (WidgetTester tester) async {
    store
      ..chatUseDate = today
      ..chatUseCount = 10;
    await pumpConversation(tester, repo);
    expect(find.text("You've used today's messages"), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'I want to end my life');
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();
    expect(find.text("You don't have to go through this alone"), findsOneWidget);
    expect(find.text('Call Tele-MANAS 14416 (free, 24 hours)'), findsOneWidget);
    expect(find.text('AI insights do not replace medical advice.'), findsNothing);
    expect(store.chatUseCount, 10);
  });

  testWidgets('her message stays when the reply fails, with "Try again"', (WidgetTester tester) async {
    final ConversationCubit cubit = await pumpConversation(tester, FailingChatRepository(repo));
    await tester.enterText(find.byType(TextField), 'How can I sleep better?');
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();
    // Once as the conversation title, once as her bubble.
    expect(find.text('How can I sleep better?'), findsNWidgets(2));
    expect(find.text('This answer stopped before it finished.'), findsOneWidget);
    expect(cubit.state.conversation!.items.first, isA<MemberMessage>());
    expect(store.chatUseCount, 0);
  });

  test('retry drops the incomplete answer and answers her last message again', () async {
    final FailingChatRepository failing = FailingChatRepository(repo);
    final String id = (await failing.createConversation()).id;
    await expectLater(failing.send(id, 'How can I sleep better?').drain<void>(), throwsException);
    expect((await repo.getConversation(id))!.items.whereType<AssistantAnswer>().single.streaming, isTrue);

    final ConversationCubit cubit = ConversationCubit(repo, id);
    await cubit.load();
    await cubit.retry();
    final List<ChatItem> items = cubit.state.conversation!.items;
    expect(items.whereType<AssistantAnswer>().single.streaming, isFalse);
    expect(items.whereType<MemberMessage>().length, 1);
    expect(store.chatUseCount, 1);
    await cubit.close();
  });

  testWidgets('send is inactive with guiding text when the box is empty', (WidgetTester tester) async {
    await pumpConversation(tester, repo);
    expect(find.text('Type a message to send'), findsOneWidget);
    expect(tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.arrow_upward_rounded)).onPressed, isNull);
    expect(find.text(
      'AI Care is not a doctor. It shares general wellness information from sources our clinicians have approved.',
    ), findsOneWidget);
  });
}
