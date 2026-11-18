import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/motion/motion.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/constants/route_constants.dart';
import '../../cycle/domain/cycle.dart';
import '../domain/chat.dart';
import 'chat_cubits.dart';

/// One AI Care conversation (spec 010 §8, spec 009 "Chat"). Answers grow
/// sentence by sentence; safety messages are cards, never bubbles; there is
/// no "Share with Doctor" control unless her plan allows it (AC29).
class ConversationPage extends StatelessWidget {
  const ConversationPage({required this.conversationId, super.key, this.initialMessage, this.cubit});

  final String conversationId;

  /// A starter prompt to send as soon as the conversation opens.
  final String? initialMessage;

  /// For tests and screenshots.
  final ConversationCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final Widget view = _ConversationView(initialMessage: initialMessage);
    final ConversationCubit? given = cubit;
    return given != null
        ? BlocProvider<ConversationCubit>.value(value: given, child: view)
        : BlocProvider<ConversationCubit>(create: (_) => ConversationCubit(getIt<ChatRepository>(), conversationId)..load(), child: view);
  }
}

class _ConversationView extends StatefulWidget {
  const _ConversationView({this.initialMessage});

  final String? initialMessage;

  @override
  State<_ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<_ConversationView> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _sentInitial = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final double end = _scroll.position.maxScrollExtent;
      if (NMotionRules.reduced(context)) {
        _scroll.jumpTo(end);
      } else {
        _scroll.animateTo(end, duration: NMotion.fast, curve: NMotionRules.curve);
      }
    });
  }

  void _send() {
    final String t = _input.text;
    _input.clear();
    setState(() {});
    context.read<ConversationCubit>().send(t);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocConsumer<ConversationCubit, ConversationState>(
      listenWhen: (ConversationState a, ConversationState b) => a.conversation != b.conversation || a.deleted != b.deleted || a.status != b.status,
      listener: (BuildContext context, ConversationState st) {
        if (st.deleted) {
          context.canPop() ? context.pop() : context.go(RouteConstants.chat);
          return;
        }
        if (st.status == ChatLoad.ready && !_sentInitial && widget.initialMessage != null) {
          _sentInitial = true;
          context.read<ConversationCubit>().send(widget.initialMessage!);
        }
        _toBottom();
      },
      builder: (BuildContext context, ConversationState st) {
        final Conversation? c = st.conversation;
        final ChatHome? home = st.home;
        if (st.status == ChatLoad.failure) return Scaffold(body: ErrorView(message: s.commonLoadError));
        if (c == null || home == null) return Scaffold(body: LoadingView(label: s.loading));
        final bool waiting = st.sending && (c.items.isEmpty || c.items.last is MemberMessage) && !st.failed;
        final bool failedWithoutAnswer = st.failed && c.items.isNotEmpty && c.items.last is MemberMessage;
        return Scaffold(
          backgroundColor: NColors.surfacePage,
          appBar: AppBar(
            backgroundColor: NColors.surfacePage,
            leading: IconButton(
              tooltip: s.chatBack,
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.canPop() ? context.pop() : context.go(RouteConstants.chat),
            ),
            title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: NType.h4.copyWith(color: NColors.inkPrimary)),
            actions: <Widget>[
              PopupMenuButton<String>(
                tooltip: '${s.chatRename}, ${s.chatDelete}',
                onSelected: (String v) => v == 'rename' ? _renameSheet(context, c.title) : _deleteSheet(context),
                itemBuilder: (_) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(value: 'rename', child: Text(s.chatRename)),
                  PopupMenuItem<String>(value: 'delete', child: Text(s.chatDelete)),
                ],
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.md),
                    children: <Widget>[
                      // The not-a-doctor line, once, at the top.
                      Padding(
                        padding: const EdgeInsets.only(bottom: NSpace.md),
                        child: Text(home.notADoctor, textAlign: TextAlign.center, style: NType.label.copyWith(color: NColors.inkMuted)),
                      ),
                      for (final ChatItem i in c.items)
                        switch (i) {
                          final MemberMessage m => _MemberBubble(text: m.text),
                          final AssistantAnswer a => _AnswerBubble(
                              answer: a,
                              footer: home.footer,
                              stopped: a.incomplete || (st.failed && a.streaming),
                              onRetry: st.sending ? null : context.read<ConversationCubit>().retry,
                            ),
                          final SafetyItem sf => _SafetyCardView(card: sf.card),
                        },
                      if (waiting)
                        Padding(
                          padding: const EdgeInsets.only(top: NSpace.xs),
                          child: Semantics(liveRegion: true, child: Text(s.chatThinking, style: NType.bodySm.copyWith(color: NColors.inkMuted))),
                        ),
                      if (failedWithoutAnswer) _Incomplete(onRetry: st.sending ? null : context.read<ConversationCubit>().retry),
                    ],
                  ),
                ),
                if (st.atLimit) _LimitCard(home: home),
                _InputBar(controller: _input, home: home, sending: st.sending, onChanged: () => setState(() {}), onSend: _send),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _renameSheet(BuildContext context, String current) {
    final S s = S.of(context);
    final ConversationCubit cubit = context.read<ConversationCubit>();
    final TextEditingController name = TextEditingController(text: current);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: NColors.surfacePage,
      builder: (BuildContext sheet) => Padding(
        padding: EdgeInsets.fromLTRB(NSpace.lg, 0, NSpace.lg, NSpace.lg + MediaQuery.viewInsetsOf(sheet).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Semantics(header: true, child: Text(s.chatRename, style: NType.h3.copyWith(color: NColors.inkPrimary))),
            const SizedBox(height: NSpace.md),
            TextField(controller: name, autofocus: true, maxLength: 60, decoration: InputDecoration(labelText: s.chatRenameLabel)),
            const SizedBox(height: NSpace.sm),
            NPrimaryButton(
              label: s.chatSave,
              onPressed: () async {
                await cubit.rename(name.text);
                if (sheet.mounted) Navigator.of(sheet).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSheet(BuildContext context) {
    final S s = S.of(context);
    final ConversationCubit cubit = context.read<ConversationCubit>();
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: NColors.surfacePage,
      builder: (BuildContext sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(NSpace.lg, 0, NSpace.lg, NSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(s.chatDeleteConfirm, style: NType.body.copyWith(color: NColors.inkPrimary)),
              const SizedBox(height: NSpace.md),
              NPrimaryButton(
                label: s.chatDeleteYes,
                onPressed: () {
                  Navigator.of(sheet).pop();
                  cubit.delete();
                },
              ),
              const SizedBox(height: NSpace.xs),
              NSecondaryButton(label: s.chatCancel, onPressed: () => Navigator.of(sheet).pop()),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberBubble extends StatelessWidget {
  const _MemberBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        margin: const EdgeInsets.only(bottom: NSpace.sm),
        padding: const EdgeInsets.symmetric(horizontal: NSpace.md, vertical: NSpace.sm),
        decoration: BoxDecoration(
          color: NColors.brandBlushLight,
          borderRadius: BorderRadius.circular(NRadius.lg).copyWith(bottomRight: const Radius.circular(NRadius.sm / 2)),
        ),
        child: Semantics(label: '${s.chatYou}: $text', excludeSemantics: true, child: Text(text, style: NType.body.copyWith(color: NColors.inkPrimary))),
      ),
    );
  }
}

class _AnswerBubble extends StatelessWidget {
  const _AnswerBubble({required this.answer, required this.footer, required this.stopped, required this.onRetry});

  final AssistantAnswer answer;
  final String footer;
  final bool stopped;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<CitedSentence> body = answer.sentences.where((CitedSentence x) => x.text != footer).toList();
    final bool hasFooter = answer.sentences.isNotEmpty && answer.sentences.last.text == footer;
    final bool finished = !answer.streaming && !stopped;
    final String spoken = '${s.chatAssistant}: ${answer.sentences.map((CitedSentence x) => x.text).join(' ')}';
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.88),
        margin: const EdgeInsets.only(bottom: NSpace.sm),
        padding: const EdgeInsets.all(NSpace.md),
        decoration: BoxDecoration(
          color: NColors.surfaceCard,
          borderRadius: BorderRadius.circular(NRadius.lg).copyWith(bottomLeft: const Radius.circular(NRadius.sm / 2)),
          border: Border.all(color: NColors.lineDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // A polite announcement once the whole answer is there; while it
            // streams, a screen reader hears that AI Care is writing.
            Semantics(
              liveRegion: finished,
              label: finished ? spoken : s.chatThinking,
              excludeSemantics: true,
              child: Text(body.map((CitedSentence x) => x.text).join(' '), style: NType.body.copyWith(color: NColors.inkPrimary)),
            ),
            if (hasFooter) ...<Widget>[
              const SizedBox(height: NSpace.xs),
              ExcludeSemantics(child: Text(footer, style: NType.label.copyWith(color: NColors.inkMuted))),
            ],
            if (stopped) _Incomplete(onRetry: onRetry),
            if (finished && answer.sources.isNotEmpty) ...<Widget>[
              const SizedBox(height: NSpace.sm),
              Text(s.chatSources, style: NType.label.copyWith(color: NColors.inkSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: NSpace.xxs),
              Wrap(
                spacing: NSpace.xs,
                runSpacing: NSpace.xs,
                children: <Widget>[
                  // Wraps rather than truncating, so the whole title and publisher are readable.
                  for (final ChatSource src in answer.sources)
                    Semantics(
                      button: true,
                      label: '${s.chatSources}: ${src.title} · ${src.publisher}',
                      excludeSemantics: true,
                      child: Material(
                        color: NColors.surfacePage,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NRadius.lg), side: const BorderSide(color: NColors.lineDefault)),
                        child: InkWell(
                          onTap: () => _sourceSheet(context, src),
                          borderRadius: BorderRadius.circular(NRadius.lg),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: NLayout.minTapTarget),
                            padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: NSpace.xs),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(Icons.menu_book_rounded, size: NSpace.md, color: NColors.actionLink),
                                const SizedBox(width: NSpace.xs),
                                Flexible(child: Text('${src.title} · ${src.publisher}', style: NType.label.copyWith(color: NColors.inkPrimary))),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _sourceSheet(BuildContext context, ChatSource src) async {
    final S s = S.of(context);
    final List<Passage> passages = await context.read<ConversationCubit>().passagesFor(answer, src);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: NColors.surfacePage,
      builder: (BuildContext sheet) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(NSpace.lg, 0, NSpace.lg, NSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(s.chatSourceSheetTitle.toUpperCase(), style: NType.caption.copyWith(color: NColors.inkMuted)),
              const SizedBox(height: NSpace.xs),
              Semantics(header: true, child: Text(src.title, style: NType.h3.copyWith(color: NColors.inkPrimary))),
              Text(src.publisher, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              const SizedBox(height: NSpace.md),
              for (final Passage p in passages)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: NSpace.sm),
                  padding: const EdgeInsets.all(NSpace.md),
                  decoration: BoxDecoration(
                    color: NColors.surfaceCard,
                    borderRadius: BorderRadius.circular(NRadius.lg),
                    border: const Border(left: BorderSide(color: NColors.brandLavender, width: 4)),
                  ),
                  child: Text(p.text, style: NType.body.copyWith(color: NColors.inkSecondary)),
                ),
              const SizedBox(height: NSpace.xs),
              NSecondaryButton(label: S.of(sheet).homeClose, onPressed: () => Navigator.of(sheet).pop()),
            ],
          ),
        ),
      ),
    );
  }
}

class _Incomplete extends StatelessWidget {
  const _Incomplete({required this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: NSpace.xs),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: NSpace.xs,
        children: <Widget>[
          Semantics(liveRegion: true, child: Text(s.chatIncomplete, style: NType.bodySm.copyWith(color: NColors.statusAttention))),
          TextButton(onPressed: onRetry, child: Text(s.chatTryAgain)),
        ],
      ),
    );
  }
}

class _SafetyCardView extends StatelessWidget {
  const _SafetyCardView({required this.card});

  final SafetyCard card;

  Future<void> _act(BuildContext context, SafetyAction a) async {
    if (a.href.startsWith('tel:')) {
      await launchUrl(Uri.parse(a.href));
    } else {
      context.go(a.href);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool crisis = card.kind == SafetyKind.crisis;
    return Semantics(
      container: true,
      liveRegion: true,
      label: card.title,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: NSpace.sm),
        padding: const EdgeInsets.all(NSpace.lg),
        decoration: BoxDecoration(
          color: crisis ? NColors.brandLavenderLight : NColors.statusAttentionLight,
          borderRadius: BorderRadius.circular(NRadius.xl),
          border: Border.all(color: crisis ? NColors.brandLavender : NColors.statusAttention.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(crisis ? Icons.favorite_rounded : Icons.health_and_safety_rounded, color: crisis ? NColors.statusInfo : NColors.statusAttention),
                const SizedBox(width: NSpace.sm),
                Expanded(child: Text(card.title, style: NType.h4.copyWith(color: crisis ? NColors.statusInfo : NColors.statusAttention))),
              ],
            ),
            const SizedBox(height: NSpace.xs),
            Text(card.text, style: NType.body.copyWith(color: NColors.inkSecondary)),
            const SizedBox(height: NSpace.md),
            for (final (int i, SafetyAction a) in card.actions.indexed) ...<Widget>[
              if (i > 0) const SizedBox(height: NSpace.xs),
              i == 0 ? NPrimaryButton(label: a.label, onPressed: () => _act(context, a)) : NSecondaryButton(label: a.label, onPressed: () => _act(context, a)),
            ],
          ],
        ),
      ),
    );
  }
}

class _LimitCard extends StatelessWidget {
  const _LimitCard({required this.home});

  final ChatHome home;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String resets = DateFormat('d MMMM', Localizations.localeOf(context).toString()).format(IsoDates.toLocalDate(home.allowance.resetsAt));
    return Container(
      margin: const EdgeInsets.fromLTRB(NSpace.md, 0, NSpace.md, NSpace.sm),
      padding: const EdgeInsets.all(NSpace.md),
      decoration: BoxDecoration(color: NColors.brandApricotLight, borderRadius: BorderRadius.circular(NRadius.lg)),
      child: Semantics(
        container: true,
        liveRegion: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(s.chatLimitTitle, style: NType.h4.copyWith(color: NColors.inkPrimary)),
            const SizedBox(height: NSpace.xxs),
            Text(s.chatLimitText(home.allowance.limit, resets), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
            if (home.plansWithMore.isNotEmpty) Text(s.chatLimitPlans(home.plansWithMore.join(', ')), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
            Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: () => context.push(RouteConstants.plans), child: Text(s.chatSeePlans))),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.home, required this.sending, required this.onChanged, required this.onSend});

  final TextEditingController controller;
  final ChatHome home;
  final bool sending;
  final VoidCallback onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool empty = controller.text.trim().isEmpty;
    final int remaining = home.allowance.remaining;
    return Container(
      padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.sm, NSpace.md, NSpace.sm),
      decoration: const BoxDecoration(color: NColors.surfaceCard, border: Border(top: BorderSide(color: NColors.lineDefault))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (home.allowance.showRemaining && remaining > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: NSpace.xs),
              child: Text(s.chatRemaining(remaining), style: NType.label.copyWith(color: NColors.inkMuted)),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onChanged: (_) => onChanged(),
                  onSubmitted: (_) => empty || sending ? null : onSend(),
                  decoration: InputDecoration(labelText: s.chatInputLabel, hintText: s.chatInputPlaceholder, floatingLabelBehavior: FloatingLabelBehavior.never),
                ),
              ),
              const SizedBox(width: NSpace.xs),
              IconButton.filled(
                tooltip: empty ? s.chatSendInactive : s.chatSend,
                onPressed: empty || sending ? null : onSend,
                style: IconButton.styleFrom(
                  backgroundColor: NColors.actionPrimary,
                  foregroundColor: NColors.actionOnPrimary,
                  disabledBackgroundColor: NColors.actionDisabled,
                  disabledForegroundColor: NColors.actionOnDisabled,
                  minimumSize: const Size(NLayout.minTapTarget + NSpace.xs, NLayout.minTapTarget + NSpace.xs),
                ),
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
            ],
          ),
          if (empty)
            Padding(
              padding: const EdgeInsets.only(top: NSpace.xxs),
              child: ExcludeSemantics(child: Text(s.chatSendInactive, style: NType.label.copyWith(color: NColors.inkMuted))),
            ),
        ],
      ),
    );
  }
}
