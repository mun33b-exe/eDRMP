import 'package:flutter/material.dart';

import '../constants/app_padding.dart';
import '../constants/app_radius.dart';
import '../../theme/colors.dart';

/// Surface container with the app's standard border, radius, and padding.
///
/// Pass [onTap] to make the card behave like a button.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = AppPadding.card,
    this.onTap,
    this.borderColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final defaultBorder = brightness == Brightness.dark
        ? AppColors.darkBorder
        : AppColors.border;
    final background = brightness == Brightness.dark
        ? AppColors.darkSurfaceElevated
        : AppColors.card;

    final body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.allLg,
        border: Border.all(color: borderColor ?? defaultBorder),
      ),
      child: child,
    );

    if (onTap == null) {
      return body;
    }
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.allLg,
      child: InkWell(onTap: onTap, borderRadius: AppRadius.allLg, child: body),
    );
  }
}
