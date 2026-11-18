import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/doctor.dart';
import 'doctor_shell.dart';
import 'wellness_advice_pages.dart';

/// Doctor dashboard (spec 011 §1), mirroring apps/web/src/app/(doctor)/doctor/dashboard.tsx.
/// Each count equals the list it opens (AC6).
class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key, this.repository});

  final DoctorRepository? repository;

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  late final DoctorRepository _repo = widget.repository ?? getIt<DoctorRepository>();
  late Future<DoctorDashboard> _dash = _repo.getDashboard();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return DoctorShell(
      index: 0,
      body: FutureBuilder<DoctorDashboard>(
        future: _dash,
        builder: (BuildContext context, AsyncSnapshot<DoctorDashboard> snap) {
          if (snap.hasError) {
            return ErrorView(message: s.commonLoadError, retryLabel: s.tryAgain, onRetry: () => setState(() => _dash = _repo.getDashboard()));
          }
          final DoctorDashboard? d = snap.data;
          if (d == null) return LoadingView(label: s.loading);
          final NeedsMe n = d.needsMe;
          final double? oldest = n.oldestReviewDueInHours;
          final String? oldestText = oldest == null
              ? null
              : oldest <= 0
              ? s.pvDashOldestOverdue
              : oldest < 1
              ? s.pvDashOldestUnderHour
              : s.pvDashOldestDue(oldest.round());
          Future<void> open(String path) async {
            await context.push(path);
            if (mounted) setState(() => _dash = _repo.getDashboard());
          }

          Future<void> openQueue() => open('/doctor/queue');

          return ListView(
            padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.sm, NSpace.lg, NSpace.xl),
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(s.pvDashGreeting(d.name ?? ''), style: NType.h2.copyWith(color: NColors.inkPrimary)),
              ),
              if (d.speciality != null) Text(d.speciality!, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
              const SizedBox(height: NSpace.xs),
              Row(
                children: <Widget>[
                  Icon(Icons.schedule_rounded, size: NSpace.md, color: d.onCall ? NColors.statusSuccess : NColors.inkMuted),
                  const SizedBox(width: NSpace.xs),
                  Expanded(
                    child: Text(d.onCall ? s.pvDashOnCall : s.pvDashNotOnCall, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                  ),
                ],
              ),
              const SizedBox(height: NSpace.lg),
              Semantics(
                header: true,
                child: Text(s.pvDashNeedsMe, style: NType.h4.copyWith(color: NColors.inkPrimary)),
              ),
              const SizedBox(height: NSpace.sm),
              _TileGrid(
                tiles: <_Tile>[
                  _Tile(label: s.pvDashUrgentAlerts, count: n.urgentAlerts, urgent: n.urgentAlerts > 0, onTap: () => open('/doctor/alerts')),
                  _Tile(label: s.pvDashReviews, count: n.reviews, detail: oldestText, onTap: openQueue),
                  _Tile(label: s.pvDashCarePlans, count: n.carePlans, onTap: () => open('/doctor/care-plans')),
                  _Tile(label: s.pvDashLabResults, count: n.labResults, onTap: () => open('/doctor/labs')),
                  _Tile(label: s.pvDashMessages, count: n.messages, onTap: () => open('/doctor/messages')),
                  _Tile(label: s.pvDashDrafts, count: n.draftPrescriptions, onTap: () => open('/doctor/advice')),
                  if (n.clinicalReview != null) _Tile(label: s.drReviewerTasks, count: n.clinicalReview!, onTap: () => open('/doctor/reviewer')),
                ],
              ),
              const SizedBox(height: NSpace.sm),
              NSecondaryButton(label: s.pvDashOpenQueue, onPressed: openQueue),
              const SizedBox(height: NSpace.lg),
              Semantics(
                header: true,
                child: Text(s.pvDashToday, style: NType.h4.copyWith(color: NColors.inkPrimary)),
              ),
              const SizedBox(height: NSpace.sm),
              if (d.today.isEmpty)
                Text(s.pvDashNoAppointments, style: NType.bodySm.copyWith(color: NColors.inkMuted))
              else
                for (final TodayAppointment a in d.today)
                  Container(
                    margin: const EdgeInsets.only(bottom: NSpace.xs),
                    padding: const EdgeInsets.all(NSpace.md),
                    decoration: BoxDecoration(
                      color: NColors.surfaceCard,
                      borderRadius: BorderRadius.circular(NRadius.lg),
                      border: Border.all(color: NColors.lineDefault),
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: NSpace.xl3,
                          child: Text(
                            MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(a.startsAt.toLocal())),
                            style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (a.member != null) Text(a.member!, style: NType.body.copyWith(color: NColors.inkPrimary)),
                              if (a.reason != null) Text(a.reason!, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                              // Wellness advice is written in or after the consult (spec 011 §7 "Who and when" 2); the server checks the window.
                              if (!a.startsAt.isAfter(DateTime.now()))
                                TextButton(
                                  onPressed: () async {
                                    await startAdvice(context, a.id);
                                    if (mounted) setState(() => _dash = _repo.getDashboard());
                                  },
                                  child: Text(s.drWriteAdvice),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            // The consult room is on the web app; the app's room comes next (plan 011 "Screens").
                            FilledButton(onPressed: null, child: Text(s.pvDashJoin)),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 110),
                              child: Text(
                                a.joinable ? s.pvDashJoinOnWeb : s.pvDashJoinSoon,
                                textAlign: TextAlign.end,
                                style: NType.label.copyWith(color: NColors.inkMuted, letterSpacing: 0),
                              ),
                            ),
                          ],
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

class _Tile {
  const _Tile({required this.label, required this.count, this.detail, this.onTap, this.urgent = false});

  final String label;
  final int count;
  final String? detail;
  final VoidCallback? onTap;
  final bool urgent;
}

class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.tiles});

  final List<_Tile> tiles;

  @override
  Widget build(BuildContext context) {
    Widget tile(_Tile t) => Semantics(
      button: t.onTap != null,
      label: '${t.label}: ${t.count}${t.detail == null ? '' : '. ${t.detail}'}',
      excludeSemantics: true,
      child: Material(
        color: t.onTap != null ? NColors.brandLavenderLight : NColors.surfaceCard,
        borderRadius: BorderRadius.circular(NRadius.lg),
        child: InkWell(
          onTap: t.onTap,
          borderRadius: BorderRadius.circular(NRadius.lg),
          child: Container(
            constraints: const BoxConstraints(minHeight: NLayout.minTapTarget * 2),
            padding: const EdgeInsets.all(NSpace.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(NRadius.lg),
              border: Border.all(color: NColors.lineDefault),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('${t.count}', style: NType.h2.copyWith(color: t.urgent ? NColors.statusClinicalRedFlag : NColors.inkPrimary)),
                Text(t.label, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                if (t.detail != null) Text(t.detail!, style: NType.label.copyWith(color: NColors.inkMuted, letterSpacing: 0)),
              ],
            ),
          ),
        ),
      ),
    );
    return Column(
      children: <Widget>[
        for (int i = 0; i < tiles.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: NSpace.xs),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(child: tile(tiles[i])),
                  const SizedBox(width: NSpace.xs),
                  Expanded(child: i + 1 < tiles.length ? tile(tiles[i + 1]) : const SizedBox.shrink()),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
