import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../theme/colors.dart';
import '../../devices/data/device_model.dart';
import '../data/verification_result.dart';
import '../logic/verification_provider.dart';

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class VerifyImeiPage extends ConsumerStatefulWidget {
  const VerifyImeiPage({super.key});

  @override
  ConsumerState<VerifyImeiPage> createState() => _VerifyImeiPageState();
}

class _VerifyImeiPageState extends ConsumerState<VerifyImeiPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final MobileScannerController _scannerController;
  final TextEditingController _imeiController = TextEditingController();
  bool _canScan = true;
  String _imeiValue = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scannerController = MobileScannerController();
    _tabController.addListener(_onTabChanged);
    _imeiController.addListener(_onImeiTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(verificationResultProvider.notifier).state = null;
      ref.read(verificationLoadingProvider.notifier).state = false;
      ref.read(verificationErrorProvider.notifier).state = null;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _imeiController.removeListener(_onImeiTextChanged);
    _tabController.dispose();
    _scannerController.dispose();
    _imeiController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) setState(() {});
  }

  void _onImeiTextChanged() {
    setState(() => _imeiValue = _imeiController.text);
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (!_canScan) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null) return;
    final raw = barcode.rawValue;
    if (raw == null) return;

    String imei;
    try {
      final payload = jsonDecode(raw) as Map<String, dynamic>;
      imei = (payload['imei'] as String?) ?? raw;
    } catch (_) {
      imei = raw;
    }

    setState(() => _canScan = false);
    await checkImei(imei, ref);
    if (mounted) setState(() => _canScan = true);
  }

  Future<void> _onVerifyPressed() async {
    await checkImei(_imeiValue.trim(), ref);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOnScanTab = _tabController.index == 0;
    final result = ref.watch(verificationResultProvider);
    final isLoading = ref.watch(verificationLoadingProvider);
    final error = ref.watch(verificationErrorProvider);
    final isImeiValid = AppValidators.imei(_imeiValue) == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.verifyImeiTitle),
        actions: [
          if (isOnScanTab)
            IconButton(
              icon: const Icon(Icons.flash_on_outlined),
              tooltip: 'Toggle torch',
              onPressed: _scannerController.toggleTorch,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: AppStrings.verifyTabScan),
            Tab(text: AppStrings.verifyTabEnter),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ScanTab(
            scannerController: _scannerController,
            onDetect: _onBarcodeDetected,
            result: result,
            isLoading: isLoading,
            error: error,
            isDark: isDark,
          ),
          _EnterImeiTab(
            imeiController: _imeiController,
            onImeiChanged: _onImeiTextChanged,
            onVerify: _onVerifyPressed,
            isImeiValid: isImeiValid,
            result: result,
            isLoading: isLoading,
            error: error,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1 — Scan QR
// ---------------------------------------------------------------------------

class _ScanTab extends StatelessWidget {
  const _ScanTab({
    required this.scannerController,
    required this.onDetect,
    required this.result,
    required this.isLoading,
    required this.error,
    required this.isDark,
  });

  final MobileScannerController scannerController;
  final void Function(BarcodeCapture) onDetect;
  final VerificationResult? result;
  final bool isLoading;
  final String? error;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: MobileScanner(
            controller: scannerController,
            onDetect: onDetect,
            errorBuilder: (context, error, child) {
              final innerDark = Theme.of(context).brightness == Brightness.dark;
              return _CameraPermissionDeniedState(isDark: innerDark);
            },
          ),
        ),
        if (isLoading)
          const Padding(
            padding: AppPadding.allLg,
            child: CircularProgressIndicator(),
          ),
        if (error != null && !isLoading)
          _ErrorCard(message: error!, isDark: isDark),
        if (result != null && !isLoading)
          _VerificationResultCard(result: result!, isDark: isDark),
        AppSpacing.vMd,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2 — Enter IMEI
// ---------------------------------------------------------------------------

class _EnterImeiTab extends StatelessWidget {
  const _EnterImeiTab({
    required this.imeiController,
    required this.onImeiChanged,
    required this.onVerify,
    required this.isImeiValid,
    required this.result,
    required this.isLoading,
    required this.error,
    required this.isDark,
  });

  final TextEditingController imeiController;
  final VoidCallback onImeiChanged;
  final Future<void> Function() onVerify;
  final bool isImeiValid;
  final VerificationResult? result;
  final bool isLoading;
  final String? error;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppPadding.screen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInput(
            label: AppStrings.verifyImeiTitle,
            controller: imeiController,
            hintText: AppStrings.verifyImeiHint,
            keyboardType: TextInputType.number,
            maxLength: 15,
            textInputAction: TextInputAction.done,
            validator: AppValidators.imei,
          ),
          AppSpacing.vLg,
          AppButton(
            label: AppStrings.verifyButton,
            onPressed: isImeiValid && !isLoading ? onVerify : null,
            isLoading: isLoading,
          ),
          if (error != null && !isLoading) ...[
            AppSpacing.vLg,
            _ErrorCard(message: error!, isDark: isDark),
          ],
          if (result != null && !isLoading) ...[
            AppSpacing.vLg,
            _VerificationResultCard(result: result!, isDark: isDark),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared result card
// ---------------------------------------------------------------------------

class _VerificationResultCard extends StatelessWidget {
  const _VerificationResultCard({required this.result, required this.isDark});

  final VerificationResult result;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (!result.found) {
      return _NotFoundCard(isDark: isDark);
    }
    return _FoundCard(result: result, isDark: isDark);
  }
}

class _NotFoundCard extends StatelessWidget {
  const _NotFoundCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppPadding.lg),
      padding: AppPadding.allLg,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: AppRadius.allLg,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: AppColors.warning,
          ),
          AppSpacing.vMd,
          Text(
            AppStrings.verifyNotFound,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          AppSpacing.vSm,
          Text(
            AppStrings.verifyNotFoundBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
          AppSpacing.vLg,
          AppButton(
            label: AppStrings.verifyRegisterCta,
            variant: AppButtonVariant.ghost,
            onPressed: () => context.push(RouteNames.addDevice),
          ),
        ],
      ),
    );
  }
}

class _FoundCard extends StatelessWidget {
  const _FoundCard({required this.result, required this.isDark});

  final VerificationResult result;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final status = result.status ?? DeviceStatus.pending;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppPadding.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: AppRadius.allLg,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppPadding.allLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
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
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                    AppSpacing.hMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.model ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            result.brand ?? '',
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
                      label: status.displayName,
                      variant: _statusVariant(status),
                    ),
                  ],
                ),
                AppSpacing.vMd,
                Divider(
                  height: 1,
                  color: isDark ? AppColors.darkDivider : AppColors.divider,
                ),
                AppSpacing.vMd,
                _DetailRow(
                  label: 'IMEI',
                  value: result.imei,
                  mono: true,
                  isDark: isDark,
                ),
                AppSpacing.vSm,
                _DetailRow(
                  label: 'Owner CNIC',
                  value: result.maskedCnic ?? '—',
                  isDark: isDark,
                ),
                AppSpacing.vSm,
                _DetailRow(
                  label: 'Registered',
                  value: result.registrationDateDisplay,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          if (status == DeviceStatus.blocked)
            Container(
              width: double.infinity,
              padding: AppPadding.allMd,
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.vertical(bottom: AppRadius.radiusLg),
              ),
              child: const Row(
                children: [
                  Icon(Icons.block_rounded, size: 16, color: AppColors.error),
                  AppSpacing.hSm,
                  Expanded(
                    child: Text(
                      AppStrings.verifyBlockedWarning,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
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
          width: 88,
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
              color: mono
                  ? AppColors.info
                  : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Error card
// ---------------------------------------------------------------------------

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.isDark});

  final String message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppPadding.lg),
      padding: AppPadding.allMd,
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: AppRadius.allMd,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppColors.error),
          AppSpacing.hSm,
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Camera permission denied state
// ---------------------------------------------------------------------------

class _CameraPermissionDeniedState extends StatelessWidget {
  const _CameraPermissionDeniedState({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppPadding.allXxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.no_photography_outlined,
              size: 64,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
            AppSpacing.vLg,
            Text(
              AppStrings.verifyCameraPermission,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            AppSpacing.vSm,
            Text(
              AppStrings.verifyCameraPermissionBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
