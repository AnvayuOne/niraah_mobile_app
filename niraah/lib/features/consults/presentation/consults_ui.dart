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
class SpecialistAvatar extends StatelessWidget {
  const SpecialistAvatar({required this.type, super.key, this.size = 64});

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
        colors: type == ProviderType.dietitian
            ? <Color>[NColors.brandApricotLight, NColors.brandSageLight]
            : <Color>[NColors.brandBlushLight, NColors.brandLavenderLight],
      ),
      border: Border.all(color: NColors.surfaceCard, width: 3),
      boxShadow: NShadow.sm,
    ),
    clipBehavior: Clip.antiAlias,
    padding: EdgeInsets.only(top: size * 0.08),
    child: NIllustration(asset: type == ProviderType.dietitian ? ConsultArt.dietitian : ConsultArt.doctor, height: size),
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
              Text(title, style: NType.h2.copyWith(color: NColors.inkPrimary)),
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
