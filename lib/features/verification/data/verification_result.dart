import 'package:flutter/foundation.dart';

import '../../devices/data/device_model.dart';

@immutable
class VerificationResult {
  const VerificationResult({
    required this.imei,
    required this.found,
    this.brand,
    this.model,
    this.maskedCnic,
    this.status,
    this.registeredAt,
  });

  final String imei;
  final bool found;
  final String? brand;
  final String? model;
  final String? maskedCnic;
  final DeviceStatus? status;
  final DateTime? registeredAt;

  factory VerificationResult.notFound(String imei) =>
      VerificationResult(imei: imei, found: false);

  factory VerificationResult.found({
    required String imei,
    required String brand,
    required String model,
    required String maskedCnic,
    required DeviceStatus status,
    required DateTime registeredAt,
  }) => VerificationResult(
    imei: imei,
    found: true,
    brand: brand,
    model: model,
    maskedCnic: maskedCnic,
    status: status,
    registeredAt: registeredAt,
  );

  String get registrationDateDisplay {
    if (registeredAt == null) return '—';
    final d = registeredAt!;
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}
