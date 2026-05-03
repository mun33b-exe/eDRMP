import 'package:flutter/material.dart';

import 'app_padding.dart';

/// Reusable `SizedBox` spacers — Design.md Section 2.3
/// Built from the [AppPadding] scale: xs=4, sm=8, md=16, lg=24, xl=32, xxl=48
class AppSpacing {
  AppSpacing._();

  // Vertical spacers
  static const SizedBox vXs = SizedBox(height: AppPadding.xs);
  static const SizedBox vSm = SizedBox(height: AppPadding.sm);
  static const SizedBox vMd = SizedBox(height: AppPadding.md);
  static const SizedBox vLg = SizedBox(height: AppPadding.lg);
  static const SizedBox vXl = SizedBox(height: AppPadding.xl);
  static const SizedBox vXxl = SizedBox(height: AppPadding.xxl);

  // Horizontal spacers
  static const SizedBox hXs = SizedBox(width: AppPadding.xs);
  static const SizedBox hSm = SizedBox(width: AppPadding.sm);
  static const SizedBox hMd = SizedBox(width: AppPadding.md);
  static const SizedBox hLg = SizedBox(width: AppPadding.lg);
  static const SizedBox hXl = SizedBox(width: AppPadding.xl);
  static const SizedBox hXxl = SizedBox(width: AppPadding.xxl);

  // Section spacing (24px)
  static const SizedBox section = SizedBox(height: AppPadding.lg);

  // Form field gap (16px)
  static const SizedBox formGap = SizedBox(height: AppPadding.md);
}
