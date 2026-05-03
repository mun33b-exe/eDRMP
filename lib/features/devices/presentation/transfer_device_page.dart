import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_sizes.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../theme/colors.dart';
import '../../auth/logic/auth_controller.dart';
import '../data/device_model.dart';
import '../data/transfer_model.dart';
import '../logic/device_provider.dart';
import '../logic/transfer_provider.dart';

class TransferDevicePage extends ConsumerStatefulWidget {
  const TransferDevicePage({super.key});

  @override
  ConsumerState<TransferDevicePage> createState() => _TransferDevicePageState();
}

class _TransferDevicePageState extends ConsumerState<TransferDevicePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.transferTitle),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'New Transfer'),
            Tab(text: AppStrings.transferHistory),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _NewTransferTab(
            onSuccess: () => _tabCtrl.animateTo(1),
          ),
          const _TransferHistoryTab(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1: New Transfer form
// ---------------------------------------------------------------------------

class _NewTransferTab extends ConsumerStatefulWidget {
  const _NewTransferTab({required this.onSuccess});

  final VoidCallback onSuccess;

  @override
  ConsumerState<_NewTransferTab> createState() => _NewTransferTabState();
}

class _NewTransferTabState extends ConsumerState<_NewTransferTab> {
  final _formKey = GlobalKey<FormState>();
  final _cnicCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _selectedDeviceId;
  bool _loading = false;
  bool _success = false;

  @override
  void dispose() {
    _cnicCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final devicesAsync = ref.watch(devicesProvider);
    final user = ref.watch(currentUserProvider);

    if (_success) {
      return _SuccessView(
        isDark: isDark,
        onViewTransfers: widget.onSuccess,
      );
    }

    return devicesAsync.when(
      data: (devices) {
        final transferable = devices
            .where(
              (d) =>
                  d.status == DeviceStatus.approved ||
                  d.status == DeviceStatus.unblocked,
            )
            .toList();

        return Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveHorizontalPadding,
                    vertical: AppPadding.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.transferSubtitle,
                        style: TextStyle(
                          fontSize: AppSizes.bodyRegular(context),
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      AppSpacing.vLg,
                      // Device selector
                      Text(
                        AppStrings.transferSelectDevice,
                        style: TextStyle(
                          fontSize: AppSizes.bodySmall(context),
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      AppSpacing.vSm,
                      if (transferable.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(AppPadding.lg),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : AppColors.inputFill,
                            borderRadius: AppRadius.allMd,
                          ),
                          child: Text(
                            AppStrings.transferNoDevices,
                            style: TextStyle(
                              fontSize: AppSizes.bodySmall(context),
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.textTertiary,
                            ),
                          ),
                        )
                      else
                        ...transferable.map(
                          (d) => _DeviceOption(
                            device: d,
                            isDark: isDark,
                            isSelected: _selectedDeviceId == d.id,
                            onTap: () =>
                                setState(() => _selectedDeviceId = d.id),
                          ),
                        ),
                      AppSpacing.vLg,
                      // Recipient CNIC
                      AppInput(
                        label: AppStrings.transferRecipientCnic,
                        controller: _cnicCtrl,
                        hintText: AppStrings.transferRecipientCnicHint,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\d\-]'),
                          ),
                          LengthLimitingTextInputFormatter(15),
                        ],
                        validator: (v) {
                          final val = v?.trim() ?? '';
                          if (val.isEmpty) return 'CNIC is required';
                          return AppValidators.cnic(val);
                        },
                      ),
                      AppSpacing.vMd,
                      // Note
                      AppInput(
                        label: AppStrings.transferNote,
                        controller: _noteCtrl,
                        hintText: AppStrings.transferNoteHint,
                        maxLines: 3,
                      ),
                      AppSpacing.vLg,
                      // Info banner
                      Container(
                        padding: const EdgeInsets.all(AppPadding.md),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primaryAccent.withValues(alpha: 0.3)
                              : AppColors.primarySoft,
                          borderRadius: AppRadius.allMd,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 18,
                              color: AppColors.primaryAccent,
                            ),
                            AppSpacing.hSm,
                            Expanded(
                              child: Text(
                                'The recipient must accept the transfer request. '
                                'Ownership will only change after acceptance.',
                                style: TextStyle(
                                  fontSize: AppSizes.bodySmall(context),
                                  height: 1.45,
                                  color: isDark
                                      ? AppColors.primaryAccent
                                      : AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Sticky bottom button
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.background,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.responsiveHorizontalPadding,
                      AppPadding.sm,
                      context.responsiveHorizontalPadding,
                      AppPadding.md,
                    ),
                    child: AppButton(
                      label: AppStrings.transferSubmit,
                      onPressed: (_selectedDeviceId != null &&
                              transferable.isNotEmpty &&
                              !_loading)
                          ? () => _onSubmit(user?.cnic)
                          : null,
                      isLoading: _loading,
                      icon: Icons.send_outlined,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          const Center(child: Text(AppStrings.somethingWentWrong)),
    );
  }

  Future<void> _onSubmit(String? currentCnic) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDeviceId == null) return;

    final recipientCnic = _cnicCtrl.text.trim();

    // Can't transfer to yourself
    if (currentCnic != null &&
        recipientCnic.replaceAll('-', '') ==
            currentCnic.replaceAll('-', '')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.transferSameOwner)),
        );
      }
      return;
    }

    setState(() => _loading = true);

    try {
      await ref.read(transfersProvider.notifier).create(
            deviceId: _selectedDeviceId!,
            recipientCnic: recipientCnic,
            note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          );
      if (mounted) {
        setState(() {
          _loading = false;
          _success = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Device selection option
// ---------------------------------------------------------------------------

class _DeviceOption extends StatelessWidget {
  const _DeviceOption({
    required this.device,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  final DeviceModel device;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppPadding.sm),
        padding: const EdgeInsets.all(AppPadding.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceElevated : AppColors.card,
          borderRadius: AppRadius.allMd,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.border),
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            AppSpacing.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${device.brand} ${device.model}',
                    style: TextStyle(
                      fontSize: AppSizes.bodyRegular(context),
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'IMEI ${device.maskedImei}',
                    style: TextStyle(
                      fontSize: AppSizes.bodySmall(context),
                      fontFamily: 'monospace',
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Success view
// ---------------------------------------------------------------------------

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.isDark, required this.onViewTransfers});

  final bool isDark;
  final VoidCallback onViewTransfers;

  @override
  Widget build(BuildContext context) {
    final iconSize = AppSizes.iconLg(context) + 16;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveHorizontalPadding,
        vertical: AppPadding.lg,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: const BoxDecoration(
              color: AppColors.successSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: iconSize * 0.5,
              color: AppColors.success,
            ),
          ),
          AppSpacing.vXl,
          Text(
            AppStrings.transferSuccessTitle,
            style: TextStyle(
              fontSize: AppSizes.h3(context),
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          AppSpacing.vSm,
          Text(
            AppStrings.transferSuccessBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.responsiveFontSize(13),
              height: 1.5,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.textTertiary,
            ),
          ),
          AppSpacing.vXl,
          AppButton(
            label: AppStrings.transferSuccessAction,
            onPressed: onViewTransfers,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2: Transfer History
// ---------------------------------------------------------------------------

class _TransferHistoryTab extends ConsumerWidget {
  const _TransferHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transfersAsync = ref.watch(transfersProvider);
    final currentUserId = ref.watch(currentUserProvider)?.id ?? '';

    return transfersAsync.when(
      data: (transfers) {
        if (transfers.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(transfersProvider);
              await ref.read(transfersProvider.future);
            },
            child: ListView(
              children: const [
                SizedBox(height: 120),
                EmptyState(
                  icon: Icons.swap_horiz_outlined,
                  title: AppStrings.transferEmpty,
                  message: AppStrings.transferEmptyBody,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(transfersProvider);
            await ref.read(transfersProvider.future);
          },
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveHorizontalPadding,
              vertical: AppPadding.lg,
            ),
            itemCount: transfers.length,
            separatorBuilder: (_, _) => AppSpacing.vMd,
            itemBuilder: (context, index) {
              final t = transfers[index];
              final isOutgoing = t.fromOwnerId == currentUserId;
              return _TransferCard(
                transfer: t,
                isDark: isDark,
                isOutgoing: isOutgoing,
                onAccept: t.status == TransferStatus.pending && !isOutgoing
                    ? () => ref
                          .read(transfersProvider.notifier)
                          .accept(t.id)
                    : null,
                onReject: t.status == TransferStatus.pending && !isOutgoing
                    ? () => ref
                          .read(transfersProvider.notifier)
                          .reject(t.id)
                    : null,
                onCancel: t.status == TransferStatus.pending && isOutgoing
                    ? () => ref
                          .read(transfersProvider.notifier)
                          .cancel(t.id)
                    : null,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          const Center(child: Text(AppStrings.somethingWentWrong)),
    );
  }
}

// ---------------------------------------------------------------------------
// Transfer card
// ---------------------------------------------------------------------------

class _TransferCard extends StatelessWidget {
  const _TransferCard({
    required this.transfer,
    required this.isDark,
    required this.isOutgoing,
    this.onAccept,
    this.onReject,
    this.onCancel,
  });

  final TransferModel transfer;
  final bool isDark;
  final bool isOutgoing;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('dd MMM · HH:mm').format(transfer.createdAt);
    final deviceLabel =
        '${transfer.deviceBrand ?? ''} ${transfer.deviceModel ?? ''}'.trim();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: direction badge + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isOutgoing
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 16,
                    color: isOutgoing ? AppColors.error : AppColors.success,
                  ),
                  AppSpacing.hXs,
                  Text(
                    isOutgoing
                        ? AppStrings.transferOutgoing
                        : AppStrings.transferIncoming,
                    style: TextStyle(
                      fontSize: AppSizes.bodySmall(context),
                      fontWeight: FontWeight.w600,
                      color: isOutgoing ? AppColors.error : AppColors.success,
                    ),
                  ),
                ],
              ),
              StatusBadge(
                label: transfer.status.displayName,
                variant: _mapStatus(transfer.status),
              ),
            ],
          ),
          AppSpacing.vMd,
          // Device info
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.sm + 2,
              vertical: AppPadding.sm,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.inputFill,
              borderRadius: AppRadius.allSm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.smartphone_outlined,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary,
                ),
                AppSpacing.hSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deviceLabel.isEmpty ? 'Device' : deviceLabel,
                        style: TextStyle(
                          fontSize: AppSizes.bodySmall(context),
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (transfer.deviceImei != null)
                        Text(
                          'IMEI ${transfer.deviceImei}',
                          style: TextStyle(
                            fontSize: context.responsiveFontSize(11),
                            fontFamily: 'monospace',
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(11),
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vSm,
          // From/To info
          Row(
            children: [
              Expanded(
                child: Text(
                  isOutgoing
                      ? '${AppStrings.transferTo}: ${transfer.toCnic}'
                      : '${AppStrings.transferFrom}: ${transfer.fromOwnerName ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: AppSizes.bodySmall(context),
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (transfer.note != null && transfer.note!.isNotEmpty) ...[
            AppSpacing.vXs,
            Text(
              transfer.note!,
              style: TextStyle(
                fontSize: AppSizes.bodySmall(context),
                fontStyle: FontStyle.italic,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.textTertiary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          // Action buttons
          if (transfer.status == TransferStatus.pending) ...[
            AppSpacing.vMd,
            if (!isOutgoing)
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: AppStrings.transferAccept,
                      onPressed: onAccept,
                      variant: AppButtonVariant.success,
                      icon: Icons.check,
                    ),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: AppButton(
                      label: AppStrings.transferReject,
                      onPressed: onReject,
                      variant: AppButtonVariant.reject,
                      icon: Icons.close,
                    ),
                  ),
                ],
              )
            else
              AppButton(
                label: AppStrings.transferCancel,
                onPressed: onCancel,
                variant: AppButtonVariant.ghost,
                icon: Icons.cancel_outlined,
              ),
          ],
        ],
      ),
    );
  }

  StatusBadgeVariant _mapStatus(TransferStatus s) {
    switch (s) {
      case TransferStatus.pending:
        return StatusBadgeVariant.pending;
      case TransferStatus.accepted:
        return StatusBadgeVariant.verified;
      case TransferStatus.rejected:
        return StatusBadgeVariant.rejected;
      case TransferStatus.cancelled:
        return StatusBadgeVariant.info;
    }
  }
}
