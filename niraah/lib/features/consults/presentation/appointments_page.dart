import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

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

/// Her consults (spec 014 §6): upcoming first with a date tile, status and cancel; past ones below.
class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key, this.repository});

  final ConsultsRepository? repository;

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  late final ConsultsRepository _repo = widget.repository ?? getIt<ConsultsRepository>();
  late Future<List<Appointment>> _list = _repo.appointments();

  void _reload() => setState(() {
    _list = _repo.appointments();
  });

  Future<void> _cancel(Appointment a) async {
    final bool? yes = await showModalBottomSheet<bool>(
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
                Text(ConsultsCopy.cancelTitle, style: NType.h3.copyWith(color: NColors.inkPrimary)),
                const SizedBox(height: NSpace.xs),
                Text(ConsultsCopy.cancelText, style: NType.body.copyWith(color: NColors.inkSecondary)),
                const SizedBox(height: NSpace.lg),
                NPrimaryButton(label: ConsultsCopy.keep, onPressed: () => Navigator.of(sheet).pop(false)),
                const SizedBox(height: NSpace.xs),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(sheet).pop(true),
                    style: TextButton.styleFrom(foregroundColor: NColors.brandRosewood),
                    child: const Text(ConsultsCopy.yesCancel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (yes != true) return;
    try {
      await _repo.cancel(a.id);
      if (mounted) showNote(context, ConsultsCopy.cancelled);
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, "We couldn't cancel this consult. Please try again."));
    }
    _reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: NColors.surfacePage,
    body: SafeArea(
      child: AsyncBody<List<Appointment>>(
        future: _list,
        onRetry: _reload,
        builder: (BuildContext context, List<Appointment> all) {
          final List<Appointment> upcoming = all.where((Appointment a) => a.upcoming).toList()
            ..sort((Appointment x, Appointment y) => x.startsAt.compareTo(y.startsAt));
          final List<Appointment> past = all.where((Appointment a) => !a.upcoming).toList()
            ..sort((Appointment x, Appointment y) => y.startsAt.compareTo(x.startsAt));
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl),
              children: <Widget>[
                if (context.canPop()) RoundBack(onPressed: () => context.pop()),
                const SizedBox(height: NSpace.sm),
                BlushHeader(
                  eyebrow: 'Care',
                  title: ConsultsCopy.appointments,
                  subtitle: upcoming.isEmpty ? ConsultsCopy.noUpcoming : '${upcoming.length} upcoming',
                  art: ConsultArt.verified,
                ),
                const SizedBox(height: NSpace.lg),
                Text(ConsultsCopy.upcoming, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                const SizedBox(height: NSpace.xs),
                if (upcoming.isEmpty)
                  SoftCard(
                    padding: const EdgeInsets.all(NSpace.lg),
                    child: Column(
                      children: <Widget>[
                        const NIllustration(asset: ConsultArt.empty, height: 110),
                        const SizedBox(height: NSpace.sm),
                        Text(
                          ConsultsCopy.noUpcoming,
                          textAlign: TextAlign.center,
                          style: NType.body.copyWith(color: NColors.inkSecondary),
                        ),
                        const SizedBox(height: NSpace.md),
                        NPrimaryButton(label: ConsultsCopy.bookConsult, onPressed: () => context.push(RouteConstants.bookDoctor)),
                      ],
                    ),
                  )
                else
                  for (final Appointment a in upcoming) ...<Widget>[
                    _AppointmentCard(
                      a: a,
                      onConfirm: a.status == AppointmentStatus.held
                          ? () async {
                              await context.push('${RouteConstants.appointments}/${Uri.encodeComponent(a.id)}/confirm');
                              _reload();
                            }
                          : null,
                      onCancel: a.canCancel ? () => _cancel(a) : null,
                    ),
                    const SizedBox(height: NSpace.sm),
                  ],
                if (upcoming.isNotEmpty) ...<Widget>[
                  const SizedBox(height: NSpace.xs),
                  OutlinedButton.icon(
                    onPressed: () => context.push(RouteConstants.bookDoctor),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(NLayout.minTapTarget + 4), shape: const StadiumBorder()),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(ConsultsCopy.bookConsult),
                  ),
                ],
                if (past.isNotEmpty) ...<Widget>[
                  const SizedBox(height: NSpace.lg),
                  Text(ConsultsCopy.past, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                  const SizedBox(height: NSpace.xs),
                  for (final Appointment a in past) ...<Widget>[_AppointmentCard(a: a, muted: true), const SizedBox(height: NSpace.sm)],
                ],
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.a, this.onCancel, this.onConfirm, this.muted = false});

  final Appointment a;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (a.status) {
      AppointmentStatus.confirmed || AppointmentStatus.inProgress => (NColors.statusSuccessLight, NColors.statusSuccess),
      AppointmentStatus.held => (NColors.statusWarningLight, NColors.statusWarningText),
      AppointmentStatus.completed => (NColors.brandLavenderLight, NColors.brandPlum),
      _ => (NColors.surfaceWarm, NColors.inkMuted),
    };
    return SoftCard(
      onTap: onConfirm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: NSpace.xs),
                decoration: BoxDecoration(color: muted ? NColors.surfaceWarm : NColors.brandBlushLight, borderRadius: BorderRadius.circular(NRadius.md)),
                child: Column(
                  children: <Widget>[
                    Text(
                      DateFormat('MMM').format(a.startsAt).toUpperCase(),
                      style: NType.caption.copyWith(color: muted ? NColors.inkMuted : NColors.brandRosewood),
                    ),
                    Text('${a.startsAt.day}', style: NType.h2.copyWith(color: muted ? NColors.inkSecondary : NColors.inkPrimary, height: 1.05)),
                    Text(DateFormat('EEE').format(a.startsAt), style: NType.label.copyWith(color: NColors.inkMuted)),
                  ],
                ),
              ),
              const SizedBox(width: NSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SoftPill(text: ConsultsCopy.status[a.status]!, background: bg, foreground: fg),
                    const SizedBox(height: NSpace.xxs),
                    Text(a.clinicianName ?? ConsultsCopy.someone, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                    Text(
                      '${timeLabel(a.startsAt)} – ${timeLabel(a.endsAt)} · ${ConsultsCopy.videoConsult}',
                      style: NType.bodySm.copyWith(color: NColors.inkSecondary),
                    ),
                  ],
                ),
              ),
              SpecialistAvatar(type: a.providerType, size: 44),
            ],
          ),
          if (onConfirm != null || onCancel != null) ...<Widget>[
            const SizedBox(height: NSpace.sm),
            Divider(height: 1, color: NColors.lineDefault),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                if (onCancel != null)
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(foregroundColor: NColors.inkMuted),
                    child: const Text(ConsultsCopy.cancel),
                  ),
                if (onConfirm != null)
                  TextButton(
                    onPressed: onConfirm,
                    style: TextButton.styleFrom(foregroundColor: NColors.brandRosewood),
                    child: const Text(ConsultsCopy.confirmTitle),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
