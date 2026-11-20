import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/clinician_ui.dart';
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
          if (d == null) return LoadingView(label: s.loadCare, kind: NLoaderKind.care);
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

          final List<TodayAppointment> today = d.today;
          final DateTime now = DateTime.now();
          final TodayAppointment? next = today.where((TodayAppointment a) => a.startsAt.isAfter(now.subtract(const Duration(minutes: 20)))).firstOrNull;
          final int waiting = n.urgentAlerts + n.reviews + n.carePlans + n.labResults + n.messages + n.draftPrescriptions;
          String hhmm(DateTime t) => MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(t.toLocal()));

          return RefreshIndicator(
            onRefresh: () async => setState(() => _dash = _repo.getDashboard()),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl),
              children: <Widget>[
                CHero(
                  eyebrow: d.speciality ?? s.pvShellHome,
                  title: s.pvDashGreeting(d.name ?? ''),
                  subtitle: waiting > 0 ? s.drDashWaiting(waiting, today.length) : s.drDashAllClear(today.length),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: NSpace.xxs + 2),
                    decoration: BoxDecoration(color: d.onCall ? NColors.brandApricot : NColors.surfaceCard, borderRadius: BorderRadius.circular(NRadius.pill)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(width: 7, height: 7, decoration: BoxDecoration(color: d.onCall ? NColors.statusClinicalRedFlag : NColors.inkMuted, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(d.onCall ? s.drOnCallShort : s.drOffCallShort, style: NType.caption.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  child: CStatGrid(
                    children: <Widget>[
                      CHeroStat(label: s.pvDashUrgentAlerts, value: '${n.urgentAlerts}', icon: Icons.notifications_active_outlined, alert: n.urgentAlerts > 0, onTap: () => open('/doctor/alerts')),
                      CHeroStat(label: s.pvDashReviews, value: '${n.reviews}', icon: Icons.fact_check_outlined, note: oldestText, onTap: openQueue),
                      CHeroStat(label: s.pvDashCarePlans, value: '${n.carePlans}', icon: Icons.draw_outlined, onTap: () => open('/doctor/care-plans')),
                      CHeroStat(label: s.pvDashLabResults, value: '${n.labResults}', icon: Icons.science_outlined, onTap: () => open('/doctor/labs')),
                      CHeroStat(label: s.pvDashMessages, value: '${n.messages}', icon: Icons.chat_bubble_outline_rounded, onTap: () => open('/doctor/messages')),
                      CHeroStat(label: s.pvDashDrafts, value: '${n.draftPrescriptions}', icon: Icons.edit_note_rounded, onTap: () => open('/doctor/advice')),
                      if (n.clinicalReview != null) CHeroStat(label: s.drReviewerTasks, value: '${n.clinicalReview}', icon: Icons.verified_user_outlined, onTap: () => open('/doctor/reviewer')),
                    ],
                  ),
                ),
                const SizedBox(height: NSpace.md),
                CPanel(
                  title: s.pvDashToday,
                  note: s.drDashBooked(today.length),
                  icon: Icons.event_available_outlined,
                  action: TextButton(onPressed: () => context.go('/doctor/schedule'), child: Text(s.pvShellSchedule)),
                  child: today.isEmpty
                      ? CEmpty(icon: Icons.event_available_outlined, title: s.pvDashNoAppointments)
                      : Column(
                          children: <Widget>[
                            for (int i = 0; i < today.length; i++)
                              CEntrance(
                                delayMs: 60 * i,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: NSpace.xs),
                                  child: _ConsultRow(
                                    a: today[i],
                                    time: hhmm(today[i].startsAt),
                                    isNext: today[i].id == next?.id,
                                    nextLabel: s.drNextUp,
                                    joinLabel: s.pvDashJoin,
                                    joinNote: today[i].joinable ? s.pvDashJoinOnWeb : s.pvDashJoinSoon,
                                    adviceLabel: !today[i].startsAt.isAfter(now) ? s.drWriteAdvice : null,
                                    onAdvice: () async {
                                      await startAdvice(context, today[i].id);
                                      if (mounted) setState(() => _dash = _repo.getDashboard());
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: NSpace.md),
                CPanel(
                  title: s.pvShellQueue,
                  note: oldestText,
                  icon: Icons.fact_check_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text('${n.reviews}', style: NType.h1.copyWith(color: NColors.inkPrimary, fontFamily: NType.body.fontFamily, fontWeight: FontWeight.w700)),
                          const SizedBox(width: NSpace.sm),
                          Expanded(child: Text(s.pvDashReviews, style: NType.body.copyWith(color: NColors.inkSecondary))),
                        ],
                      ),
                      const SizedBox(height: NSpace.sm),
                      NPrimaryButton(label: s.pvDashOpenQueue, onPressed: n.reviews > 0 ? openQueue : null, inactiveHint: s.drQueueClear),
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

class _ConsultRow extends StatelessWidget {
  const _ConsultRow({required this.a, required this.time, required this.isNext, required this.nextLabel, required this.joinLabel, required this.joinNote, required this.onAdvice, this.adviceLabel});

  final TodayAppointment a;
  final String time;
  final bool isNext;
  final String nextLabel;
  final String joinLabel;
  final String joinNote;
  final String? adviceLabel;
  final VoidCallback onAdvice;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(NSpace.sm),
        decoration: BoxDecoration(
          color: isNext ? NColors.brandBlushLight : NColors.surfacePage,
          borderRadius: BorderRadius.circular(NRadius.lg),
          border: Border.all(color: isNext ? NColors.brandBlush : Colors.transparent),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(time, style: NType.caption.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700, letterSpacing: 0, fontSize: 13)),
                  if (isNext) ...<Widget>[const SizedBox(height: 2), CPill(nextLabel, tone: CTone.plum)],
                ],
              ),
            ),
            CAvatar(name: a.member, size: 36),
            const SizedBox(width: NSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(a.member ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                  if (a.reason != null) Text(a.reason!, maxLines: 1, overflow: TextOverflow.ellipsis, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
                  if (adviceLabel != null)
                    GestureDetector(
                      onTap: onAdvice,
                      child: Padding(padding: const EdgeInsets.only(top: 2), child: Text(adviceLabel!, style: NType.caption.copyWith(color: NColors.actionLink, fontWeight: FontWeight.w700, letterSpacing: 0))),
                    ),
                ],
              ),
            ),
            Tooltip(message: joinNote, child: a.joinable ? CPill(joinLabel, tone: CTone.sage) : const Icon(Icons.videocam_off_outlined, size: 20, color: NColors.inkMuted)),
          ],
        ),
      );
}

