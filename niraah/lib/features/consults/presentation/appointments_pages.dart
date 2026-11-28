import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../../shared/constants/route_constants.dart';
import '../../../shared/helpers/money.dart';
import '../domain/consults.dart';
import 'booking_pages.dart';
import 'consult_cubits.dart';
import 'consult_widgets.dart';
import 'consults_ui.dart';
import 'transcript_page.dart';

String _appointmentPath(String id) => '${RouteConstants.appointments}/${Uri.encodeComponent(id)}';

/// "Appointments" (spec 010 §9.3): upcoming and past consults with their state, and the way to her wellness advice
/// from past consults.
class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key, this.repository, this.clock});

  final ConsultsRepository? repository;
  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) => BlocProvider<AppointmentsCubit>(
        create: (_) => AppointmentsCubit(repository ?? getIt<ConsultsRepository>(), clock: clock)..load(),
        child: const _AppointmentsView(),
      );
}

class _AppointmentsView extends StatelessWidget {
  const _AppointmentsView();

  Future<void> _open(BuildContext context, String path) async {
    await context.push(path);
    if (context.mounted) await context.read<AppointmentsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.csAppointmentsTitle,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(context, RouteConstants.bookDoctor),
        icon: const Icon(Icons.add_rounded),
        label: Text(s.csBookAction, style: NType.button.copyWith(color: NColors.inkOnBrand)),
        backgroundColor: NColors.brandPlum,
        foregroundColor: NColors.inkOnBrand,
        elevation: 2,
        shape: const StadiumBorder(),
      ),
      body: BlocBuilder<AppointmentsCubit, AppointmentsState>(
        builder: (BuildContext context, AppointmentsState st) {
          final AppointmentsCubit cubit = context.read<AppointmentsCubit>();
          switch (st.status) {
            case LoadStatus.loading:
              return LoadingView(label: s.loading);
            case LoadStatus.failure:
              if (st.error is AreaLocked) return AreaLockedView(refusal: st.error! as AreaLocked);
              return ErrorView(message: s.commonLoadError, retryLabel: s.tryAgain, onRetry: cubit.load);
            case LoadStatus.ready:
              return RefreshIndicator(
                onRefresh: cubit.load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.md, NSpace.lg, 96),
                  children: <Widget>[
                    BlushHeader(
                      title: s.csAppointmentsTitle,
                      art: ConsultArt.verified,
                    ),
                    const ConsultWellnessNote(),
                    Semantics(
                      button: true,
                      label: s.waTitle,
                      child: SoftCard(
                        onTap: () => context.push(RouteConstants.wellnessAdvice),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(color: NColors.brandLavenderLight, shape: BoxShape.circle),
                              child: Icon(Icons.description_outlined, color: NColors.brandPlum, size: 20),
                            ),
                            const SizedBox(width: NSpace.sm),
                            Expanded(child: Text(s.waTitle, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600))),
                            Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
                          ],
                        ),
                      ),
                    ),
                    SoftSectionTitle(s.csUpcoming),
                    if (st.upcoming.isEmpty)
                      EmptyNote(text: s.csNoUpcoming, picture: ConsultArt.empty, actionLabel: s.csBookAction, onAction: () => _open(context, RouteConstants.bookDoctor)),
                    for (final Appointment a in st.upcoming) ...<Widget>[
                      AppointmentCard(appointment: a, onTap: () => _open(context, _appointmentPath(a.id))),
                      const SizedBox(height: NSpace.sm),
                    ],
                    if (st.past.isNotEmpty) SoftSectionTitle(s.csPast),
                    for (final Appointment a in st.past) ...<Widget>[
                      AppointmentCard(appointment: a, muted: true, onTap: () => _open(context, _appointmentPath(a.id))),
                      const SizedBox(height: NSpace.xs),
                    ],
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({required this.appointment, required this.onTap, super.key, this.muted = false});

  final Appointment appointment;
  final VoidCallback onTap;

  /// Past consults sit quieter: a warm date tile and no actions.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Appointment a = appointment;
    final String who = a.clinicianName ?? typeName(s, a.providerType);
    final (Color bg, Color fg) = statusColors(a.status);
    return Semantics(
      button: true,
      label: '${whenText(context, a.startsAt)}, $who, ${statusText(s, a.status)}',
      excludeSemantics: true,
      child: SoftCard(
        onTap: onTap,
        color: muted ? NColors.surfacePage : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                DateTile(date: a.startsAt, muted: muted),
                const SizedBox(width: NSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SoftPill(text: statusText(s, a.status), background: bg, foreground: fg),
                      const SizedBox(height: NSpace.xxs),
                      Text(who, maxLines: 1, overflow: TextOverflow.ellipsis, style: NType.h4.copyWith(color: muted ? NColors.inkSecondary : NColors.inkPrimary)),
                      Text(
                        '${timeText(context, a.startsAt)} – ${timeText(context, a.endsAt)} · ${typeName(s, a.providerType)}',
                        style: NType.bodySm.copyWith(color: NColors.inkSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: NSpace.xs),
                IllustratedAvatar(type: a.providerType, size: 44),
              ],
            ),
            if (!muted) ...<Widget>[
              const SizedBox(height: NSpace.sm),
              Divider(height: 1, color: NColors.lineDefault),
              const SizedBox(height: NSpace.xs),
              Row(
                children: <Widget>[
                  Icon(a.held ? Icons.hourglass_bottom_rounded : Icons.videocam_outlined, size: 16, color: a.held ? NColors.statusWarningText : NColors.inkMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      a.held ? s.csFinishBooking : ConsultLabels.videoConsult,
                      style: NType.label.copyWith(color: a.held ? NColors.statusWarningText : NColors.inkMuted, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: NColors.brandRosewood),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One appointment (spec 014 §4-§6): join the room, move it, accept a time the clinician proposed, cancel with the
/// outcome said before and after, report a call that did not work, take another time or her money back after a
/// clinician did not join or a call failed, and rate a finished consult.
class AppointmentPage extends StatelessWidget {
  const AppointmentPage({required this.appointmentId, super.key, this.repository, this.clock});

  final String appointmentId;
  final ConsultsRepository? repository;
  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    final ConsultsRepository repo = repository ?? getIt<ConsultsRepository>();
    return RepositoryProvider<ConsultsRepository>.value(
      value: repo,
      child: BlocProvider<AppointmentCubit>(create: (_) => AppointmentCubit(repo, appointmentId, clock: clock)..load(), child: const _AppointmentView()),
    );
  }
}

class _AppointmentView extends StatelessWidget {
  const _AppointmentView();

  static String _outcome(S s, String? o) => switch (o) {
        'released' => s.csOutcomeReleased,
        'refunded' => s.csOutcomeRefunded,
        'unit_returned' => s.csOutcomeUnitReturned,
        'kept' => s.csOutcomeKept,
        'moved' => s.csOutcomeMoved,
        'rated' => s.csOutcomeRated,
        'waiting' => s.csFailureWaiting,
        'member_choice' => s.csFailureChoice,
        _ => s.csOutcomeDone,
      };

  Future<bool> _ask(BuildContext context, String title, String body, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (BuildContext d) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(S.of(context).csKeep)),
            FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(action)),
          ],
        ),
      ) ??
      false;

  void _say(BuildContext context, ActionResult r) {
    final S s = S.of(context);
    showNote(context, r.ok ? _outcome(s, r.outcome) : failureText(r.error!, s.commonLoadError));
  }

  /// Times for moving it or taking another: the same clinician, or whoever is free for a pooled consult.
  SlotLoader _loader(BuildContext context, Appointment a, {bool anyClinician = false}) {
    final ConsultsRepository repo = context.read<ConsultsRepository>();
    if (a.pooled || anyClinician) return (DateTime from, DateTime to) => repo.slots(type: a.providerType ?? 'doctor', from: from, to: to);
    return (DateTime from, DateTime to) => repo.slots(providerId: a.clinicianId, from: from, to: to);
  }

  Future<void> _reschedule(BuildContext context, Appointment a) async {
    final S s = S.of(context);
    final AppointmentCubit cubit = context.read<AppointmentCubit>();
    final DateTime? to = await Navigator.of(context).push<DateTime>(MaterialPageRoute<DateTime>(
      builder: (_) => SlotPickerPage(title: s.csRescheduleTitle, loader: _loader(context, a), note: s.csRescheduleNote(a.reschedulesLeft)),
    ));
    if (to == null || !context.mounted) return;
    final ActionResult r = await cubit.reschedule(to);
    if (context.mounted) _say(context, r);
  }

  Future<void> _rebook(BuildContext context, Appointment a) async {
    final S s = S.of(context);
    final AppointmentCubit cubit = context.read<AppointmentCubit>();
    // After a clinician did not join, another clinician may be offered (§6 "No-shows" 2).
    final DateTime? to = await Navigator.of(context).push<DateTime>(MaterialPageRoute<DateTime>(
      builder: (_) => SlotPickerPage(title: s.csRebookTitle, loader: _loader(context, a, anyClinician: a.status == 'no_show'), note: s.csRebookNote),
    ));
    if (to == null || !context.mounted) return;
    final ActionResult r = await cubit.rebook(to);
    if (!context.mounted) return;
    if (r.ok && r.outcome != null) {
      showNote(context, s.csOutcomeMoved);
      context.pushReplacement(_appointmentPath(r.outcome!));
    } else {
      _say(context, r);
    }
  }

  Future<void> _cancel(BuildContext context, Appointment a) async {
    final S s = S.of(context);
    final AppointmentCubit cubit = context.read<AppointmentCubit>();
    // The cut-off and what she gets back are the server's; it states the outcome straight after (AC35).
    final String body = a.held ? s.csReleaseBody : (a.included ? s.csCancelBodyIncluded : s.csCancelBodyPaid);
    if (!await _ask(context, a.held ? s.csRelease : s.csCancelTitle, body, a.held ? s.csRelease : s.csCancelAction)) return;
    final ActionResult r = await cubit.cancel();
    if (context.mounted) _say(context, r);
  }

  Future<void> _accept(BuildContext context) async {
    final S s = S.of(context);
    final AppointmentCubit cubit = context.read<AppointmentCubit>();
    if (!await _ask(context, s.csProposalTitle, s.csProposalBody, s.csProposalAccept)) return;
    final ActionResult r = await cubit.acceptProposal();
    if (context.mounted) _say(context, r);
  }

  Future<void> _decline(BuildContext context) async {
    final S s = S.of(context);
    final AppointmentCubit cubit = context.read<AppointmentCubit>();
    if (!await _ask(context, s.csDeclineTitle, s.csDeclineBody, s.csDeclineAction)) return;
    final ActionResult r = await cubit.declineOffer();
    if (context.mounted) _say(context, r);
  }

  Future<void> _report(BuildContext context) async {
    final S s = S.of(context);
    final AppointmentCubit cubit = context.read<AppointmentCubit>();
    if (!await _ask(context, s.csReportTitle, s.csReportBody, s.csReportAction)) return;
    final ActionResult r = await cubit.reportFailure();
    if (context.mounted) _say(context, r);
  }

  Future<void> _finish(BuildContext context, Appointment a) async {
    final AppointmentCubit cubit = context.read<AppointmentCubit>();
    final Appointment? done = await Navigator.of(context).push<Appointment>(
      MaterialPageRoute<Appointment>(builder: (_) => ConfirmBookingPage(repository: context.read<ConsultsRepository>(), held: a)),
    );
    if (done != null) await cubit.load();
  }

  Future<void> _rate(BuildContext context) async {
    final AppointmentCubit cubit = context.read<AppointmentCubit>();
    await Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => BlocProvider<AppointmentCubit>.value(value: cubit, child: const RateConsultPage())));
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.csAppointmentTitle,
      body: BlocBuilder<AppointmentCubit, AppointmentState>(
        builder: (BuildContext context, AppointmentState st) {
          final AppointmentCubit cubit = context.read<AppointmentCubit>();
          final Appointment? a = st.appointment;
          if (a == null) {
            if (st.status == LoadStatus.failure) {
              if (st.error is AreaLocked) return AreaLockedView(refusal: st.error! as AreaLocked);
              return ErrorView(message: s.commonLoadError, retryLabel: s.tryAgain, onRetry: cubit.load);
            }
            return LoadingView(label: s.loading);
          }
          final DateTime now = cubit.now;
          final bool future = a.startsAt.isAfter(now);
          final bool offerOpen = a.status == 'no_show' || (st.failure?.memberChoice ?? false);
          final String who = a.clinicianName ?? s.csYourClinician;
          return ListView(
            padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.md, NSpace.lg, NSpace.xl),
            children: <Widget>[
              Builder(
                builder: (BuildContext context) {
                  final (Color bg, Color fg) = statusColors(a.status);
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(NRadius.xl),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[NColors.brandBlushLight, NColors.surfaceCard, NColors.brandLavenderLight],
                      ),
                      boxShadow: NShadow.sm,
                      border: Border.all(color: NColors.lineDefault.withValues(alpha: 0.6)),
                    ),
                    padding: const EdgeInsets.all(NSpace.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            DateTile(date: a.startsAt, background: NColors.surfaceCard),
                            const SizedBox(width: NSpace.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SoftPill(text: statusText(s, a.status), background: bg, foreground: fg, strong: true),
                                  const SizedBox(height: NSpace.xxs),
                                  Semantics(header: true, child: Text(whenText(context, a.startsAt), style: NType.h4.copyWith(color: NColors.inkPrimary))),
                                  Text('$who · ${typeName(s, a.providerType)}', style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                                ],
                              ),
                            ),
                            const SizedBox(width: NSpace.xs),
                            IllustratedAvatar(type: a.providerType, size: 52),
                          ],
                        ),
                        const SizedBox(height: NSpace.sm),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: <Widget>[
                            SoftPill(text: '${timeText(context, a.startsAt)} – ${timeText(context, a.endsAt)}', icon: Icons.schedule_rounded, background: NColors.surfaceCard),
                            SoftPill(text: ConsultLabels.videoConsult, icon: Icons.videocam_outlined, background: NColors.surfaceCard),
                            SoftPill(
                              text: a.included ? s.csPaidIncluded : s.csPaidFee(rupees(a.feePaise)),
                              icon: a.included ? Icons.check_circle_outline_rounded : Icons.currency_rupee_rounded,
                              background: NColors.surfaceCard,
                              foreground: NColors.brandRosewood,
                              strong: true,
                            ),
                          ],
                        ),
                        if (a.recording) ...<Widget>[
                          const SizedBox(height: NSpace.xs),
                          Row(
                            children: <Widget>[
                              Icon(Icons.fiber_manual_record_rounded, size: 12, color: NColors.statusClinicalRedFlag),
                              const SizedBox(width: 6),
                              Expanded(child: Text(s.csRecordingOn, style: NType.bodySm.copyWith(color: NColors.inkPrimary))),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: NSpace.md),
              if (a.held) ...<Widget>[
                NPrimaryButton(label: s.csFinishBooking, onPressed: st.busy ? null : () => _finish(context, a)),
                const SizedBox(height: NSpace.xs),
                NSecondaryButton(label: s.csRelease, onPressed: st.busy ? null : () => _cancel(context, a)),
              ],
              if (a.live) ...<Widget>[
                Text(s.csRoomOpensAt(timeText(context, a.roomOpensAt)), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                const SizedBox(height: NSpace.xs),
                NPrimaryButton(label: s.csJoin, onPressed: () => context.push('${_appointmentPath(a.id)}/room')),
                // Spec 014 §4.4: a device check from the appointment screen at any time.
                TextButton(onPressed: () => context.push(RouteConstants.deviceCheck), child: Text(s.dcLink)),
                const SizedBox(height: NSpace.xs),
              ],
              if (a.confirmed && future) ...<Widget>[
                if (a.reschedulesLeft > 0) NSecondaryButton(label: s.csReschedule, onPressed: st.busy ? null : () => _reschedule(context, a)),
                const SizedBox(height: NSpace.xs),
                NSecondaryButton(label: s.csCancelAction, onPressed: st.busy ? null : () => _cancel(context, a)),
                TextButton(onPressed: st.busy ? null : () => _accept(context), child: Text(s.csProposalLink)),
              ],
              if (offerOpen) ...<Widget>[
                SoftCard(
                  color: NColors.statusWarningLight,
                  border: NColors.statusWarningLight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(a.status == 'no_show' ? s.csNoShowOffer : s.csFailureChoice, style: NType.body.copyWith(color: NColors.inkPrimary)),
                      const SizedBox(height: NSpace.sm),
                      NSecondaryButton(label: s.csRebook, onPressed: st.busy ? null : () => _rebook(context, a)),
                      TextButton(onPressed: st.busy ? null : () => _decline(context), child: Text(s.csDeclineAction)),
                    ],
                  ),
                ),
                const SizedBox(height: NSpace.sm),
              ],
              if (a.status == 'completed') ...<Widget>[
                NSecondaryButton(label: s.csRate, onPressed: () => _rate(context)),
                const SizedBox(height: NSpace.xs),
                TextButton(onPressed: () => context.push(RouteConstants.wellnessAdvice), child: Text(s.waTitle)),
              ],
              // Her consult transcript (spec 014 §5 "Reading a transcript" 1, 8): opened on its own page, only when asked.
              if (a.transcript != null) ...<Widget>[
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Semantics(header: true, child: Text(s.csTranscriptTitle, style: NType.h4.copyWith(color: NColors.inkPrimary))),
                      const SizedBox(height: NSpace.xs),
                      if (a.transcript == 'ready')
                        NSecondaryButton(
                          label: s.csTranscriptRead,
                          onPressed: () => Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(builder: (_) => TranscriptPage(appointmentId: a.id, repository: context.read<ConsultsRepository>())),
                          ),
                        )
                      else
                        Text(a.transcript == 'pending' ? s.csTranscriptPending : s.csTranscriptFailed, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                      const SizedBox(height: NSpace.xs),
                      Text(s.csTranscriptWhoReads, style: NType.caption.copyWith(color: NColors.inkMuted)),
                    ],
                  ),
                ),
                const SizedBox(height: NSpace.sm),
              ],
              if (cubit.canReportFailure && st.failure == null) TextButton(onPressed: st.busy ? null : () => _report(context), child: Text(s.csReportAction)),
              if (st.failure != null && !st.failure!.memberChoice) Text(s.csFailureWaiting, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              if (a.status == 'cancelled' || a.status == 'expired')
                TextButton(onPressed: () => context.push('${RouteConstants.bookDoctor}/${Uri.encodeComponent(a.clinicianId)}'), child: Text(s.csBookAgain)),
              const ConsultWellnessNote(),
            ],
          );
        },
      ),
    );
  }
}

/// Rating a finished consult from one to five, with an optional comment (spec 014 §5 "Ending and completion" 4). It
/// is never shown with her name (AC33); the server takes one per consult.
class RateConsultPage extends StatefulWidget {
  const RateConsultPage({super.key});

  @override
  State<RateConsultPage> createState() => _RateConsultPageState();
}

class _RateConsultPageState extends State<RateConsultPage> {
  final TextEditingController _comment = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final S s = S.of(context);
    final ActionResult r = await context.read<AppointmentCubit>().rate(_rating, _comment.text);
    if (!mounted) return;
    showNote(context, r.ok ? s.csOutcomeRated : failureText(r.error!, s.commonLoadError));
    if (r.ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool busy = context.select((AppointmentCubit c) => c.state.busy);
    return AreaScaffold(
      title: s.csRateTitle,
      body: ListView(
        padding: const EdgeInsets.all(NSpace.lg),
        children: <Widget>[
          Text(s.csRateBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
          const SizedBox(height: NSpace.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (int i = 1; i <= 5; i++)
                IconButton(
                  tooltip: s.csRateStars(i),
                  isSelected: _rating >= i,
                  onPressed: () => setState(() => _rating = i),
                  icon: Icon(_rating >= i ? Icons.star_rounded : Icons.star_outline_rounded, color: NColors.brandApricot, size: NSpace.xl),
                ),
            ],
          ),
          const SizedBox(height: NSpace.sm),
          TextField(controller: _comment, maxLength: 1000, minLines: 2, maxLines: 5, decoration: InputDecoration(labelText: s.csRateComment)),
          const SizedBox(height: NSpace.md),
          NPrimaryButton(label: s.csRateSend, loading: busy, inactiveHint: s.csRateChoose, onPressed: _rating == 0 ? null : _send),
        ],
      ),
    );
  }
}
