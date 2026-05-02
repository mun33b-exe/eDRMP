import 'package:flutter/foundation.dart';

/// All valid status values for a registered device.
enum DeviceStatus { approved, pending, rejected, blocked, unblocked }

extension DeviceStatusX on DeviceStatus {
  String get displayName {
    switch (this) {
      case DeviceStatus.approved:
        return 'Approved';
      case DeviceStatus.pending:
        return 'Pending';
      case DeviceStatus.rejected:
        return 'Rejected';
      case DeviceStatus.blocked:
        return 'Blocked';
      case DeviceStatus.unblocked:
        return 'Unblocked';
    }
  }

  bool get canFileFir =>
      this == DeviceStatus.approved || this == DeviceStatus.unblocked;

  static DeviceStatus fromString(String s) {
    switch (s) {
      case 'approved':
        return DeviceStatus.approved;
      case 'rejected':
        return DeviceStatus.rejected;
      case 'blocked':
        return DeviceStatus.blocked;
      case 'unblocked':
        return DeviceStatus.unblocked;
      default:
        return DeviceStatus.pending;
    }
  }
}

/// Application-level representation of a citizen-registered device.
@immutable
class DeviceModel {
  const DeviceModel({
    required this.id,
    required this.ownerId,
    required this.model,
    required this.brand,
    required this.imei,
    required this.imei2,
    required this.operator,
    required this.status,
    required this.registeredAt,
    this.invoicePath,
  });

  final String id;
  final String ownerId;
  final String model;
  final String brand;

  /// Primary IMEI (15 digits, space-formatted).
  final String imei;

  /// Optional secondary IMEI for dual-SIM devices.
  final String? imei2;

  final String operator;
  final DeviceStatus status;
  final DateTime registeredAt;

  /// Path to the uploaded invoice file in Supabase Storage.
  final String? invoicePath;

  /// Masked IMEI for display: shows first 9 digits and last 1, hides middle.
  String get maskedImei {
    final digits = imei.replaceAll(' ', '');
    if (digits.length < 10) return imei;
    return '${digits.substring(0, 9)} *** ${digits[digits.length - 1]}';
  }

  String get displayDate {
    final d = registeredAt;
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

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      model: (json['model'] as String?) ?? '',
      brand: (json['brand'] as String?) ?? 'Unknown',
      imei: json['imei1'] as String,
      imei2: json['imei2'] as String?,
      operator: (json['operator'] as String?) ?? '',
      status: DeviceStatusX.fromString(json['status'] as String),
      registeredAt: DateTime.parse(json['registered_at'] as String),
      invoicePath: json['purchase_invoice_url'] as String?,
    );
  }

  DeviceModel copyWith({DeviceStatus? status}) {
    return DeviceModel(
      id: id,
      ownerId: ownerId,
      model: model,
      brand: brand,
      imei: imei,
      imei2: imei2,
      operator: operator,
      status: status ?? this.status,
      registeredAt: registeredAt,
      invoicePath: invoicePath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DeviceModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
