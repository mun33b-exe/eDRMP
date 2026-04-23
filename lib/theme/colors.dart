import 'package:flutter/material.dart';

/// AppColors - Production-ready color palette for eDRMP
/// Derived from the Official Secure Authority Design System
class AppColors {
  // --- BRAND COLORS ---
  static const Color primary = Color(0xFF0A2540); // Deep Trust Blue
  static const Color primaryDark = Color(0xFF051220);
  static const Color primaryLight = Color(0xFF1B3D5F);
  static const Color secondary = Color(0xFF00D4FF); // Accent Cyan
  static const Color accent = Color(0xFF00D4FF);
  static const Color tertiary = Color(0xFF64748B); // Slate/Muted Blue

  // --- LIGHT THEME COLORS ---
  static const Color scaffoldBackground = Color(0xFFFAFAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color inputFill = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color shadow = Color(0x0D0A2540); // Subtle deep blue shadow
  static const Color overlay = Color(0x800A2540);

  // --- DARK THEME COLORS (Proposed for Dark Mode Theme) ---
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkInput = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkDivider = Color(0xFF1E293B);
  static const Color darkOverlay = Color(0xCC000000);

  // --- TEXT COLORS (LIGHT) ---
  static const Color textPrimary = Color(0xFF0A2540);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textInverse = Color(0xFFFFFFFF);

  // --- TEXT COLORS (DARK) ---
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF64748B);

  // --- STATUS COLORS ---
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // --- DOMAIN SPECIFIC STATUS ---
  static const Color pending = Color(0xFFF59E0B); // Amber
  static const Color approved = Color(0xFF10B981); // Emerald
  static const Color rejected = Color(0xFFEF4444); // Red
  static const Color verified = Color(0xFF10B981); // Emerald
  static const Color blocked = Color(0xFF0F172A); // Slate 900 (High Contrast)
  static const Color active = Color(0xFF3B82F6); // Blue

  // --- BUTTON COLORS ---
  static const Color buttonPrimary = Color(0xFF0A2540);
  static const Color buttonSecondary = Color(0xFFFFFFFF);
  static const Color buttonDisabled = Color(0xFFCBD5E1);
  static const Color buttonDanger = Color(0xFFB91C1C);
  static const Color buttonTextLight = Color(0xFFFFFFFF);
  static const Color buttonTextDark = Color(0xFF0A2540);

  // --- COMPONENT COLORS ---
  static const Color appBar = Color(0xFFFFFFFF);
  static const Color bottomNav = Color(0xFFFFFFFF);
  static const Color selectedNav = Color(0xFF00D4FF);
  static const Color unselectedNav = Color(0xFF94A3B8);
  static const Color chipBackground = Color(0xFFF1F5F9);
  static const Color chipSelected = Color(0xFF0A2540);
  static const Color dialogBackground = Color(0xFFFFFFFF);
  static const Color snackbarSuccess = Color(0xFF065F46);
  static const Color snackbarError = Color(0xFF991B1B);
  static const Color snackbarWarning = Color(0xFF92400E);
  static const Color timelineLine = Color(0xFFE2E8F0);
  static const Color timelineDone = Color(0xFF00D4FF);
  static const Color timelinePending = Color(0xFFCBD5E1);

  // --- ADMIN DASHBOARD COLORS ---
  static const Color policePrimary = Color(0xFF1E40AF);
  static const Color ptaPrimary = Color(0xFF0A2540);
  static const Color analyticsBlue = Color(0xFF3B82F6);
  static const Color analyticsGreen = Color(0xFF10B981);
  static const Color analyticsOrange = Color(0xFFF97316);
  static const Color analyticsRed = Color(0xFFEF4444);

  // --- MAP COLORS ---
  static const Color lowRiskZone = Color(0x3310B981); // 20% Emerald
  static const Color mediumRiskZone = Color(0x33F59E0B); // 20% Amber
  static const Color highRiskZone = Color(0x33EF4444); // 20% Red

  // --- SKELETON / LOADING COLORS ---
  static const Color shimmerBase = Color(0xFFF1F5F9);
  static const Color shimmerHighlight = Color(0xFFFFFFFF);
}

/*
--- COLOR SCHEME & USAGE GUIDE ---

1. ColorScheme.fromSeed:
   - seedColor: AppColors.primary
   - brightness: Brightness.light / Brightness.dark
   - primary: AppColors.primary
   - secondary: AppColors.secondary
   - error: AppColors.error
   - surface: AppColors.surface

2. Usage Recommendations:
   - Buttons: Use `AppColors.buttonPrimary` for high-priority CTAs (Register, Login). Use `AppColors.buttonSecondary` for outlined/ghost buttons.
   - Cards: Use `AppColors.surface` with a `BoxShadow` color of `AppColors.shadow`.
   - Forms: `AppColors.inputFill` for text field backgrounds with a border color of `AppColors.border`.
   - Dashboards: Use `AppColors.analyticsBlue/Green` for KPI indicators to maintain a professional data-viz feel.
   - Admin Screens: Differentiate between Police and PTA using `AppColors.policePrimary` and `AppColors.ptaPrimary` in app bars or side drawers.
*/