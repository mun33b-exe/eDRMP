import 'package:flutter/material.dart';

import '../constants/app_padding.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../../theme/colors.dart';

/// Visual variants for [AppButton].
enum AppButtonVariant { primary, success, reject, ghost, disabled }

/// Primary call-to-action button used across the app.
///
/// Renders one of five visual variants and supports a loading spinner that
/// preserves the button's intrinsic height to avoid layout jump.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  bool get _isDisabled =>
      variant == AppButtonVariant.disabled || onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = _palette(context);
    final child = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(colors.foreground),
            ),
          )
        : _ButtonContent(label: label, icon: icon);

    final button = variant == AppButtonVariant.ghost
        ? OutlinedButton(
            onPressed: _isDisabled ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.foreground,
              side: BorderSide(color: colors.border),
              minimumSize: const Size.fromHeight(52),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.allMd,
              ),
            ),
            child: child,
          )
        : ElevatedButton(
            onPressed: _isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.background,
              foregroundColor: colors.foreground,
              disabledBackgroundColor: AppColors.border,
              disabledForegroundColor: AppColors.textMuted,
              minimumSize: const Size.fromHeight(52),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.allMd,
              ),
            ),
            child: child,
          );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  _ButtonPalette _palette(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    switch (variant) {
      case AppButtonVariant.primary:
        return _ButtonPalette(
          background: brightness == Brightness.dark
              ? AppColors.primaryLight
              : AppColors.primary,
          foreground: AppColors.onPrimary,
          border: AppColors.border,
        );
      case AppButtonVariant.success:
        return const _ButtonPalette(
          background: AppColors.success,
          foreground: AppColors.onPrimary,
          border: AppColors.success,
        );
      case AppButtonVariant.reject:
        return const _ButtonPalette(
          background: AppColors.error,
          foreground: AppColors.onPrimary,
          border: AppColors.error,
        );
      case AppButtonVariant.ghost:
        return _ButtonPalette(
          background: Colors.transparent,
          foreground: brightness == Brightness.dark
              ? AppColors.darkTextPrimary
              : AppColors.textPrimary,
          border: brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.border,
        );
      case AppButtonVariant.disabled:
        return const _ButtonPalette(
          background: AppColors.border,
          foreground: AppColors.textMuted,
          border: AppColors.border,
        );
    }
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.sm),
        child: Text(label, overflow: TextOverflow.ellipsis),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        AppSpacing.hSm,
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _ButtonPalette {
  const _ButtonPalette({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}
