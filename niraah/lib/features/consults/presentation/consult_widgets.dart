import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../domain/consults.dart';
import 'consult_cubits.dart';
import 'consults_ui.dart';

/// "Tue 18 Nov, 4:30 PM" in her locale and time zone (spec 014 §1.7: times are shown in the viewer's time zone).
String whenText(BuildContext context, DateTime t) => DateFormat('EEE d MMM, h:mm a', Localizations.localeOf(context).toString()).format(t.toLocal());

String timeText(BuildContext context, DateTime t) => DateFormat.jm(Localizations.localeOf(context).toString()).format(t.toLocal());

String dayText(BuildContext context, DateTime t) => DateFormat('EEEE d MMMM', Localizations.localeOf(context).toString()).format(t.toLocal());

/// "Doctor" or "Dietitian" for a provider type.
String typeName(S s, String? type) => type == 'dietitian' ? s.csTypeDietitian : s.csTypeDoctor;

/// The words for an appointment's state (spec 014 §3 "States").
String statusText(S s, String status) => switch (status) {
      'held' => s.csStatusHeld,
      'confirmed' => s.csStatusConfirmed,
      'in_progress' => s.csStatusInProgress,
      'completed' => s.csStatusCompleted,
      'cancelled' => s.csStatusCancelled,
      'no_show' => s.csStatusNoShow,
      'expired' => s.csStatusExpired,
      _ => status,
    };

/// A data category she may share with the clinician (spec 001 categories; spec 014 §3 "Steps" 2).
String categoryText(S s, String c) => switch (c) {
      'health_data' => s.csCatHealth,
      'assessment' => s.csCatAssessment,
      'cycle_symptoms' => s.csCatCycle,
      'meals' => s.csCatMeals,
      'lab_reports' => s.csCatLabs,
      'messages' => s.csCatMessages,
      _ => c,
    };

/// The clinician's initials. The directory says whether she has a photo but sends no picture, so none is shown.
class SpecialistAvatar extends StatelessWidget {
  const SpecialistAvatar({required this.name, super.key});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final String initials = (name ?? '').trim().split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).take(2).map((String w) => w[0].toUpperCase()).join();
    return ExcludeSemantics(
      child: CircleAvatar(
        radius: NSpace.lg,
        backgroundColor: NColors.brandLavenderLight,
        child: initials.isEmpty ? Icon(Icons.person_outline_rounded, color: NColors.inkSecondary) : Text(initials, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

/// Bookable times, a week at a time, in her time zone: a strip of day cards ("N free" / "Full"), then the chosen day's
/// times grouped Morning / Afternoon / Evening. Tapping a time calls [onPick] straight away, as before.
class SlotPicker extends StatefulWidget {
  const SlotPicker({required this.onPick, super.key, this.header});

  final void Function(Slot slot, SlotList list) onPick;

  /// Shown above the times once they are loaded: the fee or "included", or the dedicated fallback.
  final Widget Function(BuildContext context, SlotList list)? header;

  @override
  State<SlotPicker> createState() => _SlotPickerState();
}

class _SlotPickerState extends State<SlotPicker> {
  /// The day she tapped in the strip, for the week on screen ([_week]); otherwise the first day with times.
  DateTime? _day;
  DateTime? _week;

  /// The time she tapped last, shown rose while it is being held.
  DateTime? _picked;

  static DateTime _date(DateTime t) {
    final DateTime l = t.toLocal();
    return DateTime(l.year, l.month, l.day);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<SlotsCubit, SlotsState>(
      builder: (BuildContext context, SlotsState st) {
        final SlotsCubit cubit = context.read<SlotsCubit>();
        switch (st.status) {
          case LoadStatus.loading:
            return SizedBox(height: NSpace.xl3 * 2, child: LoadingView(label: s.loading));
          case LoadStatus.failure:
            if (st.error is AreaLocked) return AreaLockedView(refusal: st.error! as AreaLocked);
            return ErrorView(message: failureText(st.error!, s.commonLoadError), retryLabel: s.tryAgain, onRetry: () => cubit.load(st.from));
          case LoadStatus.ready:
            final SlotList list = st.list!;
            final DateTime start = _date(st.from ?? DateTime.now());
            final List<DateTime> days = <DateTime>[for (int i = 0; i < SlotsCubit.window.inDays; i++) DateTime(start.year, start.month, start.day + i)];
            final Map<DateTime, List<Slot>> byDay = <DateTime, List<Slot>>{};
            for (final Slot x in list.slots) {
              final DateTime d = _date(x.startsAt);
              byDay.putIfAbsent(d, () => <Slot>[]).add(x);
              if (!days.contains(d)) days.add(d);
            }
            days.sort();
            if (_week != start) {
              _week = start;
              _day = null;
            }
            final DateTime day = _day != null && (byDay[_day] ?? const <Slot>[]).isNotEmpty
                ? _day!
                : days.firstWhere((DateTime d) => (byDay[d] ?? const <Slot>[]).isNotEmpty, orElse: () => days.first);
            final List<Slot> times = <Slot>[...?byDay[day]]..sort((Slot a, Slot b) => a.startsAt.compareTo(b.startsAt));
            final String locale = Localizations.localeOf(context).toString();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (widget.header != null) widget.header!(context, list),
                const SizedBox(height: NSpace.sm),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(DateFormat('MMMM y', locale).format(day), style: NType.label.copyWith(color: NColors.inkMuted, fontWeight: FontWeight.w600)),
                    ),
                    if (cubit.canGoEarlier) _NavPill(label: s.csEarlier, icon: Icons.chevron_left_rounded, onPressed: st.holding ? null : cubit.earlier),
                    if (cubit.canGoEarlier && cubit.canGoLater) const SizedBox(width: NSpace.xs),
                    if (cubit.canGoLater) _NavPill(label: s.csLater, icon: Icons.chevron_right_rounded, trailing: true, onPressed: st.holding ? null : cubit.later),
                  ],
                ),
                const SizedBox(height: NSpace.xs),
                if (byDay.isEmpty)
                  EmptyNote(text: s.csNoTimesThisWeek, actionLabel: cubit.canGoLater ? s.csLater : null, onAction: cubit.canGoLater ? cubit.later : null)
                else ...<Widget>[
                  _DayStrip(
                    days: days,
                    selected: day,
                    counts: <DateTime, int>{for (final DateTime d in days) d: (byDay[d] ?? const <Slot>[]).length},
                    onPick: (DateTime d) => setState(() => _day = d),
                  ),
                  const SizedBox(height: NSpace.md),
                  _TimeGroups(
                    times: times,
                    picked: st.holding ? _picked : null,
                    enabled: !st.holding,
                    onPick: (Slot x) {
                      setState(() => _picked = x.startsAt);
                      widget.onPick(x, list);
                    },
                  ),
                ],
              ],
            );
        }
      },
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({required this.label, required this.icon, required this.onPressed, this.trailing = false});

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool trailing;

  @override
  Widget build(BuildContext context) {
    final Widget i = Icon(icon, size: 18);
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: NColors.brandRosewood,
        backgroundColor: NColors.surfaceCard,
        side: BorderSide(color: NColors.lineDefault),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: NSpace.sm),
        minimumSize: const Size(0, 40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[if (!trailing) i, Text(label, style: NType.label.copyWith(fontWeight: FontWeight.w700)), if (trailing) i],
      ),
    );
  }
}

/// The week's days as cards: weekday, date and "N free"; a day with nothing free is page-coloured with a faint border.
class _DayStrip extends StatelessWidget {
  const _DayStrip({required this.days, required this.selected, required this.counts, required this.onPick});

  final List<DateTime> days;
  final DateTime selected;
  final Map<DateTime, int> counts;
  final ValueChanged<DateTime> onPick;

  static const double _w = 66;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    return SizedBox(
      height: 94,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: NSpace.xs),
        itemBuilder: (BuildContext context, int i) {
          final DateTime d = days[i];
          final int n = counts[d] ?? 0;
          final bool on = d == selected;
          final bool off = n == 0;
          return Semantics(
            button: !off,
            selected: on,
            label: '${DateFormat('EEEE d MMMM', locale).format(d)}, ${ConsultLabels.free(n)}',
            excludeSemantics: true,
            child: GestureDetector(
              onTap: off ? null : () => onPick(d),
              child: AnimatedContainer(
                duration: NMotion.fast,
                width: _w,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: on ? NColors.brandPlum : (off ? NColors.surfacePage : NColors.surfaceCard),
                  borderRadius: BorderRadius.circular(NRadius.lg),
                  border: Border.all(color: on ? NColors.brandPlum : NColors.lineDefault.withValues(alpha: off ? 0.7 : 1)),
                  boxShadow: on ? NShadow.md : (off ? const <BoxShadow>[] : NShadow.xs),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(DateFormat('EEE', locale).format(d).toUpperCase(), style: NType.caption.copyWith(color: on ? NColors.inkOnBrand.withValues(alpha: 0.8) : NColors.inkMuted, letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text('${d.day}', style: NType.h4.copyWith(fontSize: 22, fontWeight: FontWeight.w700, color: on ? NColors.inkOnBrand : (off ? NColors.inkMuted : NColors.inkPrimary), height: 1.1)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: on ? NColors.inkOnBrand.withValues(alpha: 0.16) : (off ? Colors.transparent : NColors.statusSuccessLight),
                        borderRadius: BorderRadius.circular(NRadius.pill),
                      ),
                      child: Text(
                        ConsultLabels.free(n),
                        maxLines: 1,
                        style: NType.label.copyWith(fontSize: 11, color: on ? NColors.inkOnBrand : (off ? NColors.inkMuted : NColors.statusSuccess), fontWeight: FontWeight.w600),
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
}

/// The chosen day's times in Morning / Afternoon / Evening groups, an even three-column grid (four on wide screens).
class _TimeGroups extends StatelessWidget {
  const _TimeGroups({required this.times, required this.picked, required this.enabled, required this.onPick});

  final List<Slot> times;
  final DateTime? picked;
  final bool enabled;
  final ValueChanged<Slot> onPick;

  static String _cap(String w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    int hour(Slot x) => x.startsAt.toLocal().hour;
    final List<(String, IconData, List<Slot>)> groups = <(String, IconData, List<Slot>)>[
      (_cap(s.homePartMorning), Icons.wb_twilight_rounded, times.where((Slot x) => hour(x) < 12).toList()),
      (_cap(s.homePartAfternoon), Icons.wb_sunny_outlined, times.where((Slot x) => hour(x) >= 12 && hour(x) < 17).toList()),
      (_cap(s.homePartEvening), Icons.nightlight_outlined, times.where((Slot x) => hour(x) >= 17).toList()),
    ];
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.md, NSpace.md, NSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final (String label, IconData icon, List<Slot> list) in groups)
            if (list.isNotEmpty) ...<Widget>[
              Semantics(
                header: true,
                child: Row(
                  children: <Widget>[
                    Icon(icon, size: 16, color: NColors.brandRosewood),
                    const SizedBox(width: 6),
                    Text(label, style: NType.label.copyWith(color: NColors.inkSecondary, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    Text('${list.length}', style: NType.label.copyWith(color: NColors.inkMuted)),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.xs),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints c) {
                  const double gap = NSpace.xs;
                  final int cols = c.maxWidth >= 420 ? 4 : 3;
                  final double w = ((c.maxWidth - gap * (cols - 1)) / cols).floorToDouble();
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: <Widget>[
                      for (final Slot x in list) _TimeChip(width: w, slot: x, on: x.startsAt == picked, onTap: enabled ? () => onPick(x) : null),
                    ],
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
  const _TimeChip({required this.width, required this.slot, required this.on, required this.onTap});

  final double width;
  final Slot slot;
  final bool on;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Tooltip(
      message: s.csChooseTime(whenText(context, slot.startsAt)),
      child: Semantics(
        button: true,
        enabled: onTap != null,
        selected: on,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(NRadius.md),
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
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(timeText(context, slot.startsAt), style: NType.body.copyWith(color: on ? NColors.inkOnBrand : NColors.inkPrimary, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A page that picks one time and returns it: moving an appointment, or taking another time (spec 014 §6).
class SlotPickerPage extends StatelessWidget {
  const SlotPickerPage({required this.title, required this.loader, super.key, this.note});

  final String title;
  final SlotLoader loader;
  final String? note;

  @override
  Widget build(BuildContext context) => BlocProvider<SlotsCubit>(
        create: (_) => SlotsCubit(loader)..load(),
        child: AreaScaffold(
          title: title,
          body: ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              if (note != null) Text(note!, style: NType.body.copyWith(color: NColors.inkSecondary)),
              SlotPicker(onPick: (Slot x, SlotList _) => Navigator.of(context).pop(x.startsAt)),
            ],
          ),
        ),
      );
}

/// The wellness-only line for the specialist area (spec 010 §9.4, AC51).
class ConsultWellnessNote extends StatelessWidget {
  const ConsultWellnessNote({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: NSpace.sm),
        child: Text(S.of(context).csWellness, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
      );
}
