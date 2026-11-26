import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/di/service_locator.dart';
import '../../design_system/tokens/tokens.dart';
import '../../design_system/widgets/bottom_nav.dart';
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
    return Scaffold(
      backgroundColor: NColors.surfacePage,
      appBar: AppBar(
        backgroundColor: NColors.surfacePage,
        automaticallyImplyLeading: false,
        title: Text(title ?? s.pvRoleInstructor, style: NType.h4.copyWith(color: NColors.inkPrimary)),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () => providerSignOut(context),
            icon: const Icon(Icons.logout_rounded, size: NSpace.md + NSpace.xxs),
            label: Text(s.pvSignOut),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      body: SafeArea(top: false, child: body),
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

String _when(BuildContext context, String? iso) {
  if (iso == null) return '';
  return DateFormat('EEE d MMM, h:mm a', Localizations.localeOf(context).toString()).format(DateTime.parse(iso).toLocal());
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
          return RefreshIndicator(
            onRefresh: () async => setState(() => _home = _repo.home()),
            child: ListView(
              padding: const EdgeInsets.all(NSpace.lg),
              children: <Widget>[
                if (h.obj('next').isNotEmpty) NCard(color: NColors.brandSageLight, child: Text(s.inNextSoon(h.obj('next').str('title') ?? '', _when(context, h.obj('next').str('startsAt'))))),
                NSectionTitle(s.pvDashToday),
                if (h.objs('today').isEmpty) EmptyNote(text: s.inNoToday),
                for (final Json c in h.objs('today')) ...<Widget>[
                  NCard(
                    onTap: () => context.push('/instructor/sessions/${c.str('id')}'),
                    semanticsLabel: c.str('title'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(c.str('title') ?? '', style: NType.body.copyWith(fontWeight: FontWeight.w700)),
                        Text(
                          '${_when(context, c.str('startsAt'))} · ${s.inBooked(c.integer('booked'), c.integer('capacity'))} · ${classStatus(s, c.str('status'))}',
                          style: NType.caption.copyWith(color: NColors.inkSecondary),
                        ),
                        if (c.flag('startable'))
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(onPressed: () => context.push('/instructor/sessions/${c.str('id')}/room'), child: Text(s.icOpenRoom)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: NSpace.xs),
                ],
                NSectionTitle(s.pvDashNeedsMe),
                ListTile(contentPadding: EdgeInsets.zero, title: Text(s.inRequests), trailing: Text('${n.integer('requests')}'), onTap: () => context.go('/instructor/sessions')),
                ListTile(contentPadding: EdgeInsets.zero, title: Text(s.inAttendanceToConfirm), trailing: Text('${n.integer('attendanceToConfirm')}'), onTap: () => context.go('/instructor/sessions')),
                ListTile(contentPadding: EdgeInsets.zero, title: Text(s.inContentReturned), trailing: Text('${n.integer('contentReturned')}'), onTap: () => context.go('/instructor/library')),
                ListTile(contentPadding: EdgeInsets.zero, title: Text(s.inNoBookings), trailing: Text('${n.integer('classesWithoutBookings')}'), onTap: () => context.go('/instructor/sessions')),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ClassEditorPage(repository: _repo)));
          if (mounted) setState(() => _list = _load());
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(s.inNewClass),
      ),
      body: AsyncBody<List<Json>>(
        future: _list,
        onRetry: () => setState(() => _list = _load()),
        builder: (BuildContext context, List<Json> rows) => rows.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(NSpace.lg),
                child: EmptyNote(text: s.inNoClasses),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, NSpace.lg, 96),
                children: <Widget>[
                  for (final Json c in rows) ...<Widget>[
                    NCard(
                      onTap: () async {
                        await context.push('/instructor/sessions/${c.str('id')}');
                        if (mounted) setState(() => _list = _load());
                      },
                      semanticsLabel: c.str('title'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(c.str('title') ?? '', style: NType.body.copyWith(fontWeight: FontWeight.w700)),
                          Text(
                            <String>[
                              _when(context, c.str('startsAt')),
                              classStatus(s, c.str('status')),
                              s.inBooked(c.integer('booked'), c.integer('capacity')),
                              if (c.integer('waiting') > 0) s.inWaiting(c.integer('waiting')),
                              if (c.integer('requests') > 0) s.inNewRequests(c.integer('requests')),
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
          for (final String r in <String>[s.inReasonUnwell, s.inReasonEmergency, s.inReasonTechnical, s.inReasonOther]) SimpleDialogOption(onPressed: () => Navigator.of(d).pop(r), child: Text(r)),
        ],
      ),
    );
    if (reason != null) await _act(() => _repo.cancel(widget.classId, reason), s.inCancelled);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.inClass,
      body: AsyncBody<Json>(
        future: _c,
        onRetry: () => setState(() => _c = _repo.classDetail(widget.classId)),
        builder: (BuildContext context, Json c) {
          final String status = c.str('status') ?? '';
          final bool before = status == 'draft' || status == 'scheduled' || status == 'awaiting_approval';
          return ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              Text(c.str('title') ?? '', style: NType.h3),
              Text(
                '${_when(context, c.str('startsAt'))} · ${classStatus(s, status)} · ${s.inBooked(c.integer('booked'), c.integer('capacity'))}',
                style: NType.bodySm.copyWith(color: NColors.inkSecondary),
              ),
              if ((c.str('description') ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: NSpace.xs),
                  child: Text(c.str('description')!),
                ),
              if (c.flag('lateCancellation')) Text(s.inLateCancellation, style: NType.caption.copyWith(color: NColors.statusAttention)),
              NSectionTitle(s.inBookings),
              if (c.objs('bookings').isEmpty) EmptyNote(text: s.inNoBookingsYet),
              for (final Json b in c.objs('bookings'))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(b.str('firstName') ?? ''),
                  subtitle: Text(
                    <String>[
                      if (b.str('status') == 'waitlisted') s.inOnWaitingList,
                      if (b['attended'] != null) (b.flag('attended') ? s.inAttended : s.inNotAttended),
                      if (b.obj('request').isNotEmpty) s.inRequest(_choice(s, b.obj('request').str('choice')), b.obj('request').str('text') ?? ''),
                    ].join(' · '),
                  ),
                  trailing: Wrap(
                    children: <Widget>[
                      if (b.obj('request').isNotEmpty && !b.obj('request').flag('seen'))
                        IconButton(tooltip: s.inMarkSeen, icon: const Icon(Icons.done_rounded), onPressed: () => _act(() => _repo.seeRequest(b.str('id')!), s.inSeen)),
                      if (c.flag('attendanceCorrectable')) Switch(value: b.flag('attended'), onChanged: (bool v) => _act(() => _repo.correctAttendance(b.str('id')!, v), s.inCorrected)),
                    ],
                  ),
                ),
              const SizedBox(height: NSpace.lg),
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
                TextButton(onPressed: _cancel, child: Text(status == 'draft' ? s.inDeleteDraft : s.inCancelClass)),
              ],
              if (status == 'completed' && !c.flag('attendanceConfirmed') && c.flag('attendanceCorrectable'))
                NPrimaryButton(label: s.inConfirmAttendance, onPressed: () => _act(() => _repo.confirmAttendance(widget.classId), s.inAttendanceConfirmed)),
              // The class room and console (spec 013 §4; spec 014 §8). The server says when the room is open.
              if (status == 'scheduled' || status == 'live')
                Padding(
                  padding: const EdgeInsets.only(top: NSpace.sm),
                  child: NSecondaryButton(label: s.icOpenRoom, onPressed: () => context.push('/instructor/sessions/${widget.classId}/room')),
                ),
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
    for (final TextEditingController c in <TextEditingController>[_title, _description, _minutes, _capacity]) {
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
    return AreaScaffold(
      title: _e == null ? s.inNewClass : s.inChange,
      body: ListView(
        padding: const EdgeInsets.all(NSpace.lg),
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
            decoration: InputDecoration(labelText: s.inDescription, helperText: s.inNoMedicalClaims),
          ),
          OutlinedButton.icon(onPressed: _pickStart, icon: const Icon(Icons.event_rounded), label: Text(_start == null ? s.inPickStart : _when(context, _start!.toUtc().toIso8601String()))),
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
          if (_e == null)
            DropdownButton<String?>(
              value: _level,
              isExpanded: true,
              hint: Text(s.inLevel),
              items: <DropdownMenuItem<String?>>[for (final String l in _levels) DropdownMenuItem<String?>(value: l, child: Text(l))],
              onChanged: (String? v) => setState(() => _level = v),
            ),
          NSectionTitle(s.inPhaseTags),
          Wrap(
            spacing: NSpace.xs,
            children: <Widget>[
              for (final String p in _phases) FilterChip(label: Text(p), selected: _phaseTags.contains(p), onSelected: (bool v) => setState(() => v ? _phaseTags.add(p) : _phaseTags.remove(p))),
            ],
          ),
          if (_e == null) ...<Widget>[
            SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(s.inWeekly), value: _weekly, onChanged: (bool v) => setState(() => _weekly = v)),
            if (_weekly)
              OutlinedButton(
                onPressed: () async {
                  final DateTime now = DateTime.now();
                  final DateTime? u = await showDatePicker(context: context, initialDate: now.add(const Duration(days: 28)), firstDate: now, lastDate: now.add(const Duration(days: 182)));
                  if (u != null) setState(() => _until = u);
                },
                child: Text(_until == null ? s.inUntil : s.inUntilDate(MaterialLocalizations.of(context).formatMediumDate(_until!))),
              ),
          ],
          const SizedBox(height: NSpace.lg),
          Text(s.inFeeNote, style: NType.caption.copyWith(color: NColors.inkMuted)),
          const SizedBox(height: NSpace.sm),
          NPrimaryButton(label: s.drSave, loading: _busy, onPressed: _save),
        ],
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
          for (final Json c in mine) SimpleDialogOption(onPressed: () => Navigator.of(d).pop(c), child: Text(c.str('title') ?? '')),
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
        builder: (BuildContext context, List<Json> rows) => rows.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(NSpace.lg),
                child: EmptyNote(text: s.inNoStudents),
              )
            : ListView(
                padding: const EdgeInsets.all(NSpace.lg),
                children: <Widget>[
                  for (final Json st in rows)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(st.str('firstName') ?? ''),
                      subtitle: Text(
                        <String>[
                          s.inAttendedOf(st.obj('attendance').integer('attended'), st.obj('attendance').integer('booked')),
                          if (st.str('cyclePhase') != null) s.inPhase(st.str('cyclePhase')!),
                          s.inProgress(st.obj('practiceProgress').integer('sessionsCompleted'), st.obj('practiceProgress').integer('minutesThisMonth')),
                        ].join(' · '),
                      ),
                      trailing: IconButton(tooltip: s.inRecommend, icon: const Icon(Icons.recommend_outlined), onPressed: () => _recommend(st)),
                    ),
                ],
              ),
      ),
    );
  }
}

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

  String _state(S s, String? st) => switch (st) {
    'draft' => s.dtPlanDraft,
    'in_review' => s.inInReview,
    'returned' => s.inReturned,
    'published' => s.dtPublishedLabel,
    'withdrawn' => s.inWithdrawn,
    _ => st ?? '',
  };

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return InstructorShell(
      index: 3,
      title: s.inLibrary,
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _edit(null), icon: const Icon(Icons.add_rounded), label: Text(s.inNewSession)),
      body: AsyncBody<List<Json>>(
        future: _list,
        onRetry: () => setState(() => _list = _repo.content()),
        builder: (BuildContext context, List<Json> rows) => rows.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(NSpace.lg),
                child: EmptyNote(text: s.inNoContent),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, NSpace.lg, 96),
                children: <Widget>[
                  for (final Json c in rows)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(c.str('title') ?? ''),
                      subtitle: Text(
                        <String>[
                          _state(s, c.str('status')),
                          s.practiceMinutes(c.integer('minutes')),
                          s.inStats(c.obj('stats').integer('plays'), c.obj('stats').integer('completions')),
                          if (c.str('reviewNote') != null) c.str('reviewNote')!,
                        ].join(' · '),
                      ),
                      onTap: () => _edit(c),
                    ),
                ],
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
    return AreaScaffold(
      title: c == null ? s.inNewSession : (c.str('title') ?? ''),
      body: ListView(
        padding: const EdgeInsets.all(NSpace.lg),
        children: <Widget>[
          if (c != null && c.str('reviewNote') != null) NCard(color: NColors.statusWarningLight, child: Text(c.str('reviewNote')!)),
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
            decoration: InputDecoration(labelText: s.inDescription, helperText: s.inNoMedicalClaims),
          ),
          TextField(
            controller: _minutes,
            enabled: editable,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: s.dtMinutes),
          ),
          NSectionTitle(s.inPhaseTags),
          Wrap(
            spacing: NSpace.xs,
            children: <Widget>[
              for (final String p in _phases)
                FilterChip(label: Text(p), selected: _suitability.contains(p), onSelected: editable ? (bool v) => setState(() => v ? _suitability.add(p) : _suitability.remove(p)) : null),
            ],
          ),
          NSectionTitle(s.inIntensity),
          Wrap(
            spacing: NSpace.xs,
            children: <Widget>[for (int i = 1; i <= 5; i++) ChoiceChip(label: Text('$i'), selected: _intensity == i, onSelected: editable ? (_) => setState(() => _intensity = i) : null)],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(s.inProposePregnancy),
            subtitle: Text(s.inReviewerDecides),
            value: _pregnancy ?? false,
            onChanged: editable ? (bool v) => setState(() => _pregnancy = v) : null,
          ),
          CheckboxListTile(contentPadding: EdgeInsets.zero, title: Text(s.inRights), value: _rights, onChanged: editable ? (bool? v) => setState(() => _rights = v ?? false) : null),
          if (c != null) Text(s.inStatsLong(c.obj('stats').integer('plays'), c.obj('stats').integer('completions')), style: NType.caption.copyWith(color: NColors.inkSecondary)),
          if (c != null && !c.flag('hasVideo')) Text(s.inVideoNotInApp, style: NType.caption.copyWith(color: NColors.inkMuted)),
          const SizedBox(height: NSpace.lg),
          if (editable) NSecondaryButton(label: s.drSaveDraft, onPressed: _busy ? null : () => _run(() => widget.repository.saveContent(c?.str('id'), _input), s.drSaved)),
          if (c != null && (c.str('status') == 'draft' || c.str('status') == 'returned')) ...<Widget>[
            const SizedBox(height: NSpace.xs),
            NPrimaryButton(label: s.inSubmit, loading: _busy, onPressed: () => _run(() => widget.repository.submitContent(c.str('id')!), s.inSubmitted)),
          ],
          if (c != null && c.str('status') == 'published')
            TextButton(
              onPressed: _busy
                  ? null
                  : () async {
                      await widget.repository.withdrawContent(c.str('id')!);
                      if (context.mounted) Navigator.of(context).pop();
                    },
              child: Text(s.inWithdraw),
            ),
        ],
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
              child: Text(label, style: NType.body.copyWith(fontWeight: FontWeight.w600)),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
    return InstructorShell(
      index: 4,
      title: s.pvShellMore,
      body: ListView(
        padding: const EdgeInsets.all(NSpace.lg),
        children: <Widget>[
          row(Icons.account_balance_wallet_outlined, s.earnTitle, '/instructor/earnings'),
          row(Icons.person_outline_rounded, s.profileTitle, '/instructor/profile'),
          row(Icons.notifications_none_rounded, s.notifTitle, RouteConstants.notificationSettings),
          const SizedBox(height: NSpace.md),
          OutlinedButton.icon(onPressed: () => providerSignOut(context), icon: const Icon(Icons.logout_rounded), label: Text(s.pvSignOut)),
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
    return AreaScaffold(
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
          return ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              Text(p.str('name') ?? '', style: NType.h3),
              Text(s.drApproval(p.str('approvalStatus') ?? ''), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
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
                controller: _types,
                decoration: InputDecoration(labelText: s.inPracticeTypes, helperText: s.drCommaSeparated),
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
