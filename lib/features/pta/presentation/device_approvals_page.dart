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
import '../../devices/data/device_model.dart';
import '../../devices/logic/device_provider.dart';

class DeviceApprovalsPage extends ConsumerStatefulWidget {
  const DeviceApprovalsPage({super.key});

  @override
  ConsumerState<DeviceApprovalsPage> createState() =>
      _DeviceApprovalsPageState();
}

class _DeviceApprovalsPageState extends ConsumerState<DeviceApprovalsPage> {
  String _filter = 'Pending';

  @override
  Widget build(BuildContext context) {
    final devicesAsync = ref.watch(devicesProvider);
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
              'Approval queue',
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
        actions: [
          _buildIconBtn(Icons.filter_list, isDark),
          AppSpacing.hSm,
          _buildIconBtn(Icons.search, isDark),
          AppSpacing.hLg,
        ],
      ),
      body: devicesAsync.when(
        data: (devices) {
          final filtered = devices.where((d) {
            if (_filter == 'Pending') return d.status == DeviceStatus.pending;
            if (_filter == 'Approved') return d.status == DeviceStatus.approved;
            if (_filter == 'Rejected') return d.status == DeviceStatus.rejected;
            return true; // All
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
                        devices
                            .where((d) => d.status == DeviceStatus.pending)
                            .length,
                        isDark,
                      ),
                      AppSpacing.hSm,
                      _buildChip(
                        'Approved',
                        devices
                            .where((d) => d.status == DeviceStatus.approved)
                            .length,
                        isDark,
                      ),
                      AppSpacing.hSm,
                      _buildChip(
                        'Rejected',
                        devices
                            .where((d) => d.status == DeviceStatus.rejected)
                            .length,
                        isDark,
                      ),
                      AppSpacing.hSm,
                      _buildChip('All', devices.length, isDark),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppPadding.lg),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => AppSpacing.vMd,
                  itemBuilder: (context, index) {
                    final d = filtered[index];
                    return _DeviceApprovalCard(
                      device: d,
                      isDark: isDark,
                      onApprove: () => _handleApprove(context, ref, d),
                      onReject: () => _handleReject(context, ref, d),
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

  Widget _buildIconBtn(IconData icon, bool isDark) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 17,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
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
                    'Citizen ID ${device.id.split('-').last}',
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
                    'CNIC 42101-1234567-8', // Mock CNIC
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.textMuted,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkInput : AppColors.inputFill,
              borderRadius: BorderRadius.circular(8),
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
                        fontSize: 12,
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
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
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
          if (device.status == DeviceStatus.pending) ...[
            AppSpacing.vMd,
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Approve',
                    onPressed: onApprove,
                    variant: AppButtonVariant.success,
                    icon: Icons.check,
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
