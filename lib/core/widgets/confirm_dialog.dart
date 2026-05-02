import 'package:flutter/material.dart';

import '../constants/app_padding.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import 'app_button.dart';

/// Two-button confirmation dialog for destructive or sensitive actions.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    required this.title,
    required this.message,
    this.confirmLabel = AppStrings.confirm,
    this.cancelLabel = AppStrings.cancel,
    this.isDestructive = false,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  /// Show the dialog and resolve to `true` if the user confirms.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = AppStrings.confirm,
    String cancelLabel = AppStrings.cancel,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: textTheme.titleMedium),
            AppSpacing.vSm,
            Text(message, style: textTheme.bodyMedium),
            AppSpacing.vXl,
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: cancelLabel,
                    onPressed: () => Navigator.of(context).pop(false),
                    variant: AppButtonVariant.ghost,
                  ),
                ),
                AppSpacing.hMd,
                Expanded(
                  child: AppButton(
                    label: confirmLabel,
                    onPressed: () => Navigator.of(context).pop(true),
                    variant: isDestructive
                        ? AppButtonVariant.reject
                        : AppButtonVariant.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
