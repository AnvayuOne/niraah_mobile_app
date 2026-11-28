import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../design_system/generated/niraah_assets.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/n_illustration.dart';
import '../domain/consults.dart';

/// Pictures for booking, shared with the website ("Soft blush clinic").
abstract final class ConsultArt {
  static const NImageAsset doctor = NImageAsset('assets/images/specialist_doctor_f.webp', width: 240, height: 240, semanticLabel: null);
  static const NImageAsset dietitian = NImageAsset('assets/images/specialist_dietitian_f.webp', width: 240, height: 242, semanticLabel: null);
  static const NImageAsset empty = NImageAsset('assets/images/empty_consults.webp', width: 280, height: 190, semanticLabel: null);
  static const NImageAsset verified = NImageAsset('assets/images/doctor_verified.webp', width: 420, height: 414, semanticLabel: null);
}

/// The specialist's illustrated portrait in a soft round frame.
class IllustratedAvatar extends StatelessWidget {
  const IllustratedAvatar({required this.type, super.key, this.size = 64});

  final ProviderType? type;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: type == 'dietitian'
            ? <Color>[NColors.brandApricotLight, NColors.brandSageLight]
            : <Color>[NColors.brandBlushLight, NColors.brandLavenderLight],
      ),
      border: Border.all(color: NColors.surfaceCard, width: 3),
      boxShadow: NShadow.sm,
    ),
    clipBehavior: Clip.antiAlias,
    padding: EdgeInsets.only(top: size * 0.08),
    child: NIllustration(asset: type == 'dietitian' ? ConsultArt.dietitian : ConsultArt.doctor, height: size),
  );
}

/// A small rounded label: fee, speciality, status.
class SoftPill extends StatelessWidget {
  const SoftPill({required this.text, super.key, this.background, this.foreground, this.icon, this.strong = false});

  final String text;
  final Color? background;
  final Color? foreground;
  final IconData? icon;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final Color fg = foreground ?? NColors.inkSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: NSpace.sm - 2, vertical: 5),
      decoration: BoxDecoration(color: background ?? NColors.surfaceWarm, borderRadius: BorderRadius.circular(NRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NType.label.copyWith(color: fg, fontWeight: strong ? FontWeight.w700 : FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// A white rounded card with a gentle shadow.
class SoftCard extends StatelessWidget {
  const SoftCard({required this.child, super.key, this.padding = const EdgeInsets.all(NSpace.md), this.color, this.onTap, this.border});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    final BorderRadius r = BorderRadius.circular(NRadius.lg);
    return Material(
      color: color ?? NColors.surfaceCard,
      borderRadius: r,
      shadowColor: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: r,
          boxShadow: NShadow.sm,
          border: Border.all(color: border ?? NColors.lineDefault.withValues(alpha: 0.6)),
        ),
        child: InkWell(
          borderRadius: r,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// The blush band at the top of a booking screen: eyebrow, title in Cormorant, a line, and a picture.
class BlushHeader extends StatelessWidget {
  const BlushHeader({required this.title, super.key, this.eyebrow, this.subtitle, this.art, this.trailing});

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final NImageAsset? art;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(NRadius.xl),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[NColors.brandBlushLight, NColors.surfacePage, NColors.brandLavenderLight],
      ),
      border: Border.all(color: NColors.brandBlushLight),
      boxShadow: NShadow.sm,
    ),
    clipBehavior: Clip.antiAlias,
    child: Stack(
      children: <Widget>[
        if (art != null) Positioned(right: -4, bottom: -6, child: NIllustration(asset: art!, height: 112)),
        Padding(
          padding: EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, art != null ? 112 : NSpace.lg, NSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (eyebrow != null) Text(eyebrow!.toUpperCase(), style: NType.caption.copyWith(color: NColors.brandRosewood, letterSpacing: 2)),
              if (eyebrow != null) const SizedBox(height: NSpace.xxs),
              // A one-word title ("Appointments") shrinks to fit rather than breaking mid-word beside the picture.
              if (title.contains(' '))
                Text(title, style: NType.h2.copyWith(color: NColors.inkPrimary))
              else
                FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(title, maxLines: 1, style: NType.h2.copyWith(color: NColors.inkPrimary))),
              if (subtitle != null) ...<Widget>[const SizedBox(height: NSpace.xs), Text(subtitle!, style: NType.bodySm.copyWith(color: NColors.inkSecondary))],
              if (trailing != null) ...<Widget>[const SizedBox(height: NSpace.md), trailing!],
            ],
          ),
        ),
      ],
    ),
  );
}

/// A round back button that sits on the page, used at the top of the booking screens.
class RoundBack extends StatelessWidget {
  const RoundBack({required this.onPressed, super.key, this.label = 'Back'});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: IconButton(
      tooltip: label,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: NColors.surfaceCard,
        side: BorderSide(color: NColors.lineDefault),
      ),
      icon: Icon(Icons.arrow_back_rounded, color: NColors.inkPrimary),
    ),
  );
}

/// "Wed 26 Nov" / "Today" / "Tomorrow".
String dayLabel(DateTime d, {bool relative = true}) {
  final DateTime now = DateTime.now();
  final DateTime a = DateTime(d.year, d.month, d.day);
  final DateTime b = DateTime(now.year, now.month, now.day);
  final int diff = a.difference(b).inDays;
  if (relative && diff == 0) return 'Today';
  if (relative && diff == 1) return 'Tomorrow';
  return DateFormat('EEE d MMM').format(d);
}

/// "10:30 am".
String timeLabel(DateTime d) => DateFormat('h:mm a').format(d).toLowerCase();

/// "Wed 26 Nov, 10:30 am".
String whenLabel(DateTime d) => '${dayLabel(d)}, ${timeLabel(d)}';

/// Short labels the "Soft blush clinic" booking screens show beside the translated copy. They are presentation-only
/// (no l10n keys were added in this restyle; brain.md §7w), and every action or message still comes from l10n.
abstract final class ConsultLabels {
  static const String videoConsult = 'Video consult';
  static const String book = 'Book';
  static const String full = 'Full';
  static String free(int n) => n == 0 ? full : '$n free';
}

/// A date tile: month, day number, weekday. Blush for consults, sage for live classes, warm when it is in the past.
class DateTile extends StatelessWidget {
  const DateTile({required this.date, super.key, this.background, this.accent, this.muted = false, this.width = 60});

  final DateTime date;
  final Color? background;
  final Color? accent;
  final bool muted;
  final double width;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final DateTime d = date.toLocal();
    return ExcludeSemantics(
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: NSpace.xs),
        decoration: BoxDecoration(
          color: muted ? NColors.surfaceWarm : (background ?? NColors.brandBlushLight),
          borderRadius: BorderRadius.circular(NRadius.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(DateFormat('MMM', locale).format(d).toUpperCase(), style: NType.caption.copyWith(color: muted ? NColors.inkMuted : (accent ?? NColors.brandRosewood), letterSpacing: 1)),
            Text('${d.day}', style: NType.h3.copyWith(fontFamily: NType.sansFamily, fontWeight: FontWeight.w700, fontSize: 24, color: muted ? NColors.inkSecondary : NColors.inkPrimary, height: 1.15)),
            Text(DateFormat('EEE', locale).format(d), style: NType.label.copyWith(color: NColors.inkMuted)),
          ],
        ),
      ),
    );
  }
}

/// One line of a summary card: a soft icon square and text.
class InfoLine extends StatelessWidget {
  const InfoLine({required this.icon, required this.text, super.key, this.strong = false});

  final IconData icon;
  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: <Widget>[
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: NColors.brandBlushLight, borderRadius: BorderRadius.circular(NRadius.sm)),
          child: Icon(icon, size: 17, color: NColors.brandRosewood),
        ),
        const SizedBox(width: NSpace.sm),
        Expanded(child: Text(text, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: strong ? FontWeight.w700 : FontWeight.w500))),
      ],
    ),
  );
}

/// A soft note with an icon: fallbacks, "no times", hold ended.
class SoftNotice extends StatelessWidget {
  const SoftNotice({required this.child, super.key, this.icon = Icons.info_outline_rounded, this.color});

  final Widget child;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(NSpace.md),
    decoration: BoxDecoration(color: color ?? NColors.surfaceWarm, borderRadius: BorderRadius.circular(NRadius.md)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 18, color: NColors.inkMuted),
        const SizedBox(width: NSpace.xs),
        Expanded(child: child),
      ],
    ),
  );
}

/// A section heading in the booking screens, with an optional line under it and something on the right.
class SoftSectionTitle extends StatelessWidget {
  const SoftSectionTitle(this.title, {super.key, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: NSpace.lg, bottom: NSpace.xs),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(child: Semantics(header: true, child: Text(title, style: NType.h4.copyWith(color: NColors.inkPrimary)))),
            ?trailing,
          ],
        ),
        if (subtitle != null) ...<Widget>[const SizedBox(height: 2), Text(subtitle!, style: NType.bodySm.copyWith(color: NColors.inkSecondary))],
      ],
    ),
  );
}

/// The status pill colours for an appointment state.
(Color, Color) statusColors(String status) => switch (status) {
  'confirmed' || 'in_progress' => (NColors.statusSuccessLight, NColors.statusSuccess),
  'held' => (NColors.statusWarningLight, NColors.statusWarningText),
  'completed' => (NColors.brandLavenderLight, NColors.brandPlum),
  _ => (NColors.surfaceWarm, NColors.inkMuted),
};
