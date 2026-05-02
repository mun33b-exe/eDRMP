import 'package:flutter/material.dart';

/// Authoritative design tokens for eDRMP.
///
/// Every value in this file is sourced from the design handoff. Do not
/// introduce any other `Color(0xFF...)` literal anywhere in the codebase —
/// extend this palette here instead.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------
  static const Color primary = Color(0xFF0B2A5B);
  static const Color primaryDark = Color(0xFF071C40);
  static const Color primaryLight = Color(0xFF2A4A7F);
  static const Color primarySoft = Color(0xFFE6ECF6);
  static const Color secondary = Color(0xFF0E7C5A);
  static const Color secondaryDark = Color(0xFF0A5C43);
  static const Color accent = Color(0xFFC9A227);
  static const Color tertiary = Color(0xFF1F6FEB);

  // ---------------------------------------------------------------------------
  // Light surfaces
  // ---------------------------------------------------------------------------
  static const Color scaffoldBackground = Color(0xFFF4F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color inputFill = Color(0xFFF1F4F9);
  static const Color border = Color(0xFFE1E6EF);
  static const Color divider = Color(0xFFEDF0F5);

  // ---------------------------------------------------------------------------
  // Dark surfaces
  // ---------------------------------------------------------------------------
  static const Color darkBackground = Color(0xFF0A1428);
  static const Color darkSurface = Color(0xFF0F1B33);
  static const Color darkCard = Color(0xFF152544);
  static const Color darkInput = Color(0xFF0F1B33);
  static const Color darkBorder = Color(0xFF22335A);
  static const Color darkDivider = Color(0xFF1B2A4A);

  // ---------------------------------------------------------------------------
  // Status — feedback
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF0E7C5A);
  static const Color successLight = Color(0xFFE6F4EE);
  static const Color warning = Color(0xFFB7791F);
  static const Color warningLight = Color(0xFFFBF1D7);
  static const Color error = Color(0xFFB42318);
  static const Color errorLight = Color(0xFFFDECEA);
  static const Color info = Color(0xFF1F6FEB);
  static const Color infoLight = Color(0xFFE4EEFD);

  // ---------------------------------------------------------------------------
  // Domain — workflow status (devices / FIRs / blocks)
  // ---------------------------------------------------------------------------
  static const Color pending = Color(0xFFB7791F);
  static const Color approved = Color(0xFF0E7C5A);
  static const Color rejected = Color(0xFFB42318);

  // ---------------------------------------------------------------------------
  // Foreground — text on light surfaces
  // ---------------------------------------------------------------------------
  static const Color textPrimary = Color(0xFF0B2A5B);
  static const Color textSecondary = Color(0xFF4A5B7A);
  static const Color textMuted = Color(0xFF8895AD);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Foreground — text on dark surfaces
  // ---------------------------------------------------------------------------
  static const Color darkTextPrimary = Color(0xFFEEF2F8);
  static const Color darkTextSecondary = Color(0xFFB6C2D6);
  static const Color darkTextMuted = Color(0xFF7A88A3);
}
