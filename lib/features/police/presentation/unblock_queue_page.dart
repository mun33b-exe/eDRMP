import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_sizes.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../theme/colors.dart';
import '../../devices/data/unblock_request_model.dart';
import '../../devices/logic/device_provider.dart';

class PoliceUnblockQueuePage extends ConsumerWidget {
  const PoliceUnblockQueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(pendingPoliceUnblockProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.policeUnblockTitle,
          style: TextStyle(
            fontSize: AppSizes.bodyLarge(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const EmptyState(
              icon: Icons.lock_open_outlined,
              title: AppStrings.policeUnblockEmpty,
              message: AppStrings.policeUnblockEmptyBody,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(pendingPoliceUnblockProvider);
              await ref.read(pendingPoliceUnblockProvider.future);
            },
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveHorizontalPadding,
                vertical: AppPadding.lg,
              ),
              itemCount: requests.length,
              separatorBuilder: (_, __) => AppSpacing.vMd,
              itemBuilder: (context, index) {
                return _UnblockRequestCard(
                  request: requests[index],
                  isDark: isDark,
                  onApprove: () =>
                      _handleApprove(context, ref, requests[index]),
                  onReject: () => _handleReject(context, ref, requests[index]),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _handleApprove(
    BuildContext context,
    WidgetRef ref,
    UnblockRequestModel request,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.policeUnblockApproveConfirmTitle),
        content: const Text(AppStrings.policeUnblockApproveConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.success),
            child: const Text(AppStrings.policeUnblockApprove),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(unblockRequestRepositoryProvider)
          .policeApprove(request.id);
      ref.invalidate(pendingPoliceUnblockProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.policeUnblockApproved)),
        );
      }
    }
  }

  void _handleReject(
    BuildContext context,
    WidgetRef ref,
    UnblockRequestModel request,
  ) async {
    final reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.policeUnblockRejectTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please provide a reason for rejecting this reactivation request.',
            ),
            AppSpacing.vMd,
            AppInput(
              label: AppStrings.policeUnblockReject,
              controller: reasonController,
              hintText: AppStrings.policeUnblockRejectHint,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) return;
              Navigator.of(ctx).pop(true);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.policeUnblockReject),
          ),
        ],
      ),
    );

    if (confirm == true && reasonController.text.trim().isNotEmpty) {
      await ref
          .read(unblockRequestRepositoryProvider)
          .reject(request.id, reasonController.text.trim());
      ref.invalidate(pendingPoliceUnblockProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.policeUnblockRejected)),
        );
      }
    }
  }
}

class _UnblockRequestCard extends StatelessWidget {
  const _UnblockRequestCard({
    required this.request,
    required this.isDark,
    required this.onApprove,
    required this.onReject,
  });

  final UnblockRequestModel request;
  final bool isDark;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('dd MMM yyyy, HH:mm').format(request.createdAt);

    return Container(
      padding: const EdgeInsets.all(AppPadding.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.card,
        borderRadius: AppRadius.allMd,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 0.5,
        ),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: AppRadius.allSm,
                ),
                child: const Icon(
                  Icons.lock_open_outlined,
                  color: AppColors.warning,
                  size: 18,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device ID: ${request.deviceId.split('-').first.toUpperCase()}',
                      style: TextStyle(
                        fontSize: AppSizes.bodyRegular(context),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Submitted $dateStr',
                      style: TextStyle(
                        fontSize: AppSizes.bodySmall(context),
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vMd,
          Container(
            padding: const EdgeInsets.all(AppPadding.sm),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.inputFill,
              borderRadius: AppRadius.allSm,
            ),
            child: Text(
              'FIR: ${request.firId.split('-').first.toUpperCase()}',
              style: TextStyle(
                fontSize: AppSizes.bodySmall(context),
                fontFamily: 'monospace',
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          AppSpacing.vMd,
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: AppStrings.policeUnblockApprove,
                  icon: Icons.check,
                  variant: AppButtonVariant.success,
                  onPressed: onApprove,
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: AppButton(
                  label: AppStrings.policeUnblockReject,
                  icon: Icons.close,
                  variant: AppButtonVariant.reject,
                  onPressed: onReject,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
