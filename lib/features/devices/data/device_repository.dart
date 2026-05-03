import '../../../core/services/supabase_service.dart';
import 'device_model.dart';

class DeviceRepository {
  DeviceRepository();

  // IMEI prefix → brand/model auto-fill (UI convenience, no backend call).
  static const Map<String, ({String brand, String model})> _imeiPrefixMap = {
    '35693809': (brand: 'Apple', model: 'iPhone 15 Pro'),
    '35467812': (brand: 'Samsung', model: 'Galaxy S24'),
    '86991204': (brand: 'Xiaomi', model: 'Redmi Note 13'),
    '35975010': (brand: 'OnePlus', model: 'OnePlus 12'),
    '86123456': (brand: 'Tecno', model: 'Camon 30'),
    '35912310': (brand: 'Google', model: 'Pixel 8'),
    '86400000': (brand: 'Infinix', model: 'Hot 40'),
    '35800000': (brand: 'Vivo', model: 'Y200'),
  };

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Fetches devices for the current session.
  /// RLS ensures citizens see only their own; PTA/police see all.
  Future<List<DeviceModel>> fetchAll() async {
    final rows = await SupabaseService.client
        .from('devices')
        .select('*, profiles(full_name, cnic, phone)')
        .order('registered_at', ascending: false);
    return rows.map(DeviceModel.fromJson).toList();
  }

  Future<DeviceModel?> fetchById(String id) async {
    final rows = await SupabaseService.client
        .from('devices')
        .select('*, profiles(full_name, cnic, phone)')
        .eq('id', id)
        .limit(1);
    if (rows.isEmpty) return null;
    return DeviceModel.fromJson(rows.first);
  }

  /// Returns `null` if no IMEI prefix match. Called during IMEI entry auto-fill.
  ({String brand, String model})? lookupImei(String rawImei) {
    final digits = rawImei.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return null;
    return _imeiPrefixMap[digits.substring(0, 8)];
  }

  /// Inserts a new device registration and returns the created model.
  Future<DeviceModel> register({
    required String imei,
    String? imei2,
    required String brand,
    required String model,
    required String operator,
  }) async {
    final row = await SupabaseService.client
        .from('devices')
        .insert({
          'owner_id': SupabaseService.client.auth.currentUser!.id,
          'imei1': imei,
          'imei2': imei2,
          'brand': brand,
          'model': model,
          'operator': operator,
          'status': 'pending',
        })
        .select()
        .single();
    return DeviceModel.fromJson(row);
  }

  Future<void> updateDeviceStatus(String id, DeviceStatus status) async {
    await SupabaseService.client
        .from('devices')
        .update({
          'status': _deviceStatusToString(status),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  static String _deviceStatusToString(DeviceStatus s) {
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
}
