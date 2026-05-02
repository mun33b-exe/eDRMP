import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/widgets/app_app_bar.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../theme/colors.dart';
import '../data/fir_model.dart';
import '../logic/fir_provider.dart';

class FirHistoryPage extends ConsumerWidget {
  const FirHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firsAsync = ref.watch(firsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const AppAppBar(title: AppStrings.titleFirHistory),
      body: firsAsync.when(
        data: (firs) {
          if (firs.isEmpty) {
            return const _EmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppPadding.lg),
            itemCount: firs.length,
            separatorBuilder: (context, index) => AppSpacing.vMd,
            itemBuilder: (context, index) {
              return _FirCard(
                fir: firs[index],
                isDark: isDark,
                onTap: () {
                  context.push(RouteNames.caseTracking, extra: firs[index].id);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _FirCard extends StatelessWidget {
  const _FirCard({
    required this.fir,
    required this.isDark,
    required this.onTap,
  });

  final FirModel fir;
  final bool isDark;
  final VoidCallback onTap;

  StatusBadgeVariant _mapStatus(CaseStatus s) {
    switch (s) {
      case CaseStatus.deviceRegistered:
      case CaseStatus.firVerified:
      case CaseStatus.blockApproved:
      case CaseStatus.deviceRecovered:
        return StatusBadgeVariant.verified;
      case CaseStatus.firSubmitted:
      case CaseStatus.firUnderReview:
      case CaseStatus.blockPending:
        return StatusBadgeVariant.pending;
      case CaseStatus.firRejected:
      case CaseStatus.blockRejected:
        return StatusBadgeVariant.rejected;
      case CaseStatus.deviceBlocked:
        return StatusBadgeVariant.blocked;
    }
  }

  String _statusText(CaseStatus s) {
    switch (s) {
      case CaseStatus.deviceRegistered:
        return 'Registered';
      case CaseStatus.firSubmitted:
        return 'Submitted';
      case CaseStatus.firUnderReview:
        return 'Under Review';
      case CaseStatus.firVerified:
        return 'Verified';
      case CaseStatus.firRejected:
        return 'Rejected';
      case CaseStatus.blockPending:
        return 'Block Pending';
      case CaseStatus.blockApproved:
        return 'Block Approved';
      case CaseStatus.blockRejected:
        return 'Block Rejected';
      case CaseStatus.deviceBlocked:
        return 'Blocked';
      case CaseStatus.deviceRecovered:
        return 'Recovered';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(fir.incidentDate);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.allMd,
      child: Container(
        padding: const EdgeInsets.all(AppPadding.md),
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
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    fir.deviceInfo.split('·').first.trim(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppSpacing.hSm,
                StatusBadge(
                  label: _statusText(fir.caseStatus),
                  variant: _mapStatus(fir.caseStatus),
                ),
              ],
            ),
            AppSpacing.vXs,
            Text(
              'Case ID: ${fir.id.toUpperCase()}',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                letterSpacing: 0.3,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            AppSpacing.vSm,
            Row(
              children: [
                Icon(
                  Icons.local_police_outlined,
                  size: 14,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
                AppSpacing.hXs,
                Text(
                  fir.policeStation,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.textMuted,
                  ),
                ),
                const Spacer(),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.textMuted,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 110,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: AppRadius.allMd,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Center(
                child: Icon(
                  Icons.shield_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
            AppSpacing.vXl,
            Text(
              AppStrings.firHistoryEmpty,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            AppSpacing.vSm,
            Text(
              AppStrings.firHistoryEmptyBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
