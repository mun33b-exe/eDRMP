import 'package:flutter/material.dart';

import '../../../theme/colors.dart';

enum RiskLevel { low, medium, high }

class TheftZone {
  const TheftZone({
    required this.id,
    required this.name,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.riskLevel,
    required this.firCount,
  });

  final String id;
  final String name;
  final String city;
  final double latitude;
  final double longitude;
  final RiskLevel riskLevel;
  final int firCount;

  factory TheftZone.fromJson(Map<String, dynamic> json) {
    final lat = (json['lat'] as num).toDouble();
    final lng = (json['lng'] as num).toDouble();
    final address = json['address'] as String?;
    return TheftZone(
      id: (json['fir_id'] as String?) ?? (json['id'] as String? ?? ''),
      name: address?.isNotEmpty == true
          ? address!
          : '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
      city: '',
      latitude: lat,
      longitude: lng,
      riskLevel: RiskLevelX.fromString(
        json['risk_level'] as String? ?? 'medium',
      ),
      firCount: json['fir_count'] as int? ?? 1,
    );
  }
}

extension RiskLevelColor on RiskLevel {
  Color get colorToken {
    switch (this) {
      case RiskLevel.low:
        return AppColors.analyticsGreen;
      case RiskLevel.medium:
        return AppColors.analyticsOrange;
      case RiskLevel.high:
        return AppColors.analyticsRed;
    }
  }
}

extension RiskLevelX on RiskLevel {
  static RiskLevel fromString(String s) {
    switch (s) {
      case 'low':
        return RiskLevel.low;
      case 'high':
        return RiskLevel.high;
      default:
        return RiskLevel.medium;
    }
  }
}
