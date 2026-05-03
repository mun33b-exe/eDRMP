import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/utils/app_sizes.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../theme/colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../auth/logic/auth_controller.dart';
import '../../fir/data/fir_model.dart';
import '../../fir/logic/fir_provider.dart';

class PoliceDashboardPage extends ConsumerWidget {
  const PoliceDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firsAsync = ref.watch(firsProvider);

    // Police module is natively dark-themed in design, but we respect app theme.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.background,
      appBar: AppBar(
        title: Text(
          'OFFICER MODE',
          style: TextStyle(
            fontSize: AppSizes.bodyRegular(context),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.primary,
        foregroundColor: isDark ? AppColors.darkTextPrimary : Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_outlined),
            tooltip: AppStrings.verifyImeiTitle,
            onPressed: () => context.push(RouteNames.verifyImei),
          ),
          IconButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => const ConfirmDialog(
                  title: AppStrings.profileSignOut,
                  message: AppStrings.profileSignOutConfirm,
                  confirmLabel: AppStrings.profileSignOut,
                  isDestructive: true,
                ),
              );
              if (confirmed == true && context.mounted) {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) {
                  context.go(RouteNames.login);
                }
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: firsAsync.when(
        data: (firs) {
          final pendingCount = firs
              .where(
                (f) =>
                    f.caseStatus == CaseStatus.firSubmitted ||
                    f.caseStatus == CaseStatus.firUnderReview,
              )
              .length;
          final verifiedCount = firs
              .where((f) => f.caseStatus == CaseStatus.firVerified)
              .length;
          final rejectedCount = firs
              .where((f) => f.caseStatus == CaseStatus.firRejected)
              .length;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(firsProvider);
              await ref.read(firsProvider.future);
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveHorizontalPadding,
                vertical: AppPadding.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatCard(
                    context: context,
                    title: 'Pending FIRs',
                    value: pendingCount.toString(),
                    icon: Icons.pending_actions,
                    color: AppColors.pending,
                    isDark: isDark,
                  ),
                  AppSpacing.vMd,
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context: context,
                          title: 'Verified',
                          value: verifiedCount.toString(),
                          icon: Icons.check_circle_outline,
                          color: AppColors.success,
                          isDark: isDark,
                        ),
                      ),
                      AppSpacing.hMd,
                      Expanded(
                        child: _buildStatCard(
                          context: context,
                          title: 'Rejected',
                          value: rejectedCount.toString(),
                          icon: Icons.cancel_outlined,
                          color: AppColors.error,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vXl,
                  AppButton(
                    label: 'Open Pending Queue',
                    onPressed: () => context.push(RouteNames.pendingFirQueue),
                    icon: Icons.list_alt,
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.lg),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: AppRadius.allSm,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              AppSpacing.hSm,
              Text(
                title,
                style: TextStyle(
                  fontSize: AppSizes.bodySmall(context),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          AppSpacing.vMd,
          Text(
            value,
            style: TextStyle(
              fontSize: AppSizes.h1(context),
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
