import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/utils/app_sizes.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_app_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input.dart';
import '../../../theme/colors.dart';
import '../../devices/data/device_model.dart';
import '../../devices/logic/device_provider.dart';
import '../logic/fir_provider.dart';

class SubmitFirPage extends ConsumerStatefulWidget {
  const SubmitFirPage({super.key});

  @override
  ConsumerState<SubmitFirPage> createState() => _SubmitFirPageState();
}

class _SubmitFirPageState extends ConsumerState<SubmitFirPage> {
  String? _selectedDeviceId;
  final _policeStationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _firNumberCtrl = TextEditingController();
  final _dateCtrl = TextEditingController(text: '28 Apr 2026, 09:30 PM');
  final _locationCtrl = TextEditingController(
    text: AppStrings.locationPickerHint,
  );

  double? _pickedLat;
  double? _pickedLng;
  String? _pickedAddress;
  XFile? _pickedProof;
  bool _isLoading = false;

  @override
  void dispose() {
    _policeStationCtrl.dispose();
    _descriptionCtrl.dispose();
    _firNumberCtrl.dispose();
    _dateCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickProof() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => _pickedProof = file);
  }

  Future<void> _pickLocation() async {
    final result = await context.push<LatLng>(RouteNames.locationPicker);
    if (result == null) return;
    setState(() {
      _pickedLat = result.latitude;
      _pickedLng = result.longitude;
      _pickedAddress =
          '${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}';
      _locationCtrl.text = _pickedAddress!;
    });
  }

  void _submit() async {
    if (_selectedDeviceId == null || _policeStationCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await ref
        .read(firsProvider.notifier)
        .submitFir(
          deviceId: _selectedDeviceId!,
          firNumber: _firNumberCtrl.text.trim(),
          policeStation: _policeStationCtrl.text.trim(),
          incidentDate: DateTime.now(),
          description: _descriptionCtrl.text.trim(),
          proofFilePath: _pickedProof?.path,
          incidentLat: _pickedLat,
          incidentLng: _pickedLng,
          incidentAddress: _pickedAddress,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      context.go(RouteNames.firHistory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final devicesAsync = ref.watch(devicesProvider);

    return Scaffold(
      appBar: const AppAppBar(title: AppStrings.submitFirTitle),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveHorizontalPadding,
                vertical: AppPadding.md,
              ),
              child: Column(
                children: [
                  _WarningCard(isDark: isDark),
                  AppSpacing.vLg,

                  // Device dropdown
                  devicesAsync.when(
                    data: (devices) {
                      final approvedDevices = devices
                          .where(
                            (d) =>
                                d.status == DeviceStatus.approved ||
                                d.status == DeviceStatus.unblocked,
                          )
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.submitFirDeviceLabel,
                            style: TextStyle(
                              fontSize: AppSizes.bodySmall(context),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          AppSpacing.vXs,
                          DropdownButtonFormField<String>(
                            initialValue: _selectedDeviceId,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.inputFill,
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.allMd,
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppRadius.allMd,
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.border,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppPadding.md,
                                vertical: AppPadding.sm,
                              ),
                            ),
                            dropdownColor: isDark
                                ? AppColors.darkSurfaceElevated
                                : AppColors.card,
                            hint: const Text('Select an approved device'),
                            items: approvedDevices.map((d) {
                              return DropdownMenuItem(
                                value: d.id,
                                child: Text(
                                  '${d.brand} ${d.model} · ${d.maskedImei}',
                                  style: TextStyle(fontSize: context.responsiveFontSize(13)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedDeviceId = val);
                            },
                          ),
                        ],
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stackTrace) =>
                        const Text('Error loading devices'),
                  ),

                  AppSpacing.vLg,

                  // FIR Number (if any)
                  AppInput(
                    label: 'FIR number (Optional)',
                    controller: _firNumberCtrl,
                    hintText: 'e.g. 124/26',
                  ),
                  AppSpacing.vMd,

                  AppInput(
                    label: AppStrings.submitFirDateLabel,
                    controller: _dateCtrl,
                    enabled: false,
                    suffix: const Icon(Icons.keyboard_arrow_down, size: 20),
                  ),
                  AppSpacing.vMd,

                  // Location field — tappable, opens LocationPickerPage
                  GestureDetector(
                    onTap: _pickLocation,
                    child: AbsorbPointer(
                      child: AppInput(
                        label: AppStrings.submitFirLocationLabel,
                        controller: _locationCtrl,
                        enabled: false,
                        suffix: const Icon(Icons.map, size: 20),
                      ),
                    ),
                  ),
                  AppSpacing.vMd,

                  AppInput(
                    label: AppStrings.submitFirStationLabel,
                    controller: _policeStationCtrl,
                    hintText: 'e.g. Clifton P.S.',
                    suffix: const Icon(Icons.keyboard_arrow_down, size: 20),
                  ),
                  AppSpacing.vMd,

                  AppInput(
                    label: AppStrings.submitFirDescriptionLabel,
                    controller: _descriptionCtrl,
                    hintText: AppStrings.submitFirDescriptionHint,
                    maxLines: 3,
                  ),
                  AppSpacing.vMd,

                  // Proof upload
                  GestureDetector(
                    onTap: _pickProof,
                    child: AbsorbPointer(
                      child: AppInput(
                        label: 'Proof upload (FIR copy/Photos)',
                        enabled: false,
                        hintText: _pickedProof == null
                            ? 'Tap to upload a file'
                            : _pickedProof!.name,
                        suffix: const Icon(Icons.upload_file, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sticky Bottom Button
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveHorizontalPadding,
              vertical: AppPadding.lg,
            ),
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
              child: AppButton(
                label: AppStrings.submitFirAction,
                onPressed: _isLoading ? null : _submit,
                variant: AppButtonVariant.reject,
                icon: Icons.shield,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.sm + 4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.rejected.withValues(alpha: 0.14)
            : AppColors.errorSoft,
        borderRadius: AppRadius.allMd,
        border: Border.all(
          color: isDark
              ? AppColors.rejected.withValues(alpha: 0.32)
              : AppColors.errorSoft,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: AppColors.error,
          ),
          AppSpacing.hSm,
          Expanded(
            child: Text(
              AppStrings.submitFirWarning,
              style: TextStyle(
                fontSize: AppSizes.bodySmall(context),
                height: 1.45,
                color: isDark
                    ? AppColors.error
                    : AppColors.errorDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
