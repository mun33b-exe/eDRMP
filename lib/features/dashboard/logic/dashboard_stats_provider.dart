import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../devices/data/device_model.dart';
import '../../devices/logic/device_provider.dart';
import '../../fir/logic/fir_provider.dart';

/// Lightweight device entry shown in the dashboard preview strip (max 2).
@immutable
class DashboardDevice {
  const DashboardDevice({
    required this.model,
    required this.imei,
    required this.status,
    required this.date,
    required this.operator,
  });

  final String model;
  final String imei;

  /// Lower-cased status string: 'approved', 'pending', 'rejected', 'blocked', 'unblocked'.
  final String status;
  final String date;
  final String operator;
}

/// Aggregate stats derived from the real device and FIR providers.
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
  final List<DashboardDevice> devices;
}

/// Computes dashboard stats from the real devicesProvider and firsProvider.
/// Returns zeros while the underlying data is still loading.
final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final devices = ref.watch(devicesProvider).valueOrNull ?? [];
  final firs = ref.watch(firsProvider).valueOrNull ?? [];

  final approved = devices
      .where(
        (d) =>
            d.status == DeviceStatus.approved ||
            d.status == DeviceStatus.unblocked,
      )
      .length;
  final pending = devices.where((d) => d.status == DeviceStatus.pending).length;

  final preview = devices.take(2).map((d) {
    return DashboardDevice(
      model: '${d.brand} ${d.model}'.trim(),
      imei: d.imei,
      status: _deviceStatusString(d.status),
      date: d.displayDate,
      operator: d.operator,
    );
  }).toList();

  return DashboardStats(
    totalDevices: devices.length,
    approved: approved,
    pending: pending,
    firs: firs.length,
    devices: preview,
  );
});

String _deviceStatusString(DeviceStatus s) {
  switch (s) {
    case DeviceStatus.approved:
      return 'approved';
    case DeviceStatus.rejected:
      return 'rejected';
    case DeviceStatus.blocked:
      return 'blocked';
    case DeviceStatus.unblocked:
      return 'unblocked';
    default:
      return 'pending';
  }
}
