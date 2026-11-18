import 'package:material_ui/material_ui.dart';

import '../../../design_system/tokens/tokens.dart';
import '../../../l10n/app_localizations.dart';

/// Options for one of today's log fields. Tapping an option saves it and
/// closes the sheet, so a log is two taps from Home (spec 010 §3.3).
Future<void> showQuickLogSheet<T extends Enum>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required String Function(T) label,
  required T? selected,
  required void Function(T) onPick,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: NColors.surfacePage,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(NRadius.xl))),
    builder: (BuildContext sheet) => QuickLogSheet<T>(title: title, options: options, label: label, selected: selected, onPick: onPick),
  );
}

class QuickLogSheet<T extends Enum> extends StatelessWidget {
  const QuickLogSheet({
    required this.title,
    required this.options,
    required this.label,
    required this.selected,
    required this.onPick,
    super.key,
  });

  final String title;
  final List<T> options;
  final String Function(T) label;
  final T? selected;
  final void Function(T) onPick;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(NSpace.lg, 0, NSpace.lg, NSpace.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Semantics(header: true, child: Text(title, style: NType.h3.copyWith(color: NColors.inkPrimary))),
            const SizedBox(height: NSpace.md),
            Wrap(
              spacing: NSpace.xs,
              runSpacing: NSpace.xs,
              children: <Widget>[
                for (final T o in options)
                  Semantics(
                    container: true,
                    checked: o == selected,
                    inMutuallyExclusiveGroup: true,
                    label: label(o),
                    onTap: () => _pick(context, o),
                    child: ExcludeSemantics(
                      child: ChoiceChip(
                        label: Text(label(o)),
                        selected: o == selected,
                        showCheckmark: false,
                        labelStyle: NType.body.copyWith(
                          color: o == selected ? NColors.actionOnPrimary : NColors.inkPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        selectedColor: NColors.actionPrimary,
                        backgroundColor: NColors.surfaceCard,
                        side: const BorderSide(color: NColors.lineDefault),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: NSpace.md, vertical: NSpace.sm),
                        onSelected: (_) => _pick(context, o),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: NSpace.md),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(s.homeClose)),
          ],
        ),
      ),
    );
  }

  void _pick(BuildContext context, T o) {
    onPick(o);
    Navigator.of(context).pop();
  }
}
