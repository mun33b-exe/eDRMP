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
import '../../../core/widgets/empty_state.dart';
import '../../../theme/colors.dart';
import '../../devices/data/device_model.dart';
import '../../devices/data/unblock_request_model.dart';
import '../../devices/logic/device_provider.dart';
import '../../fir/data/fir_model.dart';
import '../../fir/logic/fir_provider.dart';

class PtaUnblockRequestsPage extends ConsumerWidget {
  const PtaUnblockRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(pendingPtaUnblockProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              AppStrings.ptaRegulatoryLabel,
              style: TextStyle(
                fontSize: context.responsiveFontSize(11),
                fontWeight: FontWeight.w600,
                color: AppColors.success,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              AppStrings.ptaUnblockTitle,
              style: TextStyle(
                fontSize: context.responsiveFontSize(18),
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
      ),
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const EmptyState(
              icon: Icons.phonelink_off_outlined,
              title: AppStrings.ptaUnblockEmpty,
              message: AppStrings.ptaUnblockEmptyBody,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(pendingPtaUnblockProvider);
              await ref.read(pendingPtaUnblockProvider.future);
            },
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveHorizontalPadding,
                vertical: AppPadding.lg,
              ),
              itemCount: requests.length,
              separatorBuilder: (_, __) => AppSpacing.vMd,
              itemBuilder: (context, index) {
                return _PtaUnblockCard(
                  request: requests[index],
                  isDark: isDark,
                  onUnblock: () =>
                      _handleUnblock(context, ref, requests[index]),
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

  void _handleUnblock(
    BuildContext context,
    WidgetRef ref,
    UnblockRequestModel request,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.ptaUnblockConfirmTitle),
        content: const Text(AppStrings.ptaUnblockConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.success),
            child: const Text(AppStrings.ptaUnblockAction),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(unblockRequestRepositoryProvider)
          .ptaUnblock(request.id);
      // Update FIR status to deviceRecovered and device status to active
      await ref
          .read(firsProvider.notifier)
          .updateFirStatus(request.firId, CaseStatus.deviceRecovered);
      await ref
          .read(devicesProvider.notifier)
          .updateDeviceStatus(request.deviceId, DeviceStatus.unblocked);
      ref.invalidate(pendingPtaUnblockProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.ptaUnblockDone)),
        );
      }
    }
  }
}

class _PtaUnblockCard extends StatelessWidget {
  const _PtaUnblockCard({
    required this.request,
    required this.isDark,
    required this.onUnblock,
  });

  final UnblockRequestModel request;
  final bool isDark;
  final VoidCallback onUnblock;

  @override
  Widget build(BuildContext context) {
    final submittedStr =
        DateFormat('dd MMM yyyy, HH:mm').format(request.createdAt);
    final approvedStr = request.policeApprovedAt != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(request.policeApprovedAt!)
        : '—';

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
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: AppRadius.allSm,
                ),
                child: const Icon(
                  Icons.phonelink_off_outlined,
                  color: AppColors.success,
                  size: 18,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device: ${request.deviceId.split('-').first.toUpperCase()}',
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
                      'Police-approved · $approvedStr',
                      style: TextStyle(
                        fontSize: AppSizes.bodySmall(context),
                        color: AppColors.success,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FIR: ${request.firId.split('-').first.toUpperCase()}',
                  style: TextStyle(
                    fontSize: AppSizes.bodySmall(context),
                    fontFamily: 'monospace',
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Submitted: $submittedStr',
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
          AppSpacing.vMd,
          AppButton(
            label: AppStrings.ptaUnblockAction,
            icon: Icons.lock_open,
            variant: AppButtonVariant.success,
            onPressed: onUnblock,
          ),
        ],
      ),
    );
  }
}
