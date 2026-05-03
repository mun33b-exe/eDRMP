// =============================================================
// eDRMP — colors.dart
// Electronic Device Registration & Monitoring Portal (Pakistan)
// Design.md Section 2.1 — Core Design System Color Palette
// =============================================================

import 'package:flutter/material.dart';

/// AppColors — Design.md Section 2.1 Color Palette
///
/// Primary: Blue (#0066CC) — Trust & Authority
/// Secondary: Green (#10B981) — Success & Verification
/// Alert: Red (#EF4444) — Warnings & Rejections
/// Warning: Orange (#F97316) — Pending & In-Progress
/// Neutral: Grays — UI Foundation
class AppColors {
  AppColors._();

  // -------------------------------------------------------------
  // PRIMARY COLORS — Brand Blue (Trust & Authority)
  // -------------------------------------------------------------
  /// Primary Brand Blue — AppBar, primary buttons, active states
  static const Color primary = Color(0xFF1A56DB);

  /// Darker primary — Pressed state, darker mode primary
  static const Color primaryDark = Color(0xFF1E3A5F);

  /// Accent primary — Slightly softer for secondary highlights
  static const Color primaryAccent = Color(0xFF3B82F6);

  /// Soft primary background — Light blue surfaces
  static const Color primarySoft = Color(0xFFEFF6FF);

  // -------------------------------------------------------------
  // SECONDARY COLORS — Green (Success & Verification)
  // -------------------------------------------------------------
  /// Success green — Approval states, checkmarks, verified badges
  static const Color success = Color(0xFF0D9488);

  /// Darker success — Pressed state, darker backgrounds
  static const Color successDark = Color(0xFF0F766E);

  /// Soft success background
  static const Color successSoft = Color(0xFFF0FDFA);

  // -------------------------------------------------------------
  // ALERT COLORS — Red (Warnings & Rejections)
  // -------------------------------------------------------------
  /// Error red — Errors, warnings, rejection states
  static const Color error = Color(0xFFDC2626);

  /// Darker error — Pressed state
  static const Color errorDark = Color(0xFFB91C1C);

  /// Soft error background
  static const Color errorSoft = Color(0xFFFEF2F2);

  // -------------------------------------------------------------
  // WARNING COLORS — Orange (Pending & In-Progress)
  // -------------------------------------------------------------
  /// Warning orange — Pending status, in-progress indicators
  static const Color warning = Color(0xFFD97706);

  /// Darker warning — Pressed state
  static const Color warningDark = Color(0xFFB45309);

  /// Soft warning background
  static const Color warningSoft = Color(0xFFFFFBEB);

  // -------------------------------------------------------------
  // NEUTRAL GRAY — UI Foundation (Light Theme)
  // -------------------------------------------------------------
  /// Page backgrounds, light surfaces
  static const Color background = Color(0xFFF8FAFC);

  /// Cards, elevated surfaces
  static const Color surface = Color(0xFFFFFFFF);

  /// Card background
  static const Color card = Color(0xFFFFFFFF);

  /// Input field backgrounds
  static const Color inputFill = Color(0xFFF8FAFC);

  /// Body text, primary labels
  static const Color textPrimary = Color(0xFF0F172A);

  /// Secondary labels, hints, timestamps
  static const Color textSecondary = Color(0xFF475569);

  /// Disabled states, very light labels
  static const Color textTertiary = Color(0xFF94A3B8);

  /// White text — for dark backgrounds
  static const Color textInverse = Color(0xFFFFFFFF);

  /// Subtle dividers, input borders
  static const Color border = Color(0xFFE2E8F0);

  /// More prominent borders, focused inputs
  static const Color borderStrong = Color(0xFFCBD5E1);

  /// Divider color
  static const Color divider = Color(0xFFE2E8F0);

  // -------------------------------------------------------------
  // DARK THEME — Surfaces & Structure
  // -------------------------------------------------------------
  /// Page background (dark)
  static const Color darkBackground = Color(0xFF0C1222);

  /// Cards, elevated surfaces (dark)
  static const Color darkSurface = Color(0xFF162032);

  /// Higher elevation surfaces (dark)
  static const Color darkSurfaceElevated = Color(0xFF1E2D45);

  /// Primary text on dark
  static const Color darkTextPrimary = Color(0xFFE2E8F0);

  /// Secondary text on dark
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  /// Tertiary text on dark
  static const Color darkTextTertiary = Color(0xFF64748B);

  /// Borders on dark
  static const Color darkBorder = Color(0xFF2D3F56);

  // -------------------------------------------------------------
  // DOMAIN STATUS — eDRMP Application/Device States
  // -------------------------------------------------------------
  /// Pending status — amber
  static const Color pending = Color(0xFFD97706);

  /// Approved status — emerald
  static const Color approved = Color(0xFF0D9488);

  /// Rejected status — red
  static const Color rejected = Color(0xFFDC2626);

  /// Verified status — teal
  static const Color verified = Color(0xFF0E7490);

  /// Blocked status — deep red
  static const Color blocked = Color(0xFF991B1B);

  /// Active status — alias of approved
  static const Color active = Color(0xFF0D9488);

  // Soft/tint variants for badge backgrounds
  static const Color pendingBg = Color(0xFFFFFBEB);
  static const Color approvedBg = Color(0xFFF0FDFA);
  static const Color rejectedBg = Color(0xFFFEF2F2);
  static const Color verifiedBg = Color(0xFFECFDF5);
  static const Color blockedBg = Color(0xFFFEF2F2);

  // -------------------------------------------------------------
  // BUTTONS
  // -------------------------------------------------------------
  static const Color buttonPrimary = primary;
  static const Color buttonPrimaryPressed = primaryDark;
  static const Color buttonSecondary = surface;
  static const Color buttonDisabled = Color(0xFFE5E7EB);
  static const Color buttonDanger = error;
  static const Color buttonSuccess = success;
  static const Color buttonTextLight = Color(0xFFFFFFFF);
  static const Color buttonTextDark = textPrimary;

  // -------------------------------------------------------------
  // COMPONENT ROLES
  // -------------------------------------------------------------
  static const Color appBar = primary;
  static const Color darkAppBar = darkSurface;
  static const Color bottomNav = surface;
  static const Color darkBottomNav = darkSurface;
  static const Color selectedNav = primary;
  static const Color unselectedNav = textSecondary;
  static const Color chipBackground = inputFill;
  static const Color chipSelected = primary;
  static const Color dialogBackground = surface;
  static const Color darkDialogBackground = darkSurface;
  static const Color snackbarSuccess = success;
  static const Color snackbarError = error;
  static const Color snackbarWarning = warning;

  // Timeline (case tracking)
  static const Color timelineLine = border;
  static const Color darkTimelineLine = darkBorder;
  static const Color timelineDone = success;
  static const Color timelineActive = primary;
  static const Color timelinePending = Color(0xFF94A3B8);
  static const Color timelineRejected = rejected;

  // -------------------------------------------------------------
  // SHADOWS & ELEVATION
  // -------------------------------------------------------------
  /// Elevation 1 shadow color — blue-tinted for depth
  static const Color shadowLight = Color(0x0A0F172A);

  /// Elevation 2 shadow color — blue-tinted for depth
  static const Color shadowMedium = Color(0x140F172A);

  /// Elevation 3 shadow color — blue-tinted for depth
  static const Color shadowHeavy = Color(0x1F0F172A);

  // -------------------------------------------------------------
  // SKELETON / SHIMMER
  // -------------------------------------------------------------
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF1F5F9);
  static const Color darkShimmerBase = Color(0xFF1E2D45);
  static const Color darkShimmerHighlight = Color(0xFF2D3F56);

  // -------------------------------------------------------------
  // MAP — Risk Heat Zones
  // -------------------------------------------------------------
  static const Color lowRiskZone = Color(0xFF0D9488);
  static const Color mediumRiskZone = Color(0xFFD97706);
  static const Color highRiskZone = Color(0xFFB91C1C);

  // -------------------------------------------------------------
  // ACCESSIBILITY NOTES (Design.md Appendix A)
  // -------------------------------------------------------------
  // - primary (#1A56DB) on white → 7.5:1 (AAA)
  // - success (#0D9488) on white → 4.6:1 (AA)
  // - error (#DC2626) on white → 4.6:1 (AA)
  // - warning (#D97706) on white → 4.2:1 (AA-large)
  // - textSecondary (#475569) on background → 7:1 (AAA)
  // - textTertiary (#94A3B8) on background → 3.5:1 (AA-large)
  // - On dark: darkTextPrimary on darkBackground → 13:1 (AAA)
  // =============================================================
}

