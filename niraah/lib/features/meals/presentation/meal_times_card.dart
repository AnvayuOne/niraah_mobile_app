import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/errors/api_exception.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../domain/meals.dart';

/// Her meal times under "Meal times" in notification settings (spec 010 §6b rule 2, §13; AC69): each meal with its
/// time in her time zone and its own switch. A reminder goes only for meals her plan has that day.
class MealTimesCard extends StatefulWidget {
  const MealTimesCard({super.key, this.repository});

  final MealsRepository? repository;

  @override
  State<MealTimesCard> createState() => _MealTimesCardState();
}

class _MealTimesCardState extends State<MealTimesCard> {
  late final MealsRepository _repo = widget.repository ?? getIt<MealsRepository>();
  late Future<MealTimes> _times = _repo.mealTimes();
  bool _busy = false;

  Future<void> _change(String slot, {String? time, bool? enabled}) async {
    setState(() => _busy = true);
    try {
      final MealTimes t = await _repo.setMealTime(slot, time: time, enabled: enabled);
      if (mounted) setState(() => _times = Future<MealTimes>.value(t));
    } on Object catch (e) {
      if (mounted) showNote(context, failureText(e, S.of(context).commonLoadError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickTime(MealTime m) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(m.time.substring(0, 2)), minute: int.parse(m.time.substring(3, 5))),
    );
    if (picked == null || !mounted) return;
    String two(int v) => v.toString().padLeft(2, '0');
    await _change(m.slot, time: '${two(picked.hour)}:${two(picked.minute)}');
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return FutureBuilder<MealTimes>(
      future: _times,
      builder: (BuildContext context, AsyncSnapshot<MealTimes> snap) {
        // Not on this server yet (404): leave the card out rather than show an error on Meals.
        if (snap.error case ApiException(statusCode: 404)) return const SizedBox.shrink();
        if (snap.hasError) return Text(s.commonLoadError, style: NType.bodySm.copyWith(color: NColors.inkSecondary));
        if (snap.connectionState != ConnectionState.done) return const LinearProgressIndicator();
        final MealTimes t = snap.data!;
        return NCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(s.mealTimesTitle, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
              Text(t.hasPlan ? s.mealTimesNote : s.mealTimesNoPlan, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
              for (final MealTime m in t.slots)
                Row(
                  key: ValueKey<String>('meal-time-${m.slot}'),
                  children: <Widget>[
                    Expanded(child: Text(m.name, style: NType.bodySm.copyWith(color: NColors.inkPrimary))),
                    TextButton(
                      onPressed: _busy ? null : () => _pickTime(m),
                      child: Text(m.time, semanticsLabel: s.mealTimesChange(m.name, m.time)),
                    ),
                    Switch(
                      value: m.enabled,
                      onChanged: _busy ? null : (bool on) => _change(m.slot, enabled: on),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
