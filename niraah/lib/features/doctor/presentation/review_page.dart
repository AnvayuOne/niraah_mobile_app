import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/clinician_ui.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/doctor.dart';
import 'doctor_shell.dart';
import 'review_queue_page.dart';

/// One pre-score review (spec 011 §4, spec 007 §7). Opening it claims it.
/// Built for a decision in about a minute: the AI clinician summary and flags
/// first, answers below. Score, band and flags cannot be changed (AC36).
class ReviewPage extends StatefulWidget {
  const ReviewPage({required this.reviewId, super.key, this.repository});

  final String reviewId;
  final DoctorRepository? repository;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late final DoctorRepository _repo = widget.repository ?? getIt<DoctorRepository>();
  ReviewDetail? _review;
  ClaimFailure? _failure;
  int? _editing;
  final TextEditingController _edit = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _claim();
  }

  @override
  void dispose() {
    _edit.dispose();
    super.dispose();
  }

  Future<void> _claim() async {
    final ClaimResult r = await _repo.claim(widget.reviewId);
    if (mounted) {
      setState(() {
        _review = r.review;
        _failure = r.failure;
      });
    }
  }

  Future<void> _setObservation(int index, String? text) async {
    final ReviewDetail next = await _repo.editObservation(widget.reviewId, index, text);
    if (mounted) {
      setState(() {
        _review = next;
        _editing = null;
      });
    }
  }

  Future<void> _complete(ReviewOutcome outcome, String note, {bool next = false}) async {
    final S s = S.of(context);
    setState(() => _busy = true);
    final CompleteResult r = await _repo.complete(widget.reviewId, outcome, note, next: next);
    if (!mounted) return;
    setState(() => _busy = false);
    if (r.noteRequired) return;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(s.pvReviewDone)));
    // "Verify and next" completes and opens the next review in one step (spec 007 §7.4).
    if (r.next != null) {
      context.pushReplacement('/doctor/review/${r.next}');
    } else {
      context.canPop() ? context.pop() : context.go('/doctor/queue');
    }
  }

  Future<void> _release() async {
    await _repo.release(widget.reviewId);
    if (mounted) context.canPop() ? context.pop() : context.go('/doctor/queue');
  }

  Future<String?> _noteSheet({required String title, required String label, required String send, String? inactive}) {
    final TextEditingController note = TextEditingController();
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: NColors.surfacePage,
      builder: (BuildContext sheet) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(NSpace.lg, 0, NSpace.lg, NSpace.lg + MediaQuery.viewInsetsOf(sheet).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(title, style: NType.h3.copyWith(color: NColors.inkPrimary)),
              ),
              const SizedBox(height: NSpace.md),
              TextField(
                controller: note,
                minLines: 2,
                maxLines: 5,
                maxLength: 500,
                onChanged: (_) => setSheet(() {}),
                decoration: InputDecoration(labelText: label),
              ),
              const SizedBox(height: NSpace.sm),
              NPrimaryButton(label: send, inactiveHint: inactive, onPressed: inactive != null && note.text.trim().isEmpty ? null : () => Navigator.of(sheet).pop(note.text.trim())),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    if (_failure != null) {
      return Scaffold(
        backgroundColor: NColors.surfacePage,
        appBar: AppBar(backgroundColor: NColors.surfacePage, title: Text(s.pvReviewBack)),
        body: Padding(
          padding: const EdgeInsets.all(NSpace.lg),
          child: Semantics(
            liveRegion: true,
            child: Text(_failure == ClaimFailure.holdingAnother ? s.pvQueueHoldingAnother : s.pvQueueGone, style: NType.body.copyWith(color: NColors.inkPrimary)),
          ),
        ),
      );
    }
    final ReviewDetail? r = _review;
    if (r == null) {
      return Scaffold(
        body: LoadingView(label: s.loadCare, kind: NLoaderKind.care),
      );
    }

    return Scaffold(
      backgroundColor: NColors.surfacePage,
      appBar: AppBar(
        backgroundColor: NColors.surfacePage,
        leading: IconButton(tooltip: s.pvReviewBack, icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.canPop() ? context.pop() : context.go('/doctor/queue')),
        title: Text(s.pvReviewTitle, style: NType.h4.copyWith(color: NColors.inkPrimary)),
        actions: <Widget>[TextButton(onPressed: _release, child: Text(s.pvReviewRelease))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl),
        children: <Widget>[
          CHero(
            eyebrow: s.pvShellQueue,
            title: r.member ?? s.pvReviewTitle,
            subtitle: <String?>[r.ageBand, r.plan].whereType<String>().join(' · '),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (r.dueInHours != null) ...<Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: NSpace.xxs + 2),
                    decoration: BoxDecoration(color: r.dueInHours! <= 0 ? NColors.brandApricot : NColors.surfaceCard, borderRadius: BorderRadius.circular(NRadius.pill), border: Border.all(color: NColors.lineDefault)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.schedule_rounded, size: 14, color: r.dueInHours! <= 0 ? NColors.inkPrimary : NColors.inkSecondary),
                        const SizedBox(width: 4),
                        Text(
                          dueText(s, r.dueInHours),
                          style: NType.caption.copyWith(color: r.dueInHours! <= 0 ? NColors.inkPrimary : NColors.inkSecondary, fontWeight: FontWeight.w700, letterSpacing: 0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: NSpace.sm),
                ],
                Text(
                  s.pvReviewConsent.toUpperCase(),
                  style: NType.label.copyWith(color: NColors.inkMuted, letterSpacing: 1.2, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: NSpace.xxs),
                Wrap(
                  spacing: NSpace.xxs,
                  runSpacing: NSpace.xxs,
                  children: <Widget>[
                    for (final String c in r.consentCategories)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: NSpace.xs + 2, vertical: 4),
                        decoration: BoxDecoration(
                          color: r.consent.contains(c) ? NColors.brandSageLight : NColors.surfaceCard.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(NRadius.pill),
                          border: Border.all(color: NColors.lineDefault),
                        ),
                        child: Text(
                          '$c · ${r.consent.contains(c) ? s.pvReviewConsentView : s.pvReviewConsentNone}',
                          style: NType.caption.copyWith(
                            color: r.consent.contains(c) ? NColors.statusSuccess : NColors.inkMuted,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: NSpace.md),

          // The AI's clinician summary leads the screen (spec 007 §7.6); absent when none was made.
          if (r.summary != null) ...<Widget>[
            CEntrance(
              delayMs: 40,
              child: Container(
                padding: const EdgeInsets.all(NSpace.md),
                decoration: BoxDecoration(
                  color: NColors.brandLavenderLight,
                  borderRadius: BorderRadius.circular(NRadius.xl),
                  border: Border.all(color: NColors.brandLavender.withValues(alpha: 0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(Icons.auto_awesome_outlined, size: 18, color: NColors.statusInfo),
                        const SizedBox(width: NSpace.xs),
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: Text(s.pvReviewSummary, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: NSpace.xs),
                    Text(r.summary!, style: NType.body.copyWith(color: NColors.inkPrimary)),
                    const SizedBox(height: NSpace.xs),
                    Text(s.pvReviewSummaryNote, style: NType.label.copyWith(color: NColors.inkSecondary, letterSpacing: 0)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: NSpace.md),
          ],
          CPanel(
            title: s.pvReviewFlags,
            icon: Icons.flag_outlined,
            child: r.flags.isEmpty
                ? Text(s.pvQueueNoFlags, style: NType.bodySm.copyWith(color: NColors.inkMuted))
                : Wrap(
                    spacing: NSpace.xs,
                    runSpacing: NSpace.xs,
                    children: <Widget>[for (final QueueFlag f in r.flags) FlagBadge(flag: f)],
                  ),
          ),
          const SizedBox(height: NSpace.md),
          CPanel(
            title: s.pvReviewScores,
            icon: Icons.insights_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    ScoreRing(value: r.total.toDouble(), max: r.maximum.toDouble()),
                    const SizedBox(width: NSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            s.pvReviewTotal(r.total, r.maximum, r.band ?? '—'),
                            style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: NSpace.xxs),
                          Row(
                            children: <Widget>[
                              const Icon(Icons.lock_outline_rounded, size: 14, color: NColors.inkMuted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(s.pvReviewScoreLocked, style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (r.dimensions.isNotEmpty) ...<Widget>[
                  const SizedBox(height: NSpace.sm),
                  CLabel(s.drADimensions),
                  for (final DimensionPoints d in r.dimensions) DimensionBar(name: d.name, points: d.points, max: d.max, level: d.level),
                ],
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.report_outlined, size: 18),
                    onPressed: () async {
                      final String? note = await _noteSheet(title: s.pvReviewConcern, label: s.pvReviewConcernLabel, send: s.pvReviewConcernSend, inactive: s.pvReviewConcernInactive);
                      if (note == null || !context.mounted) return;
                      await _repo.scoringConcern(widget.reviewId, note);
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.pvReviewConcernSent)));
                    },
                    label: Text(s.pvReviewConcern),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: NSpace.md),
          CPanel(
            title: s.pvReviewObservations,
            icon: Icons.visibility_outlined,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[for (final (int i, ReviewObservation o) in r.observations.indexed) _observation(s, i, o)]),
          ),
          const SizedBox(height: NSpace.md),
          CPanel(
            title: s.pvReviewAnswers,
            icon: Icons.question_answer_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final (int i, ReviewAnswer a) in r.answers.indexed)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: NSpace.xs),
                    decoration: BoxDecoration(
                      border: i == 0 ? null : const Border(top: BorderSide(color: NColors.lineDefault)),
                    ),
                    child: MergeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(a.q, style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0)),
                          const SizedBox(height: 2),
                          Text(
                            a.a,
                            style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.sm, NSpace.md, NSpace.sm),
          decoration: const BoxDecoration(
            color: NColors.surfaceCard,
            border: Border(top: BorderSide(color: NColors.lineDefault)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              NPrimaryButton(
                label: s.pvReviewVerifyNext,
                loading: _busy,
                onPressed: () async {
                  final String? note = await _noteSheet(title: s.pvReviewVerifyNext, label: s.pvReviewNoteLabel, send: s.pvReviewVerifyNext);
                  if (note != null) await _complete(ReviewOutcome.verified, note, next: true);
                },
              ),
              const SizedBox(height: NSpace.xs),
              // Tighter padding so both labels fit on one line at phone width.
              OutlinedButtonTheme(
                data: OutlinedButtonThemeData(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: NSpace.xs, vertical: NSpace.md),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: NSecondaryButton(label: s.pvReviewAccept, onPressed: _busy ? null : () => _complete(ReviewOutcome.verified, '')),
                    ),
                    const SizedBox(width: NSpace.xs),
                    Expanded(
                      child: NSecondaryButton(
                        label: s.pvReviewFollowUp,
                        onPressed: _busy
                            ? null
                            : () async {
                                final String? note = await _noteSheet(title: s.pvReviewFollowUp, label: s.pvReviewFollowUpLabel, send: s.pvReviewFollowUpSend, inactive: s.pvReviewFollowUpInactive);
                                if (note != null) await _complete(ReviewOutcome.followUp, note);
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _observation(S s, int i, ReviewObservation o) {
    final bool editing = _editing == i;
    return Container(
      margin: const EdgeInsets.only(bottom: NSpace.xs),
      padding: const EdgeInsets.fromLTRB(NSpace.sm, NSpace.sm, NSpace.sm, NSpace.xxs),
      decoration: BoxDecoration(
        color: o.removed ? NColors.surfaceBackdrop : (o.edited != null ? NColors.brandBlushLight.withValues(alpha: 0.5) : NColors.surfacePage),
        borderRadius: BorderRadius.circular(NRadius.lg),
        border: Border(left: BorderSide(color: o.removed ? NColors.lineStrong : NColors.brandRosewood, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (editing) ...<Widget>[
            TextField(
              controller: _edit,
              minLines: 2,
              maxLines: 4,
              maxLength: 160,
              autofocus: true,
              decoration: InputDecoration(labelText: s.pvReviewEdit),
            ),
            Row(
              children: <Widget>[
                TextButton(onPressed: () => _setObservation(i, _edit.text.trim()), child: Text(s.pvReviewSave)),
                TextButton(onPressed: () => setState(() => _editing = null), child: Text(s.pvReviewCancel)),
              ],
            ),
          ] else ...<Widget>[
            if (o.edited != null && !o.removed)
              Padding(
                padding: const EdgeInsets.only(bottom: NSpace.xxs),
                child: CPill(s.pvReviewEdited, tone: CTone.rose),
              ),
            Text(
              o.shown,
              style: NType.body.copyWith(color: o.removed ? NColors.inkMuted : NColors.inkPrimary, decoration: o.removed ? TextDecoration.lineThrough : null),
            ),
            if (o.edited != null && !o.removed) ...<Widget>[const SizedBox(height: NSpace.xxs), Text('${s.pvReviewOriginalAi}: ${o.original}', style: NType.bodySm.copyWith(color: NColors.inkMuted))],
            Wrap(
              children: <Widget>[
                if (!o.removed)
                  TextButton(
                    onPressed: () => setState(() {
                      _editing = i;
                      _edit.text = o.shown;
                    }),
                    child: Text(s.pvReviewEdit),
                  ),
                if (!o.removed) TextButton(onPressed: () => _setObservation(i, null), child: Text(s.pvReviewRemove)),
                if (o.changed) TextButton(onPressed: () => _setObservation(i, o.original), child: Text(s.pvReviewRestore)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
