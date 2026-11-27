import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/di/service_locator.dart';
import '../../design_system/generated/niraah_assets.dart';
import '../../design_system/theme/theme_controller.dart';
import '../../design_system/tokens/tokens.dart';
import '../../design_system/widgets/bottom_nav.dart';
import '../../design_system/widgets/clinician_ui.dart';
import '../../design_system/widgets/n_appearance.dart';
import '../../design_system/widgets/n_button.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/area/area_access.dart';
import '../../shared/area/area_widgets.dart';
import '../../shared/constants/route_constants.dart';
import '../provider_auth/presentation/provider_pages.dart';
import '../provider_work/domain/provider_work.dart';
import 'instructor_repository.dart';

const List<String> _phases = <String>['menstrual', 'follicular', 'ovulatory', 'luteal'];
const List<String> _levels = <String>['gentle', 'beginner', 'intermediate', 'advanced'];

/// The instructor workspace frame (spec 013 "Web and mobile"): Home, Sessions, Students, Library, More.
class InstructorShell extends StatelessWidget {
  const InstructorShell({required this.index, required this.body, super.key, this.title, this.floatingActionButton});

  final int index;
  final Widget body;
  final String? title;
  final Widget? floatingActionButton;

  static const List<String> paths = <String>['/instructor', '/instructor/sessions', '/instructor/students', '/instructor/library', '/instructor/more'];
  static const List<IconData> icons = <IconData>[Icons.home_rounded, Icons.event_note_outlined, Icons.groups_outlined, Icons.video_library_outlined, Icons.more_horiz_rounded];

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    CRole.fallback = CRole.instructor(child: SizedBox.shrink());
    return Scaffold(
      backgroundColor: NColors.surfacePage,
      appBar: AppBar(
        backgroundColor: NColors.surfacePage,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: NSpace.lg,
        title: Row(
          children: <Widget>[
            Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: NColors.brandPlum, shape: BoxShape.circle),
              child: Image.asset(NImages.niraahLogo.path, fit: BoxFit.contain, excludeFromSemantics: true),
            ),
            const SizedBox(width: NSpace.sm),
            Flexible(
              child: Text(
                title ?? s.inWorkspace,
                overflow: TextOverflow.ellipsis,
                style: NType.h4.copyWith(color: NColors.inkPrimary),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          if (NThemeController.darkModeEnabled) ...<Widget>[const Center(child: NThemeToggle()), const SizedBox(width: NSpace.xs)],
          IconButton(
            tooltip: s.pvSignOut,
            onPressed: () => providerSignOut(context),
            icon: Icon(Icons.logout_rounded, color: NColors.inkSecondary),
          ),
          const SizedBox(width: NSpace.xs),
        ],
      ),
      floatingActionButton: floatingActionButton,
      body: SafeArea(top: false, child: CRole.instructor(child: body)),
      bottomNavigationBar: NBottomNav(
        labels: <String>[s.pvShellHome, s.inSessions, s.inStudents, s.inLibrary, s.pvShellMore],
        icons: icons,
        index: index,
        onSelected: (int i) {
          if (i != index) context.go(paths[i]);
        },
      ),
    );
  }
}

/// A pushed instructor page (class, editors, profile): the workspace frame without the bottom bar.
class _InstructorPage extends StatelessWidget {
  const _InstructorPage({required this.title, required this.body});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) => AreaScaffold(
    title: title,
    body: CRole.instructor(child: body),
  );
}

FloatingActionButton _fab(BuildContext context, String label, VoidCallback onPressed) =>
    FloatingActionButton.extended(onPressed: onPressed, backgroundColor: NColors.roleInstructor, foregroundColor: Colors.white, shape: const StadiumBorder(), elevation: 2, icon: const Icon(Icons.add_rounded), label: Text(label));

String _when(BuildContext context, String? iso) {
  if (iso == null) return '';
  return DateFormat('EEE d MMM, h:mm a', Localizations.localeOf(context).toString()).format(DateTime.parse(iso).toLocal());
}

String _time(BuildContext context, String? iso) {
  if (iso == null) return '';
  return MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(DateTime.parse(iso).toLocal()));
}

String classStatus(S s, String? st) => switch (st) {
  'draft' => s.dtPlanDraft,
  'awaiting_approval' => s.inAwaitingApproval,
  'scheduled' => s.dtPlanScheduled,
  'live' => s.inLive,
  'completed' => s.schedCompleted,
  'cancelled' => s.schedCancelled,
  _ => st ?? '',
};

CTone _statusTone(String? st) => switch (st) {
  'live' => CTone.plum,
  'scheduled' => CTone.sage,
  'awaiting_approval' => CTone.apricot,
  'draft' => CTone.lavender,
  'cancelled' => CTone.red,
  _ => CTone.quiet,
};

/// Booked against capacity as words and a bar in the role colour (amber when full).
class _Capacity extends StatelessWidget {
  const _Capacity({required this.booked, required this.capacity});

  final int booked;
  final int capacity;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final double v = capacity <= 0 ? 0 : booked / capacity;
    final bool full = capacity > 0 && booked >= capacity;
    return Row(
      children: <Widget>[
        Expanded(
          child: CBar(value: v, height: 6, color: full ? NColors.statusWarning : CRole.of(context).accent),
        ),
        const SizedBox(width: NSpace.sm),
        Text(
          s.inBooked(booked, capacity),
          style: NType.caption.copyWith(color: NColors.inkSecondary, letterSpacing: 0, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// One class as a timeline entry: time on the left rail, the card on the right.
class _ClassTile extends StatelessWidget {
  const _ClassTile({required this.c, required this.onTap, this.isNext = false, this.last = false});

  final Json c;
  final VoidCallback onTap;
  final bool isNext;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final CRole role = CRole.of(context);
    final String? status = c.str('status');
    final bool muted = status == 'cancelled' || status == 'completed';
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 58,
            child: Padding(
              padding: const EdgeInsets.only(top: NSpace.sm),
              child: Text(
                _time(context, c.str('startsAt')),
                style: NType.caption.copyWith(color: muted ? NColors.inkMuted : NColors.inkPrimary, fontWeight: FontWeight.w700, letterSpacing: 0, fontSize: 13),
              ),
            ),
          ),
          SizedBox(
            width: 18,
            child: Column(
              children: <Widget>[
                const SizedBox(height: NSpace.sm + 3),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: muted ? NColors.lineStrong : role.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: role.light, width: 2),
                  ),
                ),
                if (!last) Expanded(child: Container(width: 2, color: NColors.lineDefault)),
              ],
            ),
          ),
          const SizedBox(width: NSpace.xs),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: NSpace.xs),
              child: Semantics(
                button: true,
                label: c.str('title'),
                child: Material(
                  color: isNext ? role.light : NColors.surfaceCard,
                  borderRadius: BorderRadius.circular(NRadius.lg),
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(NRadius.lg),
                    child: Container(
                      padding: const EdgeInsets.all(NSpace.sm),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(NRadius.lg),
                        border: Border.all(color: isNext ? role.accent.withValues(alpha: 0.4) : NColors.lineDefault),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  c.str('title') ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: NSpace.xs),
                              CPill(isNext ? s.inNextUp : classStatus(s, status), tone: isNext ? CTone.plum : _statusTone(status)),
                            ],
                          ),
                          const SizedBox(height: NSpace.xs),
                          _Capacity(booked: c.integer('booked'), capacity: c.integer('capacity')),
                          if (c.integer('waiting') > 0 || c.integer('requests') > 0) ...<Widget>[
                            const SizedBox(height: NSpace.xs),
                            Wrap(
                              spacing: NSpace.xxs,
                              runSpacing: NSpace.xxs,
                              children: <Widget>[
                                if (c.integer('waiting') > 0) CPill(s.inWaiting(c.integer('waiting')), tone: CTone.apricot),
                                if (c.integer('requests') > 0) CPill(s.inNewRequests(c.integer('requests')), tone: CTone.rose),
                              ],
                            ),
                          ],
                          if (c.flag('startable')) ...<Widget>[const SizedBox(height: NSpace.xxs), Text(s.inStartOnWeb, style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0))],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Home (spec 013 §1): today's sessions with booked against capacity, the next one within the hour, and what needs
/// me. Numbers of students only, never a health detail.
class InstructorHomePage extends StatefulWidget {
  const InstructorHomePage({super.key, this.repository});

  final InstructorRepository? repository;

  @override
  State<InstructorHomePage> createState() => _InstructorHomePageState();
}

class _InstructorHomePageState extends State<InstructorHomePage> {
  late final InstructorRepository _repo = widget.repository ?? getIt<InstructorRepository>();
  late Future<Json> _home = _repo.home();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return InstructorShell(
      index: 0,
      body: AsyncBody<Json>(
        future: _home,
        onRetry: () => setState(() => _home = _repo.home()),
        builder: (BuildContext context, Json h) {
          final Json n = h.obj('needsMe');
          final Json next = h.obj('next');
          final List<Json> today = h.objs('today');
          return RefreshIndicator(
            onRefresh: () async => setState(() => _home = _repo.home()),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl),
              children: <Widget>[
                CHero(
                  eyebrow: s.inWorkspace,
                  title: s.inHomeTitle,
                  subtitle: s.inTodayCount(today.length),
                  trailing: next.isEmpty
                      ? null
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: NSpace.xxs + 2),
                          decoration: BoxDecoration(
                            color: NColors.surfaceCard,
                            borderRadius: BorderRadius.circular(NRadius.pill),
                            border: Border.all(color: NColors.lineDefault),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.self_improvement_rounded, size: 16, color: NColors.roleInstructor),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  s.inNextSoon(next.str('title') ?? '', _when(context, next.str('startsAt'))),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: NType.caption.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700, letterSpacing: 0),
                                ),
                              ),
                            ],
                          ),
                        ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: CHeroStat(
                              label: s.inRequests,
                              value: '${n.integer('requests')}',
                              icon: Icons.mark_chat_unread_outlined,
                              alert: n.integer('requests') > 0,
                              onTap: () => context.go('/instructor/sessions'),
                            ),
                          ),
                          const SizedBox(width: NSpace.xs),
                          Expanded(
                            child: CHeroStat(
                              label: s.inAttendanceToConfirm,
                              value: '${n.integer('attendanceToConfirm')}',
                              icon: Icons.how_to_reg_outlined,
                              onTap: () => context.go('/instructor/sessions'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: NSpace.xs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: CHeroStat(label: s.inContentReturned, value: '${n.integer('contentReturned')}', icon: Icons.replay_rounded, onTap: () => context.go('/instructor/library')),
                          ),
                          const SizedBox(width: NSpace.xs),
                          Expanded(
                            child: CHeroStat(label: s.inNoBookings, value: '${n.integer('classesWithoutBookings')}', icon: Icons.event_busy_outlined, onTap: () => context.go('/instructor/sessions')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: NSpace.md),
                CPanel(
                  title: s.pvDashToday,
                  icon: Icons.event_available_outlined,
                  action: TextButton(onPressed: () => context.go('/instructor/sessions'), child: Text(s.inSessions)),
                  child: today.isEmpty
                      ? CEmpty(icon: Icons.self_improvement_rounded, title: s.inNoToday)
                      : Column(
                          children: <Widget>[
                            for (int i = 0; i < today.length; i++)
                              CEntrance(
                                delayMs: 60 * i,
                                child: _ClassTile(
                                  c: today[i],
                                  isNext: next.isNotEmpty && today[i].str('id') == next.str('id'),
                                  last: i == today.length - 1,
                                  onTap: () => context.push('/instructor/sessions/${today[i].str('id')}'),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Sessions (spec 013 §2): her agenda for the coming weeks and the past week, and scheduling.
class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key, this.repository});

  final InstructorRepository? repository;

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  late final InstructorRepository _repo = widget.repository ?? getIt<InstructorRepository>();
  late Future<List<Json>> _list = _load();

  Future<List<Json>> _load() => _repo.classes(from: DateTime.now().subtract(const Duration(days: 7)), to: DateTime.now().add(const Duration(days: 42)));

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return InstructorShell(
      index: 1,
      title: s.inSessions,
      floatingActionButton: _fab(context, s.inNewClass, () async {
        await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ClassEditorPage(repository: _repo)));
        if (mounted) setState(() => _list = _load());
      }),
      body: AsyncBody<List<Json>>(
        future: _list,
        onRetry: () => setState(() => _list = _load()),
        builder: (BuildContext context, List<Json> rows) {
          final DateTime now = DateTime.now();
          bool past(Json c) => c.str('startsAt') != null && DateTime.parse(c.str('startsAt')!).isBefore(now) && c.str('status') != 'live';
          final List<Json> ahead = rows.where((Json c) => !past(c)).toList();
          final List<Json> before = rows.where(past).toList();
          Future<void> open(Json c) async {
            await context.push('/instructor/sessions/${c.str('id')}');
            if (mounted) setState(() => _list = _load());
          }

          String day(Json c) => c.str('startsAt') == null ? '' : DateFormat('EEEE d MMMM', Localizations.localeOf(context).toString()).format(DateTime.parse(c.str('startsAt')!).toLocal());

          List<Widget> timeline(List<Json> list) {
            final List<Widget> out = <Widget>[];
            for (int i = 0; i < list.length; i++) {
              final bool newDay = i == 0 || day(list[i]) != day(list[i - 1]);
              final bool lastOfDay = i == list.length - 1 || day(list[i]) != day(list[i + 1]);
              if (newDay) out.add(CLabel(day(list[i])));
              out.add(
                CEntrance(
                  delayMs: 40 * (i % 6),
                  child: _ClassTile(c: list[i], last: lastOfDay, onTap: () => open(list[i])),
                ),
              );
            }
            return out;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, 96),
            children: <Widget>[
              CHero(eyebrow: s.inSessions, title: s.inAgendaTitle, subtitle: s.inUpcomingCount(ahead.length)),
              const SizedBox(height: NSpace.md),
              if (rows.isEmpty) CEmpty(icon: Icons.event_note_outlined, title: s.inNoClasses),
              if (ahead.isNotEmpty) ...<Widget>[Text(s.inComingUp, style: NType.h3.copyWith(color: NColors.inkPrimary)), ...timeline(ahead)],
              if (before.isNotEmpty) ...<Widget>[const SizedBox(height: NSpace.md), Text(s.inPastWeek, style: NType.h3.copyWith(color: NColors.inkPrimary)), ...timeline(before.reversed.toList())],
            ],
          );
        },
      ),
    );
  }
}

/// One class (spec 013 §2, §3): bookings with first name, attendance and requests; publish, change, cancel with a
/// reason, confirm or correct attendance within 24 hours. No fee can be changed here.
class ClassPage extends StatefulWidget {
  const ClassPage({required this.classId, super.key, this.repository});

  final String classId;
  final InstructorRepository? repository;

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  late final InstructorRepository _repo = widget.repository ?? getIt<InstructorRepository>();
  late Future<Json> _c = _repo.classDetail(widget.classId);

  Future<void> _act(Future<void> Function() f, String done) async {
    try {
      await f();
      if (!mounted) return;
      showNote(context, done);
      setState(() => _c = _repo.classDetail(widget.classId));
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    }
  }

  Future<void> _cancel() async {
    final S s = S.of(context);
    final String? reason = await showDialog<String>(
      context: context,
      builder: (BuildContext d) => SimpleDialog(
        title: Text(s.inCancelWhy),
        children: <Widget>[
          for (String r in <String>[s.inReasonUnwell, s.inReasonEmergency, s.inReasonTechnical, s.inReasonOther]) SimpleDialogOption(onPressed: () => Navigator.of(d).pop(r), child: Text(r)),
        ],
      ),
    );
    if (reason != null) await _act(() => _repo.cancel(widget.classId, reason), s.inCancelled);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return _InstructorPage(
      title: s.inClass,
      body: AsyncBody<Json>(
        future: _c,
        onRetry: () => setState(() => _c = _repo.classDetail(widget.classId)),
        builder: (BuildContext context, Json c) {
          final String status = c.str('status') ?? '';
          final bool before = status == 'draft' || status == 'scheduled' || status == 'awaiting_approval';
          final bool confirm = status == 'completed' && !c.flag('attendanceConfirmed') && c.flag('attendanceCorrectable');
          final List<Json> bookings = c.objs('bookings');
          return ListView(
            padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl),
            children: <Widget>[
              CHero(
                eyebrow: classStatus(s, status),
                title: c.str('title') ?? '',
                subtitle: _when(context, c.str('startsAt')),
                child: Container(
                  padding: const EdgeInsets.all(NSpace.sm),
                  decoration: BoxDecoration(
                    color: NColors.surfaceCard.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(NRadius.lg),
                    border: Border.all(color: NColors.lineDefault),
                  ),
                  child: _Capacity(booked: c.integer('booked'), capacity: c.integer('capacity')),
                ),
              ),
              if ((c.str('description') ?? '').isNotEmpty || c.flag('lateCancellation')) ...<Widget>[
                const SizedBox(height: NSpace.md),
                CPanel(
                  title: s.inClassDetails,
                  icon: Icons.notes_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if ((c.str('description') ?? '').isNotEmpty) Text(c.str('description')!, style: NType.body.copyWith(color: NColors.inkSecondary)),
                      if (c.flag('lateCancellation')) ...<Widget>[
                        const SizedBox(height: NSpace.xs),
                        Text(
                          s.inLateCancellation,
                          style: NType.caption.copyWith(color: NColors.statusAttention, letterSpacing: 0, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: NSpace.md),
              CPanel(
                title: s.inBookings,
                icon: Icons.groups_outlined,
                note: s.inBooked(c.integer('booked'), c.integer('capacity')),
                child: bookings.isEmpty
                    ? CEmpty(icon: Icons.event_seat_outlined, title: s.inNoBookingsYet)
                    : Column(
                        children: <Widget>[
                          for (int i = 0; i < bookings.length; i++)
                            CEntrance(
                              delayMs: 40 * i,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: NSpace.xs),
                                child: _BookingRow(
                                  b: bookings[i],
                                  choice: _choice,
                                  correctable: c.flag('attendanceCorrectable'),
                                  onSeen: () => _act(() => _repo.seeRequest(bookings[i].str('id')!), s.inSeen),
                                  onAttended: (bool v) => _act(() => _repo.correctAttendance(bookings[i].str('id')!, v), s.inCorrected),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
              if (status == 'draft' || before || confirm || status == 'scheduled' || status == 'live') ...<Widget>[
                const SizedBox(height: NSpace.md),
                CPanel(
                  title: s.inClassActions,
                  icon: Icons.tune_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (status == 'draft')
                        NPrimaryButton(
                          label: s.inPublish,
                          onPressed: () => _act(() => _repo.publish(widget.classId, series: c.str('seriesId') != null), s.inPublished),
                        ),
                      if (before) ...<Widget>[
                        const SizedBox(height: NSpace.xs),
                        NSecondaryButton(
                          label: s.inChange,
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ClassEditorPage(repository: _repo, existing: c),
                              ),
                            );
                            if (mounted) setState(() => _c = _repo.classDetail(widget.classId));
                          },
                        ),
                        TextButton(
                          onPressed: _cancel,
                          style: TextButton.styleFrom(foregroundColor: NColors.statusClinicalRedFlag),
                          child: Text(status == 'draft' ? s.inDeleteDraft : s.inCancelClass),
                        ),
                      ],
                      if (confirm) NPrimaryButton(label: s.inConfirmAttendance, onPressed: () => _act(() => _repo.confirmAttendance(widget.classId), s.inAttendanceConfirmed)),
                      if (status == 'scheduled' || status == 'live')
                        Padding(
                          padding: const EdgeInsets.only(top: NSpace.xs),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.desktop_windows_outlined, size: 16, color: NColors.inkMuted),
                              const SizedBox(width: NSpace.xs),
                              Expanded(
                                child: Text(s.inStartOnWeb, style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _choice(S s, String? c) => switch (c) {
    'first_class' => s.inReqFirst,
    'camera_optional' => s.inReqCamera,
    'arriving_late' => s.inReqLate,
    'leaving_early' => s.inReqEarly,
    _ => s.inReqOther,
  };
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({required this.b, required this.choice, required this.correctable, required this.onSeen, required this.onAttended});

  final Json b;
  final String Function(S, String?) choice;
  final bool correctable;
  final VoidCallback onSeen;
  final ValueChanged<bool> onAttended;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Json req = b.obj('request');
    final bool unseen = req.isNotEmpty && !req.flag('seen');
    return Container(
      padding: const EdgeInsets.all(NSpace.sm),
      decoration: BoxDecoration(
        color: NColors.surfacePage,
        borderRadius: BorderRadius.circular(NRadius.lg),
        border: Border.all(color: unseen ? NColors.brandBlush : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CAvatar(name: b.str('firstName'), size: 36),
              const SizedBox(width: NSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      b.str('firstName') ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
                    ),
                    if (b.str('status') == 'waitlisted' || b['attended'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Wrap(
                          spacing: NSpace.xxs,
                          children: <Widget>[
                            if (b.str('status') == 'waitlisted') CPill(s.inOnWaitingList, tone: CTone.apricot),
                            if (b['attended'] != null) CPill(b.flag('attended') ? s.inAttended : s.inNotAttended, tone: b.flag('attended') ? CTone.sage : CTone.quiet),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (correctable) Switch(value: b.flag('attended'), activeTrackColor: CRole.of(context).accent, onChanged: onAttended),
            ],
          ),
          if (req.isNotEmpty) ...<Widget>[
            const SizedBox(height: NSpace.xs),
            Container(
              padding: const EdgeInsets.fromLTRB(NSpace.sm, NSpace.xs, NSpace.xxs, NSpace.xs),
              decoration: BoxDecoration(color: unseen ? NColors.brandBlushLight : NColors.surfaceCard, borderRadius: BorderRadius.circular(NRadius.md)),
              child: Row(
                children: <Widget>[
                  Icon(Icons.chat_bubble_outline_rounded, size: 16, color: unseen ? NColors.brandRosewood : NColors.inkMuted),
                  const SizedBox(width: NSpace.xs),
                  Expanded(
                    child: Text(s.inRequest(choice(s, req.str('choice')), req.str('text') ?? ''), style: NType.bodySm.copyWith(color: NColors.inkPrimary)),
                  ),
                  if (unseen)
                    IconButton(
                      tooltip: s.inMarkSeen,
                      icon: Icon(Icons.done_rounded, color: NColors.brandRosewood),
                      onPressed: onSeen,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tappable selection chips in the role colour.
Widget _chips(BuildContext context, List<String> values, bool Function(String) selected, ValueChanged<String>? onToggle) => Wrap(
  spacing: NSpace.xs,
  runSpacing: NSpace.xs,
  children: <Widget>[
    for (String p in values)
      FilterChip(
        label: Text(p),
        selected: selected(p),
        showCheckmark: true,
        selectedColor: CRole.of(context).light,
        checkmarkColor: CRole.of(context).accent,
        side: BorderSide(color: selected(p) ? CRole.of(context).accent.withValues(alpha: 0.5) : NColors.lineDefault),
        labelStyle: NType.bodySm.copyWith(color: NColors.inkPrimary, fontWeight: selected(p) ? FontWeight.w700 : FontWeight.w500),
        backgroundColor: NColors.surfaceCard,
        onSelected: onToggle == null ? null : (_) => onToggle(p),
      ),
  ],
);

const SizedBox _gap = SizedBox(height: NSpace.sm);

/// Scheduling or changing a class (spec 013 §2): one occurrence, or weekly until a date.
class ClassEditorPage extends StatefulWidget {
  const ClassEditorPage({required this.repository, super.key, this.existing});

  final InstructorRepository repository;
  final Json? existing;

  @override
  State<ClassEditorPage> createState() => _ClassEditorPageState();
}

class _ClassEditorPageState extends State<ClassEditorPage> {
  late final Json? _e = widget.existing;
  late final TextEditingController _title = TextEditingController(text: _e?.str('title') ?? '');
  late final TextEditingController _description = TextEditingController(text: _e?.str('description') ?? '');
  late final TextEditingController _minutes = TextEditingController(text: _e == null ? '60' : '${DateTime.parse(_e.str('endsAt')!).difference(DateTime.parse(_e.str('startsAt')!)).inMinutes}');
  late final TextEditingController _capacity = TextEditingController(text: '${_e?.integer('capacity') ?? 15}');
  late DateTime? _start = _e == null ? null : DateTime.parse(_e.str('startsAt')!).toLocal();
  late String? _level = _e?.str('level');
  late final Set<String> _phaseTags = <String>{...?_e?.strs('phaseTags')};
  bool _weekly = false;
  DateTime? _until;
  bool _busy = false;

  @override
  void dispose() {
    for (TextEditingController c in <TextEditingController>[_title, _description, _minutes, _capacity]) {
      c.dispose();
    }
    super.dispose();
  }

  String _offsetIso(DateTime t) {
    final Duration o = t.timeZoneOffset;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)}T${two(t.hour)}:${two(t.minute)}:00${o.isNegative ? '-' : '+'}${two(o.inHours.abs())}:${two(o.inMinutes.abs() % 60)}';
  }

  Future<void> _pickStart() async {
    final DateTime now = DateTime.now();
    final DateTime? d = await showDatePicker(context: context, initialDate: _start ?? now.add(const Duration(days: 2)), firstDate: now, lastDate: now.add(const Duration(days: 180)));
    if (d == null || !mounted) return;
    final TimeOfDay? t = await showTimePicker(context: context, initialTime: _start == null ? const TimeOfDay(hour: 7, minute: 0) : TimeOfDay.fromDateTime(_start!));
    if (t != null) setState(() => _start = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  Future<void> _save() async {
    final S s = S.of(context);
    final int? minutes = int.tryParse(_minutes.text.trim());
    final int? capacity = int.tryParse(_capacity.text.trim());
    if (_title.text.trim().isEmpty || _start == null || minutes == null || capacity == null) {
      showNote(context, s.inIncomplete);
      return;
    }
    String two(int v) => v.toString().padLeft(2, '0');
    setState(() => _busy = true);
    try {
      if (_e == null) {
        await widget.repository.createClass(<String, dynamic>{
          'title': _title.text.trim(),
          'description': _description.text.trim(),
          'level': ?_level,
          'startsAt': _offsetIso(_start!),
          'minutes': minutes,
          'capacity': capacity,
          'phaseTags': _phaseTags.toList(),
          if (_weekly && _until != null)
            'repeat': <String, dynamic>{
              'weekdays': <int>[_start!.toUtc().weekday % 7],
              'until': '${_until!.year}-${two(_until!.month)}-${two(_until!.day)}',
            },
        });
      } else {
        await widget.repository.updateClass(_e.str('id')!, <String, dynamic>{
          'title': _title.text.trim(),
          'description': _description.text.trim(),
          'startsAt': _offsetIso(_start!),
          'minutes': minutes,
          'capacity': capacity,
          'phaseTags': _phaseTags.toList(),
        });
      }
      if (mounted) Navigator.of(context).pop();
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return _InstructorPage(
      title: _e == null ? s.inNewClass : s.inChange,
      body: Builder(
        builder: (BuildContext context) => ListView(
          padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl),
          children: <Widget>[
            CPanel(
              title: s.inClassDetails,
              icon: Icons.self_improvement_rounded,
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _title,
                    maxLength: 120,
                    decoration: InputDecoration(labelText: s.inTitle),
                  ),
                  TextField(
                    controller: _description,
                    minLines: 2,
                    maxLines: 5,
                    maxLength: 2000,
                    decoration: InputDecoration(labelText: s.inDescription, helperText: s.inNoMedicalClaims, helperMaxLines: 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: NSpace.md),
            CPanel(
              title: s.inTimeAndSize,
              icon: Icons.schedule_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: _pickStart,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: NColors.inkPrimary,
                      minimumSize: const Size.fromHeight(NLayout.minTapTarget),
                      side: BorderSide(color: CRole.of(context).accent.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NRadius.lg)),
                    ),
                    icon: Icon(Icons.event_rounded, color: CRole.of(context).accent),
                    label: Text(_start == null ? s.inPickStart : _when(context, _start!.toUtc().toIso8601String())),
                  ),
                  _gap,
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _minutes,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: s.dtMinutes),
                        ),
                      ),
                      const SizedBox(width: NSpace.sm),
                      Expanded(
                        child: TextField(
                          controller: _capacity,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: s.inCapacity),
                        ),
                      ),
                    ],
                  ),
                  if (_e == null) ...<Widget>[
                    _gap,
                    DropdownButtonFormField<String?>(
                      initialValue: _level,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: s.inLevel),
                      items: <DropdownMenuItem<String?>>[for (String l in _levels) DropdownMenuItem<String?>(value: l, child: Text(l))],
                      onChanged: (String? v) => setState(() => _level = v),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: NSpace.md),
            CPanel(
              title: s.inPhaseTags,
              icon: Icons.spa_outlined,
              child: _chips(context, _phases, _phaseTags.contains, (String p) => setState(() => _phaseTags.contains(p) ? _phaseTags.remove(p) : _phaseTags.add(p))),
            ),
            if (_e == null) ...<Widget>[
              const SizedBox(height: NSpace.md),
              CPanel(
                title: s.inRepeatSection,
                icon: Icons.repeat_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Material(
                      type: MaterialType.transparency,
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeTrackColor: CRole.of(context).accent,
                        title: Text(s.inWeekly, style: NType.body.copyWith(color: NColors.inkPrimary)),
                        value: _weekly,
                        onChanged: (bool v) => setState(() => _weekly = v),
                      ),
                    ),
                    if (_weekly)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: NColors.inkPrimary, minimumSize: const Size.fromHeight(NLayout.minTapTarget)),
                        onPressed: () async {
                          final DateTime now = DateTime.now();
                          final DateTime? u = await showDatePicker(context: context, initialDate: now.add(const Duration(days: 28)), firstDate: now, lastDate: now.add(const Duration(days: 182)));
                          if (u != null) setState(() => _until = u);
                        },
                        child: Text(_until == null ? s.inUntil : s.inUntilDate(MaterialLocalizations.of(context).formatMediumDate(_until!))),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: NSpace.md),
            Row(
              children: <Widget>[
                Icon(Icons.info_outline_rounded, size: 16, color: NColors.inkMuted),
                const SizedBox(width: NSpace.xs),
                Expanded(
                  child: Text(s.inFeeNote, style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0)),
                ),
              ],
            ),
            const SizedBox(height: NSpace.sm),
            NPrimaryButton(label: s.drSave, loading: _busy, onPressed: _save),
          ],
        ),
      ),
    );
  }
}

/// Students (spec 013 §5): the four facts only: first name, attendance with her, cycle phase when shared, practice
/// progress.
class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key, this.repository});

  final InstructorRepository? repository;

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  late final InstructorRepository _repo = widget.repository ?? getIt<InstructorRepository>();
  late Future<List<Json>> _list = _repo.students();

  Future<void> _recommend(Json st) async {
    final S s = S.of(context);
    final List<Json> mine = (await _repo.content()).where((Json c) => c.str('status') == 'published').toList();
    if (!mounted) return;
    final Json? pick = await showDialog<Json>(
      context: context,
      builder: (BuildContext d) => SimpleDialog(
        title: Text(s.inRecommend),
        children: <Widget>[
          if (mine.isEmpty) Padding(padding: const EdgeInsets.all(NSpace.lg), child: Text(s.inNoPublished)),
          for (Json c in mine) SimpleDialogOption(onPressed: () => Navigator.of(d).pop(c), child: Text(c.str('title') ?? '')),
        ],
      ),
    );
    if (pick == null) return;
    try {
      await _repo.recommend(st.str('id')!, contentId: pick.str('id'));
      if (mounted) showNote(context, s.inRecommended);
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return InstructorShell(
      index: 2,
      title: s.inStudents,
      body: AsyncBody<List<Json>>(
        future: _list,
        onRetry: () => setState(() => _list = _repo.students()),
        builder: (BuildContext context, List<Json> rows) => ListView(
          padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl),
          children: <Widget>[
            CHero(eyebrow: s.inStudentsCount(rows.length), title: s.inStudentsTitle),
            const SizedBox(height: NSpace.md),
            if (rows.isEmpty) CEmpty(icon: Icons.groups_outlined, title: s.inNoStudents),
            for (int i = 0; i < rows.length; i++)
              CEntrance(
                delayMs: 40 * (i % 8),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: NSpace.xs),
                  child: _StudentCard(st: rows[i], onRecommend: () => _recommend(rows[i])),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.st, required this.onRecommend});

  final Json st;
  final VoidCallback onRecommend;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Json a = st.obj('attendance');
    final Json pp = st.obj('practiceProgress');
    final int booked = a.integer('booked');
    return Container(
      padding: const EdgeInsets.fromLTRB(NSpace.sm, NSpace.sm, NSpace.xxs, NSpace.sm),
      decoration: BoxDecoration(
        color: NColors.surfaceCard,
        borderRadius: BorderRadius.circular(NRadius.lg),
        border: Border.all(color: NColors.lineDefault),
        boxShadow: NShadow.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CAvatar(name: st.str('firstName'), size: 44),
          const SizedBox(width: NSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        st.str('firstName') ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (st.str('cyclePhase') != null) ...<Widget>[const SizedBox(width: NSpace.xs), CPill(s.inPhase(st.str('cyclePhase')!), tone: CTone.rose)],
                  ],
                ),
                const SizedBox(height: NSpace.xxs),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CBar(value: booked == 0 ? 0 : a.integer('attended') / booked, height: 6, color: CRole.of(context).accent),
                    ),
                    const SizedBox(width: NSpace.xs),
                    Text(
                      s.inAttendedOf(a.integer('attended'), booked),
                      style: NType.caption.copyWith(color: NColors.inkSecondary, letterSpacing: 0, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: NSpace.xxs),
                Text(s.inProgress(pp.integer('sessionsCompleted'), pp.integer('minutesThisMonth')), style: NType.bodySm.copyWith(color: NColors.inkMuted)),
              ],
            ),
          ),
          IconButton(
            tooltip: s.inRecommend,
            icon: Icon(Icons.recommend_outlined, color: CRole.of(context).accent),
            onPressed: onRecommend,
          ),
        ],
      ),
    );
  }
}

String _contentState(S s, String? st) => switch (st) {
  'draft' => s.dtPlanDraft,
  'in_review' => s.inInReview,
  'returned' => s.inReturned,
  'published' => s.dtPublishedLabel,
  'withdrawn' => s.inWithdrawn,
  _ => st ?? '',
};

CTone _contentTone(String? st) => switch (st) {
  'published' => CTone.sage,
  'in_review' => CTone.lavender,
  'returned' => CTone.apricot,
  'withdrawn' => CTone.quiet,
  _ => CTone.rose,
};

/// The content library (spec 013 §6): her recorded sessions with states and counts-only statistics.
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key, this.repository});

  final InstructorRepository? repository;

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late final InstructorRepository _repo = widget.repository ?? getIt<InstructorRepository>();
  late Future<List<Json>> _list = _repo.content();

  Future<void> _edit(Json? c) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ContentEditorPage(repository: _repo, existing: c),
      ),
    );
    if (mounted) setState(() => _list = _repo.content());
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return InstructorShell(
      index: 3,
      title: s.inLibrary,
      floatingActionButton: _fab(context, s.inNewSession, () => _edit(null)),
      body: AsyncBody<List<Json>>(
        future: _list,
        onRetry: () => setState(() => _list = _repo.content()),
        builder: (BuildContext context, List<Json> rows) {
          int count(String st) => rows.where((Json c) => c.str('status') == st).length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, 96),
            children: <Widget>[
              CHero(
                eyebrow: s.inLibrary,
                title: s.inLibraryTitle,
                child: CStatGrid(
                  children: <Widget>[
                    CHeroStat(label: s.dtPublishedLabel, value: '${count('published')}', icon: Icons.play_circle_outline_rounded),
                    CHeroStat(label: s.inInReview, value: '${count('in_review')}', icon: Icons.hourglass_top_rounded),
                    CHeroStat(label: s.inReturned, value: '${count('returned')}', icon: Icons.replay_rounded, alert: count('returned') > 0),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.md),
              if (rows.isEmpty) CEmpty(icon: Icons.video_library_outlined, title: s.inNoContent),
              for (int i = 0; i < rows.length; i++)
                CEntrance(
                  delayMs: 40 * (i % 8),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: NSpace.sm),
                    child: _ContentCard(c: rows[i], state: _contentState(s, rows[i].str('status')), onTap: () => _edit(rows[i])),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.c, required this.state, required this.onTap});

  final Json c;
  final String state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final CRole role = CRole.of(context);
    return Semantics(
      button: true,
      label: c.str('title'),
      child: Material(
        color: NColors.surfaceCard,
        borderRadius: BorderRadius.circular(NRadius.xl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(NRadius.xl),
          child: Container(
            padding: const EdgeInsets.all(NSpace.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(NRadius.xl),
              border: Border.all(color: NColors.lineDefault),
              boxShadow: NShadow.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[role.light, NColors.brandBlushLight]),
                        borderRadius: BorderRadius.circular(NRadius.lg),
                      ),
                      child: Icon(Icons.play_arrow_rounded, color: role.accent, size: 28),
                    ),
                    const SizedBox(width: NSpace.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            c.str('title') ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: NSpace.xxs),
                          Wrap(
                            spacing: NSpace.xxs,
                            runSpacing: NSpace.xxs,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              CPill(state, tone: _contentTone(c.str('status'))),
                              CPill(s.practiceMinutes(c.integer('minutes'))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
                  ],
                ),
                const SizedBox(height: NSpace.xs),
                Row(
                  children: <Widget>[
                    Icon(Icons.bar_chart_rounded, size: 16, color: NColors.inkMuted),
                    const SizedBox(width: NSpace.xxs),
                    Expanded(
                      child: Text(s.inStats(c.obj('stats').integer('plays'), c.obj('stats').integer('completions')), style: NType.caption.copyWith(color: NColors.inkSecondary, letterSpacing: 0)),
                    ),
                  ],
                ),
                if (c.str('reviewNote') != null) ...<Widget>[
                  const SizedBox(height: NSpace.xs),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(NSpace.xs + 2),
                    decoration: BoxDecoration(color: NColors.brandApricotLight, borderRadius: BorderRadius.circular(NRadius.md)),
                    child: Text(c.str('reviewNote')!, style: NType.bodySm.copyWith(color: NColors.inkPrimary)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A recorded session's details (spec 013 §6). She proposes pregnancy safety; the reviewer decides. Uploading the video
/// is not in the app yet.
class ContentEditorPage extends StatefulWidget {
  const ContentEditorPage({required this.repository, super.key, this.existing});

  final InstructorRepository repository;
  final Json? existing;

  @override
  State<ContentEditorPage> createState() => _ContentEditorPageState();
}

class _ContentEditorPageState extends State<ContentEditorPage> {
  late Json? _c = widget.existing;
  late final TextEditingController _title = TextEditingController(text: _c?.str('title') ?? '');
  late final TextEditingController _description = TextEditingController(text: _c?.str('description') ?? '');
  late final TextEditingController _minutes = TextEditingController(text: '${_c?.integer('minutes') ?? 15}');
  late int? _intensity = _c?.number('intensity')?.toInt();
  late bool? _pregnancy = _c?['proposedPregnancySafe'] as bool?;
  late bool _rights = _c?.flag('rightsConfirmed') ?? false;
  late final Set<String> _suitability = <String>{...?_c?.strs('phaseSuitability')};
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _minutes.dispose();
    super.dispose();
  }

  Future<void> _run(Future<Json> Function() f, String done) async {
    setState(() => _busy = true);
    try {
      final Json r = await f();
      if (!mounted) return;
      setState(() => _c = r);
      showNote(context, done);
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Json get _input => <String, dynamic>{
    'title': _title.text.trim(),
    'description': _description.text.trim(),
    'minutes': int.tryParse(_minutes.text.trim()) ?? 15,
    'phaseSuitability': _suitability.toList(),
    'intensity': _intensity,
    'proposedPregnancySafe': _pregnancy,
    'rightsConfirmed': _rights,
  };

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Json? c = _c;
    final bool editable = c == null || c.str('status') != 'withdrawn';
    return _InstructorPage(
      title: c == null ? s.inNewSession : (c.str('title') ?? ''),
      body: Builder(
        builder: (BuildContext context) {
          final CRole role = CRole.of(context);
          return ListView(
            padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl),
            children: <Widget>[
              if (c != null) ...<Widget>[
                Row(
                  children: <Widget>[
                    CPill(_contentState(s, c.str('status')), tone: _contentTone(c.str('status'))),
                    const SizedBox(width: NSpace.xs),
                    Expanded(
                      child: Text(s.inStatsLong(c.obj('stats').integer('plays'), c.obj('stats').integer('completions')), style: NType.caption.copyWith(color: NColors.inkSecondary, letterSpacing: 0)),
                    ),
                  ],
                ),
                const SizedBox(height: NSpace.sm),
              ],
              if (c != null && c.str('reviewNote') != null) ...<Widget>[
                Container(
                  padding: const EdgeInsets.all(NSpace.sm),
                  decoration: BoxDecoration(color: NColors.brandApricotLight, borderRadius: BorderRadius.circular(NRadius.lg)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.rate_review_outlined, size: 18, color: NColors.statusWarningText),
                      const SizedBox(width: NSpace.xs),
                      Expanded(
                        child: Text(c.str('reviewNote')!, style: NType.bodySm.copyWith(color: NColors.inkPrimary)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: NSpace.sm),
              ],
              CPanel(
                title: s.inClassDetails,
                icon: Icons.video_library_outlined,
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _title,
                      enabled: editable,
                      maxLength: 120,
                      decoration: InputDecoration(labelText: s.inTitle),
                    ),
                    TextField(
                      controller: _description,
                      enabled: editable,
                      minLines: 2,
                      maxLines: 6,
                      maxLength: 2000,
                      decoration: InputDecoration(labelText: s.inDescription, helperText: s.inNoMedicalClaims, helperMaxLines: 3),
                    ),
                    TextField(
                      controller: _minutes,
                      enabled: editable,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: s.dtMinutes),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.md),
              CPanel(
                title: s.inPhaseTags,
                icon: Icons.spa_outlined,
                child: _chips(context, _phases, _suitability.contains, editable ? (String p) => setState(() => _suitability.contains(p) ? _suitability.remove(p) : _suitability.add(p)) : null),
              ),
              const SizedBox(height: NSpace.md),
              CPanel(
                title: s.inIntensity,
                icon: Icons.local_fire_department_outlined,
                child: Row(
                  children: <Widget>[
                    for (int i = 1; i <= 5; i++) ...<Widget>[
                      if (i > 1) const SizedBox(width: NSpace.xs),
                      Expanded(
                        child: ChoiceChip(
                          label: SizedBox(
                            width: double.infinity,
                            child: Text('$i', textAlign: TextAlign.center),
                          ),
                          showCheckmark: false,
                          selected: _intensity == i,
                          selectedColor: role.accent,
                          backgroundColor: NColors.surfaceCard,
                          side: BorderSide(color: _intensity == i ? role.accent : NColors.lineDefault),
                          labelStyle: NType.body.copyWith(color: _intensity == i ? Colors.white : NColors.inkPrimary, fontWeight: FontWeight.w700),
                          onSelected: editable ? (_) => setState(() => _intensity = i) : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: NSpace.md),
              CPanel(
                title: s.inRights,
                icon: Icons.verified_outlined,
                child: Column(
                  children: <Widget>[
                    Material(
                      type: MaterialType.transparency,
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeTrackColor: role.accent,
                        title: Text(s.inProposePregnancy, style: NType.body.copyWith(color: NColors.inkPrimary)),
                        subtitle: Text(s.inReviewerDecides, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
                        value: _pregnancy ?? false,
                        onChanged: editable ? (bool v) => setState(() => _pregnancy = v) : null,
                      ),
                    ),
                    Material(
                      type: MaterialType.transparency,
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: role.accent,
                        title: Text(s.inRights, style: NType.body.copyWith(color: NColors.inkPrimary)),
                        value: _rights,
                        onChanged: editable ? (bool? v) => setState(() => _rights = v ?? false) : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (c != null && !c.flag('hasVideo')) ...<Widget>[
                const SizedBox(height: NSpace.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.info_outline_rounded, size: 16, color: NColors.inkMuted),
                    const SizedBox(width: NSpace.xs),
                    Expanded(
                      child: Text(s.inVideoNotInApp, style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: NSpace.md),
              if (editable) NSecondaryButton(label: s.drSaveDraft, onPressed: _busy ? null : () => _run(() => widget.repository.saveContent(c?.str('id'), _input), s.drSaved)),
              if (c != null && (c.str('status') == 'draft' || c.str('status') == 'returned')) ...<Widget>[
                const SizedBox(height: NSpace.xs),
                NPrimaryButton(label: s.inSubmit, loading: _busy, onPressed: () => _run(() => widget.repository.submitContent(c.str('id')!), s.inSubmitted)),
              ],
              if (c != null && c.str('status') == 'published')
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: NColors.statusClinicalRedFlag),
                  onPressed: _busy
                      ? null
                      : () async {
                          await widget.repository.withdrawContent(c.str('id')!);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                  child: Text(s.inWithdraw),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// More: earnings, profile, notifications, sign out.
class InstructorMorePage extends StatelessWidget {
  const InstructorMorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    Widget row(IconData icon, String label, String path, int i) => CEntrance(
      delayMs: 50 * i,
      child: Padding(
        padding: const EdgeInsets.only(bottom: NSpace.xs),
        child: Semantics(
          label: label,
          button: true,
          excludeSemantics: true,
          child: CHubTile(icon: icon, title: label, onTap: () => context.push(path)),
        ),
      ),
    );
    return InstructorShell(
      index: 4,
      title: s.pvShellMore,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl),
        children: <Widget>[
          CHero(eyebrow: s.pvShellMore, title: s.inMoreTitle),
          const SizedBox(height: NSpace.md),
          row(Icons.account_balance_wallet_outlined, s.earnTitle, '/instructor/earnings', 0),
          row(Icons.person_outline_rounded, s.profileTitle, '/instructor/profile', 1),
          row(Icons.notifications_none_rounded, s.notifTitle, RouteConstants.notificationSettings, 2),
          const SizedBox(height: NSpace.md),
          const NAppearanceCard(),
          const SizedBox(height: NSpace.md),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: NColors.inkSecondary, minimumSize: const Size.fromHeight(NLayout.minTapTarget)),
            onPressed: () => providerSignOut(context),
            icon: const Icon(Icons.logout_rounded),
            label: Text(s.pvSignOut),
          ),
        ],
      ),
    );
  }
}

/// Her profile (spec 013 §7).
class InstructorProfilePage extends StatefulWidget {
  const InstructorProfilePage({super.key, this.repository});

  final InstructorRepository? repository;

  @override
  State<InstructorProfilePage> createState() => _InstructorProfilePageState();
}

class _InstructorProfilePageState extends State<InstructorProfilePage> {
  late final InstructorRepository _repo = widget.repository ?? getIt<InstructorRepository>();
  late Future<Json> _p = _repo.profile();
  final TextEditingController _bio = TextEditingController();
  final TextEditingController _languages = TextEditingController();
  final TextEditingController _types = TextEditingController();
  bool _filled = false;

  @override
  void dispose() {
    _bio.dispose();
    _languages.dispose();
    _types.dispose();
    super.dispose();
  }

  List<String> _split(String v) => v.split(',').map((String x) => x.trim()).where((String x) => x.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return _InstructorPage(
      title: s.profileTitle,
      body: AsyncBody<Json>(
        future: _p,
        onRetry: () => setState(() => _p = _repo.profile()),
        builder: (BuildContext context, Json p) {
          if (!_filled) {
            _filled = true;
            _bio.text = p.str('bio') ?? '';
            _languages.text = p.strs('languages').join(', ');
            _types.text = p.strs('practiceTypes').join(', ');
          }
          final Json rating = p.obj('rating');
          final double? avg = rating.number('average');
          return ListView(
            padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl),
            children: <Widget>[
              CHero(
                eyebrow: s.inWorkspace,
                title: p.str('name') ?? '',
                subtitle: s.drApproval(p.str('approvalStatus') ?? ''),
                trailing: Wrap(
                  spacing: NSpace.xxs,
                  runSpacing: NSpace.xxs,
                  children: <Widget>[
                    if (avg != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: NSpace.xxs + 2),
                        decoration: BoxDecoration(
                          color: NColors.surfaceCard,
                          borderRadius: BorderRadius.circular(NRadius.pill),
                          border: Border.all(color: NColors.lineDefault),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.star_rounded, size: 16, color: NColors.statusWarning),
                            const SizedBox(width: 4),
                            Text(
                              s.inRatingLine(avg.toStringAsFixed(1), rating.integer('count')),
                              style: NType.caption.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700, letterSpacing: 0),
                            ),
                          ],
                        ),
                      ),
                    for (String t in p.strs('practiceTypes')) CPill(t, tone: CTone.sage),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.md),
              CPanel(
                title: s.drAboutYou,
                icon: Icons.person_outline_rounded,
                child: Column(
                  children: <Widget>[
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
                    const SizedBox(height: NSpace.sm),
                    TextField(
                      controller: _types,
                      decoration: InputDecoration(labelText: s.inPracticeTypes, helperText: s.drCommaSeparated),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.md),
              NPrimaryButton(
                label: s.profileSave,
                onPressed: () async {
                  try {
                    final Json r = await _repo.updateProfile(bio: _bio.text.trim(), languages: _split(_languages.text), practiceTypes: _split(_types.text));
                    if (!context.mounted) return;
                    setState(() => _p = Future<Json>.value(r));
                    showNote(context, s.profileSaved);
                  } on Object catch (e) {
                    if (context.mounted) showNote(context, failureText(e, s.commonLoadError));
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
