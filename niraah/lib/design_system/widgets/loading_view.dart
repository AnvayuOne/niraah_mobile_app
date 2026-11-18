import 'package:material_ui/material_ui.dart';

import '../tokens/tokens.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({required this.label, super.key});

  /// Announced to screen readers.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: label,
        child: const CircularProgressIndicator(color: NColors.actionPrimary),
      ),
    );
  }
}
