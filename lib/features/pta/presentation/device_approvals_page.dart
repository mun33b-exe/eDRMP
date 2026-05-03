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
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../theme/colors.dart';
import '../../devices/data/device_model.dart';
import '../../devices/logic/device_provider.dart';

class DeviceApprovalsPage extends ConsumerStatefulWidget {
  const DeviceApprovalsPage({super.key});

  @override
  ConsumerState<DeviceApprovalsPage> createState() =>
      _DeviceApprovalsPageState();
}

class _DeviceApprovalsPageState extends ConsumerState<DeviceApprovalsPage> {
  String _filter = AppStrings.ptaFilterPending;
  bool _showSearch = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final devicesAsync = ref.watch(devicesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              AppStrings.ptaRegulatoryLabel,
              style: TextStyle(
                fontSize: AppSizes.bodySmall(context),
                fontWeight: FontWeight.w600,
                color: AppColors.success,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              AppStrings.ptaApprovalQueueTitle,
              style: TextStyle(
                fontSize: AppSizes.h3(context),
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
        actions: [
          _buildIconBtn(
            Icons.filter_list,
            isDark,
            onTap: () => showModalBottomSheet<void>(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (_) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      [
                            AppStrings.ptaFilterPending,
                            AppStrings.ptaFilterApproved,
                            AppStrings.ptaFilterRejected,
                            AppStrings.ptaFilterAll,
                          ]
                          .map(
                            (f) => ListTile(
                              title: Text(f),
                              trailing: _filter == f
                                  ? const Icon(
                                      Icons.check,
                                      color: AppColors.success,
                                    )
                                  : null,
                              onTap: () {
                                setState(() => _filter = f);
                                Navigator.of(context).pop();
                              },
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
          ),
          AppSpacing.hSm,
          _buildIconBtn(
            Icons.search,
            isDark,
            onTap: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) _searchQuery = '';
            }),
          ),
          AppSpacing.hLg,
        ],
      ),
      body: devicesAsync.when(
        data: (devices) {
          final filtered = devices.where((d) {
            if (_filter == AppStrings.ptaFilterPending &&
                d.status != DeviceStatus.pending) {
              return false;
            }
            if (_filter == AppStrings.ptaFilterApproved &&
                d.status != DeviceStatus.approved) {
              return false;
            }
            if (_filter == AppStrings.ptaFilterRejected &&
                d.status != DeviceStatus.rejected) {
              return false;
            }
            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              final name = (d.ownerName ?? '').toLowerCase();
              final imei = d.imei.toLowerCase();
              final model = '${d.brand} ${d.model}'.toLowerCase();
              return name.contains(q) || imei.contains(q) || model.contains(q);
            }
            return true;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_showSearch)
                Container(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  padding: EdgeInsets.fromLTRB(
                    context.responsiveHorizontalPadding,
                    AppPadding.sm,
                    context.responsiveHorizontalPadding,
                    0,
                  ),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: AppStrings.ptaSearchHint,
                      prefixIcon: const Icon(Icons.search, size: 18),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurface
                          : AppColors.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border,
                        ),
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v.trim()),
                  ),
                ),
              Container(
                color: isDark ? AppColors.darkSurface : Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveHorizontalPadding,
                  vertical: AppPadding.md,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip(
                        AppStrings.ptaFilterPending,
                        devices
                            .where((d) => d.status == DeviceStatus.pending)
                            .length,
                        isDark,
                      ),
                      AppSpacing.hSm,
                      _buildChip(
                        AppStrings.ptaFilterApproved,
                        devices
                            .where((d) => d.status == DeviceStatus.approved)
                            .length,
                        isDark,
                      ),
                      AppSpacing.hSm,
                      _buildChip(
                        AppStrings.ptaFilterRejected,
                        devices
                            .where((d) => d.status == DeviceStatus.rejected)
                            .length,
                        isDark,
                      ),
                      AppSpacing.hSm,
                      _buildChip(
                        AppStrings.ptaFilterAll,
                        devices.length,
                        isDark,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.checklist,
                        title: AppStrings.ptaApprovalsEmpty,
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(devicesProvider);
                          await ref.read(devicesProvider.future);
                        },
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.responsiveHorizontalPadding,
                            vertical: AppPadding.lg,
                          ),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => AppSpacing.vMd,
                          itemBuilder: (context, index) {
                            final d = filtered[index];
                            return _DeviceApprovalCard(
                              device: d,
                              isDark: isDark,
                              onApprove: () => _handleApprove(context, ref, d),
                              onReject: () => _handleReject(context, ref, d),
                              onReview: () =>
                                  context.push(RouteNames.ptaHistory, extra: d),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
        loading: () => const _DeviceApprovalSkeleton(),
        error: (e, _) =>
            const Center(child: Text(AppStrings.somethingWentWrong)),
      ),
    );
  }

  Widget _buildIconBtn(
    IconData icon,
    bool isDark, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.iconSm(context),
        height: AppSizes.iconSm(context),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceElevated : AppColors.inputFill,
          borderRadius: AppRadius.allMd,
        ),
        child: Icon(
          icon,
          size: 17,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildChip(String label, int count, bool isDark) {
    final isOn = _filter == label;
    return InkWell(
      onTap: () => setState(() => _filter = label),
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.sm + 4, vertical: 6),
        decoration: BoxDecoration(
          color: isOn
              ? AppColors.success
              : (isDark ? AppColors.darkSurfaceElevated : AppColors.inputFill),
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
                fontSize: AppSizes.bodySmall(context),
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
                fontSize: AppSizes.bodySmall(context),
                fontWeight: FontWeight.w500,
                color: isOn
                    ? Colors.white70
                    : (isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleApprove(
    BuildContext context,
    WidgetRef ref,
    DeviceModel device,
  ) async {
    await ref
        .read(devicesProvider.notifier)
        .updateDeviceStatus(device.id, DeviceStatus.approved);
  }

  void _handleReject(
    BuildContext context,
    WidgetRef ref,
    DeviceModel device,
  ) async {
    await ref
        .read(devicesProvider.notifier)
        .updateDeviceStatus(device.id, DeviceStatus.rejected);
  }
}

class _DeviceApprovalCard extends StatelessWidget {
  const _DeviceApprovalCard({
    required this.device,
    required this.isDark,
    required this.onApprove,
    required this.onReject,
    required this.onReview,
  });

  final DeviceModel device;
  final bool isDark;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM · HH:mm').format(device.registeredAt);

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.ownerName ?? 'Citizen ${device.id.split('-').last}',
                    style: TextStyle(
                      fontSize: AppSizes.bodyRegular(context),
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.vXs,
                  Text(
                    'CNIC ${device.ownerCnic ?? "—"}',
                    style: TextStyle(
                      fontSize: AppSizes.bodySmall(context),
                      fontFamily: 'monospace',
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              StatusBadge(
                label: device.status.displayName,
                variant: _mapStatus(device.status),
              ),
            ],
          ),
          AppSpacing.vMd,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.sm + 2, vertical: AppPadding.sm),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.inputFill,
              borderRadius: AppRadius.allSm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${device.brand} ${device.model}',
                      style: TextStyle(
                        fontSize: AppSizes.bodySmall(context),
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    AppSpacing.vXs,
                    Text(
                      device.imei,
                      style: TextStyle(
                        fontSize: AppSizes.bodySmall(context),
                        fontFamily: 'monospace',
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.textTertiary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
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
          ),
          if (device.status == DeviceStatus.pending) ...[
            AppSpacing.vMd,
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: AppStrings.ptaApprove,
                    onPressed: onApprove,
                    variant: AppButtonVariant.success,
                    icon: Icons.check,
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: AppButton(
                    label: AppStrings.ptaReject,
                    onPressed: onReject,
                    variant: AppButtonVariant.reject,
                    icon: Icons.close,
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: AppButton(
                    label: AppStrings.ptaReviewCta,
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

  StatusBadgeVariant _mapStatus(DeviceStatus s) {
    if (s == DeviceStatus.approved) {
      return StatusBadgeVariant.verified;
    }
    if (s == DeviceStatus.pending) {
      return StatusBadgeVariant.pending;
    }
    if (s == DeviceStatus.rejected) {
      return StatusBadgeVariant.rejected;
    }
    return StatusBadgeVariant.info;
  }
}

class _DeviceApprovalSkeleton extends StatelessWidget {
  const _DeviceApprovalSkeleton();

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 12,
                    width: 160,
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
              AppSpacing.vMd,
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: highlightColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              AppSpacing.vMd,
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: highlightColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: highlightColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: highlightColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
