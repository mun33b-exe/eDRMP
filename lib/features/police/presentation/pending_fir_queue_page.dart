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
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../theme/colors.dart';
import '../../fir/data/fir_model.dart';
import '../../fir/logic/fir_provider.dart';

class PendingFirQueuePage extends ConsumerStatefulWidget {
  const PendingFirQueuePage({super.key});

  @override
  ConsumerState<PendingFirQueuePage> createState() =>
      _PendingFirQueuePageState();
}

class _PendingFirQueuePageState extends ConsumerState<PendingFirQueuePage> {
  String _filter = AppStrings.policeQueuePending; // Pending, All

  @override
  Widget build(BuildContext context) {
    final firsAsync = ref.watch(firsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.policeQueueTitle,
          style: TextStyle(fontSize: AppSizes.bodyLarge(context), fontWeight: FontWeight.w700),
        ),
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: firsAsync.when(
        data: (firs) {
          final filteredFirs = firs.where((f) {
            if (_filter == AppStrings.policeQueuePending) {
              return f.caseStatus == CaseStatus.firSubmitted ||
                  f.caseStatus == CaseStatus.firUnderReview;
            }
            if (_filter == AppStrings.policeQueueVerified) {
              return f.caseStatus == CaseStatus.firVerified;
            }
            if (_filter == AppStrings.policeQueueRejected) {
              return f.caseStatus == CaseStatus.firRejected;
            }
            return true;
          }).toList();

          return Column(
            children: [
              // Filter Chips
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveHorizontalPadding,
                  vertical: AppPadding.md,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip(AppStrings.policeQueuePending, isDark),
                      AppSpacing.hSm,
                      _buildChip(AppStrings.policeQueueVerified, isDark),
                      AppSpacing.hSm,
                      _buildChip(AppStrings.policeQueueRejected, isDark),
                      AppSpacing.hSm,
                      _buildChip(AppStrings.policeQueueAll, isDark),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: filteredFirs.isEmpty
                    ? const EmptyState(
                        icon: Icons.shield_outlined,
                        title: AppStrings.policeQueueEmptyTitle,
                        message: AppStrings.policeQueueEmptyBody,
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(firsProvider);
                          await ref.read(firsProvider.future);
                        },
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.responsiveHorizontalPadding,
                            vertical: AppPadding.lg,
                          ),
                          itemCount: filteredFirs.length,
                          separatorBuilder: (context, index) => AppSpacing.vMd,
                          itemBuilder: (context, index) {
                            return _FirQueueCard(
                              fir: filteredFirs[index],
                              isDark: isDark,
                              onTap: () {
                                context.push(
                                  RouteNames.firReview,
                                  extra: filteredFirs[index].id,
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
        loading: () => const _FirQueueSkeleton(),
        error: (e, _) =>
            const Center(child: Text(AppStrings.somethingWentWrong)),
      ),
    );
  }

  Widget _buildChip(String label, bool isDark) {
    final isSelected = _filter == label;
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? (isDark ? Colors.white : AppColors.primary)
              : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      backgroundColor: isSelected
          ? (isDark
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.primarySoft)
          : (isDark ? AppColors.darkSurfaceElevated : AppColors.inputFill),
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.darkBorder : AppColors.border),
      ),
      onPressed: () {
        setState(() {
          _filter = label;
        });
      },
    );
  }
}

class _FirQueueCard extends StatelessWidget {
  const _FirQueueCard({
    required this.fir,
    required this.isDark,
    required this.onTap,
  });

  final FirModel fir;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(fir.createdAt);

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
              : [
                  const BoxShadow(
                    color: AppColors.shadowLight,
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
                    '${AppStrings.policeQueueCasePrefix} ${fir.id.toUpperCase()}',
                    style: TextStyle(
                      fontSize: AppSizes.bodyRegular(context),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                StatusBadge(
                  label: _statusText(fir.caseStatus),
                  variant: _mapStatus(fir.caseStatus),
                ),
              ],
            ),
            AppSpacing.vSm,
            Text(
              fir.deviceInfo,
              style: TextStyle(
                fontSize: AppSizes.bodyRegular(context),
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            AppSpacing.vXs,
            Text(
              '${AppStrings.policeQueueStationPrefix} ${fir.policeStation}',
              style: TextStyle(
                fontSize: AppSizes.bodySmall(context),
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            AppSpacing.vSm,
            Divider(color: isDark ? AppColors.darkBorder : AppColors.border),
            AppSpacing.vXs,
            Text(
              '${AppStrings.policeQueueFiledPrefix} $dateStr',
              style: TextStyle(
                fontSize: AppSizes.bodySmall(context),
                color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  StatusBadgeVariant _mapStatus(CaseStatus s) {
    if (s == CaseStatus.firUnderReview) return StatusBadgeVariant.pending;
    if (s == CaseStatus.firVerified) return StatusBadgeVariant.verified;
    if (s == CaseStatus.firRejected) return StatusBadgeVariant.rejected;
    return StatusBadgeVariant.info;
  }

  String _statusText(CaseStatus s) {
    if (s == CaseStatus.firUnderReview) {
      return AppStrings.policeQueuePendingReview;
    }
    if (s == CaseStatus.firVerified) return AppStrings.policeQueueVerified;
    if (s == CaseStatus.firRejected) return AppStrings.policeQueueRejected;
    return AppStrings.policeQueueOther;
  }
}

class _FirQueueSkeleton extends StatelessWidget {
  const _FirQueueSkeleton();

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
                    width: 140,
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
                width: 220,
                decoration: BoxDecoration(
                  color: highlightColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              AppSpacing.vSm,
              Container(
                height: 10,
                width: 160,
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
