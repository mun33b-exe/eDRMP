import 'package:flutter/material.dart';

import '../constants/app_padding.dart';
import '../constants/app_radius.dart';
import '../../theme/colors.dart';

/// Workflow status pill used to surface device, FIR, and block states.
enum StatusBadgeVariant {
  pending,
  approved,
  rejected,
  verified,
  blocked,
  active,
  info,
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.label, required this.variant, super.key});

  final String label;
  final StatusBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final palette = _palette();
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.md,
        vertical: AppPadding.xs,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: AppRadius.allPill,
        border: Border.all(color: palette.foreground.withValues(alpha: 0.18)),
      ),
      child: Text(
        label.toUpperCase(),
        style: textTheme.labelSmall?.copyWith(color: palette.foreground),
      ),
    );
  }

  _BadgePalette _palette() {
    switch (variant) {
      case StatusBadgeVariant.pending:
        return const _BadgePalette(
          background: AppColors.warningLight,
          foreground: AppColors.pending,
        );
      case StatusBadgeVariant.approved:
      case StatusBadgeVariant.verified:
      case StatusBadgeVariant.active:
        return const _BadgePalette(
          background: AppColors.successLight,
          foreground: AppColors.approved,
        );
      case StatusBadgeVariant.rejected:
        return const _BadgePalette(
          background: AppColors.errorLight,
          foreground: AppColors.rejected,
        );
      case StatusBadgeVariant.blocked:
        return const _BadgePalette(
          background: AppColors.primarySoft,
          foreground: AppColors.primaryDark,
        );
      case StatusBadgeVariant.info:
        return const _BadgePalette(
          background: AppColors.infoLight,
          foreground: AppColors.info,
        );
    }
  }
}

class _BadgePalette {
  const _BadgePalette({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
