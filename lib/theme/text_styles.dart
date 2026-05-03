// =============================================================
// eDRMP — text_styles.dart
// Electronic Device Registration & Monitoring Portal (Pakistan)
// Design.md Section 2.2 — Typography System
// =============================================================

import 'package:flutter/material.dart';
import 'colors.dart';

/// AppTextStyles — Design.md Section 2.2 Typography System
///
/// Font Families:
/// - Display (Headlines): Poppins — Bold, confident, modern
/// - Body (Copy): Roboto — Professional, highly legible
/// - Monospace (Data): RobotoMono — IMEI, case IDs, timestamps
class AppTextStyles {
  AppTextStyles._();

  // -------------------------------------------------------------
  // FONT FAMILY NAMES
  // -------------------------------------------------------------
  static const String displayFont = 'Poppins';
  static const String bodyFont = 'Roboto';
  static const String monoFont = 'RobotoMono';

  // -------------------------------------------------------------
  // DISPLAY — H1 (32px, Poppins Bold, line-height 1.25)
  // Used: Page titles (Dashboard, Device Registration)
  // Example: "My Devices" | "Submit First Information Report"
  // -------------------------------------------------------------
  static TextStyle h1({Color? color}) => TextStyle(
        fontFamily: displayFont,
        fontSize: 32,
        fontWeight: FontWeight.w700, // Bold
        height: 1.25,
        color: color ?? AppColors.textPrimary,
      );

  // -------------------------------------------------------------
  // DISPLAY — H2 (24px, Poppins SemiBold, line-height 1.35)
  // Used: Section headers, dialog titles
  // Example: "Device Information" | "Verify IMEI"
  // -------------------------------------------------------------
  static TextStyle h2({Color? color}) => TextStyle(
        fontFamily: displayFont,
        fontSize: 24,
        fontWeight: FontWeight.w600, // SemiBold
        height: 1.35,
        color: color ?? AppColors.textPrimary,
      );

  // -------------------------------------------------------------
  // DISPLAY — H3 (20px, Poppins SemiBold, line-height 1.4)
  // Used: Card titles, form section headers
  // Example: "Device Details" | "Your Case Status"
  // -------------------------------------------------------------
  static TextStyle h3({Color? color}) => TextStyle(
        fontFamily: displayFont,
        fontSize: 20,
        fontWeight: FontWeight.w600, // SemiBold
        height: 1.4,
        color: color ?? AppColors.textPrimary,
      );

  // -------------------------------------------------------------
  // BODY — Body Large (16px, Roboto Regular, line-height 1.5)
  // Used: Primary body text, CTAs
  // Example: Button text, form labels
  // -------------------------------------------------------------
  static TextStyle bodyLarge({Color? color, FontWeight? weight}) => TextStyle(
        fontFamily: bodyFont,
        fontSize: 16,
        fontWeight: weight ?? FontWeight.w400, // Regular
        height: 1.5,
        color: color ?? AppColors.textPrimary,
      );

  // -------------------------------------------------------------
  // BODY — Body Regular (14px, Roboto Regular, line-height 1.5)
  // Used: Secondary body text, descriptions
  // Example: Help text, timestamps, status labels
  // -------------------------------------------------------------
  static TextStyle bodyRegular({Color? color, FontWeight? weight}) => TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        fontWeight: weight ?? FontWeight.w400, // Regular
        height: 1.5,
        color: color ?? AppColors.textSecondary,
      );

  // -------------------------------------------------------------
  // BODY — Body Small (12px, Roboto Regular, line-height 1.4)
  // Used: Tertiary labels, badges, very small UI text
  // Example: "Verified on Mar 15, 2025" | Error hints
  // -------------------------------------------------------------
  static TextStyle bodySmall({Color? color, FontWeight? weight}) => TextStyle(
        fontFamily: bodyFont,
        fontSize: 12,
        fontWeight: weight ?? FontWeight.w400, // Regular
        height: 1.4,
        color: color ?? AppColors.textTertiary,
      );

  // -------------------------------------------------------------
  // LABEL — (13px, Poppins SemiBold, line-height 1.4)
  // Used: Button text (when caps are needed)
  // Example: "SUBMIT REPORT" | "VERIFY IMEI"
  // -------------------------------------------------------------
  static TextStyle label({Color? color}) => TextStyle(
        fontFamily: displayFont,
        fontSize: 13,
        fontWeight: FontWeight.w600, // SemiBold
        height: 1.4,
        letterSpacing: 0.5,
        color: color ?? AppColors.textPrimary,
      );

  // -------------------------------------------------------------
  // LABEL — Label Large (14px, Poppins SemiBold)
  // Used: Button text, emphasized labels
  // -------------------------------------------------------------
  static TextStyle labelLarge({Color? color}) => TextStyle(
        fontFamily: displayFont,
        fontSize: 14,
        fontWeight: FontWeight.w600, // SemiBold
        height: 1.4,
        color: color ?? AppColors.textPrimary,
      );

  // -------------------------------------------------------------
  // MONOSPACE — Data (14px, RobotoMono Regular, line-height 1.5)
  // Used: IMEI, case IDs, reference numbers
  // Example: "35 989300 000000 0" (IMEI display)
  // -------------------------------------------------------------
  static TextStyle mono({Color? color, FontWeight? weight}) => TextStyle(
        fontFamily: monoFont,
        fontSize: 14,
        fontWeight: weight ?? FontWeight.w400, // Regular
        height: 1.5,
        letterSpacing: 0.5,
        color: color ?? AppColors.textSecondary,
      );

  // -------------------------------------------------------------
  // MONOSPACE — Small (12px, RobotoMono Regular)
  // Used: Small data displays, timestamps
  // -------------------------------------------------------------
  static TextStyle monoSmall({Color? color}) => TextStyle(
        fontFamily: monoFont,
        fontSize: 12,
        fontWeight: FontWeight.w400, // Regular
        height: 1.4,
        letterSpacing: 0.5,
        color: color ?? AppColors.textTertiary,
      );

  // -------------------------------------------------------------
  // STATUS BADGE TEXT — (12px, Roboto SemiBold)
  // Used: Status badges, tags
  // -------------------------------------------------------------
  static TextStyle badge({Color? color}) => TextStyle(
        fontFamily: bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w600, // SemiBold
        height: 1.4,
        color: color ?? AppColors.textInverse,
      );

  // -------------------------------------------------------------
  // BUTTON TEXT — (16px, Poppins SemiBold)
  // Used: Primary and secondary buttons
  // -------------------------------------------------------------
  static TextStyle button({Color? color}) => TextStyle(
        fontFamily: displayFont,
        fontSize: 16,
        fontWeight: FontWeight.w600, // SemiBold
        height: 1.5,
        color: color ?? AppColors.textInverse,
      );

  // -------------------------------------------------------------
  // INPUT LABEL — (14px, Roboto SemiBold)
  // Used: Form field labels
  // -------------------------------------------------------------
  static TextStyle inputLabel({Color? color}) => TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w600, // SemiBold
        height: 1.4,
        color: color ?? AppColors.textPrimary,
      );

  // -------------------------------------------------------------
  // INPUT HINT — (14px, Roboto Regular)
  // Used: Form field placeholders
  // -------------------------------------------------------------
  static TextStyle inputHint({Color? color}) => TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w400, // Regular
        height: 1.5,
        color: color ?? AppColors.textTertiary,
      );

  // -------------------------------------------------------------
  // ERROR TEXT — (12px, Roboto Regular)
  // Used: Form validation errors
  // -------------------------------------------------------------
  static TextStyle error({Color? color}) => TextStyle(
        fontFamily: bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w400, // Regular
        height: 1.4,
        color: color ?? AppColors.error,
      );

  // -------------------------------------------------------------
  // LINK TEXT — (14px, Roboto Medium)
  // Used: Clickable links, navigation
  // -------------------------------------------------------------
  static TextStyle link({Color? color}) => TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w500, // Medium
        height: 1.5,
        color: color ?? AppColors.primary,
      );

  // -------------------------------------------------------------
  // APP BAR TITLE — (20px, Poppins SemiBold)
  // Used: AppBar titles
  // -------------------------------------------------------------
  static TextStyle appBarTitle({Color? color}) => TextStyle(
        fontFamily: displayFont,
        fontSize: 20,
        fontWeight: FontWeight.w600, // SemiBold
        height: 1.35,
        color: color ?? AppColors.textPrimary,
      );

  // -------------------------------------------------------------
  // BOTTOM NAV LABEL — (12px, Roboto Medium)
  // Used: Bottom navigation labels
  // -------------------------------------------------------------
  static TextStyle bottomNavLabel({Color? color}) => TextStyle(
        fontFamily: bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w500, // Medium
        height: 1.4,
        letterSpacing: 0.4,
        color: color ?? AppColors.textSecondary,
      );

  // -------------------------------------------------------------
  // DARK THEME VARIANTS
  // -------------------------------------------------------------
  static TextStyle h1Dark({Color? color}) => h1(color: color ?? AppColors.darkTextPrimary);
  static TextStyle h2Dark({Color? color}) => h2(color: color ?? AppColors.darkTextPrimary);
  static TextStyle h3Dark({Color? color}) => h3(color: color ?? AppColors.darkTextPrimary);
  static TextStyle bodyLargeDark({Color? color}) => bodyLarge(color: color ?? AppColors.darkTextPrimary);
  static TextStyle bodyRegularDark({Color? color}) => bodyRegular(color: color ?? AppColors.darkTextSecondary);
  static TextStyle bodySmallDark({Color? color}) => bodySmall(color: color ?? AppColors.darkTextTertiary);
}

// =============================================================
// USAGE NOTES
// =============================================================
//
// All text styles are static methods on AppTextStyles:
//
// Text('My Devices', style: AppTextStyles.h1())
// Text('Device Info', style: AppTextStyles.h2())
// Text('Details', style: AppTextStyles.h3(color: AppColors.primary))
// Text('Description', style: AppTextStyles.bodyRegular())
// Text('IMEI: 123...', style: AppTextStyles.mono())
//
