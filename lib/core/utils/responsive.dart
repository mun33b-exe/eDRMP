// =============================================================
// eDRMP — responsive.dart
// Screen-size helpers — Design.md Appendix B breakpoints
// Mobile: 0–480px | Tablet: 480–800px | Desktop: 800px+
// =============================================================

import 'package:flutter/material.dart';

/// Breakpoints from Design.md Appendix B.
enum AppBreakpoint {
  /// 0–480 logical pixels — phones (default target).
  mobile,

  /// 480–800 logical pixels — tablets, large phones in landscape.
  tablet,

  /// 800+ logical pixels — desktop, large tablets.
  desktop,
}

/// Responsive helpers available on any [BuildContext].
///
/// Usage:
/// ```dart
/// context.screenWidth          // logical width
/// context.isTablet             // true on 480+
/// context.responsiveFontSize(32)   // clamps 32px for current screen
/// context.responsivePadding       // horizontal page padding
/// ```
extension ResponsiveContext on BuildContext {
  // ---------------------------------------------------------------------------
  // Screen dimensions
  // ---------------------------------------------------------------------------

  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Logical pixels of the top media padding (status bar).
  double get statusBarHeight => MediaQuery.paddingOf(this).top;

  // ---------------------------------------------------------------------------
  // Breakpoint helpers
  // ---------------------------------------------------------------------------

  AppBreakpoint get breakpoint {
    final w = screenWidth;
    if (w >= 800) return AppBreakpoint.desktop;
    if (w >= 480) return AppBreakpoint.tablet;
    return AppBreakpoint.mobile;
  }

  bool get isMobile => breakpoint == AppBreakpoint.mobile;
  bool get isTablet => breakpoint == AppBreakpoint.tablet;
  bool get isDesktop => breakpoint == AppBreakpoint.desktop;

  // ---------------------------------------------------------------------------
  // Responsive font size
  // ---------------------------------------------------------------------------

  /// Scales [baseSize] proportionally to the screen width relative to the
  /// 360 dp baseline used in the Design.md spec.
  ///
  /// Clamps between [minSize] and [maxSize] to avoid extreme scaling.
  double responsiveFontSize(
    double baseSize, {
    double minSize = 10,
    double maxSize = 64,
  }) {
    const baselineWidth = 360.0;
    final scaleFactor = (screenWidth / baselineWidth).clamp(0.85, 1.3);
    return (baseSize * scaleFactor).clamp(minSize, maxSize);
  }

  // ---------------------------------------------------------------------------
  // Responsive layout values
  // ---------------------------------------------------------------------------

  /// Horizontal page padding — 16 px mobile, 24 px tablet, 32 px desktop.
  double get responsiveHorizontalPadding {
    switch (breakpoint) {
      case AppBreakpoint.desktop:
        return 32;
      case AppBreakpoint.tablet:
        return 24;
      case AppBreakpoint.mobile:
        return 16;
    }
  }

  /// Maximum content width for constrained layouts (cards, forms).
  /// Returns [double.infinity] on mobile so content fills the screen.
  double get maxContentWidth {
    switch (breakpoint) {
      case AppBreakpoint.desktop:
        return 900;
      case AppBreakpoint.tablet:
        return 600;
      case AppBreakpoint.mobile:
        return double.infinity;
    }
  }

  /// Returns the value matching the current breakpoint.
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (breakpoint) {
      case AppBreakpoint.desktop:
        return desktop ?? tablet ?? mobile;
      case AppBreakpoint.tablet:
        return tablet ?? mobile;
      case AppBreakpoint.mobile:
        return mobile;
    }
  }
}
