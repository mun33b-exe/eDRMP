import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../theme/colors.dart';
import '../../fir/data/fir_model.dart';
import '../../fir/logic/fir_provider.dart';

class BlockRequestsPage extends ConsumerStatefulWidget {
  const BlockRequestsPage({super.key});

  @override
  ConsumerState<BlockRequestsPage> createState() => _BlockRequestsPageState();
}

class _BlockRequestsPageState extends ConsumerState<BlockRequestsPage> {
  String _filter = 'Pending';

  @override
  Widget build(BuildContext context) {
    final firsAsync = ref.watch(firsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'PTA REGULATORY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.ptaPrimary,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Block requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
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
      body: firsAsync.when(
        data: (firs) {
          final filtered = firs.where((f) {
            final isPending =
                f.caseStatus == CaseStatus.firVerified ||
                f.caseStatus == CaseStatus.blockPending;
            final isBlocked =
                f.caseStatus == CaseStatus.blockApproved ||
                f.caseStatus == CaseStatus.deviceBlocked;
            final isRejected = f.caseStatus == CaseStatus.blockRejected;

            if (_filter == 'Pending') return isPending;
            if (_filter == 'Blocked') return isBlocked;
            if (_filter == 'Rejected') return isRejected;

            // "All" filter excludes initial citizen/police stages to keep list relevant to PTA
            return isPending || isBlocked || isRejected;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: isDark ? AppColors.darkSurface : Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.lg,
                  vertical: AppPadding.md,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip(
                        'Pending',
                        firs
                            .where(
                              (f) =>
                                  f.caseStatus == CaseStatus.firVerified ||
                                  f.caseStatus == CaseStatus.blockPending,
                            )
                            .length,
                        isDark,
                      ),
                      AppSpacing.hSm,
                      _buildChip(
                        'Blocked',
                        firs
                            .where(
                              (f) =>
                                  f.caseStatus == CaseStatus.blockApproved ||
                                  f.caseStatus == CaseStatus.deviceBlocked,
                            )
                            .length,
                        isDark,
                      ),
                      AppSpacing.hSm,
                      _buildChip(
                        'Rejected',
                        firs
                            .where(
                              (f) => f.caseStatus == CaseStatus.blockRejected,
                            )
                            .length,
                        isDark,
                      ),
                      AppSpacing.hSm,
                      _buildChip(
                        'All',
                        firs
                            .where(
                              (f) => [
                                CaseStatus.firVerified,
                                CaseStatus.blockPending,
                                CaseStatus.blockApproved,
                                CaseStatus.deviceBlocked,
                                CaseStatus.blockRejected,
                              ].contains(f.caseStatus),
                            )
                            .length,
                        isDark,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No block requests.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppPadding.lg),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => AppSpacing.vMd,
                        itemBuilder: (context, index) {
                          final f = filtered[index];
                          return _BlockRequestCard(
                            fir: f,
                            isDark: isDark,
                            onBlock: () => _handleBlock(context, ref, f),
                            onReject: () => _handleReject(context, ref, f),
                            onReview: () => context.push(RouteNames.ptaHistory),
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

  Widget _buildChip(String label, int count, bool isDark) {
    final isOn = _filter == label;
    return InkWell(
      onTap: () => setState(() => _filter = label),
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isOn
              ? AppColors.ptaPrimary
              : (isDark ? AppColors.darkCard : AppColors.inputFill),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isOn
                ? Colors.transparent
                : (isDark ? AppColors.darkBorder : AppColors.border),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isOn
                    ? Colors.white
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
              ),
            ),
            AppSpacing.hSm,
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isOn
                    ? Colors.white70
                    : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBlock(BuildContext context, WidgetRef ref, FirModel fir) async {
    await ref
        .read(firsProvider.notifier)
        .updateFirStatus(fir.id, CaseStatus.deviceBlocked);
  }

  void _handleReject(BuildContext context, WidgetRef ref, FirModel fir) async {
    await ref
        .read(firsProvider.notifier)
        .updateFirStatus(
          fir.id,
          CaseStatus.blockRejected,
          'Insufficient PTA validation',
        );
  }
}

class _BlockRequestCard extends StatelessWidget {
  const _BlockRequestCard({
    required this.fir,
    required this.isDark,
    required this.onBlock,
    required this.onReject,
    required this.onReview,
  });

  final FirModel fir;
  final bool isDark;
  final VoidCallback onBlock;
  final VoidCallback onReject;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM · HH:mm').format(fir.incidentDate);

    final isPending =
        fir.caseStatus == CaseStatus.firVerified ||
        fir.caseStatus == CaseStatus.blockPending;

    return Container(
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
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Case ${fir.id.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.vXs,
                  Text(
                    fir.policeStation,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              StatusBadge(
                label: _statusText(fir.caseStatus),
                variant: _mapStatus(fir.caseStatus),
              ),
            ],
          ),
          AppSpacing.vMd,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkInput : AppColors.inputFill,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    fir.deviceInfo,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
          ),
          if (isPending) ...[
            AppSpacing.vMd,
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Block',
                    onPressed: onBlock,
                    variant: AppButtonVariant.success,
                    icon: Icons.gavel,
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: AppButton(
                    label: 'Reject',
                    onPressed: onReject,
                    variant: AppButtonVariant.reject,
                    icon: Icons.close,
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: AppButton(
                    label: 'Review',
                    onPressed: onReview,
                    variant: AppButtonVariant.ghost,
                    icon: Icons.visibility,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  StatusBadgeVariant _mapStatus(CaseStatus s) {
    if (s == CaseStatus.blockApproved || s == CaseStatus.deviceBlocked) {
      return StatusBadgeVariant.verified;
    }
    if (s == CaseStatus.firVerified || s == CaseStatus.blockPending) {
      return StatusBadgeVariant.pending;
    }
    if (s == CaseStatus.blockRejected) {
      return StatusBadgeVariant.rejected;
    }
    return StatusBadgeVariant.info;
  }

  String _statusText(CaseStatus s) {
    if (s == CaseStatus.blockApproved || s == CaseStatus.deviceBlocked) {
      return 'Blocked';
    }
    if (s == CaseStatus.firVerified || s == CaseStatus.blockPending) {
      return 'Pending Block';
    }
    if (s == CaseStatus.blockRejected) {
      return 'Rejected';
    }
    return 'Other';
  }
}
