import 'package:flutter/material.dart';

/// Spacing scale — Design.md Section 2.3
/// Base Unit: 4px
/// xs: 4px, sm: 8px, md: 16px, lg: 24px, xl: 32px, xxl: 48px
class AppPadding {
  AppPadding._();

  static const double xs = 4;   // tight spacing, small padding
  static const double sm = 8;   // button padding, small gaps
  static const double md = 16;  // standard padding, form spacing
  static const double lg = 24;  // section spacing, large gaps
  static const double xl = 32;  // page-level spacing, major sections
  static const double xxl = 48; // very large gaps, rarely used

  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);
  static const EdgeInsets allXxl = EdgeInsets.all(xxl);

  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);

  /// Page padding: 16px horizontal, 24px top/bottom
  static const EdgeInsets screen = EdgeInsets.fromLTRB(md, lg, md, lg);

  /// Card padding: 16px all sides
  static const EdgeInsets card = EdgeInsets.all(md);

  /// Form field spacing: 16px between fields
  static const EdgeInsets formField = EdgeInsets.symmetric(vertical: md);
}
