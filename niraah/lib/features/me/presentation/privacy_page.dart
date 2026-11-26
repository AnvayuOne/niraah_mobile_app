import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../../shared/constants/route_constants.dart';
import '../domain/me.dart';
import 'fresh_check.dart';

/// Privacy (spec 010 §13 "Privacy"): who can see her data with a switch to withdraw, staff access, the
/// personalised AI switch, chat history, export, and deleting her account. Every list comes from the server (AC43).
class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key, this.repository});

  final MeRepository? repository;

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyData {
  _PrivacyData(this.privacy, this.exports, this.exportRefusal);

  PrivacyDocument privacy;
  List<DataExport> exports;

  /// Set when her plan has no `data.export`: the export part shows that state, the rest still works.
  final AreaLocked? exportRefusal;
}

class _PrivacyPageState extends State<PrivacyPage> {
  late final MeRepository _repo = widget.repository ?? getIt<MeRepository>();
  late Future<_PrivacyData> _data = _load();
  bool _busy = false;

  Future<_PrivacyData> _load() async {
    final PrivacyDocument p = await _repo.privacy();
    try {
      return _PrivacyData(p, await _repo.exports(), null);
    } on AreaLocked catch (e) {
      return _PrivacyData(p, const <DataExport>[], e);
    }
  }

  void _reload() => setState(() => _data = _load());

  Future<bool> _confirm(String title, String body, String action) async {
    final S s = S.of(context);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text(s.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(c).pop(true), child: Text(action)),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _act(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _withdraw(_PrivacyData d, Consent c) async {
    final S s = S.of(context);
    if (!await _confirm(s.privacyWithdrawTitle, s.privacyWithdrawBody(c.who, c.category), s.privacyWithdraw)) return;
    await _act(() async {
      final PrivacyDocument p = await _repo.withdrawConsent(c.id);
      if (!mounted) return;
      setState(() => d.privacy = p);
      showNote(context, s.privacyWithdrawn);
    });
  }

  Future<void> _personalised(_PrivacyData d, bool on) => _act(() async {
        await _repo.setPersonalisedAi(on);
        final PrivacyDocument p = await _repo.privacy();
        if (mounted) setState(() => d.privacy = p);
      });

  Future<void> _deleteChats() async {
    final S s = S.of(context);
    if (!await _confirm(s.privacyChatTitle, s.privacyChatBody, s.privacyChatDelete)) return;
    await _act(() async {
      await _repo.deleteChatHistory();
      if (mounted) showNote(context, s.privacyChatDeleted);
    });
  }

  Future<void> _requestExport(_PrivacyData d) => _act(() async {
        final List<DataExport> list = await _repo.requestExport();
        if (!mounted) return;
        setState(() => d.exports = list);
        showNote(context, S.of(context).privacyExportRequested);
      });

  Future<void> _download(DataExport e) async {
    final String? proof = await freshCheck(context, _repo);
    if (proof == null || !mounted) return;
    await _act(() async {
      final Map<String, dynamic> file = await _repo.downloadExport(e.id, proof);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _ExportView(json: const JsonEncoder.withIndent('  ').convert(file))));
    });
  }

  Future<void> _deleteAccount() async {
    final S s = S.of(context);
    if (!await _confirm(s.privacyDeleteTitle, s.privacyDeleteBody, s.privacyDeleteContinue)) return;
    if (!mounted) return;
    final String? proof = await freshCheck(context, _repo);
    if (proof == null || !mounted) return;
    await _act(() async {
      final String on = await _repo.requestDeletion(proof);
      if (!mounted) return;
      showNote(context, s.privacyDeleteStarted(shortDate(context, on)));
      context.go('${RouteConstants.accountStatus}?state=deletion_pending');
    });
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.privacyTitle,
      body: AsyncBody<_PrivacyData>(
        future: _data,
        onRetry: _reload,
        builder: (BuildContext context, _PrivacyData d) {
          final PrivacyDocument p = d.privacy;
          final bool teen = p.accountKind == 'teen';
          return ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              NSectionTitle(s.privacyWhoCanSee),
              if (p.consents.isEmpty) EmptyNote(text: s.privacyNoConsents),
              for (final Consent c in p.consents) ...<Widget>[
                NCard(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(c.role == null ? c.who : '${c.who} · ${c.role}', style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                            Text('${c.category} · ${c.purpose}', style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                            Text(s.privacyGivenOn(shortDate(context, c.givenOn)), style: NType.caption.copyWith(color: NColors.inkMuted)),
                          ],
                        ),
                      ),
                      Switch(value: true, onChanged: _busy ? null : (_) => _withdraw(d, c)),
                    ],
                  ),
                ),
                const SizedBox(height: NSpace.xs),
              ],
              NSectionTitle(s.privacyStaffAccess),
              if (p.staffAccess.isEmpty) EmptyNote(text: s.privacyNoStaffAccess),
              for (final StaffAccess a in p.staffAccess)
                Padding(
                  padding: const EdgeInsets.only(bottom: NSpace.xs),
                  child: Text('${shortDate(context, a.on)} · ${a.reason}', style: NType.body.copyWith(color: NColors.inkPrimary)),
                ),
              if (!teen) ...<Widget>[
                NSectionTitle(s.privacyAiTitle),
                NCard(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: p.personalisedAi,
                    onChanged: _busy ? null : (bool on) => _personalised(d, on),
                    title: Text(s.privacyAiSwitch, style: NType.body.copyWith(color: NColors.inkPrimary)),
                    subtitle: Text(p.personalisedAi ? s.privacyAiOn : s.privacyAiOff, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                  ),
                ),
              ],
              NSectionTitle(s.privacyChatTitle),
              NSecondaryButton(label: s.privacyChatDelete, onPressed: _busy ? null : _deleteChats),
              NSectionTitle(s.privacyExportTitle),
              if (d.exportRefusal != null)
                EmptyNote(text: d.exportRefusal!.description ?? d.exportRefusal!.message, actionLabel: s.areaSeePlans, onAction: () => context.push(RouteConstants.plans))
              else ...<Widget>[
                Text(s.privacyExportBody, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                const SizedBox(height: NSpace.sm),
                for (final DataExport e in d.exports) ...<Widget>[
                  NCard(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(s.privacyExportRequestedOn(shortDate(context, e.requestedAt)), style: NType.body.copyWith(color: NColors.inkPrimary)),
                              Text(
                                e.ready && e.expiresAt != null ? s.privacyExportReadyUntil(shortDate(context, e.expiresAt!)) : _exportStatus(s, e.status),
                                style: NType.bodySm.copyWith(color: NColors.inkSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (e.ready) TextButton(onPressed: _busy ? null : () => _download(e), child: Text(s.privacyExportOpen)),
                      ],
                    ),
                  ),
                  const SizedBox(height: NSpace.xs),
                ],
                NSecondaryButton(label: s.privacyExportRequest, onPressed: _busy ? null : () => _requestExport(d)),
              ],
              // Sign-out of other devices (spec 010 §13 "Privacy" 7; spec 003 "Sessions" 7, 8).
              NSectionTitle(s.acctDevicesTitle),
              NSecondaryButton(label: s.acctDevicesOpen, onPressed: () => context.push(RouteConstants.signedInDevices)),
              NSectionTitle(s.privacyDeleteTitle),
              Text(s.privacyDeleteSummary, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              const SizedBox(height: NSpace.sm),
              NSecondaryButton(label: s.privacyDeleteAction, onPressed: _busy ? null : _deleteAccount),
            ],
          );
        },
      ),
    );
  }

  static String _exportStatus(S s, String status) => switch (status) {
        'expired' => s.privacyExportExpired,
        'failed' => s.privacyExportFailed,
        _ => s.privacyExportPreparing,
      };
}

/// Her export, readable and copyable. The file is only shown while she is signed in and after a fresh check (AC45).
class _ExportView extends StatelessWidget {
  const _ExportView({required this.json});

  final String json;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.privacyExportTitle,
      actions: <Widget>[
        IconButton(
          tooltip: s.privacyExportCopy,
          icon: const Icon(Icons.copy_rounded),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: json));
            if (context.mounted) showNote(context, s.privacyExportCopied);
          },
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(NSpace.lg),
        child: SelectableText(json, style: NType.caption.copyWith(color: NColors.inkPrimary, fontFamily: 'monospace')),
      ),
    );
  }
}
