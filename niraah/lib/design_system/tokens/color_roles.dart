import 'dart:ui';

import 'tokens.dart';

/// Maps colour token names used in content (answer palette, plan palette,
/// band colours) to token colours. Admins pick names, never hex values.
abstract final class NColorRoles {
  static Color answer(String? token) => switch (token) {
        'blush' => NColors.answerBlush,
        'peach' => NColors.answerPeach,
        'apricot' => NColors.answerApricot,
        'mint' => NColors.answerMint,
        'sage' => NColors.answerSage,
        'lavender' => NColors.answerLavender,
        _ => NColors.surfaceCard,
      };

  static Color plan(String? token) => switch (token) {
        'tier1' => NColors.planTier1,
        'tier0' => NColors.planTier0,
        'tier2' => NColors.planTier2,
        'tier3' => NColors.planTier3,
        _ => NColors.surfaceCard,
      };

  /// Text colour that meets AA on [plan] (checked by the token build).
  static Color onPlan(String? token) => token == 'tier3' ? NColors.inkOnBrand : NColors.inkPrimary;
}
