import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../design_system/tokens/tokens.dart';
import '../../design_system/widgets/error_view.dart';
import '../../design_system/widgets/loading_view.dart';
import '../../design_system/widgets/n_button.dart';
import '../../l10n/app_localizations.dart';
import '../constants/route_constants.dart';
import 'area_access.dart';

/// A plain card on the page surface, used across the member areas.
class NCard extends StatelessWidget {
  const NCard({required this.child, super.key, this.color = NColors.surfaceCard, this.onTap, this.semanticsLabel});

  final Widget child;
  final Color color;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final Widget box = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(NSpace.lg),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(NRadius.xl), border: Border.all(color: NColors.lineDefault), boxShadow: NShadow.xs),
      // Switches and checkbox rows inside a card draw their ink on the card, not under it.
      child: Material(type: MaterialType.transparency, child: child),
    );
    if (onTap == null) return box;
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(NRadius.xl), onTap: onTap, child: box)),
    );
  }
}

/// A section heading, announced as a header.
class NSectionTitle extends StatelessWidget {
  const NSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: NSpace.lg, bottom: NSpace.sm),
        child: Semantics(header: true, child: Text(text, style: NType.h4.copyWith(color: NColors.inkPrimary))),
      );
}

/// A short, kind line saying what will appear here, with one action that fills it (spec 010 "States" 2).
class EmptyNote extends StatelessWidget {
  const EmptyNote({required this.text, super.key, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => NCard(
        color: NColors.surfaceWarm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(text, style: NType.body.copyWith(color: NColors.inkSecondary)),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: NSpace.sm),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      );
}

/// "Not on your plan" or "starts after the trial" (spec 010 "Limits and plans"): what the area is, which
/// plans include it, and "See plans". No disabled controls, no blurred content.
class AreaLockedView extends StatelessWidget {
  const AreaLockedView({required this.refusal, super.key});

  final AreaLocked refusal;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return ListView(
      padding: const EdgeInsets.all(NSpace.lg),
      children: <Widget>[
        const Icon(Icons.lock_outline_rounded, color: NColors.inkMuted, size: NSpace.xl),
        const SizedBox(height: NSpace.sm),
        Semantics(header: true, child: Text(refusal.message, style: NType.h3.copyWith(color: NColors.inkPrimary))),
        if (refusal.description != null) ...<Widget>[
          const SizedBox(height: NSpace.sm),
          Text(refusal.description!, style: NType.body.copyWith(color: NColors.inkSecondary)),
        ],
        if (refusal.afterTrial && refusal.startsOn != null) ...<Widget>[
          const SizedBox(height: NSpace.sm),
          Text(s.areaStartsOn(refusal.startsOn!), style: NType.body.copyWith(color: NColors.inkSecondary)),
        ],
        if (refusal.locked && refusal.plans.isNotEmpty) ...<Widget>[
          const SizedBox(height: NSpace.md),
          Text(s.areaIncludedIn(refusal.plans.join(', ')), style: NType.body.copyWith(color: NColors.inkPrimary)),
        ],
        if (refusal.locked) ...<Widget>[
          const SizedBox(height: NSpace.lg),
          NPrimaryButton(label: s.areaSeePlans, onPressed: () => context.push(RouteConstants.plans)),
        ],
      ],
    );
  }
}

/// Loads [future] and shows a calm loading state, the area refusal, an error with "Try again", or the content.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({required this.future, required this.builder, required this.onRetry, super.key});

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return FutureBuilder<T>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<T> snap) {
        if (snap.hasError) {
          final Object e = snap.error!;
          if (e is AreaLocked) return AreaLockedView(refusal: e);
          return ErrorView(message: s.commonLoadError, retryLabel: s.tryAgain, onRetry: onRetry);
        }
        if (snap.connectionState != ConnectionState.done) return LoadingView(label: s.loading);
        return builder(context, snap.data as T);
      },
    );
  }
}

/// A plain page with a title bar and back button, for the areas reached from Me.
class AreaScaffold extends StatelessWidget {
  const AreaScaffold({required this.title, required this.body, super.key, this.floatingActionButton, this.actions});

  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NColors.surfacePage,
        appBar: AppBar(title: Text(title), backgroundColor: NColors.surfacePage, actions: actions),
        floatingActionButton: floatingActionButton,
        body: SafeArea(child: body),
      );
}

/// Shows a quiet confirmation or the server's words after an action.
void showNote(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

/// "15 Nov 2026" from an ISO date or time, in her locale.
String shortDate(BuildContext context, String iso) {
  final DateTime? d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return MaterialLocalizations.of(context).formatMediumDate(d.toLocal());
}
