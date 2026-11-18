import 'package:material_ui/material_ui.dart';

import '../../core/di/service_locator.dart';
import '../../core/network/niraah_api.dart';
import '../../design_system/tokens/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/area/area_access.dart';
import '../../shared/area/area_widgets.dart';
import '../provider_work/domain/provider_work.dart';

/// Messaging between a member and her care team (spec 015; spec 011 §10; spec 012), the same screens for the
/// member and for doctors and dietitians. Matches packages/contracts/src/messaging.ts `Threads`, `Thread`.

/// A doctor's message that reads as a medicine or dose instruction is held until she confirms (spec 011 §10 rule 3).
class NeedsConfirmation implements Exception {
  const NeedsConfirmation(this.message);
  final String message;
}

abstract class MessagingRepository {
  Future<Json> threads();

  /// Members only: opens or reopens the thread with a clinician, giving the messages consent when asked.
  Future<Json> open(String providerId, {bool consent = false});
  Future<Json> thread(String id);

  /// Sending the same [clientId] twice stores one message. Returns the safety card when screening raised one.
  Future<Json> send(String threadId, String body, String clientId, {bool confirmMedicines = false});
  Future<void> setAway({String? note, DateTime? until});
}

class ApiMessagingRepository implements MessagingRepository {
  ApiMessagingRepository(this._api);

  final NiraahApi _api;

  static String _e(String id) => Uri.encodeComponent(id);

  @override
  Future<Json> threads() async => (await _api.get('/me/threads')).orArea();

  @override
  Future<Json> open(String providerId, {bool consent = false}) async => (await _api.post('/me/threads', <String, dynamic>{'providerId': providerId, if (consent) 'consentToMessages': true})).orArea();

  @override
  Future<Json> thread(String id) async => (await _api.get('/me/threads/${_e(id)}')).orArea();

  @override
  Future<Json> send(String threadId, String body, String clientId, {bool confirmMedicines = false}) async {
    final ApiResult<Map<String, dynamic>> r = await _api.post('/me/threads/${_e(threadId)}/messages', <String, dynamic>{
      'body': body,
      'clientId': clientId,
      if (confirmMedicines) 'confirmMedicines': true,
    });
    if (r is ApiFail<Map<String, dynamic>> && r.error.details?['reason'] == 'needs_confirmation') throw NeedsConfirmation(r.error.message);
    return r.orArea();
  }

  @override
  Future<void> setAway({String? note, DateTime? until}) async => (await _api.put('/provider/away', <String, dynamic>{'note': note, 'until': until?.toUtc().toIso8601String()})).orThrow();
}

/// Her threads, unread first in the server's order, and the clinicians she can start one with (members).
class ThreadsPage extends StatefulWidget {
  const ThreadsPage({super.key, this.repository, this.clinician = false});

  final MessagingRepository? repository;

  /// Doctors and dietitians can set an away note (spec 011 §10 rule 4).
  final bool clinician;

  @override
  State<ThreadsPage> createState() => _ThreadsPageState();
}

class _ThreadsPageState extends State<ThreadsPage> {
  late final MessagingRepository _repo = widget.repository ?? getIt<MessagingRepository>();
  late Future<Json> _data = _repo.threads();

  void _reload() => setState(() => _data = _repo.threads());

  Future<void> _openThread(String id) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ThreadPage(threadId: id, repository: _repo),
      ),
    );
    if (mounted) _reload();
  }

  Future<void> _start(Json c) async {
    final S s = S.of(context);
    bool consent = false;
    if (c.flag('needsConsent')) {
      final bool? ok = await showDialog<bool>(
        context: context,
        builder: (BuildContext d) => AlertDialog(
          title: Text(s.msgConsentTitle),
          content: Text(s.msgConsentBody(c.str('name') ?? '')),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(s.commonCancel)),
            FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(s.msgConsentAgree)),
          ],
        ),
      );
      if (ok != true) return;
      consent = true;
    }
    try {
      final Json t = await _repo.open(c.str('id')!, consent: consent);
      if (mounted) await _openThread(t.str('id')!);
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    }
  }

  Future<void> _away() async {
    final S s = S.of(context);
    final TextEditingController note = TextEditingController();
    final DateTime now = DateTime.now();
    final DateTime? until = await showDatePicker(
      context: context,
      helpText: s.msgAwayUntil,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (until == null || !mounted) return;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext d) => AlertDialog(
        title: Text(s.msgAwayTitle),
        content: TextField(
          controller: note,
          maxLength: 300,
          decoration: InputDecoration(labelText: s.msgAwayNote),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(s.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(s.drSave)),
        ],
      ),
    );
    final String text = note.text.trim();
    note.dispose();
    if (ok != true || !mounted) return;
    try {
      await _repo.setAway(note: text.isEmpty ? null : text, until: until);
      if (mounted) showNote(context, s.msgAwaySet(shortDate(context, until.toIso8601String())));
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.msgTitle,
      actions: <Widget>[if (widget.clinician) TextButton(onPressed: _away, child: Text(s.msgSetAway))],
      body: AsyncBody<Json>(
        future: _data,
        onRetry: _reload,
        builder: (BuildContext context, Json d) => RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              if (!widget.clinician && !d.flag('messagingOnPlan')) EmptyNote(text: s.msgNotOnPlan),
              if (d.objs('threads').isEmpty && (widget.clinician || d.flag('messagingOnPlan'))) EmptyNote(text: s.msgNoThreads),
              for (final Json t in d.objs('threads')) ...<Widget>[
                NCard(
                  onTap: () => _openThread(t.str('id')!),
                  semanticsLabel: '${t.obj('with').str('name') ?? ''}${t.integer('unread') > 0 ? ', ${s.msgUnread(t.integer('unread'))}' : ''}',
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              t.obj('with').str('name') ?? '',
                              style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              <String>[if (t.str('lastMessageAt') != null) shortDate(context, t.str('lastMessageAt')!), if (!t.flag('canSend')) t.str('readOnlyReason') ?? s.msgReadOnly].join(' · '),
                              style: NType.caption.copyWith(color: NColors.inkSecondary),
                            ),
                          ],
                        ),
                      ),
                      if (t.integer('unread') > 0) Badge(label: Text('${t.integer('unread')}')),
                    ],
                  ),
                ),
                const SizedBox(height: NSpace.xs),
              ],
              if (d.objs('canStart').isNotEmpty) ...<Widget>[
                NSectionTitle(s.msgStart),
                for (final Json c in d.objs('canStart'))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(c.str('name') ?? ''),
                    subtitle: Text(c.str('role') ?? ''),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _start(c),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One thread: messages oldest first, the away note and urgent line, and a composer with its reminder.
class ThreadPage extends StatefulWidget {
  const ThreadPage({required this.threadId, required this.repository, super.key});

  final String threadId;
  final MessagingRepository repository;

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  late Future<Json> _thread = widget.repository.thread(widget.threadId);
  final TextEditingController _body = TextEditingController();
  String _clientId = clientId();
  bool _sending = false;

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  Future<void> _send({bool confirm = false}) async {
    final S s = S.of(context);
    final String text = _body.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      final Json r = await widget.repository.send(widget.threadId, text, _clientId, confirmMedicines: confirm);
      if (!mounted) return;
      _body.clear();
      _clientId = clientId();
      final Json safety = r.obj('safety');
      if (safety.str('text') != null) {
        await showDialog<void>(
          context: context,
          builder: (BuildContext d) => AlertDialog(
            content: Text(safety.str('text')!),
            actions: <Widget>[TextButton(onPressed: () => Navigator.of(d).pop(), child: Text(s.homeClose))],
          ),
        );
      }
      if (mounted) setState(() => _thread = widget.repository.thread(widget.threadId));
    } on NeedsConfirmation catch (e) {
      if (!mounted) return;
      final bool? ok = await showDialog<bool>(
        context: context,
        builder: (BuildContext d) => AlertDialog(
          content: Text(e.message),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(s.msgEdit)),
            FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(s.msgSendAnyway)),
          ],
        ),
      );
      if (ok == true && mounted) {
        setState(() => _sending = false);
        await _send(confirm: true);
        return;
      }
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.msgTitle,
      body: AsyncBody<Json>(
        future: _thread,
        onRetry: () => setState(() => _thread = widget.repository.thread(widget.threadId)),
        builder: (BuildContext context, Json t) {
          final Json away = t.obj('away');
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: NSpace.xs),
                child: Text(t.obj('with').str('name') ?? '', style: NType.h4.copyWith(color: NColors.inkPrimary)),
              ),
              if (t.str('urgentLine') != null)
                Container(
                  width: double.infinity,
                  color: NColors.statusWarningLight,
                  padding: const EdgeInsets.all(NSpace.sm),
                  child: Text(t.str('urgentLine')!, style: NType.bodySm),
                ),
              if (away.str('until') != null)
                Padding(
                  padding: const EdgeInsets.all(NSpace.sm),
                  child: Text(s.msgAway(shortDate(context, away.str('until')!), away.str('note') ?? ''), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                ),
              if (t.str('replyExpectation') != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: NSpace.sm),
                  child: Text(t.str('replyExpectation')!, style: NType.caption.copyWith(color: NColors.inkMuted)),
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(NSpace.lg),
                  children: <Widget>[
                    for (final Json m in t.objs('messages'))
                      Align(
                        alignment: m.flag('mine') ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 320),
                          margin: const EdgeInsets.only(bottom: NSpace.xs),
                          padding: const EdgeInsets.all(NSpace.sm),
                          decoration: BoxDecoration(
                            color: m.flag('mine') ? NColors.brandLavenderLight : NColors.surfaceCard,
                            borderRadius: BorderRadius.circular(NRadius.lg),
                            border: Border.all(color: NColors.lineDefault),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (m.flag('deleted'))
                                Text(
                                  s.msgDeleted,
                                  style: NType.bodySm.copyWith(color: NColors.inkMuted, fontStyle: FontStyle.italic),
                                )
                              else if (m.str('body') != null)
                                Text(m.str('body')!),
                              if (m.obj('shared').str('answer') != null) ...<Widget>[
                                Text(s.msgSharedFromChat, style: NType.caption.copyWith(color: NColors.inkMuted)),
                                if (m.obj('shared').str('question') != null) Text(m.obj('shared').str('question')!, style: NType.bodySm.copyWith(fontWeight: FontWeight.w600)),
                                Text(m.obj('shared').str('answer')!, style: NType.bodySm),
                              ],
                              Text(shortDate(context, m.str('createdAt') ?? ''), style: NType.caption.copyWith(color: NColors.inkMuted)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (t.flag('canSend'))
                Padding(
                  padding: const EdgeInsets.fromLTRB(NSpace.lg, 0, NSpace.lg, NSpace.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (t.str('composeReminder') != null) Text(t.str('composeReminder')!, style: NType.caption.copyWith(color: NColors.inkMuted)),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _body,
                              minLines: 1,
                              maxLines: 4,
                              maxLength: 2000,
                              decoration: InputDecoration(hintText: s.msgWrite),
                            ),
                          ),
                          IconButton(tooltip: s.msgSend, onPressed: _sending ? null : _send, icon: const Icon(Icons.send_rounded)),
                        ],
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(NSpace.lg),
                  child: Text(t.str('readOnlyReason') ?? s.msgReadOnly, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                ),
            ],
          );
        },
      ),
    );
  }
}
