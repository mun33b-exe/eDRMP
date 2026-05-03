// =============================================================
// eDRMP — app_sizes.dart
// Responsive size utilities — Design.md Appendix B
// Replaces raw static px values with context-aware equivalents.
// =============================================================

import 'package:flutter/material.dart';

import 'responsive.dart';

/// Context-aware size helpers.
///
/// All methods read [MediaQuery] through the [ResponsiveContext] extension
/// and return values appropriate for the current screen width.
///
/// Usage:
/// ```dart
/// AppSizes.iconMd(context)            // 44 on mobile, 48 on tablet/desktop
/// AppSizes.avatarRadius(context)      // 24 on mobile, 28 on tablet
/// AppSizes.quickActionAspect(context) // childAspectRatio for the 2×2 grid
/// ```
class AppSizes {
  AppSizes._();

  // ---------------------------------------------------------------------------
  // Icon / avatar sizes
  // ---------------------------------------------------------------------------

  /// Small icon container — 36 mobile / 40 tablet / 44 desktop.
  static double iconSm(BuildContext context) =>
      context.responsive(mobile: 36.0, tablet: 40.0, desktop: 44.0);

  /// Medium icon container — 44 mobile / 48 tablet / 52 desktop.
  static double iconMd(BuildContext context) =>
      context.responsive(mobile: 44.0, tablet: 48.0, desktop: 52.0);

  /// Large icon container — 56 mobile / 60 tablet / 64 desktop.
  static double iconLg(BuildContext context) =>
      context.responsive(mobile: 56.0, tablet: 60.0, desktop: 64.0);

  /// Avatar / profile photo size — 64 mobile / 72 tablet.
  static double avatar(BuildContext context) =>
      context.responsive(mobile: 64.0, tablet: 72.0, desktop: 80.0);

  // ---------------------------------------------------------------------------
  // Hero / header
  // ---------------------------------------------------------------------------

  /// Vertical padding for the hero gradient header.
  /// Adds status-bar height so the content clears the system UI.
  static EdgeInsets heroPadding(BuildContext context) {
    final hp = context.responsiveHorizontalPadding;
    final statusBar = context.statusBarHeight;
    return EdgeInsets.fromLTRB(hp, statusBar + 16, hp, 24);
  }

  // ---------------------------------------------------------------------------
  // Grid / layout helpers
  // ---------------------------------------------------------------------------

  /// `childAspectRatio` for the Quick Actions 2×2 grid.
  ///
  /// A wider screen can fit slightly wider tiles, so the ratio grows.
  static double quickActionAspect(BuildContext context) =>
      context.responsive(mobile: 2.2, tablet: 3.0, desktop: 3.8);

  /// Number of columns for device grids — 1 mobile / 2 tablet / 3 desktop.
  static int deviceGridColumns(BuildContext context) =>
      context.responsive(mobile: 1, tablet: 2, desktop: 3);

  // ---------------------------------------------------------------------------
  // Touch target minimum (Design.md §6.2 — 48×48 dp)
  // ---------------------------------------------------------------------------

  /// Minimum interactive element height — always 48 dp per accessibility rules.
  static const double minTouchTarget = 48.0;

  // ---------------------------------------------------------------------------
  // Font sizes (responsive wrappers around Design.md type scale)
  // ---------------------------------------------------------------------------

  /// H1 — 32 at baseline, scales with screen.
  static double h1(BuildContext context) =>
      context.responsiveFontSize(32, minSize: 24, maxSize: 40);

  /// H2 — 24 at baseline.
  static double h2(BuildContext context) =>
      context.responsiveFontSize(24, minSize: 18, maxSize: 30);

  /// H3 — 20 at baseline.
  static double h3(BuildContext context) =>
      context.responsiveFontSize(20, minSize: 16, maxSize: 26);

  /// Body large — 16 at baseline.
  static double bodyLarge(BuildContext context) =>
      context.responsiveFontSize(16, minSize: 13, maxSize: 20);

  /// Body regular — 14 at baseline.
  static double bodyRegular(BuildContext context) =>
      context.responsiveFontSize(14, minSize: 12, maxSize: 18);

  /// Body small — 12 at baseline.
  static double bodySmall(BuildContext context) =>
      context.responsiveFontSize(12, maxSize: 15);
}
