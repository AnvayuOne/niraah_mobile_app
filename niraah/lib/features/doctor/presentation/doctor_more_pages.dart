import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/clinician_ui.dart';
import '../../../design_system/widgets/n_appearance.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../provider_auth/presentation/provider_pages.dart';
import '../../provider_work/domain/provider_work.dart';
import '../domain/doctor.dart';
import '../domain/doctor_work.dart';
import 'doctor_list_card.dart';
import 'doctor_shell.dart';
import 'patients_pages.dart';

/// More (spec 011 "Web and mobile": Home, Patients, Queue, Schedule, More): every other area of the workspace.
class DoctorMorePage extends StatefulWidget {
  const DoctorMorePage({super.key, this.repository, this.dashboard});

  final DoctorWorkRepository? repository;
  final DoctorRepository? dashboard;

  @override
  State<DoctorMorePage> createState() => _DoctorMorePageState();
}

class _DoctorMorePageState extends State<DoctorMorePage> {
  late final DoctorWorkRepository _repo = widget.repository ?? getIt<DoctorWorkRepository>();
  // ignore() keeps a late failure (after leaving the page) from surfacing as an uncaught error;
  // the FutureBuilder below still receives it.
  late final Future<Json> _profile = _repo.profile()..ignore();
  // The counts on the tiles come from the dashboard; without them the tiles simply show no badge.
  late final Future<NeedsMe?> _counts = _loadCounts();

  Future<NeedsMe?> _loadCounts() async {
    try {
      final DoctorRepository r = widget.dashboard ?? getIt<DoctorRepository>();
      return (await r.getDashboard()).needsMe;
    } on Object {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    String? badge(int? n) => n == null || n <= 0 ? null : '$n';
    return DoctorShell(
      index: 4,
      title: s.pvShellMore,
      body: FutureBuilder<Json>(
        future: _profile,
        builder: (BuildContext context, AsyncSnapshot<Json> prof) => FutureBuilder<NeedsMe?>(
          future: _counts,
          builder: (BuildContext context, AsyncSnapshot<NeedsMe?> cs) {
            final Json p = prof.data ?? const <String, dynamic>{};
            final NeedsMe? n = cs.data;
            final List<Widget> work = <Widget>[
              CHubTile(icon: Icons.notification_important_outlined, title: s.drAlerts, badge: badge(n?.urgentAlerts), onTap: () => context.push('/doctor/alerts')),
              CHubTile(icon: Icons.assignment_outlined, title: s.drCarePlans, badge: badge(n?.carePlans), onTap: () => context.push('/doctor/care-plans')),
              CHubTile(icon: Icons.science_outlined, title: s.drLabResults, badge: badge(n?.labResults), onTap: () => context.push('/doctor/labs')),
              CHubTile(icon: Icons.edit_note_rounded, title: s.drAdviceDrafts, badge: badge(n?.draftPrescriptions), onTap: () => context.push('/doctor/advice')),
              CHubTile(icon: Icons.forum_outlined, title: s.msgTitle, badge: badge(n?.messages), onTap: () => context.push('/doctor/messages')),
              // Shown only to a clinical reviewer (spec 011 §13).
              if (p.flag('clinicalReviewer')) CHubTile(icon: Icons.fact_check_outlined, title: s.drReviewerTasks, badge: badge(n?.clinicalReview), onTap: () => context.push('/doctor/reviewer')),
            ];
            final List<Widget> you = <Widget>[
              CHubTile(icon: Icons.account_balance_wallet_outlined, title: s.earnTitle, onTap: () => context.push('/doctor/earnings')),
              CHubTile(icon: Icons.person_outline_rounded, title: s.profileTitle, onTap: () => context.push('/doctor/profile')),
              CHubTile(icon: Icons.notifications_none_rounded, title: s.notifTitle, onTap: () => context.push(RouteNotifications.path)),
            ];
            return ListView(
              padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl),
              children: <Widget>[
                CHero(
                  eyebrow: s.pvShellMore,
                  title: p.str('name') ?? s.pvShellMore,
                  subtitle: s.drMoreSubtitle,
                  trailing: p.str('name') == null ? null : DecoratedBox(
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: NColors.surfaceCard, width: 2)),
                    child: CAvatar(name: p.str('name'), size: 48),
                  ),
                ),
                const SizedBox(height: NSpace.sm),
                CLabel(s.drMoreWork),
                DrStagger(children: work),
                CLabel(s.drMoreYou),
                DrStagger(children: you),
                const SizedBox(height: NSpace.md),
                const NAppearanceCard(),
                const SizedBox(height: NSpace.md),
                OutlinedButton.icon(onPressed: () => providerSignOut(context), icon: const Icon(Icons.logout_rounded), label: Text(s.pvSignOut)),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The member notification settings screen also serves providers (spec 015: `/me/notification-settings` is for all).
abstract final class RouteNotifications {
  static const String path = '/me/notifications';
}

String alertStatusName(S s, String? st) => switch (st) {
  'open' => s.drAlertOpen,
  'acknowledged' => s.drAlertAcknowledged,
  'resolved' => s.drAlertResolved,
  _ => st ?? '',
};

/// Alerts (spec 011 §12): urgent first, with what raised them and their age. Opening an on-call alert takes it
/// (AC35); actions are acknowledge, ask her to book, and resolve with a note.
class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key, this.repository});

  final DoctorWorkRepository? repository;

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  late final DoctorWorkRepository _repo = widget.repository ?? getIt<DoctorWorkRepository>();
  bool _resolved = false;
  late Future<List<Json>> _list = _load();

  Future<List<Json>> _load() => _repo.alerts(status: _resolved ? 'resolved' : 'unresolved');

  Future<void> _open(Json a) async {
    final S s = S.of(context);
    try {
      final Json d = await _repo.openAlert(a.str('id')!);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: NColors.surfaceCard,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(NRadius.xl))),
        builder: (_) => _AlertSheet(alert: d, member: a.obj('member'), repo: _repo),
      );
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    }
    if (mounted) setState(() => _list = _load());
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.drAlerts,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, 0),
            child: SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: <ButtonSegment<bool>>[
                ButtonSegment<bool>(value: false, label: Text(s.drAlertsOpen), icon: const Icon(Icons.notifications_active_outlined, size: 18)),
                ButtonSegment<bool>(value: true, label: Text(s.drAlertsResolved), icon: const Icon(Icons.task_alt_rounded, size: 18)),
              ],
              selected: <bool>{_resolved},
              onSelectionChanged: (Set<bool> v) => setState(() {
                _resolved = v.first;
                _list = _load();
              }),
            ),
          ),
          Expanded(
            child: AsyncBody<List<Json>>(
              future: _list,
              onRetry: () => setState(() => _list = _load()),
              builder: (BuildContext context, List<Json> rows) => rows.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(NSpace.md),
                      child: Align(alignment: Alignment.topCenter, child: CEmpty(icon: Icons.notifications_off_outlined, title: s.drNoAlerts)),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.md, NSpace.md, NSpace.xl),
                      children: <Widget>[
                        DrStagger(
                          children: <Widget>[
                            for (Json a in rows) _alertRow(s, a),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertRow(S s, Json a) {
    final bool urgent = a.str('severity') == 'urgent';
    final String st = a.str('status') ?? '';
    return DrListCard(
      name: a.obj('member').str('name') ?? s.drUnnamed,
      subtitle: a.str('raisedBy') ?? '',
      meta: <String>[alertStatusName(s, st), s.drAge(a.integer('ageMinutes'))].join(' · '),
      accent: st == 'resolved' ? NColors.statusSuccess : (urgent ? NColors.statusClinicalRedFlag : NColors.brandApricot),
      tint: urgent && st != 'resolved' ? NColors.statusClinicalRedFlagLight.withValues(alpha: 0.45) : null,
      onTap: () => _open(a),
      semanticsLabel: '${a.str('severity')}, ${a.obj('member').str('name')}, ${a.str('raisedBy')}',
      pills: <Widget>[
        if (urgent) CPill(s.drUrgent, tone: CTone.red),
        if (a.flag('onCall')) CPill(s.drOnCallAlert, tone: CTone.plum),
        if (!a.flag('opened')) CPill(s.drNotOpened, tone: CTone.apricot),
      ],
    );
  }
}

class _AlertSheet extends StatelessWidget {
  const _AlertSheet({required this.alert, required this.member, required this.repo});

  final Json alert;
  final Json member;
  final DoctorWorkRepository repo;

  Future<void> _do(BuildContext context, Future<void> Function() action, String done) async {
    try {
      await action();
      if (!context.mounted) return;
      Navigator.of(context).pop();
      showNote(context, done);
    } on Object catch (e) {
      if (context.mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<String> actions = alert.strs('actions');
    final String id = alert.str('id')!;
    final String status = alert.str('status') ?? '';
    final bool resolved = status == 'resolved';
    final bool urgent = alert.str('severity') == 'urgent';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.sm, NSpace.lg, NSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: NColors.lineStrong, borderRadius: BorderRadius.circular(NRadius.pill))),
            ),
            const SizedBox(height: NSpace.md),
            Row(
              children: <Widget>[
                CAvatar(name: member.str('name'), size: 48),
                const SizedBox(width: NSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(member.str('name') ?? s.drUnnamed, style: NType.h3.copyWith(color: NColors.inkPrimary)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: <Widget>[
                          if (urgent) CPill(s.drUrgent, tone: CTone.red),
                          CPill(alertStatusName(s, status), tone: resolved ? CTone.sage : (status == 'open' ? CTone.apricot : CTone.lavender)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: NSpace.md),
            DrTextBox(
              label: shortDate(context, alert.str('createdAt') ?? ''),
              text: alert.str('raisedBy') ?? '',
              icon: Icons.schedule_rounded,
              color: urgent ? NColors.statusClinicalRedFlagLight : NColors.surfacePage,
            ),
            const SizedBox(height: NSpace.md),
            NSecondaryButton(label: s.drOpenProfile, onPressed: () => context.push('/doctor/patients/${alert.str('memberId')}')),
            if (!resolved) ...<Widget>[
              if (actions.contains('acknowledge') && status == 'open') ...<Widget>[
                const SizedBox(height: NSpace.xs),
                NSecondaryButton(label: s.drAcknowledge, onPressed: () => _do(context, () => repo.acknowledgeAlert(id), s.drAcknowledged)),
              ],
              if (actions.contains('ask_to_book')) ...<Widget>[
                const SizedBox(height: NSpace.xs),
                NSecondaryButton(label: s.drAskToBook, onPressed: () => _do(context, () => repo.askToBook(id), s.drAskedToBook)),
              ],
              if (actions.contains('resolve')) ...<Widget>[
                const SizedBox(height: NSpace.xs),
                NPrimaryButton(
                  label: s.drResolve,
                  onPressed: () async {
                    final String? note = await promptText(context, s.drResolve, s.drResolveHint);
                    if (note == null || !context.mounted) return;
                    await _do(context, () => repo.resolveAlert(id, note), s.drResolved);
                  },
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

bool _isFlag(Json x) => x.str('flag') == 'low' || x.str('flag') == 'high' || (x.str('flag')?.isNotEmpty ?? false) && x.str('flag') != 'normal';

/// Results to review (spec 011 §9 "Results"): flagged first, then the report with markers and ranges; she marks it
/// reviewed with an optional plain-words comment. Values typed in by the member are said to be so.
class LabResultsPage extends StatefulWidget {
  const LabResultsPage({super.key, this.repository});

  final DoctorWorkRepository? repository;

  @override
  State<LabResultsPage> createState() => _LabResultsPageState();
}

class _LabResultsPageState extends State<LabResultsPage> {
  late final DoctorWorkRepository _repo = widget.repository ?? getIt<DoctorWorkRepository>();
  late Future<List<Json>> _list = _repo.labReportsToReview();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.drLabResults,
      body: AsyncBody<List<Json>>(
        future: _list,
        onRetry: () => setState(() => _list = _repo.labReportsToReview()),
        builder: (BuildContext context, List<Json> rows) => rows.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(NSpace.md),
                child: Align(alignment: Alignment.topCenter, child: CEmpty(icon: Icons.science_outlined, title: s.drNoLabResults)),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.sm, NSpace.md, NSpace.xl),
                children: <Widget>[
                  DrStagger(
                    children: <Widget>[
                      for (Json r in rows)
                        DrListCard(
                          name: r.obj('member').str('name') ?? s.drUnnamed,
                          semanticsLabel: r.obj('member').str('name'),
                          accent: r.flag('flagged') ? NColors.statusClinicalRedFlag : null,
                          subtitle: r.str('testDate') != null ? s.labsTestedOn(shortDate(context, r.str('testDate')!)) : null,
                          pills: <Widget>[
                            if (r.flag('flagged')) CPill(r.integer('flaggedCount') > 0 ? s.drFlaggedCount(r.integer('flaggedCount')) : s.drFlagged, tone: CTone.red),
                            if (r.flag('enteredByMember')) CPill(s.drTypedByMember, tone: CTone.lavender),
                          ],
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => LabReportReviewPage(reportId: r.str('id')!, repository: _repo),
                              ),
                            );
                            if (mounted) setState(() => _list = _repo.labReportsToReview());
                          },
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class LabReportReviewPage extends StatefulWidget {
  const LabReportReviewPage({required this.reportId, required this.repository, super.key});

  final String reportId;
  final DoctorWorkRepository repository;

  @override
  State<LabReportReviewPage> createState() => _LabReportReviewPageState();
}

class _LabReportReviewPageState extends State<LabReportReviewPage> {
  late Future<Json> _report = widget.repository.labReport(widget.reportId);
  final TextEditingController _comment = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _review({bool confirmMedicines = false}) async {
    final S s = S.of(context);
    setState(() => _busy = true);
    try {
      final String c = _comment.text.trim();
      final Json r = await widget.repository.reviewLab(widget.reportId, comment: c.isEmpty ? null : c, confirmMedicines: confirmMedicines);
      if (!mounted) return;
      setState(() => _report = Future<Json>.value(r));
      showNote(context, s.drReviewed);
    } on Object catch (e) {
      if (!mounted) return;
      final String msg = failureText(e, s.commonLoadError);
      // A comment that reads as a dose needs her confirmation (AC43).
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext d) => AlertDialog(
          content: Text(msg),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(s.commonCancel)),
            if (!confirmMedicines) FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(s.drConfirmOwnDoctor)),
          ],
        ),
      );
      if (confirm == true && mounted) {
        setState(() => _busy = false);
        await _review(confirmMedicines: true);
        return;
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.drLabReport,
      body: AsyncBody<Json>(
        future: _report,
        onRetry: () => setState(() => _report = widget.repository.labReport(widget.reportId)),
        builder: (BuildContext context, Json r) {
          final List<Json> all = r.objs('results');
          final List<Json> flagged = all.where(_isFlag).toList();
          final List<Json> rest = all.where((Json x) => !_isFlag(x)).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl),
            children: <Widget>[
              CHero(
                eyebrow: s.drLabReport,
                title: r.obj('member').str('name') ?? (r.str('testDate') != null ? s.labsTestedOn(shortDate(context, r.str('testDate')!)) : s.drLabReport),
                subtitle: <String>[
                  if (r.obj('member').str('name') != null && r.str('testDate') != null) s.labsTestedOn(shortDate(context, r.str('testDate')!)),
                  if (r.flag('typedByMember')) s.drTypedByMemberLong,
                ].join('\n'),
                child: CStatGrid(
                  children: <Widget>[
                    CHeroStat(label: s.drFlagged, value: '${flagged.length}', icon: Icons.flag_outlined, alert: flagged.isNotEmpty),
                    CHeroStat(label: s.drInRange, value: '${rest.length}', icon: Icons.check_circle_outline_rounded),
                    CHeroStat(label: s.labsResults, value: '${all.length}', icon: Icons.science_outlined),
                  ],
                ),
              ),
              if (flagged.isNotEmpty) ...<Widget>[
                const SizedBox(height: NSpace.md),
                CPanel(
                  title: s.drFlagged,
                  icon: Icons.flag_outlined,
                  action: CPill(s.drFlaggedCount(flagged.length), tone: CTone.red),
                  child: Column(children: <Widget>[for (Json x in flagged) _Marker(x: x)]),
                ),
              ],
              if (rest.isNotEmpty) ...<Widget>[
                const SizedBox(height: NSpace.md),
                CPanel(
                  title: s.labsResults,
                  icon: Icons.science_outlined,
                  child: Column(children: <Widget>[for (Json x in rest) _Marker(x: x)]),
                ),
              ],
              const SizedBox(height: NSpace.md),
              CPanel(
                title: s.drReview,
                icon: Icons.rate_review_outlined,
                action: r.flag('reviewed') ? CPill(s.drReviewed, tone: CTone.sage) : null,
                child: r.flag('reviewed')
                    ? (r.str('comment') != null ? DrTextBox(label: s.drCommentForHer, text: r.str('comment')!) : Text(s.drReviewed, style: NType.body.copyWith(color: NColors.inkPrimary)))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          TextField(
                            controller: _comment,
                            minLines: 2,
                            maxLines: 6,
                            maxLength: 2000,
                            decoration: InputDecoration(labelText: s.drCommentForHer),
                          ),
                          const SizedBox(height: NSpace.xs),
                          NPrimaryButton(label: s.drMarkReviewed, loading: _busy, onPressed: _review),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// One lab marker: name, value with unit, a flag pill, and where it sits in its printed range.
class _Marker extends StatelessWidget {
  const _Marker({required this.x});

  final Json x;

  String _n(num? v) => v == null ? '–' : (v == v.roundToDouble() ? v.toInt().toString() : v.toString());

  @override
  Widget build(BuildContext context) {
    final num? value = x.number('value');
    final num? low = x.obj('range').number('low');
    final num? high = x.obj('range').number('high');
    final String? flag = x.str('flag');
    final bool flagged = _isFlag(x);
    final bool hasRange = low != null || high != null;
    return Semantics(
      label: '${x.str('name')}: ${_n(value)} ${x.str('unit') ?? ''}${hasRange ? ' (${_n(low)}–${_n(high)})' : ''}${flag != null ? ' · $flag' : ''}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: NSpace.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(child: Text(x.str('name') ?? '', style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600))),
                Text(
                  _n(value),
                  style: NType.h4.copyWith(
                    color: flagged ? NColors.statusClinicalRedFlag : NColors.inkPrimary,
                    fontFamily: NType.body.fontFamily,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 4),
                Text(x.str('unit') ?? '', style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Expanded(child: hasRange && value != null ? _RangeBar(value: value.toDouble(), low: low?.toDouble(), high: high?.toDouble(), flagged: flagged) : const SizedBox.shrink()),
                if (hasRange) ...<Widget>[
                  const SizedBox(width: NSpace.sm),
                  Text('${_n(low)}–${_n(high)}', style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0)),
                ],
                if (flag != null && flag.isNotEmpty) ...<Widget>[const SizedBox(width: NSpace.xs), CPill(flag, tone: flagged ? CTone.red : CTone.sage)],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A track with the healthy range in sage and a dot where the value sits.
class _RangeBar extends StatelessWidget {
  const _RangeBar({required this.value, required this.flagged, this.low, this.high});

  final double value;
  final double? low;
  final double? high;
  final bool flagged;

  @override
  Widget build(BuildContext context) {
    final double lo = low ?? 0;
    final double hi = high ?? (lo * 2 == 0 ? 1 : lo * 2);
    final double span = (hi - lo).abs() < 1e-9 ? 1 : hi - lo;
    final double min = (low == null ? 0 : lo - span * 0.6);
    final double max = hi + span * 0.6;
    double f(double v) => ((v - min) / (max - min)).clamp(0.0, 1.0);
    return SizedBox(
      height: 14,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final double w = c.maxWidth;
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Container(height: 6, decoration: BoxDecoration(color: NColors.surfaceBackdrop, borderRadius: BorderRadius.circular(NRadius.pill))),
              Positioned(
                left: w * f(lo),
                width: w * (f(hi) - f(lo)),
                child: Container(height: 6, decoration: BoxDecoration(color: NColors.brandSage, borderRadius: BorderRadius.circular(NRadius.pill))),
              ),
              Positioned(
                left: (w * f(value) - 7).clamp(0.0, w - 14),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: flagged ? NColors.statusClinicalRedFlag : NColors.roleDoctor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Her profile (spec 011 §15): bio, languages, specialities and on call; registration, approval and rating are
/// read-only (changes need a document and admin review).
class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key, this.repository});

  final DoctorWorkRepository? repository;

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  late final DoctorWorkRepository _repo = widget.repository ?? getIt<DoctorWorkRepository>();
  late Future<Json> _profile = _repo.profile();
  final TextEditingController _bio = TextEditingController();
  final TextEditingController _languages = TextEditingController();
  final TextEditingController _specialities = TextEditingController();
  bool _filled = false;
  bool _busy = false;

  @override
  void dispose() {
    _bio.dispose();
    _languages.dispose();
    _specialities.dispose();
    super.dispose();
  }

  List<String> _split(String v) => v.split(',').map((String x) => x.trim()).where((String x) => x.isNotEmpty).toList();

  Future<void> _save({bool? onCall}) async {
    final S s = S.of(context);
    setState(() => _busy = true);
    try {
      final Json p = await _repo.updateProfile(
        bio: onCall == null ? _bio.text.trim() : null,
        languages: onCall == null ? _split(_languages.text) : null,
        specialities: onCall == null ? _split(_specialities.text) : null,
        onCall: onCall,
      );
      if (!mounted) return;
      setState(() => _profile = Future<Json>.value(p));
      showNote(context, s.profileSaved);
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.profileTitle,
      body: AsyncBody<Json>(
        future: _profile,
        onRetry: () => setState(() => _profile = _repo.profile()),
        builder: (BuildContext context, Json p) {
          if (!_filled) {
            _filled = true;
            _bio.text = p.str('bio') ?? '';
            _languages.text = p.strs('languages').join(', ');
            _specialities.text = p.strs('specialities').join(', ');
          }
          final Json reg = p.obj('registration');
          final Json rating = p.obj('rating');
          final bool onCall = p.flag('onCall');
          final String approval = p.str('approvalStatus') ?? '';
          return ListView(
            padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl),
            children: <Widget>[
              CHero(
                eyebrow: s.profileTitle,
                title: p.str('name') ?? '',
                subtitle: s.drApproval(approval),
                trailing: DecoratedBox(
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: NColors.surfaceCard, width: 2)),
                  child: CAvatar(name: p.str('name'), size: 56),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    if (rating.number('average') != null) ...<Widget>[
                      Semantics(
                        label: s.drRating(rating.number('average')!.toStringAsFixed(1), rating.integer('count')),
                        excludeSemantics: true,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              rating.number('average')!.toStringAsFixed(1),
                              style: NType.h1.copyWith(color: NColors.inkPrimary, fontFamily: NType.body.fontFamily, fontWeight: FontWeight.w700, height: 1, fontFeatures: const <FontFeature>[FontFeature.tabularFigures()]),
                            ),
                            const SizedBox(width: 6),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(Icons.star_rounded, size: 18, color: NColors.brandApricot),
                                  Text(s.drRatingCount(rating.integer('count')), style: NType.caption.copyWith(color: NColors.inkSecondary, letterSpacing: 0)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (p.str('reverifyBy') != null)
                      Flexible(
                        flex: 3,
                        child: Text(
                          s.drReverify(shortDate(context, p.str('reverifyBy')!)),
                          textAlign: TextAlign.end,
                          style: NType.caption.copyWith(color: NColors.inkSecondary, letterSpacing: 0),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.md),
              CEntrance(
                delayMs: 60,
                child: Material(
                  color: onCall ? NColors.brandApricotLight : NColors.surfaceCard,
                  borderRadius: BorderRadius.circular(NRadius.xl),
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(NRadius.xl), border: Border.all(color: onCall ? NColors.brandApricot : NColors.lineDefault)),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: NSpace.md, vertical: NSpace.xxs),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NRadius.xl)),
                      secondary: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: onCall ? NColors.roleDoctor : NColors.brandBlushLight, borderRadius: BorderRadius.circular(NRadius.md)),
                        child: Icon(Icons.phone_in_talk_outlined, size: 20, color: onCall ? NColors.brandApricot : NColors.brandRosewood),
                      ),
                      title: Text(s.drOnCallSwitch, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)),
                      subtitle: Text(s.drOnCallNote, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                      activeThumbColor: Colors.white,
                      activeTrackColor: NColors.roleDoctor,
                      value: onCall,
                      onChanged: _busy ? null : (bool v) => _save(onCall: v),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: NSpace.md),
              CPanel(
                title: s.drRegistrationTitle,
                icon: Icons.verified_outlined,
                action: CPill(approval, tone: approval == 'approved' ? CTone.sage : CTone.apricot),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (reg.str('number') == null)
                      DrTextBox(label: s.drRegistrationTitle, text: s.drNoRegistration, color: NColors.statusWarningLight, labelColor: NColors.statusWarningText, icon: Icons.error_outline_rounded)
                    else
                      Text(s.drRegistration(reg.str('number')!, reg.str('council') ?? ''), style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: NSpace.xs),
                    Text(s.drRegistrationNote, style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0)),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.md),
              CPanel(
                title: s.drAboutYou,
                icon: Icons.person_outline_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextField(
                      controller: _bio,
                      minLines: 3,
                      maxLines: 6,
                      maxLength: 1000,
                      decoration: InputDecoration(labelText: s.drBio),
                    ),
                    const SizedBox(height: NSpace.xs),
                    TextField(
                      controller: _languages,
                      decoration: InputDecoration(labelText: s.drLanguages, helperText: s.drCommaSeparated),
                    ),
                    const SizedBox(height: NSpace.sm),
                    TextField(
                      controller: _specialities,
                      decoration: InputDecoration(labelText: s.drSpecialities, helperText: s.drCommaSeparated),
                    ),
                    const SizedBox(height: NSpace.md),
                    NPrimaryButton(label: s.profileSave, loading: _busy, onPressed: _save),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Clinical reviewer tasks (spec 011 §13): the entry point and the counts. Each task's screen belongs to its
/// owner spec and opens on the web.
class ReviewerTasksPage extends StatefulWidget {
  const ReviewerTasksPage({super.key, this.repository});

  final DoctorWorkRepository? repository;

  @override
  State<ReviewerTasksPage> createState() => _ReviewerTasksPageState();
}

class _ReviewerTasksPageState extends State<ReviewerTasksPage> {
  late final DoctorWorkRepository _repo = widget.repository ?? getIt<DoctorWorkRepository>();
  late Future<Json> _tasks = _repo.reviewerTasks();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.drReviewerTasks,
      body: AsyncBody<Json>(
        future: _tasks,
        onRetry: () => setState(() => _tasks = _repo.reviewerTasks()),
        builder: (BuildContext context, Json t) {
          final List<Json> tasks = t.objs('tasks');
          final int total = tasks.fold<int>(0, (int a, Json x) => a + x.integer('count'));
          return ListView(
            padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl),
            children: <Widget>[
              CPanel(
                title: s.drReviewerTasks,
                icon: Icons.verified_user_outlined,
                note: s.drReviewerOnWeb,
                action: Text(
                  '$total',
                  style: NType.h2.copyWith(color: NColors.inkPrimary, fontFamily: NType.body.fontFamily, fontWeight: FontWeight.w700, fontFeatures: const <FontFeature>[FontFeature.tabularFigures()]),
                ),
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < tasks.length; i++)
                      CEntrance(
                        delayMs: 50 * i,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: NSpace.sm),
                          decoration: BoxDecoration(border: i == 0 ? null : Border(top: BorderSide(color: NColors.lineDefault))),
                          child: Row(
                            children: <Widget>[
                              Expanded(child: Text(tasks[i].str('label') ?? '', style: NType.body.copyWith(color: NColors.inkPrimary))),
                              const SizedBox(width: NSpace.sm),
                              Container(
                                constraints: const BoxConstraints(minWidth: 40),
                                padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: 4),
                                decoration: BoxDecoration(color: tasks[i].integer('count') > 0 ? NColors.roleDoctor : NColors.surfaceBackdrop, borderRadius: BorderRadius.circular(NRadius.pill)),
                                child: Text(
                                  '${tasks[i].integer('count')}',
                                  textAlign: TextAlign.center,
                                  style: NType.body.copyWith(color: tasks[i].integer('count') > 0 ? Colors.white : NColors.inkMuted, fontWeight: FontWeight.w700, fontFeatures: const <FontFeature>[FontFeature.tabularFigures()]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
