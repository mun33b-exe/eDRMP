import 'package:flutter/foundation.dart';

/// Transfer request statuses.
enum TransferStatus { pending, accepted, rejected, cancelled }

extension TransferStatusX on TransferStatus {
  String get displayName {
    switch (this) {
      case TransferStatus.pending:
        return 'Pending';
      case TransferStatus.accepted:
        return 'Accepted';
      case TransferStatus.rejected:
        return 'Rejected';
      case TransferStatus.cancelled:
        return 'Cancelled';
    }
  }

  String toDbString() {
    switch (this) {
      case TransferStatus.pending:
        return 'pending';
      case TransferStatus.accepted:
        return 'accepted';
      case TransferStatus.rejected:
        return 'rejected';
      case TransferStatus.cancelled:
        return 'cancelled';
    }
  }

  static TransferStatus fromString(String s) {
    switch (s) {
      case 'accepted':
        return TransferStatus.accepted;
      case 'rejected':
        return TransferStatus.rejected;
      case 'cancelled':
        return TransferStatus.cancelled;
      default:
        return TransferStatus.pending;
    }
  }
}

/// Represents a device ownership transfer request.
@immutable
class TransferModel {
  const TransferModel({
    required this.id,
    required this.deviceId,
    required this.fromOwnerId,
    required this.toCnic,
    required this.status,
    required this.createdAt,
    this.toOwnerId,
    this.note,
    this.resolvedAt,
    this.deviceBrand,
    this.deviceModel,
    this.deviceImei,
    this.fromOwnerName,
    this.toOwnerName,
  });

  final String id;
  final String deviceId;
  final String fromOwnerId;
  final String toCnic;
  final String? toOwnerId;
  final TransferStatus status;
  final String? note;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  // Joined fields for display
  final String? deviceBrand;
  final String? deviceModel;
  final String? deviceImei;
  final String? fromOwnerName;
  final String? toOwnerName;

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    final device = json['devices'] as Map<String, dynamic>?;
    final fromProfile = json['from_profile'] as Map<String, dynamic>?;
    final toProfile = json['to_profile'] as Map<String, dynamic>?;

    return TransferModel(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      fromOwnerId: json['from_owner_id'] as String,
      toCnic: json['to_cnic'] as String,
      toOwnerId: json['to_owner_id'] as String?,
      status: TransferStatusX.fromString(json['status'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      deviceBrand: device?['brand'] as String?,
      deviceModel: device?['model'] as String?,
      deviceImei: device?['imei1'] as String?,
      fromOwnerName: fromProfile?['full_name'] as String?,
      toOwnerName: toProfile?['full_name'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TransferModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
