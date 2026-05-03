import 'package:flutter/foundation.dart';

/// Matches SRDS §5.5 Case tracking statuses
enum CaseStatus {
  deviceRegistered,
  firSubmitted,
  firUnderReview,
  firVerified,
  firRejected,
  blockPending,
  blockApproved,
  blockRejected,
  deviceBlocked,
  deviceRecovered,
  unblockPending,
  unblockApproved,
  unblocked,
}

extension CaseStatusX on CaseStatus {
  bool get isTerminal =>
      this == CaseStatus.firRejected ||
      this == CaseStatus.blockRejected ||
      this == CaseStatus.deviceBlocked ||
      this == CaseStatus.deviceRecovered ||
      this == CaseStatus.unblocked;

  bool get isApprovedPath =>
      this == CaseStatus.firVerified ||
      this == CaseStatus.blockPending ||
      this == CaseStatus.blockApproved ||
      this == CaseStatus.deviceBlocked ||
      this == CaseStatus.unblockPending ||
      this == CaseStatus.unblockApproved ||
      this == CaseStatus.unblocked;

  String toDbString() {
    switch (this) {
      case CaseStatus.deviceRegistered:
        return 'pending_review';
      case CaseStatus.firSubmitted:
        return 'pending_review';
      case CaseStatus.firUnderReview:
        return 'under_review';
      case CaseStatus.firVerified:
        return 'verified';
      case CaseStatus.firRejected:
        return 'rejected';
      case CaseStatus.blockPending:
        return 'block_pending';
      case CaseStatus.blockApproved:
        return 'block_approved';
      case CaseStatus.blockRejected:
        return 'block_rejected';
      case CaseStatus.deviceBlocked:
        return 'blocked';
      case CaseStatus.deviceRecovered:
        return 'recovered';
      case CaseStatus.unblockPending:
        return 'unblock_pending';
      case CaseStatus.unblockApproved:
        return 'unblock_approved';
      case CaseStatus.unblocked:
        return 'unblocked';
    }
  }

  static CaseStatus fromString(String s) {
    switch (s) {
      case 'pending_review':
        return CaseStatus.firSubmitted;
      case 'under_review':
        return CaseStatus.firUnderReview;
      case 'verified':
        return CaseStatus.firVerified;
      case 'rejected':
        return CaseStatus.firRejected;
      case 'block_pending':
        return CaseStatus.blockPending;
      case 'block_approved':
        return CaseStatus.blockApproved;
      case 'block_rejected':
        return CaseStatus.blockRejected;
      case 'blocked':
        return CaseStatus.deviceBlocked;
      case 'recovered':
        return CaseStatus.deviceRecovered;
      case 'unblock_pending':
        return CaseStatus.unblockPending;
      case 'unblock_approved':
        return CaseStatus.unblockApproved;
      case 'unblocked':
        return CaseStatus.unblocked;
      default:
        debugPrint('⚠️ Unknown FIR status: "$s" — defaulting to firSubmitted');
        return CaseStatus.firSubmitted;
    }
  }
}

@immutable
class FirModel {
  const FirModel({
    required this.id,
    required this.ownerId,
    required this.deviceId,
    required this.firNumber,
    required this.deviceInfo,
    required this.policeStation,
    required this.incidentDate,
    required this.description,
    required this.caseStatus,
    required this.createdAt,
    this.rejectReason,
  });

  final String id;
  final String ownerId;
  final String deviceId;
  final String firNumber;
  final String deviceInfo;
  final String policeStation;
  final DateTime incidentDate;
  final String description;
  final CaseStatus caseStatus;
  final DateTime createdAt;
  final String? rejectReason;

  factory FirModel.fromJson(Map<String, dynamic> json) {
    final device = json['devices'] as Map<String, dynamic>?;
    final brand = (device?['brand'] as String?) ?? '';
    final model = (device?['model'] as String?) ?? '';
    final imei = (device?['imei1'] as String?) ?? '';
    final deviceInfo = brand.isNotEmpty && model.isNotEmpty
        ? '$brand $model · IMEI $imei'
        : imei.isNotEmpty
        ? 'IMEI $imei'
        : 'Unknown Device';

    return FirModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      deviceId: json['device_id'] as String,
      firNumber: json['fir_number'] as String,
      deviceInfo: deviceInfo,
      policeStation: json['police_station'] as String,
      incidentDate: DateTime.parse(json['incident_date'] as String),
      description: (json['description'] as String?) ?? '',
      caseStatus: CaseStatusX.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      rejectReason: json['rejection_reason'] as String?,
    );
  }

  FirModel copyWith({
    String? id,
    String? ownerId,
    String? deviceId,
    String? firNumber,
    String? deviceInfo,
    String? policeStation,
    DateTime? incidentDate,
    String? description,
    CaseStatus? caseStatus,
    DateTime? createdAt,
    String? rejectReason,
  }) {
    return FirModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      deviceId: deviceId ?? this.deviceId,
      firNumber: firNumber ?? this.firNumber,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      policeStation: policeStation ?? this.policeStation,
      incidentDate: incidentDate ?? this.incidentDate,
      description: description ?? this.description,
      caseStatus: caseStatus ?? this.caseStatus,
      createdAt: createdAt ?? this.createdAt,
      rejectReason: rejectReason ?? this.rejectReason,
    );
  }
}
