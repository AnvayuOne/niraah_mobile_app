import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../design_system/widgets/n_illustration.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../../shared/constants/route_constants.dart';
import '../domain/consults.dart';
import 'consults_copy.dart';
import 'consults_ui.dart';

/// Confirm a held time (spec 014 §3 "Steps" 2-4): the summary with the hold timer, what she shares, an optional
/// reason, the record question when the consult is recorded, then confirm (included) or pay.
class ConfirmConsultPage extends StatefulWidget {
  const ConfirmConsultPage({required this.id, super.key, this.held, this.specialist, this.repository});

  final String id;
  final Appointment? held;
  final Specialist? specialist;
  final ConsultsRepository? repository;

  @override
  State<ConfirmConsultPage> createState() => _ConfirmConsultPageState();
}

class _ConfirmConsultPageState extends State<ConfirmConsultPage> {
  late final ConsultsRepository _repo = widget.repository ?? getIt<ConsultsRepository>();
  late Future<Appointment> _load = widget.held != null ? Future<Appointment>.value(widget.held) : _repo.appointment(widget.id);
  final Set<ShareCategory> _share = <ShareCategory>{};
  final TextEditingController _reason = TextEditingController();
  bool? _record;
  bool _busy = false;
  Timer? _tick;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _confirm(Appointment a) async {
    setState(() => _busy = true);
    try {
      final ConfirmOutcome out = await _repo.confirm(a.id, share: _share, reason: _reason.text, recordConsent: a.recording ? (_record ?? false) : null);
      if (!mounted) return;
      switch (out) {
        case Confirmed(:final Appointment appointment):
          await _booked(appointment);
        case PaymentNeeded(:final int amountPaise):
          await _payOnWeb(a, amountPaise);
      }
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, "We couldn't confirm this consult. Please try again."));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _booked(Appointment a) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: NColors.surfaceCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(NRadius.xl))),
      builder: (BuildContext sheet) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, NSpace.lg, NSpace.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const NIllustration(asset: ConsultArt.verified, height: 150, entrance: NEntrance.breathe),
                const SizedBox(height: NSpace.md),
                Text(ConsultsCopy.bookedTitle, style: NType.h2.copyWith(color: NColors.inkPrimary)),
                const SizedBox(height: NSpace.xs),
                Text(
                  ConsultsCopy.bookedText(a.clinicianName ?? ConsultsCopy.someone, whenLabel(a.startsAt)),
                  textAlign: TextAlign.center,
                  style: NType.body.copyWith(color: NColors.inkSecondary),
                ),
                const SizedBox(height: NSpace.lg),
                NPrimaryButton(label: ConsultsCopy.seeAppointments, onPressed: () => Navigator.of(sheet).pop()),
              ],
            ),
          ),
        ),
      ),
    );
    if (mounted) context.go(RouteConstants.appointments);
  }

  Future<void> _payOnWeb(Appointment a, int amount) async {
    final bool? open = await showModalBottomSheet<bool>(
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: NColors.brandBlushLight, shape: BoxShape.circle),
                  child: Icon(Icons.lock_outline_rounded, color: NColors.brandRosewood),
                ),
                const SizedBox(height: NSpace.sm),
                Text(ConsultsCopy.payTitle, style: NType.h3.copyWith(color: NColors.inkPrimary)),
                const SizedBox(height: NSpace.xs),
                Text(ConsultsCopy.payText(amount), style: NType.body.copyWith(color: NColors.inkSecondary)),
                const SizedBox(height: NSpace.lg),
                NPrimaryButton(label: ConsultsCopy.openWebsite, trailingArrow: true, onPressed: () => Navigator.of(sheet).pop(true)),
                const SizedBox(height: NSpace.xs),
                Center(
                  child: TextButton(onPressed: () => Navigator.of(sheet).pop(false), child: const Text(ConsultsCopy.later)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (open == true) {
      await launchUrl(Uri.parse('https://www.niraahwellness.com/appointments/${Uri.encodeComponent(a.id)}'), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _giveBack(Appointment a) async {
    setState(() => _busy = true);
    try {
      await _repo.cancel(a.id);
    } on Object {
      // The hold runs out on its own anyway.
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: NColors.surfacePage,
    body: SafeArea(
      child: AsyncBody<Appointment>(
        future: _load,
        onRetry: () => setState(() {
          _load = _repo.appointment(widget.id);
        }),
        builder: (BuildContext context, Appointment a) {
          final Duration left = (a.holdExpiresAt ?? _now.add(const Duration(minutes: 10))).difference(_now);
          final bool expired = a.status == AppointmentStatus.held && left.isNegative;
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.lg),
                  children: <Widget>[
                    RoundBack(onPressed: () => context.pop()),
                    const SizedBox(height: NSpace.sm),
                    Text(ConsultsCopy.confirmTitle, style: NType.h2.copyWith(color: NColors.inkPrimary)),
                    const SizedBox(height: NSpace.md),
                    _Summary(a: a, specialist: widget.specialist, left: expired ? null : left),
                    const SizedBox(height: NSpace.lg),
                    if (expired)
                      SoftCard(
                        color: NColors.statusWarningLight,
                        child: Text(ConsultsCopy.expired, style: NType.body.copyWith(color: NColors.inkPrimary)),
                      )
                    else ...<Widget>[
                      Text(ConsultsCopy.shareTitle, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                      const SizedBox(height: 2),
                      Text(ConsultsCopy.shareIntro, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                      const SizedBox(height: NSpace.sm),
                      SoftCard(
                        padding: const EdgeInsets.symmetric(vertical: NSpace.xxs),
                        child: Column(
                          children: <Widget>[
                            for (final ShareCategory c in ShareCategory.values) ...<Widget>[
                              _ShareRow(
                                label: ConsultsCopy.categories[c]!,
                                icon: _icon(c),
                                on: _share.contains(c),
                                onChanged: (bool v) => setState(() => v ? _share.add(c) : _share.remove(c)),
                              ),
                              if (c != ShareCategory.values.last) Divider(height: 1, indent: 56, color: NColors.lineDefault),
                            ],
                          ],
                        ),
                      ),
                      if (_share.isEmpty) ...<Widget>[
                        const SizedBox(height: NSpace.xs),
                        Text(ConsultsCopy.shareNone, style: NType.label.copyWith(color: NColors.inkMuted)),
                      ],
                      const SizedBox(height: NSpace.lg),
                      Text(ConsultsCopy.reason, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                      const SizedBox(height: NSpace.xs),
                      TextField(
                        controller: _reason,
                        maxLines: 3,
                        minLines: 2,
                        maxLength: 500,
                        decoration: const InputDecoration(hintText: ConsultsCopy.reasonHint),
                      ),
                      if (a.recording) ...<Widget>[
                        const SizedBox(height: NSpace.md),
                        SoftCard(
                          color: NColors.brandLavenderLight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(ConsultsCopy.recordTitle, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                              const SizedBox(height: NSpace.xxs),
                              Text(ConsultsCopy.recordText, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                              const SizedBox(height: NSpace.xs),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text('Yes, keep a record', style: NType.body.copyWith(color: NColors.inkPrimary)),
                                  ),
                                  Switch(value: _record ?? false, onChanged: (bool v) => setState(() => _record = v)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.sm, NSpace.md, NSpace.sm),
                decoration: BoxDecoration(
                  color: NColors.surfaceCard,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(NRadius.xl)),
                  boxShadow: NShadow.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (expired)
                      NPrimaryButton(label: ConsultsCopy.chooseAgain, onPressed: () => context.pop())
                    else ...<Widget>[
                      NPrimaryButton(
                        label: a.included ? ConsultsCopy.confirmIncluded : ConsultsCopy.pay(a.feePaise),
                        loading: _busy,
                        onPressed: _busy ? null : () => _confirm(a),
                      ),
                      TextButton(onPressed: _busy ? null : () => _giveBack(a), child: const Text(ConsultsCopy.giveBack)),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );

  static IconData _icon(ShareCategory c) => switch (c) {
    ShareCategory.healthData => Icons.favorite_border_rounded,
    ShareCategory.assessment => Icons.assignment_outlined,
    ShareCategory.cycleSymptoms => Icons.water_drop_outlined,
    ShareCategory.meals => Icons.restaurant_outlined,
    ShareCategory.labReports => Icons.science_outlined,
    ShareCategory.messages => Icons.chat_bubble_outline_rounded,
  };
}

class _Summary extends StatelessWidget {
  const _Summary({required this.a, required this.specialist, required this.left});

  final Appointment a;
  final Specialist? specialist;
  final Duration? left;

  @override
  Widget build(BuildContext context) {
    final String mmss = left == null ? '' : '${left!.inMinutes}:${(left!.inSeconds % 60).toString().padLeft(2, '0')}';
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
            children: <Widget>[
              SpecialistAvatar(type: a.providerType ?? specialist?.type, size: 60),
              const SizedBox(width: NSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(a.clinicianName ?? specialist?.name ?? ConsultsCopy.someone, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                    if (specialist?.title != null) Text(specialist!.title, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: NSpace.md),
          Container(
            padding: const EdgeInsets.all(NSpace.sm),
            decoration: BoxDecoration(color: NColors.surfaceCard, borderRadius: BorderRadius.circular(NRadius.md)),
            child: Column(
              children: <Widget>[
                _Line(icon: Icons.event_rounded, text: dayLabel(a.startsAt, relative: false)),
                _Line(
                  icon: Icons.schedule_rounded,
                  text: '${timeLabel(a.startsAt)} – ${timeLabel(a.endsAt)} · ${ConsultsCopy.minutes(a.endsAt.difference(a.startsAt).inMinutes)}',
                ),
                const _Line(icon: Icons.videocam_outlined, text: ConsultsCopy.videoConsult),
                _Line(
                  icon: a.included ? Icons.check_circle_outline_rounded : Icons.currency_rupee_rounded,
                  text: a.included ? ConsultsCopy.includedNote : ConsultsCopy.fee(a.feePaise),
                  strong: true,
                ),
              ],
            ),
          ),
          if (left != null) ...<Widget>[
            const SizedBox(height: NSpace.sm),
            SoftPill(
              text: ConsultsCopy.heldFor(mmss),
              background: NColors.surfaceCard,
              foreground: NColors.brandRosewood,
              icon: Icons.hourglass_bottom_rounded,
              strong: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text, this.strong = false});

  final IconData icon;
  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: <Widget>[
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: NColors.brandBlushLight, borderRadius: BorderRadius.circular(NRadius.sm)),
          child: Icon(icon, size: 17, color: NColors.brandRosewood),
        ),
        const SizedBox(width: NSpace.sm),
        Expanded(
          child: Text(
            text,
            style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: strong ? FontWeight.w700 : FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}

class _ShareRow extends StatelessWidget {
  const _ShareRow({required this.label, required this.icon, required this.on, required this.onChanged});

  final String label;
  final IconData icon;
  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: ListTile(
      onTap: () => onChanged(!on),
      minTileHeight: 56,
      leading: AnimatedContainer(
        duration: NMotion.fast,
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: on ? NColors.brandBlushLight : NColors.surfaceWarm, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: on ? NColors.brandRosewood : NColors.inkMuted),
      ),
      title: Text(label, style: NType.body.copyWith(color: NColors.inkPrimary)),
      trailing: Switch(value: on, onChanged: onChanged),
    ),
  );
}
