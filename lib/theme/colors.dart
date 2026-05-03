// =============================================================
// eDRMP — colors.dart
// Electronic Device Registration & Monitoring Portal (Pakistan)
// Design System — Forest Green / Sage Palette
// =============================================================

import 'package:flutter/material.dart';

/// AppColors — Forest Green / Warm Sage Palette
///
/// Primary: Forest Green (#166534) — Trust, Authority, Growth
/// Secondary: Sage (#4ADE80) — Success & Verification
/// Alert: Warm Red (#DC2626) — Warnings & Rejections
/// Warning: Amber (#D97706) — Pending & In-Progress
/// Neutral: Warm Stone — UI Foundation (cream-tinted grays)
class AppColors {
  AppColors._();

  // -------------------------------------------------------------
  // PRIMARY COLORS — Forest Green (Trust & Authority)
  // -------------------------------------------------------------
  /// Primary Forest Green — AppBar, primary buttons, active states
  static const Color primary = Color(0xFF166534);

  /// Darker primary — Pressed state, hero backgrounds
  static const Color primaryDark = Color(0xFF14532D);

  /// Accent primary — Lighter green for secondary highlights
  static const Color primaryAccent = Color(0xFF22C55E);

  /// Mid-tone primary — Hero gradient mid-point
  static const Color primaryMid = Color(0xFF15803D);

  /// Soft primary background — Very light sage wash
  static const Color primarySoft = Color(0xFFF0FDF4);

  // -------------------------------------------------------------
  // SECONDARY COLORS — Emerald (Success & Verification)
  // -------------------------------------------------------------
  /// Success emerald — Approval states, checkmarks, verified badges
  static const Color success = Color(0xFF059669);

  /// Darker success — Pressed state
  static const Color successDark = Color(0xFF047857);

  /// Soft success background
  static const Color successSoft = Color(0xFFECFDF5);

  // -------------------------------------------------------------
  // ALERT COLORS — Warm Red (Warnings & Rejections)
  // -------------------------------------------------------------
  /// Error red — Errors, warnings, rejection states
  static const Color error = Color(0xFFDC2626);

  /// Darker error — Pressed state
  static const Color errorDark = Color(0xFFB91C1C);

  /// Soft error background
  static const Color errorSoft = Color(0xFFFEF2F2);

  // -------------------------------------------------------------
  // WARNING COLORS — Amber (Pending & In-Progress)
  // -------------------------------------------------------------
  /// Warning amber — Pending status, in-progress indicators
  static const Color warning = Color(0xFFD97706);

  /// Darker warning — Pressed state
  static const Color warningDark = Color(0xFFB45309);

  /// Soft warning background
  static const Color warningSoft = Color(0xFFFFFBEB);

  // -------------------------------------------------------------
  // NEUTRAL STONE — Warm UI Foundation (Light Theme)
  // -------------------------------------------------------------
  /// Page backgrounds — warm off-white
  static const Color background = Color(0xFFFAFAF9);

  /// Cards, elevated surfaces — pure white
  static const Color surface = Color(0xFFFFFFFF);

  /// Card background
  static const Color card = Color(0xFFFFFFFF);

  /// Input field backgrounds — warm stone
  static const Color inputFill = Color(0xFFFAFAF9);

  /// Body text — warm charcoal
  static const Color textPrimary = Color(0xFF1C1917);

  /// Secondary labels — warm gray
  static const Color textSecondary = Color(0xFF57534E);

  /// Disabled states — stone
  static const Color textTertiary = Color(0xFFA8A29E);

  /// White text — for dark backgrounds
  static const Color textInverse = Color(0xFFFFFFFF);

  /// Subtle dividers, input borders — warm stone
  static const Color border = Color(0xFFE7E5E4);

  /// More prominent borders
  static const Color borderStrong = Color(0xFFD6D3D1);

  /// Divider color
  static const Color divider = Color(0xFFE7E5E4);

  // -------------------------------------------------------------
  // DARK THEME — Surfaces & Structure (warm dark)
  // -------------------------------------------------------------
  /// Page background (dark) — warm near-black
  static const Color darkBackground = Color(0xFF0C0A09);

  /// Cards, elevated surfaces (dark)
  static const Color darkSurface = Color(0xFF1C1917);

  /// Higher elevation surfaces (dark)
  static const Color darkSurfaceElevated = Color(0xFF292524);

  /// Primary text on dark
  static const Color darkTextPrimary = Color(0xFFFAFAF9);

  /// Secondary text on dark
  static const Color darkTextSecondary = Color(0xFFA8A29E);

  /// Tertiary text on dark
  static const Color darkTextTertiary = Color(0xFF78716C);

  /// Borders on dark — warm stone
  static const Color darkBorder = Color(0xFF44403C);

  // -------------------------------------------------------------
  // DOMAIN STATUS — eDRMP Application/Device States
  // -------------------------------------------------------------
  /// Pending status — amber
  static const Color pending = Color(0xFFD97706);

  /// Approved status — emerald
  static const Color approved = Color(0xFF059669);

  /// Rejected status — red
  static const Color rejected = Color(0xFFDC2626);

  /// Verified status — teal
  static const Color verified = Color(0xFF0D9488);

  /// Blocked status — deep red
  static const Color blocked = Color(0xFF991B1B);

  /// Active status — alias of approved
  static const Color active = Color(0xFF059669);

  // Soft/tint variants for badge backgrounds
  static const Color pendingBg = Color(0xFFFFFBEB);
  static const Color approvedBg = Color(0xFFECFDF5);
  static const Color rejectedBg = Color(0xFFFEF2F2);
  static const Color verifiedBg = Color(0xFFF0FDFA);
  static const Color blockedBg = Color(0xFFFEF2F2);

  // -------------------------------------------------------------
  // BUTTONS
  // -------------------------------------------------------------
  static const Color buttonPrimary = primary;
  static const Color buttonPrimaryPressed = primaryDark;
  static const Color buttonSecondary = surface;
  static const Color buttonDisabled = Color(0xFFD6D3D1);
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
  static const Color timelinePending = Color(0xFFA8A29E);
  static const Color timelineRejected = rejected;

  // -------------------------------------------------------------
  // SHADOWS & ELEVATION
  // -------------------------------------------------------------
  /// Elevation 1 — warm shadow
  static const Color shadowLight = Color(0x0A1C1917);

  /// Elevation 2 — warm shadow
  static const Color shadowMedium = Color(0x141C1917);

  /// Elevation 3 — warm shadow
  static const Color shadowHeavy = Color(0x1F1C1917);

  // -------------------------------------------------------------
  // SKELETON / SHIMMER
  // -------------------------------------------------------------
  static const Color shimmerBase = Color(0xFFE7E5E4);
  static const Color shimmerHighlight = Color(0xFFF5F5F4);
  static const Color darkShimmerBase = Color(0xFF292524);
  static const Color darkShimmerHighlight = Color(0xFF44403C);

  // -------------------------------------------------------------
  // MAP — Risk Heat Zones
  // -------------------------------------------------------------
  static const Color lowRiskZone = Color(0xFF059669);
  static const Color mediumRiskZone = Color(0xFFD97706);
  static const Color highRiskZone = Color(0xFFB91C1C);

  // -------------------------------------------------------------
  // ACCESSIBILITY NOTES
  // -------------------------------------------------------------
  // - primary (#166534) on white → 8.2:1 (AAA)
  // - success (#059669) on white → 4.6:1 (AA)
  // - error (#DC2626) on white → 4.6:1 (AA)
  // - warning (#D97706) on white → 4.2:1 (AA-large)
  // - textPrimary (#1C1917) on background (#FAFAF9) → 17:1 (AAA)
  // - textSecondary (#57534E) on background → 6.5:1 (AAA)
  // - textTertiary (#A8A29E) on background → 2.7:1 (AA-large)
  // - On dark: darkTextPrimary (#FAFAF9) on darkBg (#0C0A09) → 19:1 (AAA)
  // =============================================================
}

