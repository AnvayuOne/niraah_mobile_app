import 'package:material_ui/material_ui.dart';

import '../tokens/tokens.dart';

/// Primary pill button. When it cannot be used yet, pass [inactiveHint]: the
/// button then reads as guidance ("Choose an answer to continue") instead of
/// an error appearing anywhere (constitution §8.5).
class NPrimaryButton extends StatelessWidget {
  const NPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.inactiveHint,
    this.loading = false,
    this.trailingArrow = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? inactiveHint;
  final bool loading;
  final bool trailingArrow;

  @override
  Widget build(BuildContext context) {
    final bool inactive = onPressed == null && !loading;
    final String text = inactive && inactiveHint != null ? inactiveHint! : label;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? Semantics(
                label: label,
                child: const SizedBox.square(
                  dimension: NSpace.lg,
                  child: CircularProgressIndicator(strokeWidth: 2, color: NColors.actionOnDisabled),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(child: Text(text, textAlign: TextAlign.center)),
                  if (trailingArrow && !inactive) ...<Widget>[
                    const SizedBox(width: NSpace.xs),
                    const Icon(Icons.arrow_forward_rounded, size: NSpace.md + NSpace.xxs),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Secondary pill button, outlined on a card surface.
class NSecondaryButton extends StatelessWidget {
  const NSecondaryButton({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(onPressed: onPressed, child: Text(label, textAlign: TextAlign.center)),
    );
  }
}
