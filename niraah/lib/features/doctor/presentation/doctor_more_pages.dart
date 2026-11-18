import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../provider_auth/presentation/provider_pages.dart';
import '../../provider_work/domain/provider_work.dart';
import '../domain/doctor_work.dart';
import 'doctor_shell.dart';
import 'patients_pages.dart';

/// More (spec 011 "Web and mobile": Home, Patients, Queue, Schedule, More): every other area of the workspace.
class DoctorMorePage extends StatefulWidget {
  const DoctorMorePage({super.key, this.repository});

  final DoctorWorkRepository? repository;

  @override
  State<DoctorMorePage> createState() => _DoctorMorePageState();
}

class _DoctorMorePageState extends State<DoctorMorePage> {
  late final DoctorWorkRepository _repo = widget.repository ?? getIt<DoctorWorkRepository>();
  late final Future<Json> _profile = _repo.profile();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    Widget row(IconData icon, String label, String path) => Padding(
      padding: const EdgeInsets.only(bottom: NSpace.xs),
      child: NCard(
        onTap: () => context.push(path),
        semanticsLabel: label,
        child: Row(
          children: <Widget>[
            Icon(icon, color: NColors.inkSecondary),
            const SizedBox(width: NSpace.sm),
            Expanded(
              child: Text(
                label,
                style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
          ],
        ),
      ),
    );
    return DoctorShell(
      index: 4,
      title: s.pvShellMore,
      body: ListView(
        padding: const EdgeInsets.all(NSpace.lg),
        children: <Widget>[
          row(Icons.notification_important_outlined, s.drAlerts, '/doctor/alerts'),
          row(Icons.assignment_outlined, s.drCarePlans, '/doctor/care-plans'),
          row(Icons.science_outlined, s.drLabResults, '/doctor/labs'),
          row(Icons.edit_note_rounded, s.drAdviceDrafts, '/doctor/advice'),
          row(Icons.forum_outlined, s.msgTitle, '/doctor/messages'),
          row(Icons.account_balance_wallet_outlined, s.earnTitle, '/doctor/earnings'),
          row(Icons.person_outline_rounded, s.profileTitle, '/doctor/profile'),
          // Shown only to a clinical reviewer (spec 011 §13).
          FutureBuilder<Json>(
            future: _profile,
            builder: (BuildContext context, AsyncSnapshot<Json> snap) =>
                snap.data?.flag('clinicalReviewer') ?? false ? row(Icons.fact_check_outlined, s.drReviewerTasks, '/doctor/reviewer') : const SizedBox.shrink(),
          ),
          row(Icons.notifications_none_rounded, s.notifTitle, RouteNotifications.path),
          const SizedBox(height: NSpace.md),
          OutlinedButton.icon(onPressed: () => providerSignOut(context), icon: const Icon(Icons.logout_rounded), label: Text(s.pvSignOut)),
        ],
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
            padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.sm, NSpace.lg, 0),
            child: SegmentedButton<bool>(
              segments: <ButtonSegment<bool>>[
                ButtonSegment<bool>(value: false, label: Text(s.drAlertsOpen)),
                ButtonSegment<bool>(value: true, label: Text(s.drAlertsResolved)),
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
                      padding: const EdgeInsets.all(NSpace.lg),
                      child: EmptyNote(text: s.drNoAlerts),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(NSpace.lg),
                      children: <Widget>[
                        for (final Json a in rows) ...<Widget>[
                          NCard(
                            color: a.str('severity') == 'urgent' ? NColors.statusClinicalRedFlagLight : NColors.surfaceCard,
                            onTap: () => _open(a),
                            semanticsLabel: '${a.str('severity')}, ${a.obj('member').str('name')}, ${a.str('raisedBy')}',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${a.str('severity') == 'urgent' ? '${s.drUrgent} · ' : ''}${a.obj('member').str('name') ?? s.drUnnamed}',
                                  style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
                                ),
                                Text(a.str('raisedBy') ?? '', style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                                Text(
                                  <String>[
                                    alertStatusName(s, a.str('status')),
                                    s.drAge(a.integer('ageMinutes')),
                                    if (a.flag('onCall')) s.drOnCallAlert,
                                    if (!a.flag('opened')) s.drNotOpened,
                                  ].join(' · '),
                                  style: NType.caption.copyWith(color: NColors.inkSecondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: NSpace.xs),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
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
    final bool resolved = alert.str('status') == 'resolved';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(NSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(member.str('name') ?? s.drUnnamed, style: NType.h3.copyWith(color: NColors.inkPrimary)),
            Text('${alert.str('raisedBy')} · ${shortDate(context, alert.str('createdAt') ?? '')}', style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
            Text(alertStatusName(s, alert.str('status')), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
            const SizedBox(height: NSpace.md),
            NSecondaryButton(label: s.drOpenProfile, onPressed: () => context.push('/doctor/patients/${alert.str('memberId')}')),
            if (!resolved) ...<Widget>[
              if (actions.contains('acknowledge') && alert.str('status') == 'open') ...<Widget>[
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
                padding: const EdgeInsets.all(NSpace.lg),
                child: EmptyNote(text: s.drNoLabResults),
              )
            : ListView(
                padding: const EdgeInsets.all(NSpace.lg),
                children: <Widget>[
                  for (final Json r in rows) ...<Widget>[
                    NCard(
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => LabReportReviewPage(reportId: r.str('id')!, repository: _repo),
                          ),
                        );
                        if (mounted) setState(() => _list = _repo.labReportsToReview());
                      },
                      semanticsLabel: r.obj('member').str('name'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            r.obj('member').str('name') ?? s.drUnnamed,
                            style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            <String>[
                              if (r.flag('flagged')) s.drFlagged,
                              if (r.str('testDate') != null) s.labsTestedOn(shortDate(context, r.str('testDate')!)),
                              if (r.flag('enteredByMember')) s.drTypedByMember,
                            ].join(' · '),
                            style: NType.caption.copyWith(color: NColors.inkSecondary),
                          ),
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
        builder: (BuildContext context, Json r) => ListView(
          padding: const EdgeInsets.all(NSpace.lg),
          children: <Widget>[
            if (r.str('testDate') != null) Text(s.labsTestedOn(shortDate(context, r.str('testDate')!)), style: NType.h4.copyWith(color: NColors.inkPrimary)),
            if (r.flag('typedByMember')) Text(s.drTypedByMemberLong, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
            NSectionTitle(s.labsResults),
            for (final Json x in r.objs('results'))
              Padding(
                padding: const EdgeInsets.only(bottom: NSpace.xs),
                child: Text(
                  '${x.str('name')}: ${x.number('value')} ${x.str('unit')}'
                  '${x.obj('range').number('low') != null || x.obj('range').number('high') != null ? ' (${x.obj('range').number('low') ?? '–'}–${x.obj('range').number('high') ?? '–'})' : ''}'
                  '${x.str('flag') != null ? ' · ${x.str('flag')}' : ''}',
                  style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: x.str('flag') == 'low' || x.str('flag') == 'high' ? FontWeight.w700 : FontWeight.w400),
                ),
              ),
            NSectionTitle(s.drReview),
            if (r.flag('reviewed')) ...<Widget>[
              Text(s.drReviewed, style: NType.body.copyWith(color: NColors.inkPrimary)),
              if (r.str('comment') != null) Text(r.str('comment')!, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
            ] else ...<Widget>[
              TextField(
                controller: _comment,
                minLines: 2,
                maxLines: 6,
                maxLength: 2000,
                decoration: InputDecoration(labelText: s.drCommentForHer),
              ),
              NPrimaryButton(label: s.drMarkReviewed, loading: _busy, onPressed: _review),
            ],
          ],
        ),
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
          return ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              Text(p.str('name') ?? '', style: NType.h3.copyWith(color: NColors.inkPrimary)),
              Text(s.drApproval(p.str('approvalStatus') ?? ''), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              if (p.str('reverifyBy') != null) Text(s.drReverify(shortDate(context, p.str('reverifyBy')!)), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              Text(
                reg.str('number') == null ? s.drNoRegistration : s.drRegistration(reg.str('number')!, reg.str('council') ?? ''),
                style: NType.bodySm.copyWith(color: reg.str('number') == null ? NColors.statusAttention : NColors.inkSecondary),
              ),
              if (rating.number('average') != null) Text(s.drRating(rating.number('average')!.toStringAsFixed(1), rating.integer('count')), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.drOnCallSwitch),
                value: p.flag('onCall'),
                onChanged: _busy ? null : (bool v) => _save(onCall: v),
              ),
              TextField(
                controller: _bio,
                minLines: 3,
                maxLines: 6,
                maxLength: 1000,
                decoration: InputDecoration(labelText: s.drBio),
              ),
              TextField(
                controller: _languages,
                decoration: InputDecoration(labelText: s.drLanguages, helperText: s.drCommaSeparated),
              ),
              TextField(
                controller: _specialities,
                decoration: InputDecoration(labelText: s.drSpecialities, helperText: s.drCommaSeparated),
              ),
              const SizedBox(height: NSpace.md),
              NPrimaryButton(label: s.profileSave, loading: _busy, onPressed: _save),
              const SizedBox(height: NSpace.sm),
              Text(s.drRegistrationNote, style: NType.caption.copyWith(color: NColors.inkMuted)),
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
        builder: (BuildContext context, Json t) => ListView(
          padding: const EdgeInsets.all(NSpace.lg),
          children: <Widget>[
            for (final Json x in t.objs('tasks'))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(x.str('label') ?? ''),
                trailing: Text('${x.integer('count')}', style: NType.h4.copyWith(color: NColors.inkPrimary)),
              ),
            const SizedBox(height: NSpace.sm),
            Text(s.drReviewerOnWeb, style: NType.caption.copyWith(color: NColors.inkMuted)),
          ],
        ),
      ),
    );
  }
}
