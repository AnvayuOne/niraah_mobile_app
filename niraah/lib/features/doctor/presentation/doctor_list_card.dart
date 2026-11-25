import 'package:material_ui/material_ui.dart';

import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/clinician_ui.dart';

/// A clinician list row: initials avatar, name, a line of context, a quiet meta line and status pills. An optional
/// [accent] draws a severity strip on the leading edge.
class DrListCard extends StatelessWidget {
  const DrListCard({required this.name, super.key, this.subtitle, this.meta, this.pills = const <Widget>[], this.onTap, this.semanticsLabel, this.accent, this.leading, this.trailing, this.tint});

  final String name;
  final String? subtitle;
  final String? meta;
  final List<Widget> pills;
  final VoidCallback? onTap;
  final String? semanticsLabel;
  final Color? accent;
  final Widget? leading;
  final Widget? trailing;
  final Color? tint;

  @override
  Widget build(BuildContext context) => Semantics(
        button: onTap != null,
        label: semanticsLabel,
        child: Material(
          color: tint ?? NColors.surfaceCard,
          borderRadius: BorderRadius.circular(NRadius.lg),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(NRadius.lg),
                border: Border.all(color: accent?.withValues(alpha: 0.35) ?? NColors.lineDefault),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (accent != null) Container(width: 4, color: accent),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(NSpace.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            leading ?? CAvatar(name: name, size: 40),
                            const SizedBox(width: NSpace.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w700)),
                                  if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
                                    const SizedBox(height: 2),
                                    Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                                  ],
                                  if (meta != null && meta!.isNotEmpty) ...<Widget>[
                                    const SizedBox(height: 2),
                                    Text(meta!, style: NType.caption.copyWith(color: NColors.inkMuted, letterSpacing: 0)),
                                  ],
                                  if (pills.isNotEmpty) ...<Widget>[
                                    const SizedBox(height: NSpace.xs),
                                    Wrap(spacing: 6, runSpacing: 6, children: pills),
                                  ],
                                ],
                              ),
                            ),
                            if (trailing != null) ...<Widget>[const SizedBox(width: NSpace.xs), trailing!],
                            if (onTap != null) Padding(padding: EdgeInsets.only(top: 8), child: Icon(Icons.chevron_right_rounded, color: NColors.inkMuted)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

/// A staggered vertical list of cards.
class DrStagger extends StatelessWidget {
  const DrStagger({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < children.length; i++)
            CEntrance(delayMs: 50 * (i < 8 ? i : 8), child: Padding(padding: const EdgeInsets.only(bottom: NSpace.xs), child: children[i])),
        ],
      );
}

/// A bottom action bar that stays put while the content scrolls.
class DrStickyBar extends StatelessWidget {
  const DrStickyBar({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(NSpace.md, NSpace.sm, NSpace.md, NSpace.sm),
        decoration: BoxDecoration(
          color: NColors.surfaceCard,
          border: Border(top: BorderSide(color: NColors.lineDefault)),
          boxShadow: <BoxShadow>[BoxShadow(color: NColors.brandPlum.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: SafeArea(top: false, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: children)),
      );
}

/// A soft labelled box inside a panel (the AI's text, her version, a note).
class DrTextBox extends StatelessWidget {
  DrTextBox({required this.label, required this.text, super.key, Color? color, Color? labelColor, this.icon, Color? textColor}) : color = color ?? NColors.surfacePage, labelColor = labelColor ?? NColors.inkMuted, textColor = textColor ?? NColors.inkPrimary;

  final String label;
  final String text;
  final Color color;
  final Color labelColor;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(NSpace.sm),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(NRadius.md)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (icon != null) ...<Widget>[Icon(icon, size: 14, color: labelColor), const SizedBox(width: 4)],
                Flexible(child: Text(label.toUpperCase(), style: NType.label.copyWith(color: labelColor, letterSpacing: 1, fontWeight: FontWeight.w700))),
              ],
            ),
            const SizedBox(height: 4),
            Text(text, style: NType.body.copyWith(color: textColor)),
          ],
        ),
      );
}
