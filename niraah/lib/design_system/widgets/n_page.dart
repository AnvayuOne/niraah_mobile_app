import 'package:material_ui/material_ui.dart';

import '../tokens/tokens.dart';
import 'n_living.dart';

/// Page frame: safe area, side gutters, content width capped for tablets,
/// scrolling body and an optional pinned footer for the main action.
class NPage extends StatelessWidget {
  const NPage({required this.body, super.key, this.footer, this.onBack, this.backLabel, this.background, this.decor = false});

  final Widget body;
  final Widget? footer;
  final VoidCallback? onBack;
  final String? backLabel;
  final Color? background;

  /// Adds the soft brand washes behind the page (onboarding, sign-in).
  final bool decor;

  @override
  Widget build(BuildContext context) {
    final Color base = background ?? NColors.surfacePage;
    final Widget content = SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: NLayout.breakpointTablet - NSpace.xl3 * 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (onBack != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(NSpace.xs, NSpace.xs, NSpace.md, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: backLabel,
                        onPressed: onBack,
                        style: IconButton.styleFrom(backgroundColor: NColors.surfaceCard),
                        icon: Icon(Icons.arrow_back_rounded, color: NColors.inkPrimary),
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.md, NSpace.lg, NSpace.lg),
                    child: body,
                  ),
                ),
                if (footer != null) Padding(padding: const EdgeInsets.fromLTRB(NSpace.lg, 0, NSpace.lg, NSpace.lg), child: footer),
              ],
            ),
          ),
        ),
      );
    return Scaffold(backgroundColor: base, body: decor ? NBackdrop(base: base, child: content) : content);
  }
}
