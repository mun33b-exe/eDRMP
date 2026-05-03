import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../theme/colors.dart';
import '../../devices/data/device_model.dart';
import '../../devices/logic/device_provider.dart';

bool _isLuhnValid(String imei) {
  final digits = imei.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 15) return false;
  var sum = 0;
  for (var i = 0; i < digits.length; i++) {
    var d = int.parse(digits[i]);
    if (i.isOdd) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    sum += d;
  }
  return sum % 10 == 0;
}

class PtaHistoryPage extends ConsumerWidget {
  const PtaHistoryPage({this.device, super.key});

  final DeviceModel? device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final ownerName = device?.ownerName ?? 'Unknown';
    final ownerCnic = device?.ownerCnic ?? '—';
    final ownerPhone = device?.ownerPhone ?? '—';
    final deviceLabel = device != null
        ? '${device!.brand} ${device!.model}'.trim()
        : '—';
    final imei = device?.imei ?? '';
    final isImeiValid = _isLuhnValid(imei);
    final initials = ownerName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Application #APP-${now.year}-${device?.id.split('-').last ?? '???'}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '${device?.status.displayName ?? 'Review'} · ${DateFormat('dd MMM yyyy').format(now)}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppPadding.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User Info Card
                  _buildCard(
                    isDark: isDark,
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            color: AppColors.primarySoft,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initials.isEmpty ? '?' : initials,
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        AppSpacing.hMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ownerName,
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
                                'CNIC $ownerCnic · $ownerPhone',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  color: isDark
                                      ? AppColors.darkTextTertiary
                                      : AppColors.textTertiary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const StatusBadge(
                          label: 'Verified',
                          variant: StatusBadgeVariant.verified,
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.vLg,
                  Text(
                    'DEVICE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                    ),
                  ),
                  AppSpacing.vSm,
                  _buildCard(
                    isDark: isDark,
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AppPadding.md),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurface
                                      : AppColors.inputFill,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.smartphone,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              AppSpacing.hMd,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      deviceLabel,
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
                                      imei.isEmpty ? '—' : 'IMEI $imei',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.vLg,
                  Text(
                    'VERIFICATION CHECKS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                    ),
                  ),
                  AppSpacing.vSm,
                  _buildCard(
                    isDark: isDark,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _buildCheckRow(
                          'IMEI format valid (Luhn)',
                          isImeiValid ? 'pass' : 'warn',
                          isDark,
                        ),
                        _buildCheckRow(
                          'IMEI not previously registered',
                          device?.status == DeviceStatus.approved
                              ? 'warn'
                              : 'pass',
                          isDark,
                        ),
                        _buildCheckRow(
                          'CNIC matches NADRA',
                          ownerCnic == '—' ? 'warn' : 'pass',
                          isDark,
                        ),
                        _buildCheckRow(
                          'Invoice matches authorized dealer',
                          device?.invoicePath != null ? 'pass' : 'warn',
                          isDark,
                        ),
                        _buildCheckRow(
                          'Device not on stolen list',
                          device?.status == DeviceStatus.blocked
                              ? 'warn'
                              : 'pass',
                          isDark,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(AppPadding.lg),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Reject',
                      icon: Icons.close,
                      variant: AppButtonVariant.reject,
                      onPressed: () async {
                        if (device != null) {
                          await ref
                              .read(devicesProvider.notifier)
                              .updateDeviceStatus(
                                device!.id,
                                DeviceStatus.rejected,
                              );
                        }
                        if (context.mounted) context.pop();
                      },
                    ),
                  ),
                  AppSpacing.hMd,
                  Expanded(
                    child: AppButton(
                      label: 'Approve',
                      icon: Icons.check,
                      variant: AppButtonVariant.success,
                      onPressed: () async {
                        if (device != null) {
                          await ref
                              .read(devicesProvider.notifier)
                              .updateDeviceStatus(
                                device!.id,
                                DeviceStatus.approved,
                              );
                        }
                        if (context.mounted) context.pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    required bool isDark,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppPadding.lg),
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
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }

  Widget _buildCheckRow(
    String label,
    String status,
    bool isDark, {
    bool isLast = false,
  }) {
    final isPass = status == 'pass';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.md,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
          Row(
            children: [
              Icon(
                isPass ? Icons.check : Icons.warning_amber_rounded,
                size: 14,
                color: isPass ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 4),
              Text(
                isPass ? 'PASS' : 'REVIEW',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isPass ? AppColors.success : AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
