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

/// Bookable times, a week at a time, grouped by day in her time zone. Tapping one calls [onPick].
class SlotPicker extends StatelessWidget {
  const SlotPicker({required this.onPick, super.key, this.header});

  final void Function(Slot slot, SlotList list) onPick;

  /// Shown above the times once they are loaded: the fee or "included", or the dedicated fallback.
  final Widget Function(BuildContext context, SlotList list)? header;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<SlotsCubit, SlotsState>(
      builder: (BuildContext context, SlotsState st) {
        final SlotsCubit cubit = context.read<SlotsCubit>();
        final Widget nav = Row(
          children: <Widget>[
            if (cubit.canGoEarlier) TextButton.icon(onPressed: st.holding ? null : cubit.earlier, icon: const Icon(Icons.chevron_left_rounded), label: Text(s.csEarlier)),
            const Spacer(),
            if (cubit.canGoLater) TextButton.icon(onPressed: st.holding ? null : cubit.later, icon: const Icon(Icons.chevron_right_rounded), label: Text(s.csLater)),
          ],
        );
        switch (st.status) {
          case LoadStatus.loading:
            return SizedBox(height: NSpace.xl3 * 2, child: LoadingView(label: s.loading));
          case LoadStatus.failure:
            if (st.error is AreaLocked) return AreaLockedView(refusal: st.error! as AreaLocked);
            return ErrorView(message: failureText(st.error!, s.commonLoadError), retryLabel: s.tryAgain, onRetry: () => cubit.load(st.from));
          case LoadStatus.ready:
            final SlotList list = st.list!;
            final Map<String, List<Slot>> byDay = <String, List<Slot>>{};
            for (final Slot x in list.slots) {
              byDay.putIfAbsent(dayText(context, x.startsAt), () => <Slot>[]).add(x);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (header != null) header!(context, list),
                if (byDay.isEmpty) ...<Widget>[
                  const SizedBox(height: NSpace.sm),
                  EmptyNote(text: s.csNoTimesThisWeek, actionLabel: cubit.canGoLater ? s.csLater : null, onAction: cubit.canGoLater ? cubit.later : null),
                ],
                for (final MapEntry<String, List<Slot>> day in byDay.entries) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: NSpace.md, bottom: NSpace.xs),
                    child: Semantics(header: true, child: Text(day.key, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600))),
                  ),
                  Wrap(
                    spacing: NSpace.xs,
                    runSpacing: NSpace.xs,
                    children: <Widget>[
                      for (final Slot x in day.value)
                        ActionChip(
                          label: Text(timeText(context, x.startsAt)),
                          tooltip: s.csChooseTime(whenText(context, x.startsAt)),
                          onPressed: st.holding ? null : () => onPick(x, list),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: NSpace.sm),
                nav,
              ],
            );
        }
      },
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
