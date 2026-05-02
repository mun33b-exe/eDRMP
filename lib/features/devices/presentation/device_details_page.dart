import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/widgets/app_app_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_timeline.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../theme/colors.dart';
import '../data/device_model.dart';
import '../logic/device_provider.dart';

// ---------------------------------------------------------------------------
// Device Details Page — pixel match to ScreenDeviceDetail in screens-citizen.jsx
// ---------------------------------------------------------------------------

class DeviceDetailsPage extends ConsumerWidget {
  const DeviceDetailsPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(deviceByIdProvider(deviceId));
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    if (device == null) {
      return const Scaffold(
        appBar: AppAppBar(title: AppStrings.deviceDetailsTitle),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(AppStrings.deviceDetailsTitle),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppPadding.lg,
          0,
          AppPadding.lg,
          AppPadding.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device card (variant 'c' — expanded, with all detail fields)
            _DeviceDetailCard(device: device, isDark: isDark),
            AppSpacing.vLg,
            // Action buttons — matches JSX 2-col grid
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: AppStrings.deviceDetailsTransfer,
                    variant: AppButtonVariant.ghost,
                    onPressed: () {},
                    icon: Icons.swap_horiz_outlined,
                  ),
                ),
                AppSpacing.hMd,
                Expanded(
                  child: AppButton(
                    label: AppStrings.deviceDetailsReportFir,
                    variant: AppButtonVariant.reject,
                    onPressed: device.status.canFileFir
                        ? () => context.push(RouteNames.submitFir)
                        : null,
                    icon: Icons.shield_outlined,
                  ),
                ),
              ],
            ),
            if (!device.status.canFileFir) ...[
              AppSpacing.vSm,
              Text(
                AppStrings.deviceDetailsReportFirDisabled,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
            ],
            AppSpacing.vXl,
            // Application timeline
            Text(
              AppStrings.deviceDetailsTimeline,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            AppSpacing.vMd,
            _TimelineCard(device: device, isDark: isDark),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Expanded device card (variant 'c' from components.jsx)
// ---------------------------------------------------------------------------

class _DeviceDetailCard extends StatelessWidget {
  const _DeviceDetailCard({required this.device, required this.isDark});

  final DeviceModel device;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          // Top row: phone glyph + model + status badge
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.inputFill,
                  borderRadius: AppRadius.allMd,
                ),
                child: Icon(
                  Icons.smartphone_outlined,
                  size: 26,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.model,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      device.brand,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: device.status.displayName,
                variant: _statusVariant(device.status),
              ),
            ],
          ),
          AppSpacing.vMd,
          // Divider
          Divider(
            height: 1,
            color: isDark ? AppColors.darkDivider : AppColors.divider,
          ),
          AppSpacing.vMd,
          // Detail rows
          _DetailRow(
            label: AppStrings.deviceDetailsImei,
            value: device.imei,
            mono: true,
            isDark: isDark,
          ),
          if (device.imei2 != null) ...[
            AppSpacing.vSm,
            _DetailRow(
              label: '${AppStrings.deviceDetailsImei} 2',
              value: device.imei2!,
              mono: true,
              isDark: isDark,
            ),
          ],
          AppSpacing.vSm,
          _DetailRow(
            label: AppStrings.deviceDetailsOperator,
            value: device.operator,
            isDark: isDark,
          ),
          AppSpacing.vSm,
          _DetailRow(
            label: AppStrings.deviceDetailsDate,
            value: device.displayDate,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  StatusBadgeVariant _statusVariant(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.approved:
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.mono = false,
  });

  final String label;
  final String value;
  final bool isDark;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: mono ? 'monospace' : null,
              letterSpacing: mono ? 0.3 : 0,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Application timeline card
// Matches Timeline component in components.jsx:
//   state: 'done' | 'active' | 'pending'
// ---------------------------------------------------------------------------

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.device, required this.isDark});

  final DeviceModel device;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final items = _buildItems(device.status);
    return AppTimeline(items: items, isDark: isDark);
  }

  List<AppTimelineItemData> _buildItems(DeviceStatus status) {
    // Map device status to timeline state for each step.
    // States: 'done', 'active', 'pending'
    switch (status) {
      case DeviceStatus.pending:
        return [
          const AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelineSubmitted,
            meta: '28 Apr 2026 · 10:42 AM',
          ),
          const AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelineDocVerified,
            meta: '28 Apr 2026 · 11:15 AM',
            note: 'Invoice and CNIC validated by automated checks.',
          ),
          const AppTimelineItemData(
            state: 'active',
            title: AppStrings.timelinePtaReview,
            meta: 'In queue · est. 2 days',
          ),
          const AppTimelineItemData(
            state: 'pending',
            title: AppStrings.timelineApproved,
            meta: 'Awaiting',
          ),
        ];
      case DeviceStatus.approved:
        return [
          const AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelineSubmitted,
            meta: '12 Mar 2026 · 09:14 AM',
          ),
          const AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelineDocVerified,
            meta: '12 Mar 2026 · 10:01 AM',
          ),
          const AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelinePtaReview,
            meta: '13 Mar 2026 · 14:22 PM',
          ),
          const AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelineApproved,
            meta: '14 Mar 2026 · 08:30 AM',
          ),
        ];
      case DeviceStatus.rejected:
      case DeviceStatus.blocked:
        return [
          const AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelineSubmitted,
            meta: '—',
          ),
          const AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelineDocVerified,
            meta: '—',
          ),
          const AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelinePtaReview,
            meta: '—',
          ),
          AppTimelineItemData(
            state: 'done',
            title: status == DeviceStatus.rejected
                ? 'Application rejected'
                : 'Device blocked',
            meta: '—',
          ),
        ];
    }
  }
}
