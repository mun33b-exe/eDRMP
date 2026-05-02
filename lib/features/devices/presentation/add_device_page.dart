import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input.dart';
import '../../../theme/colors.dart';
import '../logic/device_provider.dart';

// ---------------------------------------------------------------------------
// Add Device Page — 3-step registration flow
// ---------------------------------------------------------------------------
// Step 1: IMEI entry + auto-fill  (matches ScreenRegister top half)
// Step 2: Confirm details         (matches ScreenRegister bottom / Submit)
// Step 3: Success                 (completion state)
// ---------------------------------------------------------------------------

class AddDevicePage extends ConsumerStatefulWidget {
  const AddDevicePage({super.key});

  @override
  ConsumerState<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends ConsumerState<AddDevicePage> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  // Step 1 controllers
  final _imeiCtrl = TextEditingController();
  final _imei2Ctrl = TextEditingController();

  // Step 2 controllers (pre-filled)
  final _operatorCtrl = TextEditingController();

  int _step = 1;
  bool _loading = false;
  String? _imeiError;

  // Auto-fill from IMEI lookup
  String _brand = '';
  String _model = '';
  bool _detected = false;

  @override
  void dispose() {
    _imeiCtrl.dispose();
    _imei2Ctrl.dispose();
    _operatorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.scaffoldBackground,
      appBar: _buildAppBar(isDark),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: _buildStep(isDark),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // AppBar varies per step
  // ---------------------------------------------------------------------------

  PreferredSizeWidget _buildAppBar(bool isDark) {
    switch (_step) {
      case 1:
        return AppBar(
          title: const Text(AppStrings.addDeviceTitle),
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppPadding.md),
              child: TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  AppStrings.addDeviceSaveDraft,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        );
      case 2:
        return AppBar(
          title: const Text(AppStrings.addDeviceStep2Title),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _step = 1),
          ),
        );
      default:
        return AppBar(
          title: const Text(AppStrings.addDeviceStep3Title),
          automaticallyImplyLeading: false,
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Step routing
  // ---------------------------------------------------------------------------

  Widget _buildStep(bool isDark) {
    switch (_step) {
      case 1:
        return _Step1(
          key: const ValueKey(1),
          formKey: _formKey1,
          imeiCtrl: _imeiCtrl,
          imei2Ctrl: _imei2Ctrl,
          brand: _brand,
          model: _model,
          detected: _detected,
          imeiError: _imeiError,
          isDark: isDark,
          onImeiChanged: _onImeiChanged,
          onContinue: _onStep1Continue,
        );
      case 2:
        return _Step2(
          key: const ValueKey(2),
          formKey: _formKey2,
          brand: _brand,
          model: _model,
          imei: _imeiCtrl.text.trim(),
          imei2: _imei2Ctrl.text.trim(),
          operatorCtrl: _operatorCtrl,
          loading: _loading,
          isDark: isDark,
          onSubmit: _onStep2Submit,
        );
      default:
        return _Step3(
          key: const ValueKey(3),
          isDark: isDark,
          brand: _brand,
          model: _model,
          onViewDevices: () {
            context.go(RouteNames.appShell);
          },
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Business logic
  // ---------------------------------------------------------------------------

  void _onImeiChanged(String value) {
    setState(() {
      _imeiError = null;
      _detected = false;
      _brand = '';
      _model = '';
    });

    // Live auto-fill once user types 8+ digit characters
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 8) {
      final repo = ref.read(deviceRepositoryProvider);
      final lookup = repo.lookupImei(digits);
      if (lookup != null) {
        setState(() {
          _brand = lookup.brand;
          _model = lookup.model;
          _detected = true;
        });
      }
    }
  }

  void _onStep1Continue() {
    if (!_formKey1.currentState!.validate()) return;

    final repo = ref.read(deviceRepositoryProvider);
    final rawImei = _imeiCtrl.text.trim();

    if (repo.isDuplicate(rawImei)) {
      setState(() => _imeiError = AppStrings.addDeviceImeiDuplicate);
      return;
    }

    setState(() => _step = 2);
  }

  Future<void> _onStep2Submit() async {
    if (!_formKey2.currentState!.validate()) return;
    setState(() => _loading = true);

    await ref
        .read(devicesProvider.notifier)
        .register(
          imei: _imeiCtrl.text.trim(),
          imei2: _imei2Ctrl.text.trim().isEmpty ? null : _imei2Ctrl.text.trim(),
          brand: _brand.isEmpty ? 'Unknown' : _brand,
          model: _model.isEmpty ? 'Unknown device' : _model,
          operator: _operatorCtrl.text.trim(),
        );

    if (mounted) {
      setState(() {
        _loading = false;
        _step = 3;
      });
    }
  }
}

// ---------------------------------------------------------------------------
// Step 1 — IMEI entry
// ---------------------------------------------------------------------------

class _Step1 extends StatelessWidget {
  const _Step1({
    super.key,
    required this.formKey,
    required this.imeiCtrl,
    required this.imei2Ctrl,
    required this.brand,
    required this.model,
    required this.detected,
    required this.imeiError,
    required this.isDark,
    required this.onImeiChanged,
    required this.onContinue,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController imeiCtrl;
  final TextEditingController imei2Ctrl;
  final String brand;
  final String model;
  final bool detected;
  final String? imeiError;
  final bool isDark;
  final ValueChanged<String> onImeiChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppPadding.screen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step indicator
                  _StepIndicator(step: 1, total: 3, isDark: isDark),
                  AppSpacing.vLg,
                  // IMEI input
                  AppInput(
                    label: AppStrings.addDeviceImeiLabel,
                    controller: imeiCtrl,
                    hintText: AppStrings.addDeviceImeiHint,
                    helperText: AppStrings.addDeviceImeiHelper,
                    errorText: imeiError,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d\s]')),
                      LengthLimitingTextInputFormatter(19),
                    ],
                    onChanged: onImeiChanged,
                    validator: (v) {
                      final formatted = v?.trim() ?? '';
                      return AppValidators.imei(formatted);
                    },
                    suffix: detected
                        ? const Padding(
                            padding: EdgeInsets.only(right: AppPadding.sm),
                            child: Icon(
                              Icons.check_circle,
                              size: 18,
                              color: AppColors.approved,
                            ),
                          )
                        : null,
                  ),
                  if (detected) ...[
                    AppSpacing.vMd,
                    _DetectedCard(brand: brand, model: model, isDark: isDark),
                  ],
                  AppSpacing.vMd,
                  // IMEI 2
                  AppInput(
                    label: AppStrings.addDeviceImei2Label,
                    controller: imei2Ctrl,
                    hintText: '(Optional)',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d\s]')),
                      LengthLimitingTextInputFormatter(19),
                    ],
                  ),
                  AppSpacing.vLg,
                  // Info banner
                  _InfoBanner(isDark: isDark),
                ],
              ),
            ),
          ),
          // Sticky bottom button
          _StickyBottom(
            child: AppButton(
              label: AppStrings.addDeviceContinue,
              onPressed: onContinue,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2 — Confirm details
// ---------------------------------------------------------------------------

class _Step2 extends StatelessWidget {
  const _Step2({
    super.key,
    required this.formKey,
    required this.brand,
    required this.model,
    required this.imei,
    required this.imei2,
    required this.operatorCtrl,
    required this.loading,
    required this.isDark,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final String brand;
  final String model;
  final String imei;
  final String imei2;
  final TextEditingController operatorCtrl;
  final bool loading;
  final bool isDark;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppPadding.screen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StepIndicator(step: 2, total: 3, isDark: isDark),
                  AppSpacing.vLg,
                  // Detected device card (read-only)
                  if (brand.isNotEmpty)
                    _DetectedCard(brand: brand, model: model, isDark: isDark),
                  AppSpacing.vMd,
                  // IMEI 1 (read-only)
                  _ReadOnlyField(
                    label: AppStrings.addDeviceImeiLabel,
                    value: imei,
                    mono: true,
                    isDark: isDark,
                    trailing: const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.approved,
                    ),
                  ),
                  AppSpacing.vMd,
                  // IMEI 2 (read-only, if provided)
                  if (imei2.isNotEmpty) ...[
                    _ReadOnlyField(
                      label: AppStrings.addDeviceImei2Label,
                      value: imei2,
                      mono: true,
                      isDark: isDark,
                    ),
                    AppSpacing.vMd,
                  ],
                  // Operator input
                  AppInput(
                    label: AppStrings.addDeviceOperatorLabel,
                    controller: operatorCtrl,
                    hintText: AppStrings.addDeviceOperatorHint,
                    validator: (v) =>
                        AppValidators.requiredField(v, fieldName: 'Operator'),
                    suffix: const Padding(
                      padding: EdgeInsets.only(right: AppPadding.sm),
                      child: Icon(Icons.keyboard_arrow_down, size: 18),
                    ),
                  ),
                  AppSpacing.vMd,
                  // Invoice upload (placeholder)
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Invoice upload will be available in the next update.',
                          ),
                        ),
                      );
                    },
                    child: _ReadOnlyField(
                      label: AppStrings.addDeviceInvoiceLabel,
                      value: AppStrings.addDeviceInvoiceHint,
                      isDark: isDark,
                      placeholder: true,
                      trailing: const Icon(Icons.upload_outlined, size: 16),
                    ),
                  ),
                  AppSpacing.vLg,
                  _InfoBanner(isDark: isDark),
                ],
              ),
            ),
          ),
          _StickyBottom(
            child: AppButton(
              label: AppStrings.addDeviceSubmit,
              onPressed: loading ? null : onSubmit,
              isLoading: loading,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3 — Success
// ---------------------------------------------------------------------------

class _Step3 extends StatelessWidget {
  const _Step3({
    super.key,
    required this.isDark,
    required this.brand,
    required this.model,
    required this.onViewDevices,
  });

  final bool isDark;
  final String brand;
  final String model;
  final VoidCallback onViewDevices;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPadding.screen,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.secondaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 40,
              color: AppColors.secondary,
            ),
          ),
          AppSpacing.vXl,
          Text(
            AppStrings.addDeviceSuccessTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          AppSpacing.vSm,
          if (brand.isNotEmpty)
            Text(
              '$brand $model',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          AppSpacing.vMd,
          Text(
            AppStrings.addDeviceSuccessBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
          AppSpacing.vXl,
          AppButton(
            label: AppStrings.addDeviceSuccessAction,
            onPressed: onViewDevices,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared sub-widgets
// ---------------------------------------------------------------------------

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.step,
    required this.total,
    required this.isDark,
  });

  final int step;
  final int total;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Step $step of $total',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
          ),
        ),
        AppSpacing.hMd,
        Expanded(
          child: ClipRRect(
            borderRadius: AppRadius.allPill,
            child: LinearProgressIndicator(
              value: step / total,
              backgroundColor: isDark ? AppColors.darkBorder : AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 4,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetectedCard extends StatelessWidget {
  const _DetectedCard({
    required this.brand,
    required this.model,
    required this.isDark,
  });

  final String brand;
  final String model;
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
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : AppColors.inputFill,
              borderRadius: AppRadius.allMd,
            ),
            child: const Icon(
              Icons.smartphone_outlined,
              size: 22,
              color: AppColors.primary,
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.addDeviceDetected,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.textMuted,
                  ),
                ),
                Text(
                  '$brand $model',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  AppStrings.addDeviceAutoFilled,
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
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.isDark,
    this.mono = false,
    this.placeholder = false,
    this.trailing,
  });

  final String label;
  final String value;
  final bool isDark;
  final bool mono;
  final bool placeholder;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.md,
        vertical: AppPadding.sm + 2,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkInput : AppColors.inputFill,
        borderRadius: AppRadius.allMd,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: mono ? 'monospace' : null,
                    letterSpacing: mono ? 0.3 : 0,
                    color: placeholder
                        ? (isDark
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted)
                        : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.info.withValues(alpha: 0.3)
            : AppColors.infoLight,
        borderRadius: AppRadius.allMd,
        border: Border.all(
          color: isDark
              ? AppColors.info.withValues(alpha: 0.3)
              : AppColors.infoBorderLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.info),
          AppSpacing.hSm,
          Expanded(
            child: Text(
              AppStrings.addDeviceInfoBanner,
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: isDark ? AppColors.infoTextDark : AppColors.infoTextDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyBottom extends StatelessWidget {
  const _StickyBottom({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppPadding.lg,
        AppPadding.sm,
        AppPadding.lg,
        AppPadding.lg,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.scaffoldBackground,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
      ),
      child: child,
    );
  }
}
