import 'dart:async';

import 'device_model.dart';

/// In-memory device store shared across the citizen, police, and PTA modules.
///
/// All async ops simulate a 400 ms network round-trip so UI loading states
/// are exercised. Phase 9 replaces this with a Supabase `devices` table query.
// TODO(Phase 9): replace with SupabaseDeviceRepository.
class DeviceRepository {
  DeviceRepository() : _devices = List.of(_seedDevices);

  final List<DeviceModel> _devices;

  // ---------------------------------------------------------------------------
  // Seed data — 3 devices (2 approved, 1 pending)
  // Mirrors the Phase 2 dashboardMockProvider counts.
  // ---------------------------------------------------------------------------
  static final List<DeviceModel> _seedDevices = [
    DeviceModel(
      id: 'dev-001',
      model: 'iPhone 15 Pro',
      brand: 'Apple',
      imei: '356938 09 123456 7',
      imei2: null,
      operator: 'Jazz',
      status: DeviceStatus.approved,
      registeredAt: DateTime(2026, 3, 12),
    ),
    DeviceModel(
      id: 'dev-002',
      model: 'Galaxy S24',
      brand: 'Samsung',
      imei: '354678 12 654321 9',
      imei2: '354678 12 654321 0',
      operator: 'Telenor',
      status: DeviceStatus.pending,
      registeredAt: DateTime(2026, 4, 28),
    ),
    DeviceModel(
      id: 'dev-003',
      model: 'Redmi Note 13',
      brand: 'Xiaomi',
      imei: '869912 04 789012 3',
      imei2: null,
      operator: 'Zong',
      status: DeviceStatus.approved,
      registeredAt: DateTime(2026, 1, 5),
    ),
  ];

  /// IMEI → brand/model auto-fill dictionary (Phase 3 mock).
  static const Map<String, ({String brand, String model})> _imeiPrefixMap = {
    '35693809': (brand: 'Apple', model: 'iPhone 15 Pro'),
    '35467812': (brand: 'Samsung', model: 'Galaxy S24'),
    '86991204': (brand: 'Xiaomi', model: 'Redmi Note 13'),
  };

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  Future<List<DeviceModel>> fetchAll() async {
    await _delay();
    return List.unmodifiable(_devices);
  }

  Future<DeviceModel?> fetchById(String id) async {
    await _delay();
    try {
      return _devices.firstWhere((d) => d.id == id);
    } on StateError {
      return null;
    }
  }

  /// Returns `null` if no match. Called during IMEI entry auto-fill.
  ({String brand, String model})? lookupImei(String rawImei) {
    final digits = rawImei.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return null;
    return _imeiPrefixMap[digits.substring(0, 8)];
  }

  /// Checks if [rawImei] already belongs to this user's account.
  bool isDuplicate(String rawImei) {
    final normalised = rawImei.replaceAll(RegExp(r'\D'), '');
    return _devices.any(
      (d) =>
          d.imei.replaceAll(RegExp(r'\D'), '') == normalised ||
          (d.imei2?.replaceAll(RegExp(r'\D'), '') ?? '') == normalised,
    );
  }

  /// Adds a new device registration and returns the created model.
  Future<DeviceModel> register({
    required String imei,
    String? imei2,
    required String brand,
    required String model,
    required String operator,
  }) async {
    await _delay();
    final device = DeviceModel(
      id: 'dev-${DateTime.now().millisecondsSinceEpoch}',
      model: model,
      brand: brand,
      imei: imei,
      imei2: imei2,
      operator: operator,
      status: DeviceStatus.pending,
      registeredAt: DateTime.now(),
    );
    _devices.insert(0, device);
    return device;
  }

  static Future<void> _delay() =>
      Future<void>.delayed(const Duration(milliseconds: 400));
}
