import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens/tokens.dart';

/// Date-of-birth field. Opens the platform date picker; the value is a date
/// only (`yyyy-MM-dd`), never a time.
class DateOfBirthInput extends StatelessWidget {
  const DateOfBirthInput({
    required this.value,
    required this.onChanged,
    required this.placeholder,
    required this.chosenLabel,
    super.key,
    this.today,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String placeholder;
  final String Function(String formatted) chosenLabel;

  /// Injected for tests.
  final DateTime? today;

  Future<void> _pick(BuildContext context) async {
    final DateTime now = today ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) onChanged(DateTime(picked.year, picked.month, picked.day));
  }

  @override
  Widget build(BuildContext context) {
    final String? formatted = value == null ? null : DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(value!);
    return Semantics(
      button: true,
      label: formatted == null ? placeholder : chosenLabel(formatted),
      child: ExcludeSemantics(
        child: InkWell(
          onTap: () => _pick(context),
          borderRadius: BorderRadius.circular(NRadius.lg),
          child: Container(
            constraints: const BoxConstraints(minHeight: NLayout.minTapTarget + NSpace.md),
            padding: const EdgeInsets.symmetric(horizontal: NSpace.md, vertical: NSpace.sm),
            decoration: BoxDecoration(
              color: NColors.surfaceCard,
              borderRadius: BorderRadius.circular(NRadius.lg),
              border: Border.all(color: value == null ? NColors.lineDefault : NColors.actionPrimary, width: value == null ? 1 : 2),
            ),
            child: Row(
              children: <Widget>[
                Icon(Icons.calendar_today_rounded, color: NColors.actionLink),
                const SizedBox(width: NSpace.sm),
                Expanded(
                  child: Text(
                    formatted == null ? placeholder : chosenLabel(formatted),
                    style: NType.body.copyWith(
                      color: formatted == null ? NColors.inkMuted : NColors.inkPrimary,
                      fontWeight: formatted == null ? FontWeight.w400 : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
