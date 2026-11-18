import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../cycle/domain/cycle.dart';
import '../../home/presentation/home_labels.dart';
import '../domain/practice.dart';
import 'practice_page.dart';

/// One recorded session (spec 010 §7 rules 3 and 4): its level and any caution the instructor wrote, the video,
/// and "I've finished", which writes one practice log however many times it is sent (AC27).
class PracticeSessionPage extends StatefulWidget {
  const PracticeSessionPage({required this.sessionId, super.key, this.repository});

  final String sessionId;
  final PracticeRepository? repository;

  @override
  State<PracticeSessionPage> createState() => _PracticeSessionPageState();
}

class _PracticeSessionPageState extends State<PracticeSessionPage> {
  late final PracticeRepository _repo = widget.repository ?? getIt<PracticeRepository>();
  late Future<PracticeSession> _session = _repo.session(widget.sessionId);

  /// One id per visit to this page, so a double tap or a resend logs once.
  final String _clientId = clientId();
  bool _saving = false;
  bool _done = false;

  Future<void> _finish(PracticeSession p) async {
    final S s = S.of(context);
    setState(() => _saving = true);
    try {
      await _repo.complete(p.id, durationSeconds: p.minutes * 60, clientId: _clientId);
      if (!mounted) return;
      setState(() => _done = true);
      showNote(context, s.practiceLogged);
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, s.commonLoadError));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) context.pop(_done);
      },
      child: AreaScaffold(
        title: s.practiceTitle,
        body: AsyncBody<PracticeSession>(
          future: _session,
          onRetry: () => setState(() => _session = _repo.session(widget.sessionId)),
          builder: (BuildContext context, PracticeSession p) => ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              Semantics(header: true, child: Text(p.title, style: NType.h2.copyWith(color: NColors.inkPrimary))),
              const SizedBox(height: NSpace.xs),
              Text(
                <String>[s.practiceMinutes(p.minutes), if (p.level != null) s.practiceLevel(p.level!), if (p.captions) s.practiceCaptions].join(' · '),
                style: NType.bodySm.copyWith(color: NColors.inkSecondary),
              ),
              if (p.caution != null) ...<Widget>[
                const SizedBox(height: NSpace.md),
                NCard(
                  color: NColors.statusWarningLight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(Icons.info_outline_rounded, color: NColors.statusWarningText),
                      const SizedBox(width: NSpace.sm),
                      Expanded(child: Text(p.caution!, style: NType.body.copyWith(color: NColors.inkPrimary))),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: NSpace.md),
              Text(p.description, style: NType.body.copyWith(color: NColors.inkPrimary)),
              const SizedBox(height: NSpace.lg),
              if (p.video != null) ...<Widget>[
                NSecondaryButton(label: s.practicePlay, onPressed: () => launchUrl(Uri.parse(p.video!), mode: LaunchMode.externalApplication)),
                const SizedBox(height: NSpace.sm),
              ] else ...<Widget>[
                Text(s.practiceNoVideo, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
                const SizedBox(height: NSpace.sm),
              ],
              NPrimaryButton(
                label: _done ? s.practiceLogged : s.practiceFinished,
                loading: _saving,
                onPressed: _done ? null : () => _finish(p),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The library (spec 010 §7 rule 1), filtered by length and cycle phase.
class PracticeLibraryPage extends StatefulWidget {
  const PracticeLibraryPage({super.key, this.repository});

  final PracticeRepository? repository;

  @override
  State<PracticeLibraryPage> createState() => _PracticeLibraryPageState();
}

class _PracticeLibraryPageState extends State<PracticeLibraryPage> {
  late final PracticeRepository _repo = widget.repository ?? getIt<PracticeRepository>();
  int? _maxMinutes;
  Phase? _phase;
  late Future<List<PracticeSession>> _items = _load();

  Future<List<PracticeSession>> _load() => _repo.library(PracticeFilters(maxMinutes: _maxMinutes, phase: _phase?.name));

  void _set(VoidCallback change) => setState(() {
        change();
        _items = _load();
      });

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.practiceLibraryTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.sm, NSpace.lg, 0),
            child: Row(
              children: <Widget>[
                for (final int m in const <int>[10, 20, 30]) ...<Widget>[
                  FilterChip(label: Text(s.practiceUpTo(m)), selected: _maxMinutes == m, onSelected: (bool on) => _set(() => _maxMinutes = on ? m : null)),
                  const SizedBox(width: NSpace.xs),
                ],
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.xs, NSpace.lg, NSpace.sm),
            child: Row(
              children: <Widget>[
                for (final Phase p in Phase.values) ...<Widget>[
                  FilterChip(label: Text(s.phaseName(p)), selected: _phase == p, onSelected: (bool on) => _set(() => _phase = on ? p : null)),
                  const SizedBox(width: NSpace.xs),
                ],
              ],
            ),
          ),
          Expanded(
            child: AsyncBody<List<PracticeSession>>(
              future: _items,
              onRetry: () => _set(() {}),
              builder: (BuildContext context, List<PracticeSession> items) => items.isEmpty
                  ? Padding(padding: const EdgeInsets.all(NSpace.lg), child: EmptyNote(text: s.practiceLibraryEmpty))
                  : ListView.separated(
                      padding: const EdgeInsets.all(NSpace.lg),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: NSpace.sm),
                      itemBuilder: (BuildContext context, int i) => SessionTile(session: items[i], onDone: () {}),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// What she did, by week (spec 010 §7 rule 6): shown as what she did, with no streak to break.
class PracticeHistoryPage extends StatefulWidget {
  const PracticeHistoryPage({super.key, this.repository});

  final PracticeRepository? repository;

  @override
  State<PracticeHistoryPage> createState() => _PracticeHistoryPageState();
}

class _PracticeHistoryPageState extends State<PracticeHistoryPage> {
  late final PracticeRepository _repo = widget.repository ?? getIt<PracticeRepository>();
  late Future<List<PracticeWeek>> _weeks = _repo.history();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.practiceHistoryTitle,
      body: AsyncBody<List<PracticeWeek>>(
        future: _weeks,
        onRetry: () => setState(() => _weeks = _repo.history()),
        builder: (BuildContext context, List<PracticeWeek> weeks) {
          final List<PracticeWeek> shown = weeks.where((PracticeWeek w) => w.sessions.isNotEmpty).toList();
          if (shown.isEmpty) return Padding(padding: const EdgeInsets.all(NSpace.lg), child: EmptyNote(text: s.practiceHistoryEmpty));
          return ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              for (final PracticeWeek w in shown) ...<Widget>[
                NSectionTitle(s.practiceWeekOf(shortDate(context, w.weekOf))),
                NCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(s.practiceWeekSummary(w.sessions.length, w.sessions.fold<int>(0, (int a, PracticeDone d) => a + d.minutes)), style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: NSpace.xs),
                      for (final PracticeDone d in w.sessions)
                        Padding(
                          padding: const EdgeInsets.only(top: NSpace.xxs),
                          child: Text('${shortDate(context, d.date)} · ${d.title ?? s.practiceTitle} · ${s.practiceMinutes(d.minutes)}', style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
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
}
