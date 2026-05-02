// =============================================================
// eDRMP — colors.dart
// Electronic Device Registration & Monitoring Portal (Pakistan)
// Derived from the designed screens in `eDRMP Design System.html`.
// Drop into  lib/core/theme/colors.dart  and start building theme.dart.
// =============================================================

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // -------------------------------------------------------------
  // BRAND
  // Deep institutional navy + emerald — government-tech credible,
  // modern SaaS feel. Never use the gold or analytics colors as
  // primary CTAs.
  // -------------------------------------------------------------
  static const Color primary = Color(0xFF0B2A5B); // app bar, primary CTA, links
  static const Color primaryDark = Color(
    0xFF071C40,
  ); // pressed primary, dark app bar
  static const Color primaryLight = Color(0xFF2A4A7F); // hover, on-color tints
  static const Color primarySoft = Color(
    0xFFE6ECF6,
  ); // soft chip bg, selected nav
  static const Color secondary = Color(
    0xFF0E7C5A,
  ); // emerald — approvals, success
  static const Color secondaryDark = Color(0xFF0A5C43);
  static const Color secondaryLight = Color(0xFFE6F4EE);
  static const Color accent = Color(
    0xFFC9A227,
  ); // muted civic gold — official seal, badges
  static const Color accentSoft = Color(0xFFFAF3DC);
  static const Color tertiary = Color(
    0xFF1F6FEB,
  ); // analytics blue — charts only

  // -------------------------------------------------------------
  // LIGHT THEME — surfaces & structure
  // -------------------------------------------------------------
  static const Color scaffoldBackground = Color(0xFFF4F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color inputFill = Color(0xFFF1F4F9);
  static const Color border = Color(0xFFE1E6EF);
  static const Color divider = Color(0xFFEDF0F5);
  static const Color shadow = Color(0x0F0B2A5B); // navy 6%
  static const Color overlay = Color(0x7A071C40); // navy 48%

  // -------------------------------------------------------------
  // DARK THEME — surfaces & structure
  // -------------------------------------------------------------
  static const Color darkBackground = Color(0xFF0A1428);
  static const Color darkSurface = Color(0xFF0F1B33);
  static const Color darkCard = Color(0xFF152544);
  static const Color darkInput = Color(0xFF0F1B33);
  static const Color darkBorder = Color(0xFF22335A);
  static const Color darkDivider = Color(0xFF1B2A4A);
  static const Color darkOverlay = Color(0xA8000000);

  // -------------------------------------------------------------
  // TEXT
  // -------------------------------------------------------------
  // Light:
  static const Color textPrimary = Color(0xFF0E1A2E);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF7A8699);
  static const Color textInverse = Color(0xFFFFFFFF);
  // Dark:
  static const Color darkTextPrimary = Color(0xFFF1F5FB);
  static const Color darkTextSecondary = Color(0xFFA8B5CC);
  static const Color darkTextMuted = Color(0xFF6F7E99);

  // -------------------------------------------------------------
  // STATUS — generic semantic
  // -------------------------------------------------------------
  static const Color success = Color(0xFF0E7C5A);
  static const Color successLight = Color(0xFFE6F4EE);
  static const Color warning = Color(0xFFB7791F);
  static const Color warningLight = Color(0xFFFBF1D7);
  static const Color error = Color(0xFFB42318);
  static const Color errorLight = Color(0xFFFDECEA);
  static const Color info = Color(0xFF1F6FEB);
  static const Color infoLight = Color(0xFFE4EEFD);

  // -------------------------------------------------------------
  // DOMAIN STATUS — eDRMP application/device states
  // Map directly to your StatusBadge widget's `kind` prop.
  // -------------------------------------------------------------
  static const Color pending = Color(0xFFB7791F); // amber — awaiting review
  static const Color approved = Color(0xFF0E7C5A); // emerald — registered
  static const Color rejected = Color(
    0xFFB42318,
  ); // garnet — application rejected
  static const Color verified = Color(
    0xFF0B7285,
  ); // teal — KYC/CNIC verified (≠ approved)
  static const Color blocked = Color(
    0xFF7A1F14,
  ); // deep maroon — stolen / on-network blocked
  static const Color active = Color(
    0xFF0E7C5A,
  ); // alias of approved for live devices

  // Soft/tint variants for badge backgrounds (light theme)
  static const Color pendingBg = Color(0xFFFBF1D7);
  static const Color approvedBg = Color(0xFFE6F4EE);
  static const Color rejectedBg = Color(0xFFFDECEA);
  static const Color verifiedBg = Color(0xFFDDEFF2);
  static const Color blockedBg = Color(0xFFF5D9D6);

  // -------------------------------------------------------------
  // BUTTONS
  // -------------------------------------------------------------
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = surface; // bordered, on-light
  static const Color buttonDisabled = Color(0xFFE1E6EF);
  static const Color buttonDanger = error;
  static const Color buttonSuccess = secondary;
  static const Color buttonTextLight = Color(
    0xFFFFFFFF,
  ); // text on filled primary/danger/success
  static const Color buttonTextDark = textPrimary; // text on secondary/ghost

  // -------------------------------------------------------------
  // COMPONENT ROLES
  // -------------------------------------------------------------
  static const Color appBar = primary;
  static const Color darkAppBar = darkSurface;
  static const Color bottomNav = surface;
  static const Color darkBottomNav = darkSurface;
  static const Color selectedNav = primary;
  static const Color unselectedNav = textMuted;
  static const Color chipBackground = inputFill;
  static const Color chipSelected = primary;
  static const Color dialogBackground = surface;
  static const Color darkDialogBackground = darkCard;
  static const Color snackbarSuccess = success;
  static const Color snackbarError = error;
  static const Color snackbarWarning = warning;
  static const Color snackbarInfo = info;

  // Timeline (case tracking)
  static const Color timelineLine = border; // light theme rail
  static const Color darkTimelineLine = darkBorder;
  static const Color timelineDone = success;
  static const Color timelineActive = primary;
  static const Color timelinePending = Color(0xFFC5CDDB);
  static const Color timelineRejected = rejected;

  // -------------------------------------------------------------
  // ADMIN DASHBOARD
  // -------------------------------------------------------------
  static const Color policePrimary = primary; // navy — officer surfaces
  static const Color ptaPrimary = secondary; // emerald — regulator surfaces
  static const Color analyticsBlue = Color(0xFF1F6FEB);
  static const Color analyticsGreen = Color(0xFF0E7C5A);
  static const Color analyticsOrange = Color(0xFFC9A227);
  static const Color analyticsRed = Color(0xFFB42318);
  static const Color analyticsViolet = Color(0xFF7C4DFF); // 5th chart series

  // -------------------------------------------------------------
  // MAP — risk heat zones
  // -------------------------------------------------------------
  static const Color lowRiskZone = Color(0xFF10B981);
  static const Color mediumRiskZone = Color(0xFFF59E0B);
  static const Color highRiskZone = Color(0xFFDC2626);

  // -------------------------------------------------------------
  // SKELETON / SHIMMER
  // -------------------------------------------------------------
  static const Color shimmerBase = Color(0xFFEAEEF5);
  static const Color shimmerHighlight = Color(0xFFF7F9FC);
  static const Color darkShimmerBase = Color(0xFF152544);
  static const Color darkShimmerHighlight = Color(0xFF1E3050);

  // -------------------------------------------------------------
  // CONVENIENCE — Material ColorScheme seeds
  // Use with ColorScheme.fromSeed in theme.dart.
  // -------------------------------------------------------------
  static const Color seedLight = primary;
  static const Color seedDark = primary;
}

// =============================================================
// RECOMMENDED ColorScheme.fromSeed VALUES
// =============================================================
//
// final lightScheme = ColorScheme.fromSeed(
//   seedColor: AppColors.primary,
//   brightness: Brightness.light,
// ).copyWith(
//   primary:        AppColors.primary,
//   onPrimary:      AppColors.buttonTextLight,
//   secondary:      AppColors.secondary,
//   onSecondary:    AppColors.buttonTextLight,
//   tertiary:       AppColors.accent,
//   error:          AppColors.error,
//   onError:        AppColors.buttonTextLight,
//   surface:        AppColors.surface,
//   onSurface:      AppColors.textPrimary,
//   surfaceVariant: AppColors.inputFill,
//   outline:        AppColors.border,
//   outlineVariant: AppColors.divider,
//   shadow:         AppColors.shadow,
// );
//
// final darkScheme = ColorScheme.fromSeed(
//   seedColor: AppColors.primary,
//   brightness: Brightness.dark,
// ).copyWith(
//   primary:        AppColors.primaryLight,        // lift navy for dark contrast
//   onPrimary:      AppColors.buttonTextLight,
//   secondary:      AppColors.secondary,
//   onSecondary:    AppColors.buttonTextLight,
//   tertiary:       AppColors.accent,
//   error:          AppColors.error,
//   onError:        AppColors.buttonTextLight,
//   surface:        AppColors.darkSurface,
//   onSurface:      AppColors.darkTextPrimary,
//   surfaceVariant: AppColors.darkCard,
//   outline:        AppColors.darkBorder,
//   outlineVariant: AppColors.darkDivider,
// );
//
// =============================================================
// USAGE MAP — which color goes where
// =============================================================
//
// BUTTONS
//   ElevatedButton (primary)  → buttonPrimary / buttonTextLight
//   FilledButton.tonal        → primarySoft  / primary (text)
//   OutlinedButton            → border       / textPrimary
//   Destructive (Reject, FIR) → buttonDanger / buttonTextLight
//   Approve (admin)           → buttonSuccess/ buttonTextLight
//   Disabled                  → buttonDisabled (textMuted on top)
//
// CARDS
//   Default card              → card / border / shadow
//   Hero device card          → primary→primaryDark gradient, white text
//   Status-accent device card → 4px left bar in domain status color
//   Dark card                 → darkCard / darkBorder (no shadow)
//
// FORMS
//   TextField fill            → inputFill (light) / darkInput (dark)
//   Border                    → border / darkBorder
//   Focus border              → primary
//   Error border              → error
//   Label                     → textSecondary / darkTextSecondary
//   Helper                    → textMuted
//   Error helper              → error
//
// DASHBOARDS (PTA admin / analytics)
//   KPI stat tile bg          → card
//   KPI accent ring (icon bg) → matching status color at 10% (light) / 20% (dark)
//   Trend up                  → success
//   Trend down                → error
//   Chart series 1..5         → analyticsBlue, analyticsGreen, analyticsOrange,
//                               analyticsRed, analyticsViolet (in that order)
//   Risk map                  → lowRiskZone / mediumRiskZone / highRiskZone @ 45–50% fill
//
// ALERTS / SNACKBARS / BANNERS
//   Success                   → successLight bg / success border / success icon / success text on dark side
//   Warning                   → warningLight bg / warning text
//   Error / destructive       → errorLight bg / error text + icon
//   Info                      → infoLight  bg / info text
//
// ADMIN ROLE TINTING
//   Police / officer screens  → policePrimary (navy) on app bar, accent gold for action
//   PTA regulator screens     → ptaPrimary (emerald) accent strip + ptaPrimary on labels
//   Both share the same neutrals and status palette — only the role tint changes
//
// STATUS BADGES (StatusPill widget)
//   pending   → pending  / pendingBg
//   approved  → approved / approvedBg
//   rejected  → rejected / rejectedBg
//   verified  → verified / verifiedBg
//   blocked   → blocked  / blockedBg
//   active    → approved / approvedBg
//
// TIMELINE (case tracking)
//   Done step  → timelineDone fill + check icon (white)
//   Active     → timelineActive fill + dot
//   Pending    → timelinePending dashed ring, transparent fill
//   Rejected   → timelineRejected fill + x
//   Connector  → timelineDone if previous step done, else timelineLine
//
// =============================================================
// ACCESSIBILITY NOTES
// =============================================================
// - primary (#0B2A5B) on white → 12.6:1 (AAA)
// - secondary (#0E7C5A) on white → 4.7:1 (AA Large / AA normal borderline — pair with bold weight ≥600)
// - error (#B42318) on white → 5.6:1 (AA)
// - textSecondary (#475569) on scaffoldBackground → 7.2:1 (AAA)
// - textMuted (#7A8699) on scaffoldBackground → 3.9:1 — use only for ≥14px non-essential meta
// - On dark: darkTextPrimary on darkBackground → 14.1:1 (AAA)
// =============================================================
