import 'package:flutter/foundation.dart';

@immutable
class CaseStatusEntry {
  const CaseStatusEntry({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.newStatus,
    required this.createdAt,
    this.oldStatus,
    this.changedBy,
    this.note,
  });

  final String id;

  /// One of: 'device', 'fir', 'block', 'unblock'
  final String entityType;
  final String entityId;
  final String? oldStatus;
  final String newStatus;
  final String? changedBy;
  final String? note;
  final DateTime createdAt;

  factory CaseStatusEntry.fromJson(Map<String, dynamic> json) {
    return CaseStatusEntry(
      id: json['id'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      oldStatus: json['old_status'] as String?,
      newStatus: json['new_status'] as String,
      changedBy: json['changed_by'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
