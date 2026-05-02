import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple value-object for a mock device entry shown in the home preview.
@immutable
class MockDevice {
  const MockDevice({
    required this.model,
    required this.imei,
    required this.status,
    required this.date,
    required this.operator,
  });

  final String model;
  final String imei;

  /// One of: 'approved', 'pending', 'rejected', 'blocked'.
  final String status;
  final String date;
  final String operator;
}

/// Aggregate stats surfaced in the hero card and mini-stat strip.
@immutable
class DashboardStats {
  const DashboardStats({
    required this.totalDevices,
    required this.approved,
    required this.pending,
    required this.firs,
    required this.devices,
  });

  final int totalDevices;
  final int approved;
  final int pending;
  final int firs;

  /// Preview list shown in the "My devices" section (max 2 items).
  final List<MockDevice> devices;
}

/// In-memory mock dashboard stats.
///
/// 3 devices — 2 approved, 1 pending, 0 FIRs.
// TODO(Phase 9): replace with a real Supabase query.
final dashboardMockProvider = Provider<DashboardStats>((ref) {
  return const DashboardStats(
    totalDevices: 3,
    approved: 2,
    pending: 1,
    firs: 0,
    devices: [
      MockDevice(
        model: 'iPhone 15 Pro',
        imei: '356938 09 123456 7',
        status: 'approved',
        date: '12 Mar 2026',
        operator: 'Jazz',
      ),
      MockDevice(
        model: 'Samsung Galaxy S24',
        imei: '354678 12 654321 9',
        status: 'pending',
        date: '28 Apr 2026',
        operator: 'Telenor',
      ),
    ],
  );
});
