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
    return ListView(
      padding: const EdgeInsets.all(NSpace.lg),
      children: <Widget>[
        Row(
          children: <Widget>[
            SpecialistAvatar(name: x.name),
            const SizedBox(width: NSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (x.label != null) Text(x.label!, style: NType.caption.copyWith(color: NColors.actionLink, fontWeight: FontWeight.w700)),
                  Semantics(header: true, child: Text(name, style: NType.h3.copyWith(color: NColors.inkPrimary))),
                  Text(<String>[x.title, ...x.specialities].join(' · '), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: NSpace.md),
        if (x.languages.isNotEmpty) Text(s.csSpeaks(x.languages.join(', ')), style: NType.body.copyWith(color: NColors.inkPrimary)),
        if (x.yearsExperience != null) Text(s.csYears(x.yearsExperience!), style: NType.body.copyWith(color: NColors.inkPrimary)),
        if (x.ratingCount > 0 && x.ratingAverage != null) Text(s.csRating(x.ratingAverage!.toStringAsFixed(1), x.ratingCount), style: NType.body.copyWith(color: NColors.inkSecondary)),
        if (x.isDoctor && x.registrationNumber != null)
          Text(s.csRegistration(x.registrationNumber!, x.registrationCouncil ?? ''), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
        if (x.bio != null && x.bio!.isNotEmpty) ...<Widget>[
          const SizedBox(height: NSpace.sm),
          Text(x.bio!, style: NType.body.copyWith(color: NColors.inkSecondary)),
        ],
        const ConsultWellnessNote(),
        NSectionTitle(s.csTimes),
        if (!x.available)
          EmptyNote(text: s.csNoTimes)
        else
          SlotPicker(
            onPick: (Slot slot, SlotList list) => _pick(context, slot, list),
            header: (BuildContext context, SlotList list) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (list.included)
                  Text(s.csIncludedThis, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600))
                else if (list.feePaise != null) ...<Widget>[
                  Text(s.csFee(rupees(list.feePaise!)), style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                ],
                if (list.fallbackReason != null) ...<Widget>[
                  const SizedBox(height: NSpace.sm),
                  NCard(
                    color: NColors.surfaceWarm,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(list.fallbackReason!, style: NType.body.copyWith(color: NColors.inkPrimary)),
                        TextButton(
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
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              Text(s.csPooledNote(typeName(s, type).toLowerCase()), style: NType.body.copyWith(color: NColors.inkSecondary)),
              const ConsultWellnessNote(),
              SlotPicker(
                onPick: (Slot slot, SlotList list) => holdAndConfirm(context, repo, context.read<SlotsCubit>(), type: type, startsAt: slot.startsAt),
                header: (BuildContext context, SlotList list) =>
                    Text(list.included ? s.csIncludedThis : s.csIncludedNone, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
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
        return AreaScaffold(
          title: s.csConfirmTitle,
          body: ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              NCard(
                color: NColors.brandLavenderLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(whenText(context, a.startsAt), style: NType.h4.copyWith(color: NColors.inkPrimary)),
                    Text(who, style: NType.body.copyWith(color: NColors.inkSecondary)),
                    const SizedBox(height: NSpace.xs),
                    Text(a.included || a.feePaise == 0 ? s.csIncludedThis : s.csFee(rupees(a.feePaise)), style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.sm),
              Semantics(
                liveRegion: cubit.expired,
                child: Text(cubit.expired ? s.csHoldExpired : s.csHoldLeft(mmss), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              ),
              NSectionTitle(s.csConsentTitle),
              Text(s.csConsentBody, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              for (final String c in consultCategories)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: st.consents.contains(c),
                  onChanged: st.busy || cubit.expired ? null : (bool? on) => cubit.toggle(c, on ?? false),
                  title: Text(categoryText(s, c)),
                ),
              Text(s.csConsentNone, style: NType.caption.copyWith(color: NColors.inkMuted)),
              NSectionTitle(s.csReasonTitle),
              TextField(controller: _reason, maxLength: 200, maxLines: 3, minLines: 1, decoration: InputDecoration(labelText: s.csReasonLabel, helperText: s.csReasonHelp)),
              // One consent names who reads the transcript, her care team included; no separate sharing choice. The
              // wording is a draft until legal approves it (spec 014 §5 "Recording" 3, AC63; 014-Q15).
              if (a.recordMode == 'transcript' && a.askTranscriptConsent) ...<Widget>[
                const SizedBox(height: NSpace.sm),
                NCard(
                  color: NColors.surfaceWarm,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Semantics(header: true, child: Text(s.csTranscriptConsentTitle, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600))),
                      Text(s.csTranscriptDraft, style: NType.caption.copyWith(color: NColors.inkSecondary, fontWeight: FontWeight.w700)),
                      const SizedBox(height: NSpace.xs),
                      Text(s.csTranscriptConsentBody, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _transcript,
                        onChanged: st.busy || cubit.expired ? null : (bool? on) => setState(() => _transcript = on ?? false),
                        title: Text(s.csTranscriptConsentYes),
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
