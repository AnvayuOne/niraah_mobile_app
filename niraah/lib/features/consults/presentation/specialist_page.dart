import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../../shared/constants/route_constants.dart';
import '../domain/consults.dart';
import 'consults_copy.dart';
import 'consults_ui.dart';

/// A specialist and her free times (spec 014 §2.3, §3 "Steps" 1): a strip of days, one day's times grouped into
/// Morning, Afternoon and Evening, and a pinned "Hold this time" button.
class SpecialistPage extends StatefulWidget {
  const SpecialistPage({required this.id, super.key, this.repository});

  final String id;
  final ConsultsRepository? repository;

  @override
  State<SpecialistPage> createState() => _SpecialistPageState();
}

class _Loaded {
  const _Loaded(this.s, this.slots);
  final Specialist s;
  final SlotList slots;
}

class _SpecialistPageState extends State<SpecialistPage> {
  late final ConsultsRepository _repo = widget.repository ?? getIt<ConsultsRepository>();
  late Future<_Loaded> _load = _fetch();
  DateTime? _day;
  DateTime? _time;
  bool _holding = false;

  Future<_Loaded> _fetch() async {
    final Specialist s = await _repo.specialist(widget.id);
    final DateTime now = DateTime.now();
    final SlotList slots = await _repo.slots(widget.id, now, now.add(Duration(days: s.horizonDays.clamp(7, 30))));
    return _Loaded(s, slots);
  }

  void _reload() => setState(() {
    _load = _fetch();
    _time = null;
  });

  static DateTime _dateOf(DateTime t) => DateTime(t.year, t.month, t.day);

  Future<void> _hold(Specialist s) async {
    final DateTime? t = _time;
    if (t == null) return;
    setState(() => _holding = true);
    try {
      final Appointment held = await _repo.hold(s.id, t);
      if (!mounted) return;
      await context.push(
        '${RouteConstants.appointments}/${Uri.encodeComponent(held.id)}/confirm',
        extra: <String, Object>{'appointment': held, 'specialist': s},
      );
      if (mounted) _reload();
    } on Object catch (e) {
      if (!mounted) return;
      showNote(context, failureText(e, "That time couldn't be held. Please choose another."));
      _reload();
    } finally {
      if (mounted) setState(() => _holding = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: NColors.surfacePage,
    body: SafeArea(
      child: AsyncBody<_Loaded>(
        future: _load,
        onRetry: _reload,
        builder: (BuildContext context, _Loaded d) {
          final Map<DateTime, List<DateTime>> byDay = <DateTime, List<DateTime>>{};
          for (final DateTime t in d.slots.slots) {
            (byDay[_dateOf(t)] ??= <DateTime>[]).add(t);
          }
          final DateTime today = _dateOf(DateTime.now());
          final int span = d.s.horizonDays.clamp(7, 30);
          final List<DateTime> days = <DateTime>[for (int i = 0; i < span; i++) today.add(Duration(days: i))];
          final DateTime day = _day ?? days.firstWhere((DateTime x) => (byDay[x] ?? const <DateTime>[]).isNotEmpty, orElse: () => days.first);
          final List<DateTime> times = (byDay[day] ?? <DateTime>[])..sort();
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.xs, NSpace.md, NSpace.lg),
                  children: <Widget>[
                    RoundBack(onPressed: () => context.pop()),
                    const SizedBox(height: NSpace.sm),
                    _ProfileCard(s: d.s),
                    const SizedBox(height: NSpace.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: Text(ConsultsCopy.chooseTime, style: NType.h3.copyWith(color: NColors.inkPrimary)),
                        ),
                        Text(
                          DateFormat('MMMM y').format(day),
                          style: NType.label.copyWith(color: NColors.inkMuted, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(ConsultsCopy.timesLocal, style: NType.label.copyWith(color: NColors.inkMuted)),
                    if (d.slots.fallbackReason != null) ...<Widget>[
                      const SizedBox(height: NSpace.sm),
                      _Notice(text: d.slots.fallbackReason!, color: NColors.statusWarningLight, icon: Icons.info_outline_rounded),
                    ],
                    const SizedBox(height: NSpace.sm),
                    if (d.slots.slots.isEmpty)
                      const _Notice(text: ConsultsCopy.noTimes, icon: Icons.event_busy_rounded)
                    else ...<Widget>[
                      _DayStrip(
                        days: days,
                        selected: day,
                        counts: <DateTime, int>{for (final DateTime x in days) x: (byDay[x] ?? const <DateTime>[]).length},
                        onPick: (DateTime x) => setState(() {
                          _day = x;
                          _time = null;
                        }),
                      ),
                      const SizedBox(height: NSpace.md),
                      if (times.isEmpty)
                        const _Notice(text: ConsultsCopy.noneThisDay, icon: Icons.event_busy_rounded)
                      else
                        _TimeGroups(times: times, selected: _time, onPick: (DateTime t) => setState(() => _time = t)),
                    ],
                  ],
                ),
              ),
              _Footer(time: _time, slots: d.slots, holding: _holding, onHold: _time == null || _holding ? null : () => _hold(d.s)),
            ],
          );
        },
      ),
    ),
  );
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.s});

  final Specialist s;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(NRadius.xl),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: s.type == ProviderType.dietitian
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
            SpecialistAvatar(type: s.type, size: 84),
            const SizedBox(width: NSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (s.label != null) ...<Widget>[
                    SoftPill(text: s.label!, background: NColors.surfaceCard, foreground: NColors.brandPlum, icon: Icons.favorite_rounded),
                    const SizedBox(height: NSpace.xxs),
                  ],
                  Text(s.name ?? s.title, style: NType.h3.copyWith(color: NColors.inkPrimary)),
                  Text(
                    <String>[s.title, if (s.yearsExperience != null) ConsultsCopy.years(s.yearsExperience!)].join(' · '),
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
            if (s.feePaise != null)
              SoftPill(
                text: ConsultsCopy.fee(s.feePaise!),
                background: NColors.surfaceCard,
                foreground: NColors.inkPrimary,
                icon: Icons.currency_rupee_rounded,
                strong: true,
              ),
            if (s.ratingAverage != null && s.ratingCount > 0)
              SoftPill(
                text: ConsultsCopy.rating(s.ratingAverage!, s.ratingCount),
                background: NColors.surfaceCard,
                foreground: NColors.inkSecondary,
                icon: Icons.star_rounded,
              ),
            SoftPill(text: ConsultsCopy.videoConsult, background: NColors.surfaceCard, foreground: NColors.inkSecondary, icon: Icons.videocam_outlined),
          ],
        ),
        if (s.specialities.isNotEmpty) ...<Widget>[
          const SizedBox(height: NSpace.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              for (final String x in s.specialities) SoftPill(text: niceWord(x), background: NColors.brandBlushLight, foreground: NColors.brandRosewood),
            ],
          ),
        ],
        if (s.bio != null && s.bio!.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: NSpace.md),
          Text(s.bio!, style: NType.body.copyWith(color: NColors.inkSecondary)),
        ],
        if (s.languages.isNotEmpty || s.registration != null) ...<Widget>[
          const SizedBox(height: NSpace.sm),
          if (s.languages.isNotEmpty) _Fact(icon: Icons.translate_rounded, text: ConsultsCopy.speaks(s.languages)),
          if (s.registration != null) _Fact(icon: Icons.verified_outlined, text: 'Registration ${s.registration}'),
        ],
      ],
    ),
  );
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
        Expanded(
          child: Text(text, style: NType.label.copyWith(color: NColors.inkMuted)),
        ),
      ],
    ),
  );
}

class _DayStrip extends StatefulWidget {
  const _DayStrip({required this.days, required this.selected, required this.counts, required this.onPick});

  final List<DateTime> days;
  final DateTime selected;
  final Map<DateTime, int> counts;
  final ValueChanged<DateTime> onPick;

  @override
  State<_DayStrip> createState() => _DayStripState();
}

class _DayStripState extends State<_DayStrip> {
  static const double _w = 68;
  static const double _gap = NSpace.xs;
  late final ScrollController _c = ScrollController(
    initialScrollOffset: (widget.days.indexOf(widget.selected).clamp(0, 999) * (_w + _gap) - _w).clamp(0, double.infinity),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 92,
    child: ListView.separated(
      controller: _c,
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      itemCount: widget.days.length,
      separatorBuilder: (_, _) => const SizedBox(width: _gap),
      itemBuilder: (BuildContext context, int i) {
        final DateTime d = widget.days[i];
        final int n = widget.counts[d] ?? 0;
        final bool on = d == widget.selected;
        final bool off = n == 0;
        return Semantics(
          button: true,
          selected: on,
          label: '${DateFormat('EEEE d MMMM').format(d)}, ${ConsultsCopy.free(n)}',
          child: GestureDetector(
            onTap: off ? null : () => widget.onPick(d),
            child: AnimatedContainer(
              duration: NMotion.fast,
              width: _w,
              decoration: BoxDecoration(
                color: on ? NColors.brandPlum : (off ? NColors.surfacePage : NColors.surfaceCard),
                borderRadius: BorderRadius.circular(NRadius.lg),
                border: Border.all(color: on ? NColors.brandPlum : NColors.lineDefault),
                boxShadow: on ? NShadow.md : (off ? const <BoxShadow>[] : NShadow.xs),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    DateFormat('EEE').format(d).toUpperCase(),
                    style: NType.caption.copyWith(color: on ? NColors.inkOnBrand.withValues(alpha: 0.8) : NColors.inkMuted, letterSpacing: 1),
                  ),
                  const SizedBox(height: 2),
                  Text('${d.day}', style: NType.h3.copyWith(color: on ? NColors.inkOnBrand : (off ? NColors.inkMuted : NColors.inkPrimary), height: 1.05)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: on ? NColors.inkOnBrand.withValues(alpha: 0.16) : (off ? Colors.transparent : NColors.statusSuccessLight),
                      borderRadius: BorderRadius.circular(NRadius.pill),
                    ),
                    child: Text(
                      ConsultsCopy.free(n),
                      style: NType.label.copyWith(
                        fontSize: 11,
                        color: on ? NColors.inkOnBrand : (off ? NColors.inkMuted : NColors.statusSuccess),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _TimeGroups extends StatelessWidget {
  const _TimeGroups({required this.times, required this.selected, required this.onPick});

  final List<DateTime> times;
  final DateTime? selected;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final List<(String, IconData, List<DateTime>)> groups = <(String, IconData, List<DateTime>)>[
      (ConsultsCopy.morning, Icons.wb_twilight_rounded, times.where((DateTime t) => t.hour < 12).toList()),
      (ConsultsCopy.afternoon, Icons.wb_sunny_outlined, times.where((DateTime t) => t.hour >= 12 && t.hour < 17).toList()),
      (ConsultsCopy.evening, Icons.nightlight_outlined, times.where((DateTime t) => t.hour >= 17).toList()),
    ];
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.md, NSpace.md, NSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (String label, IconData icon, List<DateTime> list) in groups)
            if (list.isNotEmpty) ...<Widget>[
              Row(
                children: <Widget>[
                  Icon(icon, size: 16, color: NColors.brandRosewood),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: NType.label.copyWith(color: NColors.inkSecondary, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 6),
                  Text('${list.length}', style: NType.label.copyWith(color: NColors.inkMuted)),
                ],
              ),
              const SizedBox(height: NSpace.xs),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints c) {
                  const double gap = NSpace.xs;
                  final int cols = c.maxWidth >= 420 ? 4 : 3;
                  final double w = (c.maxWidth - gap * (cols - 1)) / cols;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: <Widget>[for (final DateTime t in list) _TimeChip(width: w, t: t, on: t == selected, onTap: () => onPick(t))],
                  );
                },
              ),
              const SizedBox(height: NSpace.md),
            ],
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.width, required this.t, required this.on, required this.onTap});

  final double width;
  final DateTime t;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: on,
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: NMotion.fast,
        width: width,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? NColors.brandRosewood : NColors.surfacePage,
          borderRadius: BorderRadius.circular(NRadius.md),
          border: Border.all(color: on ? NColors.brandRosewood : NColors.lineDefault),
          boxShadow: on ? NShadow.brandGlow : const <BoxShadow>[],
        ),
        child: Text(
          timeLabel(t),
          style: NType.body.copyWith(color: on ? NColors.inkOnBrand : NColors.inkPrimary, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, this.icon, this.color});

  final String text;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(NSpace.md),
    decoration: BoxDecoration(color: color ?? NColors.surfaceWarm, borderRadius: BorderRadius.circular(NRadius.md)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (icon != null) ...<Widget>[Icon(icon, size: 18, color: NColors.inkMuted), const SizedBox(width: NSpace.xs)],
        Expanded(
          child: Text(text, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
        ),
      ],
    ),
  );
}

class _Footer extends StatelessWidget {
  const _Footer({required this.time, required this.slots, required this.holding, required this.onHold});

  final DateTime? time;
  final SlotList slots;
  final bool holding;
  final VoidCallback? onHold;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.sm, NSpace.md, NSpace.md),
    decoration: BoxDecoration(
      color: NColors.surfaceCard,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(NRadius.xl)),
      boxShadow: NShadow.lg,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedSwitcher(
          duration: NMotion.fast,
          child: Row(
            key: ValueKey<DateTime?>(time),
            children: <Widget>[
              Icon(
                time == null ? Icons.touch_app_outlined : Icons.event_available_rounded,
                size: 20,
                color: time == null ? NColors.inkMuted : NColors.brandRosewood,
              ),
              const SizedBox(width: NSpace.xs),
              Expanded(
                child: Text(
                  time == null ? ConsultsCopy.pickATime : whenLabel(time!),
                  style: NType.body.copyWith(color: time == null ? NColors.inkMuted : NColors.inkPrimary, fontWeight: FontWeight.w600),
                ),
              ),
              if (slots.included)
                const SoftPill(text: ConsultsCopy.includedNote, icon: Icons.check_circle_outline_rounded)
              else if (slots.feePaise != null)
                Text(rupees(slots.feePaise!), style: NType.h4.copyWith(color: NColors.inkPrimary)),
            ],
          ),
        ),
        const SizedBox(height: NSpace.sm),
        NPrimaryButton(label: ConsultsCopy.holdTime, onPressed: onHold, loading: holding, trailingArrow: true),
      ],
    ),
  );
}
