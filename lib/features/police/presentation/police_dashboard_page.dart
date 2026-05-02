import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/widgets/app_button.dart';
import '../../../theme/colors.dart';
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
          : AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'OFFICER MODE',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.policePrimary,
        foregroundColor: Colors.white,
      ),
      body: firsAsync.when(
        data: (firs) {
          final pendingCount = firs
              .where((f) => f.caseStatus == CaseStatus.firUnderReview)
              .length;
          final verifiedCount = firs
              .where((f) => f.caseStatus == CaseStatus.firVerified)
              .length;
          final rejectedCount = firs
              .where((f) => f.caseStatus == CaseStatus.firRejected)
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppPadding.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatCard(
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: AppRadius.allMd,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: isDark
            ? null
            : [
                const BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              AppSpacing.hSm,
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
