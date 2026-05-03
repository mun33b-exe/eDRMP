import 'package:flutter/material.dart';

import '../constants/app_padding.dart';
import '../constants/app_spacing.dart';
import '../../theme/colors.dart';
import 'app_button.dart';

/// Standard empty / error placeholder.
///
/// Use the [icon] to convey tone (e.g. inbox vs. error). Provide an
/// [actionLabel] + [onAction] pair to surface a recovery CTA.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final brightness = Theme.of(context).brightness;
    final iconColor = brightness == Brightness.dark
        ? AppColors.darkTextTertiary
        : AppColors.textTertiary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: iconColor),
            AppSpacing.vLg,
            Text(
              title,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              AppSpacing.vSm,
              Text(
                message!,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.vXl,
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
