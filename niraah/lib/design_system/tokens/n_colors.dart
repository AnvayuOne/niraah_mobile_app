// Light values come from the generated tokens; dark values are hand-tuned for the dark illustrations (#16121A).
// Widgets read NColors.x as before; the app flips [NColors.dark] and rebuilds when the theme changes.
// ignore_for_file: public_member_api_docs

import 'dart:ui';

import 'generated/niraah_tokens.dart' as gen;

abstract final class NColors {
  /// True while the app shows its dark theme.
  static bool dark = false;

  static Color get brandBlush => dark ? NColorsDark.brandBlush : gen.NColors.brandBlush;
  static Color get brandLavender => dark ? NColorsDark.brandLavender : gen.NColors.brandLavender;
  static Color get brandApricot => dark ? NColorsDark.brandApricot : gen.NColors.brandApricot;
  static Color get brandSage => dark ? NColorsDark.brandSage : gen.NColors.brandSage;
  static Color get brandPlum => dark ? NColorsDark.brandPlum : gen.NColors.brandPlum;
  static Color get brandTerracotta => dark ? NColorsDark.brandTerracotta : gen.NColors.brandTerracotta;
  static Color get brandRosewood => dark ? NColorsDark.brandRosewood : gen.NColors.brandRosewood;
  static Color get brandBlushLight => dark ? NColorsDark.brandBlushLight : gen.NColors.brandBlushLight;
  static Color get brandLavenderLight => dark ? NColorsDark.brandLavenderLight : gen.NColors.brandLavenderLight;
  static Color get brandApricotLight => dark ? NColorsDark.brandApricotLight : gen.NColors.brandApricotLight;
  static Color get brandSageLight => dark ? NColorsDark.brandSageLight : gen.NColors.brandSageLight;
  static Color get actionPrimary => dark ? NColorsDark.actionPrimary : gen.NColors.actionPrimary;
  static Color get actionPrimaryHover => dark ? NColorsDark.actionPrimaryHover : gen.NColors.actionPrimaryHover;
  static Color get actionPrimaryPressed => dark ? NColorsDark.actionPrimaryPressed : gen.NColors.actionPrimaryPressed;
  static Color get actionOnPrimary => dark ? NColorsDark.actionOnPrimary : gen.NColors.actionOnPrimary;
  static Color get actionLink => dark ? NColorsDark.actionLink : gen.NColors.actionLink;
  static Color get actionDisabled => dark ? NColorsDark.actionDisabled : gen.NColors.actionDisabled;
  static Color get actionOnDisabled => dark ? NColorsDark.actionOnDisabled : gen.NColors.actionOnDisabled;
  static Color get inkPrimary => dark ? NColorsDark.inkPrimary : gen.NColors.inkPrimary;
  static Color get inkSecondary => dark ? NColorsDark.inkSecondary : gen.NColors.inkSecondary;
  static Color get inkMuted => dark ? NColorsDark.inkMuted : gen.NColors.inkMuted;
  static Color get inkOnBrand => dark ? NColorsDark.inkOnBrand : gen.NColors.inkOnBrand;
  static Color get surfacePage => dark ? NColorsDark.surfacePage : gen.NColors.surfacePage;
  static Color get surfaceBackdrop => dark ? NColorsDark.surfaceBackdrop : gen.NColors.surfaceBackdrop;
  static Color get surfaceCard => dark ? NColorsDark.surfaceCard : gen.NColors.surfaceCard;
  static Color get surfaceWarm => dark ? NColorsDark.surfaceWarm : gen.NColors.surfaceWarm;
  static Color get surfaceInput => dark ? NColorsDark.surfaceInput : gen.NColors.surfaceInput;
  static Color get surfaceScrim => dark ? NColorsDark.surfaceScrim : gen.NColors.surfaceScrim;
  static Color get lineDefault => dark ? NColorsDark.lineDefault : gen.NColors.lineDefault;
  static Color get lineStrong => dark ? NColorsDark.lineStrong : gen.NColors.lineStrong;
  static Color get lineFocus => dark ? NColorsDark.lineFocus : gen.NColors.lineFocus;
  static Color get programPcos => dark ? NColorsDark.programPcos : gen.NColors.programPcos;
  static Color get programFertility => dark ? NColorsDark.programFertility : gen.NColors.programFertility;
  static Color get programMetabolic => dark ? NColorsDark.programMetabolic : gen.NColors.programMetabolic;
  static Color get programPregnancy => dark ? NColorsDark.programPregnancy : gen.NColors.programPregnancy;
  static Color get roleMember => dark ? NColorsDark.roleMember : gen.NColors.roleMember;
  static Color get roleDoctor => dark ? NColorsDark.roleDoctor : gen.NColors.roleDoctor;
  static Color get roleDietitian => dark ? NColorsDark.roleDietitian : gen.NColors.roleDietitian;
  static Color get roleInstructor => dark ? NColorsDark.roleInstructor : gen.NColors.roleInstructor;
  static Color get statusSuccess => dark ? NColorsDark.statusSuccess : gen.NColors.statusSuccess;
  static Color get statusSuccessLight => dark ? NColorsDark.statusSuccessLight : gen.NColors.statusSuccessLight;
  static Color get statusWarning => dark ? NColorsDark.statusWarning : gen.NColors.statusWarning;
  static Color get statusWarningText => dark ? NColorsDark.statusWarningText : gen.NColors.statusWarningText;
  static Color get statusWarningLight => dark ? NColorsDark.statusWarningLight : gen.NColors.statusWarningLight;
  static Color get statusAttention => dark ? NColorsDark.statusAttention : gen.NColors.statusAttention;
  static Color get statusAttentionLight => dark ? NColorsDark.statusAttentionLight : gen.NColors.statusAttentionLight;
  static Color get statusInfo => dark ? NColorsDark.statusInfo : gen.NColors.statusInfo;
  static Color get statusInfoLight => dark ? NColorsDark.statusInfoLight : gen.NColors.statusInfoLight;
  static Color get statusClinicalRedFlag => dark ? NColorsDark.statusClinicalRedFlag : gen.NColors.statusClinicalRedFlag;
  static Color get statusClinicalRedFlagLight => dark ? NColorsDark.statusClinicalRedFlagLight : gen.NColors.statusClinicalRedFlagLight;
  static Color get answerBlush => dark ? NColorsDark.answerBlush : gen.NColors.answerBlush;
  static Color get answerPeach => dark ? NColorsDark.answerPeach : gen.NColors.answerPeach;
  static Color get answerApricot => dark ? NColorsDark.answerApricot : gen.NColors.answerApricot;
  static Color get answerMint => dark ? NColorsDark.answerMint : gen.NColors.answerMint;
  static Color get answerSage => dark ? NColorsDark.answerSage : gen.NColors.answerSage;
  static Color get answerLavender => dark ? NColorsDark.answerLavender : gen.NColors.answerLavender;
  static Color get planTier0 => dark ? NColorsDark.planTier0 : gen.NColors.planTier0;
  static Color get planTier1 => dark ? NColorsDark.planTier1 : gen.NColors.planTier1;
  static Color get planTier2 => dark ? NColorsDark.planTier2 : gen.NColors.planTier2;
  static Color get planTier3 => dark ? NColorsDark.planTier3 : gen.NColors.planTier3;
}

/// The dark palette.
abstract final class NColorsDark {
  static const brandBlush = Color(0xFFD9A3A8);
  static const brandLavender = Color(0xFFB4A9D9);
  static const brandApricot = Color(0xFFE6B08A);
  static const brandSage = Color(0xFFA8C2A6);
  static const brandPlum = Color(0xFF2E2333);
  static const brandTerracotta = Color(0xFFD69584);
  static const brandRosewood = Color(0xFFD99BA3);
  static const brandBlushLight = Color(0xFF3A262D);
  static const brandLavenderLight = Color(0xFF2C2839);
  static const brandApricotLight = Color(0xFF392A21);
  static const brandSageLight = Color(0xFF222F25);
  static const actionPrimary = Color(0xFFE9BEC2);
  static const actionPrimaryHover = Color(0xFFF0CDD0);
  static const actionPrimaryPressed = Color(0xFFD9A6AB);
  static const actionOnPrimary = Color(0xFF1E151A);
  static const actionLink = Color(0xFFEBA99C);
  static const actionDisabled = Color(0xFF2F2731);
  static const actionOnDisabled = Color(0xFF8E7E86);
  static const inkPrimary = Color(0xFFF4ECEE);
  static const inkSecondary = Color(0xFFD9CCD1);
  static const inkMuted = Color(0xFFAA9AA2);
  static const inkOnBrand = Color(0xFFFFFFFF);
  static const surfacePage = Color(0xFF16121A);
  static const surfaceBackdrop = Color(0xFF100D13);
  static const surfaceCard = Color(0xFF211A24);
  static const surfaceWarm = Color(0xFF2A1F28);
  static const surfaceInput = Color(0xFF251E29);
  static const surfaceScrim = Color(0x99000000);
  static const lineDefault = Color(0xFF302833);
  static const lineStrong = Color(0xFF4A3F4D);
  static const lineFocus = Color(0xFFE9BEC2);
  static const programPcos = Color(0xFFD9A3A8);
  static const programFertility = Color(0xFFB4A9D9);
  static const programMetabolic = Color(0xFFE6B08A);
  static const programPregnancy = Color(0xFFA8C2A6);
  static const roleMember = Color(0xFFD69584);
  static const roleDoctor = Color(0xFFB0A3E0);
  static const roleDietitian = Color(0xFFE3A673);
  static const roleInstructor = Color(0xFF94C291);
  static const statusSuccess = Color(0xFF93C690);
  static const statusSuccessLight = Color(0xFF1F2D22);
  static const statusWarning = Color(0xFFE6B08A);
  static const statusWarningText = Color(0xFFF2C27A);
  static const statusWarningLight = Color(0xFF392A21);
  static const statusAttention = Color(0xFFE8A196);
  static const statusAttentionLight = Color(0xFF3A2427);
  static const statusInfo = Color(0xFFB0A3E0);
  static const statusInfoLight = Color(0xFF2C2839);
  static const statusClinicalRedFlag = Color(0xFFF28B81);
  static const statusClinicalRedFlagLight = Color(0xFF3E2120);
  static const answerBlush = Color(0xFF3A262D);
  static const answerPeach = Color(0xFF392A21);
  static const answerApricot = Color(0xFF3D2A1F);
  static const answerMint = Color(0xFF222F25);
  static const answerSage = Color(0xFF26332A);
  static const answerLavender = Color(0xFF2C2839);
  static const planTier0 = Color(0xFF392A21);
  static const planTier1 = Color(0xFF222F25);
  static const planTier2 = Color(0xFF4A2C33);
  static const planTier3 = Color(0xFF87545B);
}
