import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../theme/colors.dart';

/// Full-screen Google Map location picker.
///
/// The map has a fixed red pin centred on-screen (via Stack overlay).
/// When the user pans, the pin stays centred while the camera moves.
/// Tapping "Confirm Location" pops the route with the current camera
/// centre [LatLng].
class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  static const LatLng _defaultCenter = LatLng(24.8607, 67.0011);
  static const CameraPosition _initialCamera = CameraPosition(
    target: _defaultCenter,
    zoom: 12,
  );

  LatLng _centerLatLng = _defaultCenter;

  void _onCameraMove(CameraPosition position) {
    _centerLatLng = position.target;
  }

  void _confirm() => context.pop(_centerLatLng);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.locationPickerTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCamera,
            onCameraMove: _onCameraMove,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          const Center(
            child: Icon(Icons.location_pin, size: 40, color: AppColors.error),
          ),
          Positioned(
            left: AppPadding.lg,
            right: AppPadding.lg,
            bottom: AppPadding.xl,
            child: SafeArea(
              top: false,
              child: AppButton(
                label: AppStrings.locationPickerConfirm,
                onPressed: _confirm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
