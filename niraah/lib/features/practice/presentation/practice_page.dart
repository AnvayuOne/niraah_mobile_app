import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/area_navigation.dart';
import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/bottom_nav.dart';
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
                  for (final PracticeSession p in today.sessions) ...<Widget>[SessionTile(session: p, onDone: _reload), const SizedBox(height: NSpace.sm)],
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
        labels: <String>[for (final Area a in Area.values) s.areaName(a)],
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
  for (final Phase p in Phase.values) {
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
          const Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
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
          const Icon(Icons.self_improvement_rounded, color: NColors.inkPrimary),
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
          const Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
        ],
      ),
    );
  }
}

/// The schedule with instructor, time in her time zone and places left (spec 010 §7 rule 5). During the trial
/// classes show as starting with her first payment.
class _LiveClassesView extends StatelessWidget {
  const _LiveClassesView({required this.classes, required this.repo});

  final LiveClasses classes;
  final PracticeRepository repo;

  Future<void> _book(BuildContext context, LiveClass c) async {
    final S s = S.of(context);
    try {
      final BookingOutcome o = await repo.book(c.id);
      if (!context.mounted) return;
      showNote(context, o == BookingOutcome.booked ? s.practiceBooked : s.practicePayOnWeb);
    } on Object catch (e) {
      if (context.mounted) showNote(context, failureText(e, s.commonLoadError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String locale = Localizations.localeOf(context).toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (classes.access == ClassAccess.afterTrial)
          Padding(
            padding: const EdgeInsets.only(bottom: NSpace.sm),
            child: Text(classes.startsOn == null ? s.practiceClassesAfterTrial : s.areaStartsOn(classes.startsOn!), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
          ),
        if (classes.classes.isEmpty) EmptyNote(text: s.practiceClassesEmpty),
        for (final LiveClass c in classes.classes) ...<Widget>[
          NCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(c.title, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: NSpace.xxs),
                Text(
                  <String>[DateFormat('EEE d MMM, h:mm a', locale).format(c.startsAt), if (c.instructor != null) c.instructor!, if (c.level != null) c.level!].join(' · '),
                  style: NType.caption.copyWith(color: NColors.inkSecondary),
                ),
                const SizedBox(height: NSpace.xxs),
                Text(c.placesLeft > 0 ? s.practicePlacesLeft(c.placesLeft) : s.practiceClassFull, style: NType.caption.copyWith(color: NColors.inkSecondary)),
                if (classes.access == ClassAccess.included && c.placesLeft > 0) ...<Widget>[
                  const SizedBox(height: NSpace.xs),
                  Align(alignment: Alignment.centerLeft, child: OutlinedButton(onPressed: () => _book(context, c), child: Text(s.practiceBook))),
                ],
              ],
            ),
          ),
          const SizedBox(height: NSpace.sm),
        ],
      ],
    );
  }
}
