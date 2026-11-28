// GENERATED from design/tokens.json by design/scripts/build-tokens.mjs. Do not edit; run `pnpm tokens`.
// ignore_for_file: constant_identifier_names

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

abstract final class NColors {
  static const brandBlush = Color(0xFFE4B6B9);
  static const brandLavender = Color(0xFFCFC7E6);
  static const brandApricot = Color(0xFFF2C6A6);
  static const brandSage = Color(0xFFC4D4C3);
  static const brandPlum = Color(0xFF261C21);
  static const brandTerracotta = Color(0xFF93564C);
  static const brandRosewood = Color(0xFF87545B);
  static const brandBlushLight = Color(0xFFF5E6E8);
  static const brandLavenderLight = Color(0xFFECEAF4);
  static const brandApricotLight = Color(0xFFF8ECE1);
  static const brandSageLight = Color(0xFFEAEFE9);
  static const actionPrimary = Color(0xFF261C21);
  static const actionPrimaryHover = Color(0xFF3A2B32);
  static const actionPrimaryPressed = Color(0xFF120D10);
  static const actionOnPrimary = Color(0xFFFFFFFF);
  static const actionLink = Color(0xFF93564C);
  static const actionDisabled = Color(0xFFECE6DF);
  static const actionOnDisabled = Color(0xFF6D5E63);
  static const inkPrimary = Color(0xFF251C20);
  static const inkSecondary = Color(0xFF4A3C41);
  static const inkMuted = Color(0xFF6D5E63);
  static const inkOnBrand = Color(0xFFFFFFFF);
  static const surfacePage = Color(0xFFFAF8F5);
  static const surfaceBackdrop = Color(0xFFEFECE6);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const surfaceWarm = Color(0xFFF5E6E8);
  static const surfaceInput = Color(0xFFFFFFFF);
  static const surfaceScrim = Color(0x66251C20);
  static const lineDefault = Color(0xFFECE6DF);
  static const lineStrong = Color(0xFFD6CBC3);
  static const lineFocus = Color(0xFF87545B);
  static const programPcos = Color(0xFFE4B6B9);
  static const programFertility = Color(0xFFCFC7E6);
  static const programMetabolic = Color(0xFFF2C6A6);
  static const programPregnancy = Color(0xFFC4D4C3);
  static const roleMember = Color(0xFF93564C);
  static const roleDoctor = Color(0xFF7E71AE);
  static const roleDietitian = Color(0xFFB8794A);
  static const roleInstructor = Color(0xFF5F8A5D);
  static const statusSuccess = Color(0xFF4A7348);
  static const statusSuccessLight = Color(0xFFEAEFE9);
  static const statusWarning = Color(0xFFF2C6A6);
  static const statusWarningText = Color(0xFF7A4E00);
  static const statusWarningLight = Color(0xFFF8ECE1);
  static const statusAttention = Color(0xFF8A4A40);
  static const statusAttentionLight = Color(0xFFF5E6E8);
  static const statusInfo = Color(0xFF5E4FA0);
  static const statusInfoLight = Color(0xFFECEAF4);
  static const statusClinicalRedFlag = Color(0xFFB4473F);
  static const statusClinicalRedFlagLight = Color(0xFFF7E3E1);
  static const answerBlush = Color(0xFFF5E6E8);
  static const answerPeach = Color(0xFFF8ECE1);
  static const answerApricot = Color(0xFFF9E1D0);
  static const answerMint = Color(0xFFEAEFE9);
  static const answerSage = Color(0xFFDCE6DB);
  static const answerLavender = Color(0xFFECEAF4);
  static const planTier0 = Color(0xFFF8ECE1);
  static const planTier1 = Color(0xFFEAEFE9);
  static const planTier2 = Color(0xFFE4B6B9);
  static const planTier3 = Color(0xFF87545B);
}

abstract final class NSpace {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xl2 = 48;
  static const double xl3 = 64;
}

abstract final class NRadius {
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 9999;
}

abstract final class NShadow {
  static const List<BoxShadow> xs = [BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Color(0x0D251C20))];
  static const List<BoxShadow> sm = [BoxShadow(offset: Offset(0, 2), blurRadius: 8, color: Color(0x12251C20))];
  static const List<BoxShadow> md = [BoxShadow(offset: Offset(0, 8), blurRadius: 24, color: Color(0x14251C20))];
  static const List<BoxShadow> lg = [BoxShadow(offset: Offset(0, 16), blurRadius: 40, color: Color(0x1A251C20))];
  static const List<BoxShadow> brandGlow = [BoxShadow(offset: Offset(0, 6), blurRadius: 18, color: Color(0x29261C21))];
}

abstract final class NType {
  static const String sansFamily = 'PlusJakartaSans';
  static const String displayFamily = 'CormorantGaramond';
  /// Body text family; kept for widgets that set a family directly.
  static const String fontFamily = sansFamily;
  static const TextStyle display = TextStyle(fontFamily: displayFamily, fontSize: 56, fontWeight: FontWeight.w600, height: 1, letterSpacing: -0.56);
  static const TextStyle h1 = TextStyle(fontFamily: displayFamily, fontSize: 44, fontWeight: FontWeight.w600, height: 1.05, letterSpacing: -0.44);
  static const TextStyle h2 = TextStyle(fontFamily: displayFamily, fontSize: 34, fontWeight: FontWeight.w600, height: 1.08, letterSpacing: -0.34);
  static const TextStyle h3 = TextStyle(fontFamily: displayFamily, fontSize: 28, fontWeight: FontWeight.w600, height: 1.12, letterSpacing: -0.28);
  static const TextStyle screenTitle = TextStyle(fontFamily: displayFamily, fontSize: 28, fontWeight: FontWeight.w600, height: 1.12, letterSpacing: -0.28);
  static const TextStyle h4 = TextStyle(fontFamily: sansFamily, fontSize: 17, fontWeight: FontWeight.w600, height: 1.35, letterSpacing: 0);
  static const TextStyle bodyLg = TextStyle(fontFamily: sansFamily, fontSize: 17, fontWeight: FontWeight.w400, height: 1.55, letterSpacing: 0);
  static const TextStyle body = TextStyle(fontFamily: sansFamily, fontSize: 15, fontWeight: FontWeight.w400, height: 1.5, letterSpacing: 0);
  static const TextStyle bodySm = TextStyle(fontFamily: sansFamily, fontSize: 13.5, fontWeight: FontWeight.w400, height: 1.4, letterSpacing: 0);
  static const TextStyle button = TextStyle(fontFamily: sansFamily, fontSize: 15, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: 0);
  static const TextStyle label = TextStyle(fontFamily: sansFamily, fontSize: 13, fontWeight: FontWeight.w500, height: 1.35, letterSpacing: 0);
  static const TextStyle caption = TextStyle(fontFamily: sansFamily, fontSize: 11, fontWeight: FontWeight.w700, height: 1.35, letterSpacing: 1.1);
  /// Styles whose text is shown in capitals; Flutter has no text-transform.
  static const Set<String> uppercase = {'caption'};
}

abstract final class NMotion {
  static const Duration fast = Duration(milliseconds: 220);
  static const Duration medium = Duration(milliseconds: 520);
  static const Duration slow = Duration(milliseconds: 760);
  static const Cubic easeOut = Cubic(0.2, 0.8, 0.2, 1);
}

abstract final class NLayout {
  static const double minTapTarget = 44;
  static const double contentMaxWidth = 1200;
  static const double breakpointPhone = 360;
  static const double breakpointTablet = 768;
  static const double breakpointDesktop = 1024;
  static const double breakpointWide = 1440;
}
