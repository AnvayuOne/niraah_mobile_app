import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../domain/community.dart';

/// Community (spec 010 §12): circles with their rules, joining and leaving, and the rules she accepts before her
/// first post (AC40).
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key, this.repository});

  final CommunityRepository? repository;

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  late final CommunityRepository _repo = widget.repository ?? getIt<CommunityRepository>();
  late Future<Circles> _circles = _repo.circles();

  void _reload() => setState(() => _circles = _repo.circles());

  Future<void> _do(Future<void> Function() action) async {
    try {
      await action();
      _reload();
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.communityTitle,
      body: AsyncBody<Circles>(
        future: _circles,
        onRetry: _reload,
        builder: (BuildContext context, Circles c) => ListView(
          padding: const EdgeInsets.all(NSpace.lg),
          children: <Widget>[
            if (c.rules case final CommunityRules r when !r.accepted) ...<Widget>[
              NCard(
                color: NColors.brandLavenderLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(s.communityRulesTitle, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                    const SizedBox(height: NSpace.xs),
                    Text(r.text, style: NType.body.copyWith(color: NColors.inkPrimary)),
                    const SizedBox(height: NSpace.sm),
                    NPrimaryButton(label: s.communityAcceptRules, onPressed: () => _do(() => _repo.acceptRules(r.version))),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.sm),
            ],
            NSectionTitle(s.communityCircles),
            if (c.circles.isEmpty) EmptyNote(text: s.communityNoCircles),
            for (Circle circle in c.circles) ...<Widget>[
              NCard(
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => CirclePage(repository: _repo, circle: circle, canPost: c.rules?.accepted ?? true, reminder: c.composeReminder),
                )),
                semanticsLabel: circle.name,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(child: Text(circle.name, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700))),
                        TextButton(
                          onPressed: () => _do(() async => _repo.setJoined(circle.id, !circle.joined)),
                          child: Text(circle.joined ? s.communityLeave : s.communityJoin),
                        ),
                      ],
                    ),
                    if (circle.rules != null) Text(circle.rules!, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.sm),
            ],
          ],
        ),
      ),
    );
  }
}

String authorLine(S s, Author a) {
  if (a.mine) return a.anonymous ? s.communityYouAnonymous : s.communityYou;
  if (a.anonymous) return s.communityAnonymous;
  if (a.expert) return a.title == null ? (a.name ?? s.communityMember) : '${a.name ?? ''}, ${a.title}';
  return a.name ?? s.communityMember;
}

/// After posting: the held-for-review note, and supportive resources at once on a self-harm signal (rule 8).
Future<void> showPosted(BuildContext context, Posted p, String done) async {
  if (p.resources != null) {
    await showDialog<void>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        content: Text(p.resources!),
        actions: <Widget>[TextButton(onPressed: () => Navigator.of(c).pop(), child: Text(S.of(c).homeClose))],
      ),
    );
  }
  if (context.mounted) showNote(context, p.beingReviewed ?? done);
}

/// A circle's posts, without authors she muted (AC41), and compose with the anonymous option (rule 2).
class CirclePage extends StatefulWidget {
  const CirclePage({required this.repository, required this.circle, required this.canPost, required this.reminder, super.key});

  final CommunityRepository repository;
  final Circle circle;
  final bool canPost;
  final String reminder;

  @override
  State<CirclePage> createState() => _CirclePageState();
}

class _CirclePageState extends State<CirclePage> {
  late Future<List<Post>> _feed = widget.repository.feed(widget.circle.id);

  void _reload() => setState(() => _feed = widget.repository.feed(widget.circle.id));

  Future<void> _compose() async {
    final S s = S.of(context);
    final ({String body, bool anonymous})? draft = await showModalBottomSheet<({String body, bool anonymous})>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ComposeSheet(reminder: widget.reminder, allowAnonymous: true),
    );
    if (draft == null || !mounted) return;
    try {
      final Posted p = await widget.repository.post(widget.circle.id, draft.body, anonymous: draft.anonymous);
      if (!mounted) return;
      await showPosted(context, p, s.communityPosted);
      _reload();
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: widget.circle.name,
      floatingActionButton: widget.canPost ? FloatingActionButton.extended(onPressed: _compose, icon: const Icon(Icons.edit_rounded), label: Text(s.communityNewPost)) : null,
      body: AsyncBody<List<Post>>(
        future: _feed,
        onRetry: _reload,
        builder: (BuildContext context, List<Post> posts) => RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, NSpace.lg, 96),
            children: <Widget>[
              if (!widget.canPost) ...<Widget>[Text(s.communityAcceptFirst, style: NType.bodySm.copyWith(color: NColors.inkSecondary)), const SizedBox(height: NSpace.sm)],
              if (posts.isEmpty) EmptyNote(text: s.communityFeedEmpty),
              for (Post p in posts) ...<Widget>[
                NCard(
                  semanticsLabel: '${authorLine(s, p.author)}: ${p.body}',
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ThreadPage(repository: widget.repository, postId: p.id, reminder: widget.reminder)));
                    _reload();
                  },
                  child: _PostBody(post: p),
                ),
                const SizedBox(height: NSpace.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PostBody extends StatelessWidget {
  const _PostBody({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            if (post.author.expert) Padding(padding: EdgeInsets.only(right: NSpace.xxs), child: Icon(Icons.verified_outlined, size: 16, color: NColors.roleDoctor)),
            Expanded(child: Text(authorLine(s, post.author), style: NType.caption.copyWith(color: NColors.inkSecondary, fontWeight: FontWeight.w600))),
            Text(shortDate(context, post.createdAt), style: NType.caption.copyWith(color: NColors.inkMuted)),
          ],
        ),
        const SizedBox(height: NSpace.xs),
        Text(post.body, style: NType.body.copyWith(color: NColors.inkPrimary)),
        const SizedBox(height: NSpace.xs),
        Text(
          <String>[s.communityReplies(post.comments), if (post.edited) s.communityEdited, if (post.beingReviewed) s.communityBeingReviewed].join(' · '),
          style: NType.caption.copyWith(color: NColors.inkMuted),
        ),
      ],
    );
  }
}

/// A post and its replies, with reply, report, mute, edit and delete (rules 5 and 9).
class ThreadPage extends StatefulWidget {
  const ThreadPage({required this.repository, required this.postId, required this.reminder, super.key});

  final CommunityRepository repository;
  final String postId;
  final String reminder;

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

enum _Action { report, mute, edit, delete }

class _ThreadPageState extends State<ThreadPage> {
  late Future<ThreadDocument> _thread = widget.repository.thread(widget.postId);

  void _reload() => setState(() => _thread = widget.repository.thread(widget.postId));

  Future<void> _try(Future<void> Function() action) async {
    try {
      await action();
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    }
  }

  Future<void> _reply() async {
    final S s = S.of(context);
    final ({String body, bool anonymous})? draft = await showModalBottomSheet<({String body, bool anonymous})>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ComposeSheet(reminder: widget.reminder, allowAnonymous: false),
    );
    if (draft == null || !mounted) return;
    await _try(() async {
      final Posted p = await widget.repository.comment(widget.postId, draft.body);
      if (!mounted) return;
      await showPosted(context, p, s.communityReplied);
      _reload();
    });
  }

  Future<void> _act(_Action a, String target, String id, {String? body}) async {
    final S s = S.of(context);
    switch (a) {
      case _Action.report:
        String? reason = await showDialog<String>(
          context: context,
          builder: (BuildContext c) => SimpleDialog(
            title: Text(s.communityReportTitle),
            children: <Widget>[for (String r in reportReasons) SimpleDialogOption(onPressed: () => Navigator.of(c).pop(r), child: Text(_reason(s, r)))],
          ),
        );
        if (reason == null) return;
        await _try(() async {
          await widget.repository.report(target, id, reason);
          if (mounted) showNote(context, s.communityReported);
        });
      case _Action.mute:
        await _try(() async {
          await widget.repository.mute(target, id);
          if (!mounted) return;
          showNote(context, s.communityMuted);
          if (target == 'post') Navigator.of(context).pop();
          if (target == 'comment') _reload();
        });
      case _Action.edit:
        final ({String body, bool anonymous})? draft = await showModalBottomSheet<({String body, bool anonymous})>(
          context: context,
          isScrollControlled: true,
          builder: (_) => ComposeSheet(reminder: widget.reminder, allowAnonymous: false, initial: body),
        );
        if (draft == null || !mounted) return;
        await _try(() async {
          final Posted p = await widget.repository.edit(id, draft.body);
          if (!mounted) return;
          await showPosted(context, p, s.communityEditedNote);
          _reload();
        });
      case _Action.delete:
        await _try(() async {
          if (target == 'post') {
            await widget.repository.deletePost(id);
            if (mounted) Navigator.of(context).pop();
          } else {
            await widget.repository.deleteComment(id);
            _reload();
          }
          if (mounted) showNote(context, s.communityDeleted);
        });
    }
  }

  static String _reason(S s, String r) => switch (r) {
        'harmful_advice' => s.communityReasonHarmful,
        'harassment' => s.communityReasonHarassment,
        'spam' => s.communityReasonSpam,
        'personal_information' => s.communityReasonPersonal,
        'self_harm' => s.communityReasonSelfHarm,
        _ => s.communityReasonOther,
      };

  Widget _menu(Author author, String target, String id, {String? body}) {
    final S s = S.of(context);
    return PopupMenuButton<_Action>(
      tooltip: s.communityMore,
      onSelected: (_Action a) => _act(a, target, id, body: body),
      itemBuilder: (_) => <PopupMenuEntry<_Action>>[
        if (author.mine) ...<PopupMenuEntry<_Action>>[
          if (target == 'post') PopupMenuItem<_Action>(value: _Action.edit, child: Text(s.communityEdit)),
          PopupMenuItem<_Action>(value: _Action.delete, child: Text(s.communityDelete)),
        ] else ...<PopupMenuEntry<_Action>>[
          PopupMenuItem<_Action>(value: _Action.report, child: Text(s.communityReport)),
          PopupMenuItem<_Action>(value: _Action.mute, child: Text(s.communityMute)),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.communityThread,
      floatingActionButton: FloatingActionButton.extended(onPressed: _reply, icon: const Icon(Icons.reply_rounded), label: Text(s.communityReply)),
      body: AsyncBody<ThreadDocument>(
        future: _thread,
        onRetry: _reload,
        builder: (BuildContext context, ThreadDocument t) => ListView(
          padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, NSpace.lg, 96),
          children: <Widget>[
            NCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[Expanded(child: _PostBody(post: t.post)), _menu(t.post.author, 'post', t.post.id, body: t.post.body)],
              ),
            ),
            NSectionTitle(s.communityReplies(t.comments.length)),
            for (Comment c in t.comments) ...<Widget>[
              NCard(
                color: NColors.surfaceWarm,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(authorLine(s, c.author), style: NType.caption.copyWith(color: NColors.inkSecondary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: NSpace.xxs),
                          Text(c.body, style: NType.body.copyWith(color: NColors.inkPrimary)),
                          if (c.beingReviewed) Text(s.communityBeingReviewed, style: NType.caption.copyWith(color: NColors.inkMuted)),
                        ],
                      ),
                    ),
                    _menu(c.author, 'comment', c.id),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.xs),
            ],
          ],
        ),
      ),
    );
  }
}

/// Writing a post or reply, with the reminder not to share contact details or others' health information
/// (rule 7) and, for posts, the anonymous choice (rule 2).
class ComposeSheet extends StatefulWidget {
  const ComposeSheet({required this.reminder, required this.allowAnonymous, super.key, this.initial});

  final String reminder;
  final bool allowAnonymous;
  final String? initial;

  @override
  State<ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends State<ComposeSheet> {
  late final TextEditingController _body = TextEditingController(text: widget.initial ?? '');
  bool _anonymous = false;

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, NSpace.lg, MediaQuery.of(context).viewInsets.bottom + NSpace.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(widget.reminder, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
          const SizedBox(height: NSpace.sm),
          TextField(controller: _body, autofocus: true, minLines: 3, maxLines: 8, maxLength: 5000, onChanged: (_) => setState(() {}), decoration: InputDecoration(labelText: s.communityWrite)),
          if (widget.allowAnonymous)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _anonymous,
              onChanged: (bool v) => setState(() => _anonymous = v),
              title: Text(s.communityPostAnonymously),
              subtitle: Text(s.communityAnonymousNote),
            ),
          const SizedBox(height: NSpace.sm),
          NPrimaryButton(
            label: s.communitySend,
            onPressed: _body.text.trim().isEmpty ? null : () => Navigator.of(context).pop((body: _body.text.trim(), anonymous: _anonymous)),
          ),
        ],
      ),
    );
  }
}
