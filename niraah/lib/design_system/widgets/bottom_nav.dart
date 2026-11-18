import 'package:material_ui/material_ui.dart';

import '../tokens/tokens.dart';

/// Workspace bottom navigation. By default the member's five places
/// (spec 010, Navigation): Home, Cycle, AI Care, Practice, Me. Provider
/// workspaces pass their own [icons]. Labels come from the caller so they
/// can be translated.
class NBottomNav extends StatelessWidget {
  const NBottomNav({required this.labels, required this.index, required this.onSelected, super.key, this.icons = memberIcons});

  /// One label per icon, in the same order.
  final List<String> labels;
  final int index;
  final ValueChanged<int> onSelected;
  final List<IconData> icons;

  static const List<IconData> memberIcons = <IconData>[
    Icons.home_rounded,
    Icons.radio_button_checked_rounded,
    Icons.chat_bubble_outline_rounded,
    Icons.self_improvement_rounded,
    Icons.person_outline_rounded,
  ];

  /// Doctor workspace: Home, Patients, Queue, Schedule, More.
  static const List<IconData> doctorIcons = <IconData>[
    Icons.home_rounded,
    Icons.groups_outlined,
    Icons.fact_check_outlined,
    Icons.calendar_month_outlined,
    Icons.more_horiz_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    bool sel(Set<WidgetState> s) => s.contains(WidgetState.selected);
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: NColors.surfaceCard,
        indicatorColor: NColors.brandBlushLight,
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) => IconThemeData(color: sel(s) ? NColors.inkPrimary : NColors.inkMuted),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) => NType.label.copyWith(
            color: sel(s) ? NColors.inkPrimary : NColors.inkMuted,
            fontWeight: sel(s) ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onSelected,
        destinations: <Widget>[
          for (int i = 0; i < icons.length; i++) NavigationDestination(icon: Icon(icons[i]), label: labels[i]),
        ],
      ),
    );
  }
}
