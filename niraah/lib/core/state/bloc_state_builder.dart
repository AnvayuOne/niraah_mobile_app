import 'package:flutter/widgets.dart';

import '../../design_system/widgets/error_view.dart';
import '../../design_system/widgets/loading_view.dart';
import 'status.dart';

/// Builds loading, error, empty and success states. All text is passed in,
/// so it comes from the translatable strings.
class BlocStateBuilder extends StatelessWidget {
  const BlocStateBuilder({
    required this.status,
    required this.successBuilder,
    required this.loadingLabel,
    required this.errorMessage,
    required this.emptyMessage,
    super.key,
    this.onRetry,
    this.retryLabel,
  });

  final Status status;
  final Widget Function() successBuilder;
  final String loadingLabel;
  final String errorMessage;
  final String emptyMessage;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case Status.loading:
        return LoadingView(label: loadingLabel);
      case Status.failure:
        return ErrorView(message: errorMessage, onRetry: onRetry, retryLabel: retryLabel);
      case Status.empty:
        return ErrorView(message: emptyMessage);
      case Status.initial:
      case Status.success:
        return successBuilder();
    }
  }
}
