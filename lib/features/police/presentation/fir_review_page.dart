import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/app_sizes.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_app_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input.dart';
import '../../../theme/colors.dart';
import '../../fir/data/fir_model.dart';
import '../../fir/logic/fir_provider.dart';

class FirReviewPage extends ConsumerWidget {
  const FirReviewPage({super.key, required this.firId});

  final String firId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firAsync = ref.watch(firByIdProvider(firId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.background,
      appBar: const AppAppBar(title: 'FIR Verification'),
      body: firAsync.when(
        data: (fir) {
          final isPending = fir.caseStatus == CaseStatus.firUnderReview;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveHorizontalPadding,
                    vertical: AppPadding.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Status Banner
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceElevated : AppColors.card,
                          borderRadius: AppRadius.allMd,
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.border,
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppPadding.lg),
                              color: isPending
                                  ? AppColors.pending
                                  : (fir.caseStatus == CaseStatus.firVerified
                                        ? AppColors.success
                                        : AppColors.error),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: AppSizes.iconMd(context),
                                    height: AppSizes.iconMd(context),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isPending
                                          ? Icons.access_time
                                          : (fir.caseStatus ==
                                                    CaseStatus.firVerified
                                                ? Icons.check_circle
                                                : Icons.cancel),
                                      color: Colors.white,
                                    ),
                                  ),
                                  AppSpacing.hMd,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'STATUS',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: AppSizes.bodySmall(context),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          isPending
                                              ? 'PENDING REVIEW'
                                              : (fir.caseStatus ==
                                                        CaseStatus.firVerified
                                                    ? 'VERIFIED'
                                                    : 'REJECTED'),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: AppSizes.h3(context),
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        if (fir.rejectReason != null) ...[
                                          AppSpacing.vSm,
                                          Text(
                                            fir.rejectReason!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(AppPadding.lg),
                              child: Column(
                                children: [
                                  _DetailRow(
                                    label: 'Case ID',
                                    value: fir.id.toUpperCase(),
                                    isDark: isDark,
                                    isMono: true,
                                  ),
                                  const Divider(),
                                  _DetailRow(
                                    label: 'Device',
                                    value: fir.deviceInfo,
                                    isDark: isDark,
                                  ),
                                  const Divider(),
                                  _DetailRow(
                                    label: 'Station',
                                    value: fir.policeStation,
                                    isDark: isDark,
                                  ),
                                  const Divider(),
                                  _DetailRow(
                                    label: 'Incident Date',
                                    value: DateFormat(
                                      'dd MMM yyyy, HH:mm',
                                    ).format(fir.incidentDate),
                                    isDark: isDark,
                                  ),
                                  const Divider(),
                                  _DetailRow(
                                    label: 'Description',
                                    value: fir.description,
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      AppSpacing.vXl,

                      // Logs
                      Container(
                        padding: const EdgeInsets.all(AppPadding.md),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.inputFill,
                          borderRadius: AppRadius.allSm,
                        ),
                        child: Text(
                          'Officer ID: PB-0429-118 · Loaded ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                          style: TextStyle(
                            fontSize: AppSizes.bodySmall(context),
                            fontFamily: 'monospace',
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.textTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              if (isPending)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveHorizontalPadding,
                    vertical: AppPadding.lg,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBackground
                        : AppColors.background,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        AppButton(
                          label: 'Verify & Approve FIR',
                          icon: Icons.check,
                          variant: AppButtonVariant.success,
                          onPressed: () => _handleVerify(context, ref, fir),
                        ),
                        AppSpacing.vMd,
                        AppButton(
                          label: 'Reject Application',
                          icon: Icons.close,
                          variant: AppButtonVariant.reject,
                          onPressed: () => _handleReject(context, ref, fir),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _handleVerify(BuildContext context, WidgetRef ref, FirModel fir) async {
    final confirm = await _showConfirmDialog(
      context,
      title: 'Verify FIR',
      content:
          'Are you sure you want to verify Case ${fir.id.toUpperCase()}? This will forward the block request to PTA.',
      confirmText: 'Verify',
      isDestructive: false,
    );

    if (confirm == true) {
      await ref
          .read(firsProvider.notifier)
          .updateFirStatus(fir.id, CaseStatus.firVerified);
      if (context.mounted) {
        context.pop();
      }
    }
  }

  void _handleReject(BuildContext context, WidgetRef ref, FirModel fir) async {
    final reasonController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject FIR'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please provide a reason for rejecting this FIR application.',
            ),
            AppSpacing.vMd,
            AppInput(
              label: 'Reason',
              controller: reasonController,
              hintText: 'e.g. Insufficient proof provided',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                return; // Must provide reason
              }
              Navigator.of(ctx).pop(true);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (result == true && reasonController.text.trim().isNotEmpty) {
      await ref
          .read(firsProvider.notifier)
          .updateFirStatus(
            fir.id,
            CaseStatus.firRejected,
            reasonController.text.trim(),
          );
      if (context.mounted) {
        context.pop();
      }
    }
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    required bool isDestructive,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive
                  ? AppColors.error
                  : AppColors.success,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isMono = false,
  });

  final String label;
  final String value;
  final bool isDark;
  final bool isMono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: context.responsive(mobile: 90.0, tablet: 110.0, desktop: 120.0),
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppSizes.bodyRegular(context),
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppSizes.bodyRegular(context),
                fontFamily: isMono ? 'monospace' : null,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
