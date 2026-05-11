import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
import '../../fir/logic/fir_provider.dart';
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
          : AppColors.background,
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
                    onPressed: () => context.push(RouteNames.transferDevice),
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
                  color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
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
            if (device.status == DeviceStatus.blocked) ...[
              AppSpacing.vXl,
              _ReactivationCard(device: device, isDark: isDark),
            ],
            if (device.status == DeviceStatus.approved ||
                device.status == DeviceStatus.unblocked) ...[
              AppSpacing.vXl,
              _QrCard(device: device, isDark: isDark),
            ],
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
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.card,
        borderRadius: AppRadius.allLg,
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
        children: [
          // Top row: phone glyph + model + status badge
          Row(
            children: [
              Hero(
                tag: 'device-${device.id}',
                child: Container(
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
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary,
                  ),
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
                            ? AppColors.darkTextTertiary
                            : AppColors.textTertiary,
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
            color: isDark ? AppColors.darkBorder : AppColors.divider,
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
              color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
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
    final items = _buildItems(device);
    return AppTimeline(items: items, isDark: isDark);
  }

  static String _fmt(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final min = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day} ${months[d.month]} ${d.year} · $hour:$min $ampm';
  }

  List<AppTimelineItemData> _buildItems(DeviceModel device) {
    final submittedMeta = _fmt(device.registeredAt);
    switch (device.status) {
      case DeviceStatus.pending:
        return [
          AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelineSubmitted,
            meta: submittedMeta,
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
          AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelineSubmitted,
            meta: submittedMeta,
          ),
          const AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelineDocVerified,
            meta: 'Documents validated',
          ),
          const AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelinePtaReview,
            meta: 'Review complete',
          ),
          const AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelineApproved,
            meta: 'Device registered',
          ),
        ];
      case DeviceStatus.rejected:
        return [
          AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelineSubmitted,
            meta: submittedMeta,
          ),
          const AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelinePtaReview,
            meta: 'Review complete',
          ),
          const AppTimelineItemData(
            state: 'rejected',
            title: 'Application rejected',
            meta: 'See rejection details',
          ),
        ];
      case DeviceStatus.blocked:
        return [
          AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelineSubmitted,
            meta: submittedMeta,
          ),
          const AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelineApproved,
            meta: 'Was registered',
          ),
          const AppTimelineItemData(
            state: 'done',
            title: 'Device blocked',
            meta: 'Reported stolen — blocked on network',
          ),
        ];
      case DeviceStatus.unblocked:
        return [
          AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelineSubmitted,
            meta: submittedMeta,
          ),
          const AppTimelineItemData(
            state: 'done',
            title: AppStrings.timelineApproved,
            meta: 'Was registered',
          ),
          const AppTimelineItemData(
            state: 'done',
            title: 'Device unblocked',
            meta: 'Reactivated after recovery',
          ),
        ];
    }
  }
}

// ---------------------------------------------------------------------------
// QR code card — shown only for approved/unblocked devices
// ---------------------------------------------------------------------------

class _QrCard extends StatelessWidget {
  const _QrCard({required this.device, required this.isDark});

  final DeviceModel device;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final qrData = jsonEncode({'imei': device.imei, 'deviceId': device.id});

    return Container(
      padding: AppPadding.allLg,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.card,
        borderRadius: AppRadius.allLg,
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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.deviceQrTitle,
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
                      AppStrings.deviceQrSubtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 20),
                tooltip: AppStrings.deviceQrShareTooltip,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: device.imei));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(AppStrings.verifyImeiCopied),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          AppSpacing.vLg,
          Center(
            child: QrImageView(
              data: qrData,
              size: 180,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(color: AppColors.primary),
              dataModuleStyle: const QrDataModuleStyle(
                color: AppColors.primary,
              ),
            ),
          ),
          // TODO(Phase 9D): upload QR to device-qr-codes storage + insert device_qr_codes row.
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reactivation card — shown only for blocked devices
// ---------------------------------------------------------------------------

class _ReactivationCard extends ConsumerStatefulWidget {
  const _ReactivationCard({required this.device, required this.isDark});

  final DeviceModel device;
  final bool isDark;

  @override
  ConsumerState<_ReactivationCard> createState() => _ReactivationCardState();
}

class _ReactivationCardState extends ConsumerState<_ReactivationCard> {
  bool _loading = false;

  Future<void> _submit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.reactivateDialogTitle),
        content: const Text(AppStrings.reactivateDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.reactivateConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(firsProvider.notifier)
          .requestReactivation(widget.device.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.reactivateSuccess)),
        );
      }
    } on Exception catch (e) {
      if (!mounted) return;
      final msg = e.toString().contains('already_pending')
          ? AppStrings.reactivateAlreadyPending
          : e.toString().contains('no_fir')
              ? AppStrings.reactivateNoFir
              : AppStrings.somethingWentWrong;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Container(
      padding: const EdgeInsets.all(AppPadding.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.card,
        borderRadius: AppRadius.allLg,
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
            children: [
              const Icon(
                Icons.phonelink_ring_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              AppSpacing.hSm,
              Text(
                AppStrings.deviceFoundTitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Text(
            AppStrings.deviceFoundBody,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          AppSpacing.vMd,
          AppButton(
            label: AppStrings.deviceReactivateCta,
            onPressed: _loading ? null : _submit,
            isLoading: _loading,
            icon: Icons.lock_open_outlined,
          ),
        ],
      ),
    );
  }
}
