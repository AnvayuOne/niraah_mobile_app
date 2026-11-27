import 'package:flutter/widgets.dart';

import '../tokens/tokens.dart';

/// Motion rules from constitution §8.4: slow and soft, 220 to 760 ms,
/// ease-out, and nothing moves when the device asks for reduced motion.
abstract final class NMotionRules {
  /// True when the platform asks for reduced motion.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// The duration to use: zero when motion is reduced.
  static Duration duration(BuildContext context, Duration d) =>
      reduced(context) ? Duration.zero : d;

  static const Curve curve = NMotion.easeOut;
}
