import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors/api_exception.dart';
import '../../design_system/generated/niraah_assets.dart';
import '../../design_system/tokens/tokens.dart';
import '../../design_system/widgets/error_view.dart';
import '../../design_system/widgets/n_button.dart';
import '../../design_system/widgets/n_illustration.dart';
import '../../design_system/widgets/n_shimmer.dart';
import '../../l10n/app_localizations.dart';
import '../constants/route_constants.dart';
import 'area_access.dart';

/// A plain card on the page surface, used across the member areas.
class NCard extends StatelessWidget {
  NCard({required this.child, super.key, Color? color, this.onTap, this.semanticsLabel}) : color = color ?? NColors.surfaceCard;

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
  const EmptyNote({required this.text, super.key, this.actionLabel, this.onAction, this.picture});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// A soft picture for an empty area (design audit 2026-11-26): the page then reads as calm, not unfinished.
  final NImageAsset? picture;

  @override
  Widget build(BuildContext context) {
    final bool action = actionLabel != null && onAction != null;
    if (picture == null) {
      return NCard(
        color: NColors.surfaceWarm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(text, style: NType.body.copyWith(color: NColors.inkSecondary)),
            if (action) ...<Widget>[const SizedBox(height: NSpace.sm), TextButton(onPressed: onAction, child: Text(actionLabel!))],
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, NSpace.lg, NSpace.lg),
      decoration: BoxDecoration(
        color: NColors.surfaceCard,
        borderRadius: BorderRadius.circular(NRadius.lg),
        border: Border.all(color: NColors.lineDefault.withValues(alpha: 0.6)),
        boxShadow: NShadow.xs,
      ),
      child: Column(
        children: <Widget>[
          NIllustration(asset: picture!, height: 120, entrance: NEntrance.breathe),
          const SizedBox(height: NSpace.sm),
          Text(text, textAlign: TextAlign.center, style: NType.body.copyWith(color: NColors.inkSecondary)),
          if (action) ...<Widget>[
            const SizedBox(height: NSpace.md),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(minimumSize: const Size(0, NLayout.minTapTarget), shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: NSpace.lg)),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pictures for empty areas, shared with the website.
abstract final class EmptyArt {
  static const NImageAsset carePlans = NImageAsset('assets/images/empty_care_plans.webp', width: 280, height: 323, semanticLabel: null);
  static const NImageAsset messages = NImageAsset('assets/images/empty_messages.webp', width: 280, height: 176, semanticLabel: null);
  static const NImageAsset labs = NImageAsset('assets/images/empty_labs.webp', width: 280, height: 247, semanticLabel: null);
  static const NImageAsset library = NImageAsset('assets/images/empty_library.webp', width: 280, height: 168, semanticLabel: null);
  static const NImageAsset classes = NImageAsset('assets/images/empty_classes.webp', width: 280, height: 163, semanticLabel: null);
  static const NImageAsset circles = NImageAsset('assets/images/empty_students.webp', width: 280, height: 259, semanticLabel: null);
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
        Icon(Icons.lock_outline_rounded, color: NColors.inkMuted, size: NSpace.xl),
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
          // The server this build talks to does not have this area yet (404): say so calmly, not "couldn't load".
          if (e is ApiException && e.statusCode == 404) {
            return ListView(padding: const EdgeInsets.all(NSpace.lg), children: <Widget>[EmptyNote(text: '${s.comingSoonTitle}. ${s.comingSoonBody}')]);
          }
          return ErrorView(message: s.commonLoadError, retryLabel: s.tryAgain, onRetry: onRetry);
        }
        if (snap.connectionState != ConnectionState.done) return NPagePlaceholder(label: s.loading);
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
  Widget build(BuildContext context) {
    final bool canPop = Navigator.of(context).canPop() || GoRouter.maybeOf(context)?.canPop() == true;
    return Scaffold(
      backgroundColor: NColors.surfacePage,
      appBar: AppBar(
        backgroundColor: NColors.surfacePage,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        toolbarHeight: 68,
        titleSpacing: canPop ? 4 : NSpace.lg,
        automaticallyImplyLeading: false,
        leading: canPop
            ? Padding(
                padding: const EdgeInsets.only(left: NSpace.sm),
                child: Center(
                  child: IconButton(
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: IconButton.styleFrom(backgroundColor: NColors.surfaceCard, side: BorderSide(color: NColors.lineDefault)),
                    icon: Icon(Icons.arrow_back_rounded, color: NColors.inkPrimary),
                  ),
                ),
              )
            : null,
        leadingWidth: canPop ? 64 : null,
        title: Text(title, style: NType.screenTitle.copyWith(color: NColors.inkPrimary)),
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      body: SafeArea(top: false, child: body),
    );
  }
}

/// Shows a quiet confirmation or the server's words after an action.
void showNote(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

/// "Sun, Nov 15" from an ISO date or time, in her locale; with the year ("Nov 15, 2025") when it is not this
/// year, so an old lab report or consent is never mistaken for a recent one.
String shortDate(BuildContext context, String iso) {
  final DateTime? parsed = DateTime.tryParse(iso);
  if (parsed == null) return iso;
  final DateTime d = parsed.toLocal();
  if (d.year == DateTime.now().year) return MaterialLocalizations.of(context).formatMediumDate(d);
  return DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(d);
}
