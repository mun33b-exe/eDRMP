import 'package:flutter/material.dart';

import '../../../../core/constants/app_padding.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../theme/colors.dart';

/// Brand header used at the top of every auth screen.
///
/// Renders the eDRMP wordmark inside a soft branded chip plus the page-level
/// title and supporting copy beneath it. Keeps the auth screens visually
/// cohesive without each one re-implementing the same layout.
class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final brightness = Theme.of(context).brightness;
    final chipBg = brightness == Brightness.dark
        ? AppColors.primaryDark
        : AppColors.primarySoft;
    final chipFg = brightness == Brightness.dark
        ? AppColors.buttonTextLight
        : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.sm + 4,
            vertical: AppPadding.xs + 2,
          ),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: AppRadius.allSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_outlined, size: 15, color: chipFg),
              AppSpacing.hSm,
              Text(
                AppStrings.appName,
                style: textTheme.labelMedium?.copyWith(
                  color: chipFg,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.vXl,
        Text(title, style: textTheme.displayLarge),
        AppSpacing.vSm,
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
