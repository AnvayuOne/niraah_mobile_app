import 'package:material_ui/material_ui.dart';

import '../tokens/tokens.dart';

/// A calm message when something could not load. Never alarm red.
class ErrorView extends StatelessWidget {
  const ErrorView({required this.message, super.key, this.onRetry, this.retryLabel});

  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.cloud_off_rounded, size: NSpace.xl, color: NColors.inkMuted),
            const SizedBox(height: NSpace.sm),
            Text(message, textAlign: TextAlign.center, style: NType.body.copyWith(color: NColors.inkSecondary)),
            if (onRetry != null && retryLabel != null) ...<Widget>[
              const SizedBox(height: NSpace.sm),
              OutlinedButton(onPressed: onRetry, child: Text(retryLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
