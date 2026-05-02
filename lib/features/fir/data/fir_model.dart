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
}

extension CaseStatusX on CaseStatus {
  bool get isTerminal =>
      this == CaseStatus.firRejected ||
      this == CaseStatus.blockRejected ||
      this == CaseStatus.deviceBlocked ||
      this == CaseStatus.deviceRecovered;

  bool get isApprovedPath =>
      this == CaseStatus.firVerified ||
      this == CaseStatus.blockPending ||
      this == CaseStatus.blockApproved ||
      this == CaseStatus.deviceBlocked;
}

@immutable
class FirModel {
  const FirModel({
    required this.id,
    required this.deviceId,
    required this.deviceInfo,
    required this.policeStation,
    required this.incidentDate,
    required this.description,
    required this.caseStatus,
    required this.createdAt,
    this.rejectReason,
  });

  final String id;
  final String deviceId;
  final String deviceInfo; // e.g. "iPhone 15 Pro · IMEI 356938..."
  final String policeStation;
  final DateTime incidentDate;
  final String description;
  final CaseStatus caseStatus;
  final DateTime createdAt;
  final String? rejectReason;

  FirModel copyWith({
    String? id,
    String? deviceId,
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
      deviceId: deviceId ?? this.deviceId,
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
