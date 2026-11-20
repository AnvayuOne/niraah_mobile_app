import 'package:material_ui/material_ui.dart';

import '../generated/niraah_assets.dart';
import '../tokens/tokens.dart';
import 'n_loaders.dart';

export 'n_loaders.dart' show NLoaderKind;

/// A loading screen. Each area passes its own [kind], so the wait looks like the place she is going:
/// a cycle ring for Cycle, a thali for Meals, speech bubbles for AI Care, a heartbeat for care, and so on.
class LoadingView extends StatelessWidget {
  const LoadingView({required this.label, super.key, this.kind = NLoaderKind.brand});

  /// Announced to screen readers and shown under the picture.
  final String label;
  final NLoaderKind kind;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: label,
        child: ExcludeSemantics(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  NThemedLoader(kind: kind),
                  if (kind == NLoaderKind.brand) Image.asset(NImages.niraahLogo.path, width: 54, height: 54, fit: BoxFit.contain),
                ],
              ),
              const SizedBox(height: NSpace.md),
              NFadingDots(color: NColors.inkMuted, label: label),
            ],
          ),
        ),
      ),
    );
  }
}
