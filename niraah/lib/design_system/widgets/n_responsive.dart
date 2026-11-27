import 'package:material_ui/material_ui.dart';

import '../tokens/tokens.dart';
import 'n_living.dart';

/// Screen classes used across the app.
enum NScreen { compact, medium, expanded }

extension NScreenOf on BuildContext {
  NScreen get screen {
    final double w = MediaQuery.sizeOf(this).width;
    return w < 600 ? NScreen.compact : (w < 1024 ? NScreen.medium : NScreen.expanded);
  }
}

/// Keeps every in-app screen at a comfortable app width on any device.
///
/// Phones (narrower than [maxWidth]) are untouched. On foldables, tablets,
/// landscape phones and desktop browsers the app sits in a centered column
/// [maxWidth] wide over the soft brand backdrop, and the column reports its
/// own size through MediaQuery, so every page lays out exactly as it was
/// designed for a phone. Pages with their own wide layout (the public
/// landing page) pass [enabled] false.
///
/// It also bounds text scaling to [minTextScale]..[maxTextScale] so very
/// large system font sizes stay readable without breaking layouts.
class NResponsiveFrame extends StatelessWidget {
  const NResponsiveFrame({
    required this.child,
    super.key,
    this.enabled = true,
    this.maxWidth = 640,
    this.minTextScale = 0.9,
    this.maxTextScale = 1.3,
  });

  final Widget child;
  final bool enabled;
  final double maxWidth;
  final double minTextScale, maxTextScale;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mq = MediaQuery.of(context);
    final MediaQueryData scaled = mq.copyWith(
      textScaler: mq.textScaler.clamp(minScaleFactor: minTextScale, maxScaleFactor: maxTextScale),
    );
    if (!enabled || mq.size.width <= maxWidth) return MediaQuery(data: scaled, child: child);

    final bool tall = mq.size.height >= 720 && mq.size.width >= 1024;
    // On large screens the column floats as a card with a little air above and below.
    final double vGap = tall ? NSpace.lg : 0;
    final double height = mq.size.height - vGap * 2;
    final MediaQueryData inner = scaled.copyWith(
      size: Size(maxWidth, height),
      padding: tall ? EdgeInsets.zero : mq.padding,
      viewPadding: tall ? EdgeInsets.zero : mq.viewPadding,
    );
    return NBackdrop(
      base: NColors.surfaceBackdrop,
      child: Center(
        child: Container(
          width: maxWidth,
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: NColors.surfacePage,
            borderRadius: BorderRadius.circular(tall ? NRadius.xl : 0),
            boxShadow: NShadow.lg,
          ),
          child: MediaQuery(data: inner, child: child),
        ),
      ),
    );
  }
}

/// A fixed header (search, filters) above a scrolling list. When the screen is
/// too short for both (a phone in landscape, large text), the header scrolls
/// away with the page instead of overflowing, and the list keeps the full
/// height below it.
class NHeaderedList extends StatelessWidget {
  const NHeaderedList({required this.header, required this.body, super.key, this.minBodyHeight = 260});

  final Widget header;
  final Widget body;
  final double minBodyHeight;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints c) {
      if (c.maxHeight >= minBodyHeight * 1.6) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            header,
            Expanded(child: body),
          ],
        );
      }
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            header,
            SizedBox(height: c.maxHeight, child: body),
          ],
        ),
      );
    },
  );
}
