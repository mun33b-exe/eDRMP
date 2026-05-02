import 'package:flutter/material.dart';

import 'app_padding.dart';

/// Reusable `SizedBox` spacers built from the [AppPadding] scale.
class AppSpacing {
  AppSpacing._();

  static const SizedBox vXs = SizedBox(height: AppPadding.xs);
  static const SizedBox vSm = SizedBox(height: AppPadding.sm);
  static const SizedBox vMd = SizedBox(height: AppPadding.md);
  static const SizedBox vLg = SizedBox(height: AppPadding.lg);
  static const SizedBox vXl = SizedBox(height: AppPadding.xl);
  static const SizedBox vXxl = SizedBox(height: AppPadding.xxl);

  static const SizedBox hXs = SizedBox(width: AppPadding.xs);
  static const SizedBox hSm = SizedBox(width: AppPadding.sm);
  static const SizedBox hMd = SizedBox(width: AppPadding.md);
  static const SizedBox hLg = SizedBox(width: AppPadding.lg);
  static const SizedBox hXl = SizedBox(width: AppPadding.xl);
}
