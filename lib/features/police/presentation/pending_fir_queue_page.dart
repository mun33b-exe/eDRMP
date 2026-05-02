import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routes/route_names.dart';
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
  String _filter = 'Pending'; // Pending, All

  @override
  Widget build(BuildContext context) {
    final firsAsync = ref.watch(firsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Approval queue',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.policePrimary,
        foregroundColor: Colors.white,
      ),
      body: firsAsync.when(
        data: (firs) {
          final filteredFirs = firs.where((f) {
            if (_filter == 'Pending') {
              return f.caseStatus == CaseStatus.firUnderReview;
            }
            return true;
          }).toList();

          return Column(
            children: [
              // Filter Chips
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.lg,
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
                child: Row(
                  children: [
                    _buildChip('Pending', isDark),
                    AppSpacing.hSm,
                    _buildChip('All', isDark),
                  ],
                ),
              ),
              Expanded(
                child: filteredFirs.isEmpty
                    ? const Center(child: Text('No FIRs in queue.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppPadding.lg),
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
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
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
              ? (isDark ? Colors.white : AppColors.policePrimary)
              : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      backgroundColor: isSelected
          ? (isDark
                ? AppColors.policePrimary.withValues(alpha: 0.3)
                : AppColors.primarySoft)
          : (isDark ? AppColors.darkCard : AppColors.inputFill),
      side: BorderSide(
        color: isSelected
            ? AppColors.policePrimary
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
                    'Case ${fir.id.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 14,
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
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            AppSpacing.vXs,
            Text(
              'Station: ${fir.policeStation}',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            AppSpacing.vSm,
            Divider(color: isDark ? AppColors.darkBorder : AppColors.border),
            AppSpacing.vXs,
            Text(
              'Filed: $dateStr',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
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
    if (s == CaseStatus.firUnderReview) return 'Pending Review';
    if (s == CaseStatus.firVerified) return 'Verified';
    if (s == CaseStatus.firRejected) return 'Rejected';
    return 'Other';
  }
}
