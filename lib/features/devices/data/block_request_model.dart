import 'package:flutter/foundation.dart';

enum BlockRequestStatus { pending, approved, rejected }

@immutable
class BlockRequestModel {
  const BlockRequestModel({
    required this.id,
    required this.firId,
    required this.deviceId,
    required this.requestedBy,
    required this.status,
    required this.createdAt,
    this.rejectionReason,
  });

  final String id;
  final String firId;
  final String deviceId;
  final String requestedBy;
  final BlockRequestStatus status;
  final DateTime createdAt;
  final String? rejectionReason;

  factory BlockRequestModel.fromJson(Map<String, dynamic> json) {
    return BlockRequestModel(
      id: json['id'] as String,
      firId: json['fir_id'] as String,
      deviceId: json['device_id'] as String,
      requestedBy: json['requested_by'] as String,
      status: _parseStatus(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  static BlockRequestStatus _parseStatus(String s) {
    switch (s) {
      case 'approved':
        return BlockRequestStatus.approved;
      case 'rejected':
        return BlockRequestStatus.rejected;
      default:
        return BlockRequestStatus.pending;
    }
  }
}
