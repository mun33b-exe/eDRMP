import 'package:flutter/material.dart';

import '../../../theme/colors.dart';

enum RiskLevel { low, medium, high }

class TheftZone {
  const TheftZone({
    required this.name,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.riskLevel,
    required this.firCount,
  });

  final String name;
  final String city;
  final double latitude;
  final double longitude;
  final RiskLevel riskLevel;
  final int firCount;
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
