import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens/tokens.dart';

/// Six boxes drawn over one real text field, so autofill, paste and screen
/// readers work on a single input.
class CodeBoxes extends StatelessWidget {
  const CodeBoxes({required this.controller, required this.focus, required this.label, super.key});

  final TextEditingController controller;
  final FocusNode focus;
  final String label;

  @override
  Widget build(BuildContext context) {
    final String v = controller.text;
    return SizedBox(
      height: NLayout.minTapTarget + NSpace.md,
      child: Stack(
        children: <Widget>[
          ExcludeSemantics(
            child: Row(
              children: <Widget>[
                for (int i = 0; i < 6; i++) ...<Widget>[
                  if (i > 0) const SizedBox(width: NSpace.xs),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: NColors.surfaceCard,
                        borderRadius: BorderRadius.circular(NRadius.md),
                        border: Border.all(
                          color: focus.hasFocus && i == v.length.clamp(0, 5) ? NColors.lineFocus : NColors.lineDefault,
                          width: focus.hasFocus && i == v.length.clamp(0, 5) ? 2 : 1,
                        ),
                      ),
                      child: Text(i < v.length ? v[i] : '', style: NType.h3.copyWith(fontFamily: NType.sansFamily, fontWeight: FontWeight.w600, color: NColors.inkPrimary)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              alwaysIncludeSemantics: true,
              child: TextField(
                controller: controller,
                focusNode: focus,
                autofocus: true,
                keyboardType: TextInputType.number,
                autofillHints: const <String>[AutofillHints.oneTimeCode],
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                showCursor: false,
                enableInteractiveSelection: false,
                decoration: InputDecoration(labelText: label, filled: false, border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
