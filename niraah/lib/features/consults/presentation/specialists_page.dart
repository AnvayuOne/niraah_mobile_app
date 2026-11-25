import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_illustration.dart';
import '../../../shared/area/area_widgets.dart';
import '../../../shared/constants/route_constants.dart';
import '../domain/consults.dart';
import 'consults_copy.dart';
import 'consults_ui.dart';

/// Find a specialist (spec 014 §2): doctors and dietitians with their next free time, fee and a Book button.
class SpecialistsPage extends StatefulWidget {
  const SpecialistsPage({super.key, this.repository});

  final ConsultsRepository? repository;

  @override
  State<SpecialistsPage> createState() => _SpecialistsPageState();
}

class _SpecialistsPageState extends State<SpecialistsPage> {
  late final ConsultsRepository _repo = widget.repository ?? getIt<ConsultsRepository>();
  ProviderType? _type;
  late Future<List<Specialist>> _list = _repo.specialists();

  void _load() => setState(() {
    _list = _repo.specialists(type: _type);
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: NColors.surfacePage,
    body: SafeArea(
      child: AsyncBody<List<Specialist>>(
        future: _list,
        onRetry: _load,
        builder: (BuildContext context, List<Specialist> list) => RefreshIndicator(
          onRefresh: () async => _load(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.xl),
            children: <Widget>[
              Row(
                children: <Widget>[
                  if (context.canPop()) RoundBack(onPressed: () => context.pop()),
                  const Spacer(),
                  _AppointmentsLink(onTap: () => context.push(RouteConstants.appointments)),
                ],
              ),
              const SizedBox(height: NSpace.sm),
              const BlushHeader(eyebrow: 'Care', title: ConsultsCopy.findTitle, subtitle: ConsultsCopy.findIntro, art: ConsultArt.verified),
              const SizedBox(height: NSpace.md),
              _TypeChips(
                value: _type,
                onChanged: (ProviderType? t) {
                  _type = t;
                  _load();
                },
              ),
              const SizedBox(height: NSpace.md),
              if (list.isEmpty)
                _Empty()
              else
                for (final Specialist s in list) ...<Widget>[
                  _SpecialistCard(s: s, onOpen: () => context.push('${RouteConstants.bookDoctor}/${Uri.encodeComponent(s.id)}')),
                  const SizedBox(height: NSpace.sm),
                ],
              const SizedBox(height: NSpace.sm),
              _WellnessNote(),
            ],
          ),
        ),
      ),
    ),
  );
}

class _AppointmentsLink extends StatelessWidget {
  const _AppointmentsLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: onTap,
    style: TextButton.styleFrom(
      backgroundColor: NColors.surfaceCard,
      foregroundColor: NColors.brandRosewood,
      minimumSize: const Size(0, NLayout.minTapTarget),
      padding: const EdgeInsets.symmetric(horizontal: NSpace.md),
      shape: StadiumBorder(side: BorderSide(color: NColors.lineDefault)),
    ),
    icon: const Icon(Icons.event_note_rounded, size: 18),
    label: Text(ConsultsCopy.appointments, style: NType.label.copyWith(fontWeight: FontWeight.w600)),
  );
}

class _TypeChips extends StatelessWidget {
  const _TypeChips({required this.value, required this.onChanged});

  final ProviderType? value;
  final ValueChanged<ProviderType?> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, ProviderType? t, IconData icon) {
      final bool on = value == t;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(t),
          child: AnimatedContainer(
            duration: NMotion.fast,
            height: NLayout.minTapTarget,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: on ? NColors.brandPlum : Colors.transparent, borderRadius: BorderRadius.circular(NRadius.pill)),
            padding: const EdgeInsets.symmetric(horizontal: NSpace.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 16, color: on ? NColors.inkOnBrand : NColors.inkSecondary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: NType.label.copyWith(color: on ? NColors.inkOnBrand : NColors.inkSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      label: 'Kind of specialist',
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: NColors.surfaceCard,
          borderRadius: BorderRadius.circular(NRadius.pill),
          border: Border.all(color: NColors.lineDefault),
          boxShadow: NShadow.xs,
        ),
        child: Row(
          children: <Widget>[
            chip(ConsultsCopy.all, null, Icons.auto_awesome_rounded),
            chip(ConsultsCopy.doctors, ProviderType.doctor, Icons.medical_services_outlined),
            chip(ConsultsCopy.dietitians, ProviderType.dietitian, Icons.restaurant_rounded),
          ],
        ),
      ),
    );
  }
}

class _SpecialistCard extends StatelessWidget {
  const _SpecialistCard({required this.s, required this.onOpen});

  final Specialist s;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => SoftCard(
    onTap: onOpen,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SpecialistAvatar(type: s.type, size: 64),
            const SizedBox(width: NSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (s.label != null) ...<Widget>[
                    SoftPill(text: s.label!, background: NColors.brandLavenderLight, foreground: NColors.brandPlum, icon: Icons.favorite_rounded),
                    const SizedBox(height: NSpace.xxs),
                  ],
                  Text(s.name ?? s.title, style: NType.h4.copyWith(color: NColors.inkPrimary)),
                  Text(
                    <String>[s.title, if (s.yearsExperience != null) ConsultsCopy.years(s.yearsExperience!)].join(' · '),
                    style: NType.bodySm.copyWith(color: NColors.inkSecondary),
                  ),
                  if (s.ratingAverage != null && s.ratingCount > 0) ...<Widget>[
                    const SizedBox(height: 2),
                    Row(
                      children: <Widget>[
                        Icon(Icons.star_rounded, size: 16, color: NColors.brandApricot),
                        const SizedBox(width: 2),
                        Text(ConsultsCopy.rating(s.ratingAverage!, s.ratingCount), style: NType.label.copyWith(color: NColors.inkMuted)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (s.specialities.isNotEmpty) ...<Widget>[
          const SizedBox(height: NSpace.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              for (final String x in s.specialities.take(4))
                SoftPill(text: niceWord(x), background: NColors.brandBlushLight, foreground: NColors.brandRosewood),
            ],
          ),
        ],
        if (s.languages.isNotEmpty) ...<Widget>[
          const SizedBox(height: NSpace.xs),
          Row(
            children: <Widget>[
              Icon(Icons.translate_rounded, size: 15, color: NColors.inkMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(ConsultsCopy.speaks(s.languages), style: NType.label.copyWith(color: NColors.inkMuted)),
              ),
            ],
          ),
        ],
        const SizedBox(height: NSpace.sm),
        Divider(height: 1, color: NColors.lineDefault),
        const SizedBox(height: NSpace.sm),
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    s.feePaise != null ? ConsultsCopy.fee(s.feePaise!) : ConsultsCopy.noFee,
                    style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700),
                  ),
                  if (s.nextSlot != null)
                    Row(
                      children: <Widget>[
                        Icon(Icons.schedule_rounded, size: 14, color: NColors.statusSuccess),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Next: ${whenLabel(s.nextSlot!)}',
                            style: NType.label.copyWith(color: NColors.inkSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(width: NSpace.sm),
            FilledButton(
              onPressed: onOpen,
              style: FilledButton.styleFrom(minimumSize: const Size(96, NLayout.minTapTarget), shape: const StadiumBorder()),
              child: const Text(ConsultsCopy.book),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SoftCard(
    padding: const EdgeInsets.all(NSpace.lg),
    child: Column(
      children: <Widget>[
        const NIllustration(asset: ConsultArt.empty, height: 120),
        const SizedBox(height: NSpace.sm),
        Text(
          ConsultsCopy.none,
          textAlign: TextAlign.center,
          style: NType.body.copyWith(color: NColors.inkSecondary),
        ),
      ],
    ),
  );
}

class _WellnessNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(NSpace.md),
    decoration: BoxDecoration(color: NColors.brandSageLight, borderRadius: BorderRadius.circular(NRadius.md)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(Icons.spa_outlined, size: 18, color: NColors.statusSuccess),
        const SizedBox(width: NSpace.xs),
        Expanded(
          child: Text(ConsultsCopy.wellness, style: NType.label.copyWith(color: NColors.inkSecondary)),
        ),
      ],
    ),
  );
}
