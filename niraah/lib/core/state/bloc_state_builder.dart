import 'package:flutter/widgets.dart';

import '../../design_system/widgets/error_view.dart';
import '../../design_system/widgets/loading_view.dart';
import 'status.dart';

class BlocStateBuilder extends StatelessWidget {
  const BlocStateBuilder({
    required this.status,
    required this.successBuilder,
    super.key,
    this.errorMessage,
    this.onRetry,
  });

  final Status status;
  final Widget Function() successBuilder;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case Status.loading:
        return const LoadingView();
      case Status.failure:
        return ErrorView(message: errorMessage ?? 'Something went wrong', onRetry: onRetry);
      case Status.empty:
        return const ErrorView(message: 'No data available');
      case Status.initial:
      case Status.success:
        return successBuilder();
    }
  }
}
