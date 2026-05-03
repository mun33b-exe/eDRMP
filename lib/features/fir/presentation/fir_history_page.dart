import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/utils/app_sizes.dart';
import '../../../core/widgets/app_app_bar.dart';
import '../../../core/widgets/empty_state.dart';
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
            return const EmptyState(
              icon: Icons.shield_outlined,
              title: AppStrings.firHistoryEmpty,
              message: AppStrings.firHistoryEmptyBody,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(firsProvider);
              await ref.read(firsProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppPadding.lg),
              itemCount: firs.length,
              separatorBuilder: (context, index) => AppSpacing.vMd,
              itemBuilder: (context, index) {
                return _FirCard(
                  fir: firs[index],
                  isDark: isDark,
                  onTap: () {
                    context.push(
                      RouteNames.caseTracking,
                      extra: firs[index].id,
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const _FirListSkeleton(),
        error: (e, _) =>
            const Center(child: Text(AppStrings.somethingWentWrong)),
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
      case CaseStatus.unblockApproved:
      case CaseStatus.unblocked:
        return StatusBadgeVariant.verified;
      case CaseStatus.firSubmitted:
      case CaseStatus.firUnderReview:
      case CaseStatus.blockPending:
      case CaseStatus.unblockPending:
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
        return AppStrings.caseTimelineDeviceRegistered;
      case CaseStatus.firSubmitted:
        return AppStrings.caseTimelineFirSubmitted;
      case CaseStatus.firUnderReview:
        return AppStrings.caseTimelineFirUnderReview;
      case CaseStatus.firVerified:
        return AppStrings.caseTimelineFirVerified;
      case CaseStatus.firRejected:
        return AppStrings.caseTimelineFirRejected;
      case CaseStatus.blockPending:
        return AppStrings.caseTimelineBlockPending;
      case CaseStatus.blockApproved:
        return AppStrings.caseTimelineBlockApproved;
      case CaseStatus.blockRejected:
        return AppStrings.caseTimelineBlockRejected;
      case CaseStatus.deviceBlocked:
        return AppStrings.caseTimelineDeviceBlocked;
      case CaseStatus.deviceRecovered:
        return AppStrings.caseTimelineDeviceRecovered;
      case CaseStatus.unblockPending:
        return AppStrings.caseTimelineUnblockPending;
      case CaseStatus.unblockApproved:
        return AppStrings.caseTimelineUnblockApproved;
      case CaseStatus.unblocked:
        return AppStrings.caseTimelineDeviceUnblocked;
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
          color: isDark ? AppColors.darkSurfaceElevated : AppColors.card,
          borderRadius: AppRadius.allMd,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    fir.deviceInfo.split('·').first.trim(),
                    style: TextStyle(
                      fontSize: AppSizes.bodyRegular(context),
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
              '${AppStrings.caseIdLabel} ${fir.id.split('-').first.toUpperCase()}',
              style: TextStyle(
                fontSize: AppSizes.bodySmall(context),
                fontFamily: 'monospace',
                letterSpacing: 0.3,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.vSm,
            Row(
              children: [
                Icon(
                  Icons.local_police_outlined,
                  size: 14,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                ),
                AppSpacing.hXs,
                Expanded(
                  child: Text(
                    fir.policeStation,
                    style: TextStyle(
                      fontSize: AppSizes.bodySmall(context),
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppSpacing.hSm,
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: AppSizes.bodySmall(context),
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary,
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

class _FirListSkeleton extends StatelessWidget {
  const _FirListSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkSurfaceElevated : AppColors.card;
    final highlightColor = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.6)
        : AppColors.background;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppPadding.lg),
        itemCount: 4,
        separatorBuilder: (_, _) => AppSpacing.vMd,
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.all(AppPadding.md),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: AppRadius.allMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 12,
                    width: 180,
                    decoration: BoxDecoration(
                      color: highlightColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Container(
                    height: 22,
                    width: 64,
                    decoration: BoxDecoration(
                      color: highlightColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
              AppSpacing.vSm,
              Container(
                height: 10,
                width: 120,
                decoration: BoxDecoration(
                  color: highlightColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              AppSpacing.vSm,
              Container(
                height: 10,
                width: 220,
                decoration: BoxDecoration(
                  color: highlightColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
