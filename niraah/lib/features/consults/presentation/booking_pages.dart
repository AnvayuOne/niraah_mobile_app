import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/payments/payment_checkout.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../../shared/constants/route_constants.dart';
import '../../../shared/helpers/money.dart';
import '../../../shared/widgets/payment_flow.dart';
import '../domain/consults.dart';
import 'consult_cubits.dart';
import 'consult_widgets.dart';
import 'consults_ui.dart';

/// Holds [startsAt] and opens the consent and confirmation step; on a confirmed booking she lands on the appointment
/// (spec 014 §3 "Steps"). The server decides whether the time is still free (AC8) and whether it is included.
Future<void> holdAndConfirm(BuildContext context, ConsultsRepository repo, SlotsCubit slots, {String? providerId, ProviderType? type, required DateTime startsAt}) async {
  final S s = S.of(context);
  slots.holding(true);
  Appointment held;
  try {
    held = await repo.hold(providerId: providerId, type: type, startsAt: startsAt, includedOnly: providerId == null);
  } on Object catch (e) {
    if (context.mounted) showNote(context, failureText(e, s.commonLoadError));
    // The time may have just been taken (AC8): show what is free now.
    await slots.load(slots.state.from);
    return;
  }
  slots.holding(false);
  if (!context.mounted) return;
  final Appointment? done = await Navigator.of(context).push<Appointment>(MaterialPageRoute<Appointment>(builder: (_) => ConfirmBookingPage(repository: repo, held: held)));
  if (!context.mounted) return;
  if (done != null) {
    context.pushReplacement('${RouteConstants.appointments}/${Uri.encodeComponent(done.id)}');
  } else {
    await slots.load(slots.state.from);
  }
}

/// A clinician's profile and her times (spec 014 §2.1, §2.2, §2.4): registration for a doctor; "no times available"
/// when she cannot be booked; the fee with GST or "included"; for a dedicated member whose clinician has no time soon,
/// the offer of another clinician as an included consult (AC14).
class SpecialistPage extends StatefulWidget {
  const SpecialistPage({required this.specialistId, super.key, this.repository});

  final String specialistId;
  final ConsultsRepository? repository;

  @override
  State<SpecialistPage> createState() => _SpecialistPageState();
}

class _SpecialistPageState extends State<SpecialistPage> {
  late final ConsultsRepository _repo = widget.repository ?? getIt<ConsultsRepository>();
  late Future<Specialist> _profile = _repo.specialist(widget.specialistId);

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.csProfileTitle,
      body: AsyncBody<Specialist>(
        future: _profile,
        onRetry: () => setState(() => _profile = _repo.specialist(widget.specialistId)),
        builder: (BuildContext context, Specialist x) => BlocProvider<SlotsCubit>(
          create: (_) {
            final SlotsCubit c = SlotsCubit((DateTime from, DateTime to) => _repo.slots(providerId: x.id, from: from, to: to), horizonDays: x.horizonDays ?? 30);
            if (x.available) c.load();
            return c;
          },
          child: _Profile(specialist: x, repository: _repo),
        ),
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.specialist, required this.repository});

  final Specialist specialist;
  final ConsultsRepository repository;

  /// Included or paid, the time is held first (§3 "Steps" 1); a paid consult is paid for on the confirm step.
  Future<void> _pick(BuildContext context, Slot slot, SlotList list) =>
      holdAndConfirm(context, repository, context.read<SlotsCubit>(), providerId: specialist.id, startsAt: slot.startsAt);

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final Specialist x = specialist;
    final String name = x.name ?? typeName(s, x.type);
    final bool dietitian = x.type == 'dietitian';
    return ListView(
      padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.md, NSpace.lg, NSpace.xl),
      children: <Widget>[
        // The profile card: picture, name, fee / rating / video pills, specialities, bio and registration.
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(NRadius.xl),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dietitian
                  ? <Color>[NColors.brandApricotLight, NColors.surfaceCard, NColors.brandSageLight]
                  : <Color>[NColors.brandBlushLight, NColors.surfaceCard, NColors.brandLavenderLight],
            ),
            boxShadow: NShadow.sm,
            border: Border.all(color: NColors.lineDefault.withValues(alpha: 0.6)),
          ),
          padding: const EdgeInsets.all(NSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IllustratedAvatar(type: x.type, size: 84),
                  const SizedBox(width: NSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (x.label != null) ...<Widget>[
                          SoftPill(text: x.label!, icon: Icons.favorite_rounded, background: NColors.surfaceCard, foreground: NColors.brandRosewood),
                          const SizedBox(height: NSpace.xxs),
                        ],
                        Semantics(header: true, child: Text(name, style: NType.h3.copyWith(color: NColors.inkPrimary))),
                        Text(
                          <String>[x.title, if (x.yearsExperience != null) s.csYears(x.yearsExperience!)].join(' · '),
                          style: NType.bodySm.copyWith(color: NColors.inkSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NSpace.md),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: <Widget>[
                  if (x.feePaise != null)
                    SoftPill(text: s.csFee(rupees(x.feePaise!)), icon: Icons.currency_rupee_rounded, background: NColors.surfaceCard, foreground: NColors.inkPrimary, strong: true),
                  if (x.ratingCount > 0 && x.ratingAverage != null)
                    SoftPill(text: s.csRating(x.ratingAverage!.toStringAsFixed(1), x.ratingCount), icon: Icons.star_rounded, background: NColors.surfaceCard),
                  SoftPill(text: ConsultLabels.videoConsult, icon: Icons.videocam_outlined, background: NColors.surfaceCard),
                ],
              ),
              if (x.specialities.isNotEmpty) ...<Widget>[
                const SizedBox(height: NSpace.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[for (final String sp in x.specialities) SoftPill(text: sp, background: NColors.brandBlushLight, foreground: NColors.brandRosewood)],
                ),
              ],
              if (x.bio != null && x.bio!.isNotEmpty) ...<Widget>[
                const SizedBox(height: NSpace.md),
                Text(x.bio!, style: NType.body.copyWith(color: NColors.inkSecondary)),
              ],
              if (x.languages.isNotEmpty || (x.isDoctor && x.registrationNumber != null)) const SizedBox(height: NSpace.sm),
              if (x.languages.isNotEmpty) _Fact(icon: Icons.translate_rounded, text: s.csSpeaks(x.languages.join(', '))),
              if (x.isDoctor && x.registrationNumber != null)
                _Fact(icon: Icons.verified_outlined, text: s.csRegistration(x.registrationNumber!, x.registrationCouncil ?? '')),
            ],
          ),
        ),
        const ConsultWellnessNote(),
        SoftSectionTitle(s.csTimes),
        if (!x.available)
          EmptyNote(text: s.csNoTimes, picture: ConsultArt.empty)
        else
          SlotPicker(
            onPick: (Slot slot, SlotList list) => _pick(context, slot, list),
            header: (BuildContext context, SlotList list) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (list.included)
                  SoftPill(text: s.csIncludedThis, icon: Icons.check_circle_outline_rounded, background: NColors.statusSuccessLight, foreground: NColors.statusSuccess, strong: true)
                else if (list.feePaise != null)
                  SoftPill(text: s.csFee(rupees(list.feePaise!)), icon: Icons.currency_rupee_rounded, background: NColors.brandBlushLight, foreground: NColors.brandRosewood, strong: true),
                if (list.fallbackReason != null) ...<Widget>[
                  const SizedBox(height: NSpace.sm),
                  SoftNotice(
                    color: NColors.statusWarningLight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(list.fallbackReason!, style: NType.bodySm.copyWith(color: NColors.inkPrimary)),
                        TextButton(
                          style: TextButton.styleFrom(foregroundColor: NColors.brandRosewood, padding: EdgeInsets.zero),
                          onPressed: () => context.push(Uri(path: RouteConstants.bookPooled, queryParameters: <String, String>{'type': list.fallbackType ?? x.type}).toString()),
                          child: Text(s.csSeeOtherClinicians),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 15, color: NColors.inkMuted),
            const SizedBox(width: 6),
            Expanded(child: Text(text, style: NType.label.copyWith(color: NColors.inkMuted))),
          ],
        ),
      );
}

/// An included consult with whoever is free (spec 014 §3 "Pooled assignment" 1-3): she picks a time without seeing
/// who; the clinician is named as soon as she confirms.
class PooledBookingPage extends StatelessWidget {
  const PooledBookingPage({required this.type, super.key, this.repository});

  final ProviderType type;
  final ConsultsRepository? repository;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final ConsultsRepository repo = repository ?? getIt<ConsultsRepository>();
    return BlocProvider<SlotsCubit>(
      create: (_) => SlotsCubit((DateTime from, DateTime to) => repo.slots(type: type, from: from, to: to))..load(),
      child: AreaScaffold(
        title: s.csPooledTitle(typeName(s, type)),
        body: Builder(
          builder: (BuildContext context) => ListView(
            padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.md, NSpace.lg, NSpace.xl),
            children: <Widget>[
              BlushHeader(
                title: s.csPooledTitle(typeName(s, type)),
                subtitle: s.csPooledNote(typeName(s, type).toLowerCase()),
                art: type == 'dietitian' ? ConsultArt.dietitian : ConsultArt.doctor,
              ),
              const ConsultWellnessNote(),
              SoftSectionTitle(s.csChooseATime),
              SlotPicker(
                onPick: (Slot slot, SlotList list) => holdAndConfirm(context, repo, context.read<SlotsCubit>(), type: type, startsAt: slot.startsAt),
                header: (BuildContext context, SlotList list) => Align(
                  alignment: Alignment.centerLeft,
                  child: list.included
                      ? SoftPill(text: s.csIncludedThis, icon: Icons.check_circle_outline_rounded, background: NColors.statusSuccessLight, foreground: NColors.statusSuccess, strong: true)
                      : SoftPill(text: s.csIncludedNone, icon: Icons.info_outline_rounded, background: NColors.statusWarningLight, foreground: NColors.statusWarningText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Consent, reason and confirmation of a held time (spec 014 §3 "Steps" 2-5): what the clinician may see, chosen per
/// category (AC15); an optional reason only that clinician reads; the hold's time left; included or the fee. Pops with
/// the confirmed appointment, or with the held one while the payment is still being confirmed.
///
/// A paid consult opens the gateway's checkout for the server's order and waits for the server to confirm the
/// verified payment (AC11, AC18; spec 008 §5, §6). A closed or failed checkout leaves the time held until it runs out
/// (AC10), so she can pay again or give it back.
class ConfirmBookingPage extends StatelessWidget {
  const ConfirmBookingPage({required this.repository, required this.held, super.key, this.clock, this.gateway, this.sleep});

  final ConsultsRepository repository;
  final Appointment held;
  final DateTime Function()? clock;
  final PaymentCheckout? gateway;
  final Future<void> Function(Duration)? sleep;

  @override
  Widget build(BuildContext context) => BlocProvider<ConfirmCubit>(
        create: (_) => ConfirmCubit(repository, held, clock: clock, sleep: sleep),
        child: _ConfirmView(gateway),
      );
}

class _ConfirmView extends StatefulWidget {
  const _ConfirmView(this.gateway);

  final PaymentCheckout? gateway;

  @override
  State<_ConfirmView> createState() => _ConfirmViewState();
}

class _ConfirmViewState extends State<_ConfirmView> {
  final TextEditingController _reason = TextEditingController();
  Timer? _tick;

  /// Her answer to the transcript consent, asked only when the server asks for it (spec 014 §5 "Recording" 3).
  bool _transcript = false;

  @override
  void initState() {
    super.initState();
    // The countdown is text that changes once a second; nothing moves.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _confirm(ConfirmCubit cubit) async {
    final S s = S.of(context);
    final Appointment held = cubit.state.appointment;
    final bool asked = held.recordMode == 'transcript' && held.askTranscriptConsent;
    final ConfirmOutcome? o = await cubit.confirm(_reason.text, recordConsent: asked ? _transcript : null);
    if (!mounted) return;
    switch (o) {
      case Confirmed(:final Appointment appointment):
        showNote(context, s.csBooked);
        Navigator.of(context).pop(appointment);
      case PaymentNeeded(:final Checkout? checkout):
        if (checkout == null) {
          showNote(context, s.payFailed);
          return;
        }
        final PaymentResult r = await runPayment(context, (void Function() onConfirming) => cubit.pay(widget.gateway ?? getIt<PaymentCheckout>(), checkout, description: s.payDescConsult, onConfirming: onConfirming));
        if (!mounted) return;
        switch (r.outcome) {
          case PaymentOutcome.confirmed:
            showNote(context, s.csPaidBooked);
            Navigator.of(context).pop(cubit.state.appointment);
          case PaymentOutcome.pending || PaymentOutcome.lapsed:
            // The server decides; the appointment screen shows what it holds now.
            showNote(context, paymentNote(s, r)!);
            Navigator.of(context).pop(cubit.state.appointment);
          case PaymentOutcome.cancelled || PaymentOutcome.failed:
            // The time stays held (AC10): she can pay again or give it back.
            showNote(context, paymentNote(s, r)!);
        }
      case null:
        showNote(context, failureText(cubit.state.error ?? '', s.commonLoadError));
    }
  }

  Future<void> _release(ConfirmCubit cubit) async {
    await cubit.release();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<ConfirmCubit, ConfirmState>(
      builder: (BuildContext context, ConfirmState st) {
        final ConfirmCubit cubit = context.read<ConfirmCubit>();
        final Appointment a = st.appointment;
        final Duration left = cubit.remaining;
        final String mmss = '${left.inMinutes}:${(left.inSeconds % 60).toString().padLeft(2, '0')}';
        // A pooled clinician is named once she confirms (§3 "Pooled assignment" 1, 3).
        final String who = a.pooled ? s.csAssignedOnConfirm(typeName(s, a.providerType).toLowerCase()) : (a.clinicianName ?? s.csYourClinician);
        // The fee kept on the hold is the fee charged (AC18).
        final bool paid = !a.included && a.feePaise > 0;
        final int minutes = a.endsAt.difference(a.startsAt).inMinutes;
        final bool locked = st.busy || cubit.expired;
        return AreaScaffold(
          title: s.csConfirmTitle,
          body: ListView(
            padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.md, NSpace.lg, NSpace.xl),
            children: <Widget>[
              // The summary: who, date, time and length, video, price, and the hold's time left.
              Container(
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
                      children: <Widget>[
                        IllustratedAvatar(type: a.providerType, size: 60),
                        const SizedBox(width: NSpace.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(who, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                              Text(typeName(s, a.providerType), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: NSpace.md),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: NSpace.xs),
                      decoration: BoxDecoration(color: NColors.surfaceCard, borderRadius: BorderRadius.circular(NRadius.md)),
                      child: Column(
                        children: <Widget>[
                          InfoLine(icon: Icons.event_rounded, text: dayText(context, a.startsAt)),
                          InfoLine(icon: Icons.schedule_rounded, text: '${timeText(context, a.startsAt)} – ${timeText(context, a.endsAt)} · ${s.practiceMinutes(minutes)}'),
                          InfoLine(icon: Icons.videocam_outlined, text: ConsultLabels.videoConsult),
                          InfoLine(
                            icon: paid ? Icons.currency_rupee_rounded : Icons.check_circle_outline_rounded,
                            text: a.included || a.feePaise == 0 ? s.csIncludedThis : s.csFee(rupees(a.feePaise)),
                            strong: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: NSpace.sm),
                    Semantics(
                      liveRegion: cubit.expired,
                      child: SoftPill(
                        text: cubit.expired ? s.csHoldExpired : s.csHoldLeft(mmss),
                        icon: cubit.expired ? Icons.timer_off_outlined : Icons.hourglass_bottom_rounded,
                        background: cubit.expired ? NColors.statusWarningLight : NColors.surfaceCard,
                        foreground: cubit.expired ? NColors.statusWarningText : NColors.brandRosewood,
                        strong: true,
                      ),
                    ),
                  ],
                ),
              ),
              SoftSectionTitle(s.csConsentTitle, subtitle: s.csConsentBody),
              for (final String c in consultCategories) ...<Widget>[
                _ConsentCard(
                  on: st.consents.contains(c),
                  child: CheckboxListTile(
                    value: st.consents.contains(c),
                    onChanged: locked ? null : (bool? on) => cubit.toggle(c, on ?? false),
                    activeColor: NColors.brandRosewood,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NRadius.lg)),
                    secondary: Icon(_categoryIcon(c), color: st.consents.contains(c) ? NColors.brandRosewood : NColors.inkMuted),
                    title: Text(categoryText(s, c), style: NType.body.copyWith(color: NColors.inkPrimary)),
                  ),
                ),
                const SizedBox(height: NSpace.xs),
              ],
              Text(s.csConsentNone, style: NType.caption.copyWith(color: NColors.inkMuted)),
              SoftSectionTitle(s.csReasonTitle),
              TextField(controller: _reason, maxLength: 200, maxLines: 3, minLines: 1, decoration: InputDecoration(labelText: s.csReasonLabel, helperText: s.csReasonHelp)),
              // One consent names who reads the transcript, her care team included; no separate sharing choice. The
              // wording is a draft until legal approves it (spec 014 §5 "Recording" 3, AC63; 014-Q15).
              if (a.recordMode == 'transcript' && a.askTranscriptConsent) ...<Widget>[
                const SizedBox(height: NSpace.sm),
                SoftCard(
                  color: NColors.brandApricotLight,
                  border: _transcript ? NColors.brandRosewood : NColors.brandApricotLight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.subject_rounded, color: NColors.brandRosewood),
                          const SizedBox(width: NSpace.xs),
                          Expanded(child: Semantics(header: true, child: Text(s.csTranscriptConsentTitle, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)))),
                        ],
                      ),
                      const SizedBox(height: NSpace.xxs),
                      SoftPill(text: s.csTranscriptDraft, background: NColors.surfaceCard, foreground: NColors.statusWarningText),
                      const SizedBox(height: NSpace.xs),
                      Text(s.csTranscriptConsentBody, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _transcript,
                        activeColor: NColors.brandRosewood,
                        onChanged: locked ? null : (bool? on) => setState(() => _transcript = on ?? false),
                        title: Text(s.csTranscriptConsentYes, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: NSpace.md),
              if (paid) Text(s.csPayHoldNote, style: NType.caption.copyWith(color: NColors.inkMuted)),
              const SizedBox(height: NSpace.xs),
              if (cubit.expired)
                NPrimaryButton(label: s.csChooseAnotherTime, onPressed: () => Navigator.of(context).pop())
              else
                NPrimaryButton(label: paid ? s.csPayAndConfirm(rupees(a.feePaise)) : s.csConfirm, loading: st.busy, onPressed: () => _confirm(cubit)),
              const SizedBox(height: NSpace.xs),
              if (!cubit.expired) TextButton(onPressed: st.busy ? null : () => _release(cubit), child: Text(s.csRelease)),
            ],
          ),
        );
      },
    );
  }
}

/// One "What may your clinician see?" choice as a tappable card: rose border and blush fill when it is on.
class _ConsentCard extends StatelessWidget {
  const _ConsentCard({required this.on, required this.child});

  final bool on;
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        // Only the shadow sits outside: the fill and border are on the Material, so the tile's ink still shows.
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(NRadius.lg), boxShadow: on ? const <BoxShadow>[] : NShadow.xs),
        child: Material(
          color: on ? NColors.brandBlushLight : NColors.surfaceCard,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NRadius.lg),
            side: BorderSide(color: on ? NColors.brandRosewood : NColors.lineDefault, width: on ? 1.5 : 1),
          ),
          child: child,
        ),
      );
}

IconData _categoryIcon(String c) => switch (c) {
      'health_data' => Icons.favorite_border_rounded,
      'assessment' => Icons.assignment_outlined,
      'cycle_symptoms' => Icons.water_drop_outlined,
      'meals' => Icons.restaurant_outlined,
      'lab_reports' => Icons.science_outlined,
      'messages' => Icons.chat_bubble_outline_rounded,
      _ => Icons.check_box_outline_blank_rounded,
    };
