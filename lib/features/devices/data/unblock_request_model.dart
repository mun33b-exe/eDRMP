import 'package:flutter/foundation.dart';

enum UnblockRequestStatus {
  pendingPolice,
  policeApproved,
  ptaUnblocked,
  rejected,
}

@immutable
class UnblockRequestModel {
  const UnblockRequestModel({
    required this.id,
    required this.firId,
    required this.deviceId,
    required this.requestedBy,
    required this.status,
    required this.createdAt,
    this.policeApprovedAt,
    this.policeApprovedBy,
    this.rejectionReason,
  });

  final String id;
  final String firId;
  final String deviceId;
  final String requestedBy;
  final UnblockRequestStatus status;
  final DateTime createdAt;
  final DateTime? policeApprovedAt;
  final String? policeApprovedBy;
  final String? rejectionReason;

  factory UnblockRequestModel.fromJson(Map<String, dynamic> json) {
    return UnblockRequestModel(
      id: json['id'] as String,
      firId: json['fir_id'] as String,
      deviceId: json['device_id'] as String,
      requestedBy: json['requested_by'] as String,
      status: _parseStatus(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      policeApprovedAt: json['police_approved_at'] != null
          ? DateTime.parse(json['police_approved_at'] as String)
          : null,
      policeApprovedBy: json['police_approved_by'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  static UnblockRequestStatus _parseStatus(String s) {
    switch (s) {
      case 'police_approved':
        return UnblockRequestStatus.policeApproved;
      case 'pta_unblocked':
        return UnblockRequestStatus.ptaUnblocked;
      case 'rejected':
        return UnblockRequestStatus.rejected;
      default:
        return UnblockRequestStatus.pendingPolice;
    }
  }
}
