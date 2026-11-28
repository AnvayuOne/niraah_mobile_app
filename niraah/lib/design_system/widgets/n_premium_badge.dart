import 'package:material_ui/material_ui.dart';

import '../tokens/tokens.dart';

/// A small gold-toned "Premium" pill for premium features.
class NPremiumBadge extends StatelessWidget {
  const NPremiumBadge({super.key, this.label = 'Premium'});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: 3),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: <Color>[Color(0xFFE9B872), Color(0xFFC9895A)]),
      borderRadius: BorderRadius.circular(NRadius.pill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.workspace_premium_rounded, size: 14, color: Colors.white),
        const SizedBox(width: 4),
        Text(
          label,
          style: NType.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ],
    ),
  );
}
