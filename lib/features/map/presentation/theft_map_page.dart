import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../theme/colors.dart';
import '../data/theft_zone_model.dart';
import '../logic/theft_zone_provider.dart';

class TheftMapPage extends ConsumerStatefulWidget {
  const TheftMapPage({super.key});

  @override
  ConsumerState<TheftMapPage> createState() => _TheftMapPageState();
}

class _TheftMapPageState extends ConsumerState<TheftMapPage> {
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(30.3753, 69.3451),
    zoom: 5.2,
  );

  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _recenter() {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(_initialPosition),
    );
  }

  void _openZoneDetails(TheftZone zone) {
    AppBottomSheet.show<void>(
      context: context,
      title: AppStrings.theftMapZoneDetails,
      child: _ZoneDetails(zone: zone),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final zones = ref.watch(theftZoneProvider);

    final circles = zones.map((zone) {
      return Circle(
        circleId: CircleId(zone.name),
        center: LatLng(zone.latitude, zone.longitude),
        radius: 1500,
        fillColor: zone.riskLevel.colorToken.withValues(alpha: 0.35),
        strokeColor: zone.riskLevel.colorToken,
        strokeWidth: 2,
      );
    }).toSet();

    final markers = zones.map((zone) {
      final hue = HSVColor.fromColor(zone.riskLevel.colorToken).hue;
      return Marker(
        markerId: MarkerId(zone.name),
        position: LatLng(zone.latitude, zone.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        onTap: () => _openZoneDetails(zone),
      );
    }).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.titleTheftMap),
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.appBar,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            circles: circles,
            markers: markers,
            style: isDark ? _darkMapStyle : _lightMapStyle,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          Positioned(
            bottom: AppPadding.lg + 56,
            right: AppPadding.lg,
            child: _LegendCard(isDark: isDark),
          ),
          Positioned(
            bottom: AppPadding.lg + 56,
            left: AppPadding.lg,
            child: _RecenterButton(onPressed: _recenter),
          ),
        ],
      ),
    );
  }
}

class _LegendCard extends StatelessWidget {
  const _LegendCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final background = isDark ? AppColors.darkCard : AppColors.card;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.md,
        vertical: AppPadding.sm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.allMd,
        border: Border.all(color: border),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.theftMapLegendTitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          AppSpacing.vXs,
          const _LegendRow(
            label: AppStrings.theftMapLowRisk,
            level: RiskLevel.low,
          ),
          AppSpacing.vXs,
          const _LegendRow(
            label: AppStrings.theftMapMediumRisk,
            level: RiskLevel.medium,
          ),
          AppSpacing.vXs,
          const _LegendRow(
            label: AppStrings.theftMapHighRisk,
            level: RiskLevel.high,
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.label, required this.level});

  final String label;
  final RiskLevel level;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: level.colorToken,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        AppSpacing.hSm,
        Text(label, style: TextStyle(fontSize: 11, color: textColor)),
      ],
    );
  }
}

class _RecenterButton extends StatelessWidget {
  const _RecenterButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(AppPadding.sm),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.my_location, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _ZoneDetails extends StatelessWidget {
  const _ZoneDetails({required this.zone});

  final TheftZone zone;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final valueColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          zone.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        AppSpacing.vXs,
        Text(zone.city, style: TextStyle(fontSize: 12, color: labelColor)),
        AppSpacing.vMd,
        Row(
          children: [
            _DetailBlock(
              label: AppStrings.theftMapRiskLabel,
              value: _riskLabel(zone.riskLevel),
              chipColor: zone.riskLevel.colorToken,
            ),
            AppSpacing.hLg,
            _DetailBlock(
              label: AppStrings.theftMapFirLabel,
              value: zone.firCount.toString(),
            ),
          ],
        ),
        AppSpacing.vMd,
        _DetailBlock(
          label: AppStrings.theftMapLocationLabel,
          value:
              '${zone.latitude.toStringAsFixed(4)}, ${zone.longitude.toStringAsFixed(4)}',
        ),
      ],
    );
  }

  String _riskLabel(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return AppStrings.theftMapLowRisk;
      case RiskLevel.medium:
        return AppStrings.theftMapMediumRisk;
      case RiskLevel.high:
        return AppStrings.theftMapHighRisk;
    }
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({
    required this.label,
    required this.value,
    this.chipColor,
  });

  final String label;
  final String value;
  final Color? chipColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final valueColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: labelColor,
            letterSpacing: 0.2,
          ),
        ),
        AppSpacing.vXs,
        if (chipColor != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: chipColor!.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: chipColor,
              ),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
      ],
    );
  }
}

const String _lightMapStyle =
    '[\n'
    '  {"featureType":"administrative","elementType":"labels.text.fill","stylers":[{"color":"#1C2C4D"}]},\n'
    '  {"featureType":"landscape","elementType":"geometry","stylers":[{"color":"#EEF2F8"}]},\n'
    '  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#E6ECF6"}]},\n'
    '  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#D4DBE7"}]},\n'
    '  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#C7DCFB"}]}\n'
    ']';

const String _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#0a1628"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8ec3b9"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#0a1628"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#1b2a4a"}]},
  {"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9da5b3"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#152544"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#212a37"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#0f1b33"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#1f2835"}]},
  {"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#f3d19c"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#0f1b33"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#071428"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#515c6d"}]}
]
''';
