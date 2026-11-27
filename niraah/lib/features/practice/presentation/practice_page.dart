import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/area_navigation.dart';
import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/bottom_nav.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../../shared/constants/route_constants.dart';
import '../../cycle/domain/cycle.dart';
import '../../home/domain/home.dart';
import '../../home/presentation/home_labels.dart';
import '../domain/practice.dart';

/// The Practice tab (spec 010 §7): one or two sessions for today by her phase, the live class schedule, the
/// library and what she did. No streaks that can be broken (rule 6).
class PracticePage extends StatefulWidget {
  const PracticePage({super.key, this.repository});

  final PracticeRepository? repository;

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  late final PracticeRepository _repo = widget.repository ?? getIt<PracticeRepository>();
  late Future<PracticeToday> _today = _repo.today();
  late Future<LiveClasses?> _classes = _loadClasses();

  /// Live classes are their own area: a refusal there (a teen account, AC53) leaves the rest of Practice working.
  Future<LiveClasses?> _loadClasses() async {
    try {
      return await _repo.liveClasses();
    } on AreaLocked {
      return null;
    }
  }

  void _reload() => setState(() {
        _today = _repo.today();
        _classes = _loadClasses();
      });

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Scaffold(
      backgroundColor: NColors.surfacePage,
      body: SafeArea(
        child: AsyncBody<PracticeToday>(
          future: _today,
          onRetry: _reload,
          builder: (BuildContext context, PracticeToday today) => RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, NSpace.lg, NSpace.xl),
              children: <Widget>[
                Semantics(header: true, child: Text(s.practiceTitle, style: NType.h2.copyWith(color: NColors.inkPrimary))),
                const SizedBox(height: NSpace.xs),
                Text(_phaseLine(s, today.phase), style: NType.body.copyWith(color: NColors.inkSecondary)),
                NSectionTitle(s.practiceForToday),
                if (today.sessions.isEmpty)
                  EmptyNote(text: s.practiceTodayEmpty, actionLabel: s.practiceBrowse, onAction: () => context.push(RouteConstants.practiceLibrary))
                else
                  for (PracticeSession p in today.sessions) ...<Widget>[SessionTile(session: p, onDone: _reload), const SizedBox(height: NSpace.sm)],
                NSectionTitle(s.practiceLiveTitle),
                FutureBuilder<LiveClasses?>(
                  future: _classes,
                  builder: (BuildContext context, AsyncSnapshot<LiveClasses?> snap) {
                    if (snap.connectionState != ConnectionState.done) return Text(s.loading, style: NType.bodySm.copyWith(color: NColors.inkMuted));
                    if (snap.hasError) return EmptyNote(text: s.commonLoadError, actionLabel: s.tryAgain, onAction: _reload);
                    final LiveClasses? c = snap.data;
                    if (c == null) return const SizedBox.shrink();
                    return _LiveClassesView(classes: c, repo: _repo);
                  },
                ),
                NSectionTitle(s.practiceMore),
                NCard(
                  onTap: () => context.push(RouteConstants.practiceLibrary),
                  semanticsLabel: s.practiceBrowse,
                  child: _LinkRow(icon: Icons.video_library_outlined, text: s.practiceBrowse),
                ),
                const SizedBox(height: NSpace.sm),
                NCard(
                  onTap: () => context.push(RouteConstants.practiceHistory),
                  semanticsLabel: s.practiceHistoryTitle,
                  child: _LinkRow(icon: Icons.event_note_outlined, text: s.practiceHistoryTitle),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NBottomNav(
        labels: <String>[for (Area a in Area.values) s.areaName(a)],
        index: 3,
        onSelected: (int i) {
          if (i != 3) goToArea(context, Area.values[i]);
        },
      ),
    );
  }

  static String _phaseLine(S s, String? phase) {
    final Phase? p = phaseFrom(phase);
    return p == null ? s.practiceNoPhase : s.practiceForPhase(s.phaseEstimated(p));
  }
}

Phase? phaseFrom(String? key) {
  for (Phase p in Phase.values) {
    if (p.name == key) return p;
  }
  return null;
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Icon(icon, color: NColors.inkSecondary),
          const SizedBox(width: NSpace.sm),
          Expanded(child: Text(text, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600))),
          Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
        ],
      );
}

/// A session in a list: title, length and level, opening its page.
class SessionTile extends StatelessWidget {
  const SessionTile({required this.session, required this.onDone, super.key});

  final PracticeSession session;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String meta = <String>[s.practiceMinutes(session.minutes), if (session.level != null) session.level!].join(' · ');
    return NCard(
      color: NColors.brandSageLight,
      semanticsLabel: '${session.title}, $meta',
      onTap: () async {
        final bool? done = await context.push<bool>('${RouteConstants.practiceSession}/${session.id}');
        if (done ?? false) onDone();
      },
      child: Row(
        children: <Widget>[
          Icon(Icons.self_improvement_rounded, color: NColors.inkPrimary),
          const SizedBox(width: NSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(session.title, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: NSpace.xxs),
                Text(meta, style: NType.caption.copyWith(color: NColors.inkSecondary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
        ],
      ),
    );
  }
}

/// The schedule with instructor, time in her time zone and places left (spec 010 §7 rule 5). During the trial
/// classes show as starting with her first payment.
class _LiveClassesView extends StatefulWidget {
  const _LiveClassesView({required this.classes, required this.repo});

  final LiveClasses classes;
  final PracticeRepository repo;

  @override
  State<_LiveClassesView> createState() => _LiveClassesViewState();
}

class _LiveClassesViewState extends State<_LiveClassesView> {
  /// Classes she booked from this screen, shown as booked straight away.
  final Set<String> _booked = <String>{};
  String? _busy;

  Future<void> _book(BuildContext context, LiveClass c) async {
    final S s = S.of(context);
    final String locale = Localizations.localeOf(context).toString();
    final bool? go = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: NColors.surfaceCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(NRadius.xl))),
      builder: (BuildContext sheet) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(NSpace.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(c.title, style: NType.h3.copyWith(color: NColors.inkPrimary)),
                const SizedBox(height: NSpace.sm),
                _ClassFact(icon: Icons.event_rounded, text: DateFormat('EEEE d MMMM', locale).format(c.startsAt)),
                _ClassFact(
                  icon: Icons.schedule_rounded,
                  text: '${_hm(c.startsAt, locale)} – ${_hm(c.endsAt, locale)} · ${c.endsAt.difference(c.startsAt).inMinutes} min',
                ),
                if (c.instructor != null) _ClassFact(icon: Icons.self_improvement_rounded, text: c.instructor!),
                const _ClassFact(icon: Icons.videocam_outlined, text: 'Live video class'),
                const SizedBox(height: NSpace.lg),
                NPrimaryButton(label: s.practiceBook, onPressed: () => Navigator.of(sheet).pop(true)),
              ],
            ),
          ),
        ),
      ),
    );
    if (go != true || !context.mounted) return;
    setState(() => _busy = c.id);
    try {
      final BookingOutcome o = await widget.repo.book(c.id);
      if (!context.mounted) return;
      if (o == BookingOutcome.booked) setState(() => _booked.add(c.id));
      showNote(context, o == BookingOutcome.booked ? s.practiceBooked : s.practicePayOnWeb);
    } on Object catch (e) {
      if (context.mounted) showNote(context, failureText(e, s.commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String locale = Localizations.localeOf(context).toString();
    final LiveClasses classes = widget.classes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (classes.access == ClassAccess.afterTrial)
          Padding(
            padding: const EdgeInsets.only(bottom: NSpace.sm),
            child: Text(
              classes.startsOn == null ? s.practiceClassesAfterTrial : s.areaStartsOn(classes.startsOn!),
              style: NType.bodySm.copyWith(color: NColors.inkSecondary),
            ),
          ),
        if (classes.classes.isEmpty) EmptyNote(text: s.practiceClassesEmpty, picture: EmptyArt.classes),
        for (LiveClass c in classes.classes) ...<Widget>[
          _LiveClassCard(
            c: c,
            locale: locale,
            booked: _booked.contains(c.id),
            busy: _busy == c.id,
            placesText: c.placesLeft > 0 ? s.practicePlacesLeft(c.placesLeft) : s.practiceClassFull,
            bookLabel: s.practiceBook,
            onBook: classes.access == ClassAccess.included && c.placesLeft > 0 && !_booked.contains(c.id) && _busy == null ? () => _book(context, c) : null,
          ),
          const SizedBox(height: NSpace.sm),
        ],
      ],
    );
  }
}

String _hm(DateTime t, String locale) => DateFormat('h:mm a', locale).format(t).toLowerCase();

class _ClassFact extends StatelessWidget {
  const _ClassFact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: <Widget>[
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: NColors.brandSageLight, borderRadius: BorderRadius.circular(NRadius.sm)),
          child: Icon(icon, size: 17, color: NColors.statusSuccess),
        ),
        const SizedBox(width: NSpace.sm),
        Expanded(
          child: Text(text, style: NType.body.copyWith(color: NColors.inkPrimary)),
        ),
      ],
    ),
  );
}

/// One live class: a date tile, the title, time and teacher, a level pill, how full it is, and Book.
class _LiveClassCard extends StatelessWidget {
  const _LiveClassCard({
    required this.c,
    required this.locale,
    required this.booked,
    required this.busy,
    required this.placesText,
    required this.bookLabel,
    required this.onBook,
  });

  final LiveClass c;
  final String locale;
  final bool booked;
  final bool busy;
  final String placesText;
  final String bookLabel;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    final bool full = c.placesLeft <= 0;
    return Container(
      padding: const EdgeInsets.all(NSpace.md),
      decoration: BoxDecoration(
        color: NColors.surfaceCard,
        borderRadius: BorderRadius.circular(NRadius.lg),
        boxShadow: NShadow.sm,
        border: Border.all(color: booked ? NColors.brandSage : NColors.lineDefault.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 58,
                padding: const EdgeInsets.symmetric(vertical: NSpace.xs),
                decoration: BoxDecoration(color: NColors.brandSageLight, borderRadius: BorderRadius.circular(NRadius.md)),
                child: Column(
                  children: <Widget>[
                    Text(DateFormat('MMM', locale).format(c.startsAt).toUpperCase(), style: NType.caption.copyWith(color: NColors.statusSuccess)),
                    Text('${c.startsAt.day}', style: NType.h2.copyWith(color: NColors.inkPrimary, height: 1.05)),
                    Text(DateFormat('EEE', locale).format(c.startsAt), style: NType.label.copyWith(color: NColors.inkMuted)),
                  ],
                ),
              ),
              const SizedBox(width: NSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(c.title, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                    const SizedBox(height: 2),
                    Text('${_hm(c.startsAt, locale)} – ${_hm(c.endsAt, locale)}', style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                    if (c.instructor != null)
                      Row(
                        children: <Widget>[
                          Icon(Icons.self_improvement_rounded, size: 15, color: NColors.inkMuted),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              c.instructor!,
                              style: NType.label.copyWith(color: NColors.inkMuted),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (c.level != null) ...<Widget>[
                      const SizedBox(height: NSpace.xxs),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: NSpace.xs, vertical: 3),
                        decoration: BoxDecoration(color: NColors.brandLavenderLight, borderRadius: BorderRadius.circular(NRadius.pill)),
                        child: Text(
                          c.level!,
                          style: NType.label.copyWith(color: NColors.brandPlum, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: NSpace.sm),
          Divider(height: 1, color: NColors.lineDefault),
          const SizedBox(height: NSpace.sm),
          Row(
            children: <Widget>[
              Icon(full ? Icons.event_busy_rounded : Icons.people_outline_rounded, size: 16, color: full ? NColors.inkMuted : NColors.statusSuccess),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  placesText,
                  style: NType.label.copyWith(color: full ? NColors.inkMuted : NColors.inkSecondary, fontWeight: FontWeight.w600),
                ),
              ),
              if (booked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: 8),
                  decoration: BoxDecoration(color: NColors.statusSuccessLight, borderRadius: BorderRadius.circular(NRadius.pill)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.check_circle_rounded, size: 16, color: NColors.statusSuccess),
                      const SizedBox(width: 4),
                      Text(
                        'Booked',
                        style: NType.label.copyWith(color: NColors.statusSuccess, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                )
              else if (onBook != null || busy)
                FilledButton(
                  onPressed: onBook,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, NLayout.minTapTarget),
                    padding: const EdgeInsets.symmetric(horizontal: NSpace.md),
                    shape: const StadiumBorder(),
                  ),
                  child: busy
                      ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: NColors.actionOnPrimary))
                      : Text(bookLabel),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
