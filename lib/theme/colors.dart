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
  static const Color primary = Color(0xFF0066CC);

  /// Darker primary — Pressed state, darker mode primary
  static const Color primaryDark = Color(0xFF004BA3);

  /// Accent primary — Slightly softer for secondary highlights
  static const Color primaryAccent = Color(0xFF1D7FD6);

  /// Soft primary background — Light blue surfaces
  static const Color primarySoft = Color(0xFFEBF5FF);

  // -------------------------------------------------------------
  // SECONDARY COLORS — Green (Success & Verification)
  // -------------------------------------------------------------
  /// Success green — Approval states, checkmarks, verified badges
  static const Color success = Color(0xFF10B981);

  /// Darker success — Pressed state, darker backgrounds
  static const Color successDark = Color(0xFF059669);

  /// Soft success background
  static const Color successSoft = Color(0xFFD1FAE5);

  // -------------------------------------------------------------
  // ALERT COLORS — Red (Warnings & Rejections)
  // -------------------------------------------------------------
  /// Error red — Errors, warnings, rejection states
  static const Color error = Color(0xFFEF4444);

  /// Darker error — Pressed state
  static const Color errorDark = Color(0xFFDC2626);

  /// Soft error background
  static const Color errorSoft = Color(0xFFFEE2E2);

  // -------------------------------------------------------------
  // WARNING COLORS — Orange (Pending & In-Progress)
  // -------------------------------------------------------------
  /// Warning orange — Pending status, in-progress indicators
  static const Color warning = Color(0xFFF97316);

  /// Darker warning — Pressed state
  static const Color warningDark = Color(0xFFEA580C);

  /// Soft warning background
  static const Color warningSoft = Color(0xFFFFEDD5);

  // -------------------------------------------------------------
  // NEUTRAL GRAY — UI Foundation (Light Theme)
  // -------------------------------------------------------------
  /// Page backgrounds, light surfaces
  static const Color background = Color(0xFFF9FAFB);

  /// Cards, elevated surfaces
  static const Color surface = Color(0xFFFFFFFF);

  /// Card background
  static const Color card = Color(0xFFFFFFFF);

  /// Input field backgrounds
  static const Color inputFill = Color(0xFFF9FAFB);

  /// Body text, primary labels
  static const Color textPrimary = Color(0xFF111827);

  /// Secondary labels, hints, timestamps
  static const Color textSecondary = Color(0xFF6B7280);

  /// Disabled states, very light labels
  static const Color textTertiary = Color(0xFF9CA3AF);

  /// White text — for dark backgrounds
  static const Color textInverse = Color(0xFFFFFFFF);

  /// Subtle dividers, input borders
  static const Color border = Color(0xFFE5E7EB);

  /// More prominent borders, focused inputs
  static const Color borderStrong = Color(0xFFD1D5DB);

  /// Divider color
  static const Color divider = Color(0xFFE5E7EB);

  // -------------------------------------------------------------
  // DARK THEME — Surfaces & Structure
  // -------------------------------------------------------------
  /// Page background (dark)
  static const Color darkBackground = Color(0xFF0F172A);

  /// Cards, elevated surfaces (dark)
  static const Color darkSurface = Color(0xFF1E293B);

  /// Higher elevation surfaces (dark)
  static const Color darkSurfaceElevated = Color(0xFF334155);

  /// Primary text on dark
  static const Color darkTextPrimary = Color(0xFFF1F5F9);

  /// Secondary text on dark
  static const Color darkTextSecondary = Color(0xFFCBD5E1);

  /// Tertiary text on dark
  static const Color darkTextTertiary = Color(0xFF94A3B8);

  /// Borders on dark
  static const Color darkBorder = Color(0xFF475569);

  // -------------------------------------------------------------
  // DOMAIN STATUS — eDRMP Application/Device States
  // -------------------------------------------------------------
  /// Pending status — amber
  static const Color pending = Color(0xFFF97316);

  /// Approved status — emerald
  static const Color approved = Color(0xFF10B981);

  /// Rejected status — red
  static const Color rejected = Color(0xFFEF4444);

  /// Verified status — teal
  static const Color verified = Color(0xFF0B7285);

  /// Blocked status — deep red
  static const Color blocked = Color(0xFFB42318);

  /// Active status — alias of approved
  static const Color active = Color(0xFF10B981);

  // Soft/tint variants for badge backgrounds
  static const Color pendingBg = Color(0xFFFFEDD5);
  static const Color approvedBg = Color(0xFFD1FAE5);
  static const Color rejectedBg = Color(0xFFFEE2E2);
  static const Color verifiedBg = Color(0xFFDDEFF2);
  static const Color blockedBg = Color(0xFFFDECEA);

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
  static const Color timelinePending = Color(0xFF9CA3AF);
  static const Color timelineRejected = rejected;

  // -------------------------------------------------------------
  // SHADOWS & ELEVATION
  // -------------------------------------------------------------
  /// Elevation 1 shadow color (black 12% opacity) — 0x1F = ~12% alpha
  static const Color shadowLight = Color(0x1F000000);

  /// Elevation 2 shadow color (black 15% opacity) — 0x26 = ~15% alpha
  static const Color shadowMedium = Color(0x26000000);

  /// Elevation 3 shadow color (black 20% opacity) — 0x33 = ~20% alpha
  static const Color shadowHeavy = Color(0x33000000);

  // -------------------------------------------------------------
  // SKELETON / SHIMMER
  // -------------------------------------------------------------
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF3F4F6);
  static const Color darkShimmerBase = Color(0xFF374151);
  static const Color darkShimmerHighlight = Color(0xFF4B5563);

  // -------------------------------------------------------------
  // MAP — Risk Heat Zones
  // -------------------------------------------------------------
  static const Color lowRiskZone = Color(0xFF10B981);
  static const Color mediumRiskZone = Color(0xFFF59E0B);
  static const Color highRiskZone = Color(0xFFDC2626);

  // -------------------------------------------------------------
  // ACCESSIBILITY NOTES (Design.md Appendix A)
  // -------------------------------------------------------------
  // - primary (#0066CC) on white → 8:1 (AAA)
  // - success (#10B981) on white → 5:1 (AA)
  // - error (#EF4444) on white → 2:1 (Conditional — use for small UI only)
  // - warning (#F97316) on white → 3:1 (Conditional — use for large text/badges)
  // - textSecondary (#6B7280) on background → 5:1 (AA)
  // - textTertiary (#9CA3AF) on background → 2.5:1 (Use for hints only)
  // - On dark: darkTextPrimary on darkBackground → 14.1:1 (AAA)
  // =============================================================
}

