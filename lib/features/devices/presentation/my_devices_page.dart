import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/widgets/app_app_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../theme/colors.dart';
import '../data/device_model.dart';
import '../logic/device_provider.dart';

/// My Devices list page.
///
/// Filter chips (All / Active / Pending / Blocked) driven by local state.
/// Each `DeviceCard` taps through to `DeviceDetailsPage` via GoRouter extra.
class MyDevicesPage extends ConsumerStatefulWidget {
  const MyDevicesPage({super.key});

  @override
  ConsumerState<MyDevicesPage> createState() => _MyDevicesPageState();
}

class _MyDevicesPageState extends ConsumerState<MyDevicesPage> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final asyncDevices = ref.watch(devicesProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.scaffoldBackground,
      appBar: AppAppBar(
        title: AppStrings.titleMyDevices,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 24),
            tooltip: AppStrings.addDeviceTitle,
            onPressed: () => context.push(RouteNames.addDevice),
          ),
        ],
      ),
      body: asyncDevices.when(
        loading: () => const _DeviceListSkeleton(),
        error: (e, _) =>
            const Center(child: Text(AppStrings.somethingWentWrong)),
        data: (devices) {
          final filtered = _applyFilter(devices);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter chips
              _FilterRow(
                selected: _filter,
                onChanged: (f) => setState(() => _filter = f),
                isDark: isDark,
              ),
              // Device list or empty state
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.phone_android_outlined,
                        title: AppStrings.myDevicesEmpty,
                        message: AppStrings.myDevicesEmptyBody,
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(devicesProvider);
                          await ref.read(devicesProvider.future);
                        },
                        child: ListView.separated(
                          padding: AppPadding.screen,
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => AppSpacing.vMd,
                          itemBuilder: (context, i) {
                            final device = filtered[i];
                            return _DeviceCard(
                              device: device,
                              isDark: isDark,
                              onTap: () => context.push(
                                RouteNames.deviceDetails,
                                extra: device.id,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.addDevice),
        tooltip: AppStrings.addDeviceTitle,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<DeviceModel> _applyFilter(List<DeviceModel> devices) {
    switch (_filter) {
      case _Filter.all:
        return devices;
      case _Filter.active:
        return devices.where((d) => d.status == DeviceStatus.approved).toList();
      case _Filter.pending:
        return devices.where((d) => d.status == DeviceStatus.pending).toList();
      case _Filter.blocked:
        return devices
            .where(
              (d) =>
                  d.status == DeviceStatus.blocked ||
                  d.status == DeviceStatus.rejected,
            )
            .toList();
    }
  }
}

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum _Filter { all, active, pending, blocked }

// ---------------------------------------------------------------------------
// Filter chip row
// ---------------------------------------------------------------------------

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  final _Filter selected;
  final ValueChanged<_Filter> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const filters = [
      (_Filter.all, AppStrings.myDevicesFilterAll),
      (_Filter.active, AppStrings.myDevicesFilterActive),
      (_Filter.pending, AppStrings.myDevicesFilterPending),
      (_Filter.blocked, AppStrings.myDevicesFilterBlocked),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.lg,
          vertical: AppPadding.sm,
        ),
        itemCount: filters.length,
        separatorBuilder: (_, _) => AppSpacing.hSm,
        itemBuilder: (context, i) {
          final (filter, label) = filters[i];
          final isSelected = selected == filter;
          return GestureDetector(
            onTap: () => onChanged(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.md,
                vertical: AppPadding.xs,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkCard : AppColors.card),
                borderRadius: AppRadius.allPill,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.border),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Device card (matches DeviceCard variant 'a' from components.jsx)
// ---------------------------------------------------------------------------

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.device,
    required this.isDark,
    required this.onTap,
  });

  final DeviceModel device;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppPadding.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.card,
          borderRadius: AppRadius.allLg,
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
        child: Row(
          children: [
            // Phone glyph
            Hero(
              tag: 'device-${device.id}',
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.inputFill,
                  borderRadius: AppRadius.allMd,
                ),
                child: Icon(
                  Icons.smartphone_outlined,
                  size: 24,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
            ),
            AppSpacing.hMd,
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.brand == 'Unknown'
                        ? 'Unverified device'
                        : '${device.brand} ${device.model}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.vXs,
                  Text(
                    device.maskedImei,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      letterSpacing: 0.3,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.textMuted,
                    ),
                  ),
                  AppSpacing.vXs,
                  Text(
                    '${device.displayDate} · ${device.operator}',
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
            AppSpacing.hMd,
            // Status badge
            StatusBadge(
              label: device.status.displayName,
              variant: _statusVariant(device.status),
            ),
          ],
        ),
      ),
    );
  }

  StatusBadgeVariant _statusVariant(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.approved:
      case DeviceStatus.unblocked:
        return StatusBadgeVariant.approved;
      case DeviceStatus.pending:
        return StatusBadgeVariant.pending;
      case DeviceStatus.rejected:
        return StatusBadgeVariant.rejected;
      case DeviceStatus.blocked:
        return StatusBadgeVariant.blocked;
    }
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _DeviceListSkeleton extends StatelessWidget {
  const _DeviceListSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkCard : AppColors.card;
    final highlightColor = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.6)
        : AppColors.scaffoldBackground;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        padding: AppPadding.screen,
        itemCount: 4,
        separatorBuilder: (_, _) => AppSpacing.vMd,
        itemBuilder: (context, index) => Container(
          height: 72,
          padding: const EdgeInsets.all(AppPadding.md),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: AppRadius.allLg,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: highlightColor,
                  borderRadius: AppRadius.allMd,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 12,
                      width: 140,
                      decoration: BoxDecoration(
                        color: highlightColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    AppSpacing.vSm,
                    Container(
                      height: 10,
                      width: 180,
                      decoration: BoxDecoration(
                        color: highlightColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.hMd,
              Container(
                height: 24,
                width: 56,
                decoration: BoxDecoration(
                  color: highlightColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
