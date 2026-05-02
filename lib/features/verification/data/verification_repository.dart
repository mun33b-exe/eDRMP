import '../../../core/services/supabase_service.dart';
import '../../devices/data/device_model.dart';
import 'verification_result.dart';

class VerificationRepository {
  VerificationRepository();

  Future<VerificationResult> checkImei(String imei) async {
    final rows = await SupabaseService.client
        .from('devices')
        .select(
          'id, imei1, brand, model, status, registered_at, profiles!owner_id(cnic)',
        )
        .eq('imei1', imei)
        .limit(1);

    if (rows.isEmpty) return VerificationResult.notFound(imei);

    final row = rows.first;
    final profileData = row['profiles'] as Map<String, dynamic>?;
    final cnic = profileData?['cnic'] as String? ?? '';

    return VerificationResult.found(
      imei: imei,
      brand: (row['brand'] as String?) ?? '',
      model: (row['model'] as String?) ?? '',
      maskedCnic: _maskCnic(cnic),
      status: DeviceStatusX.fromString((row['status'] as String?) ?? 'pending'),
      registeredAt: DateTime.parse(row['registered_at'] as String),
    );
  }

  static String _maskCnic(String cnic) {
    final parts = cnic.split('-');
    if (parts.length == 3) {
      return '${parts[0]}-*******-${parts[2]}';
    }
    final digits = cnic.replaceAll('-', '');
    if (digits.length != 13) return 'xxxxx-xxxxxxx-x';
    return '${digits.substring(0, 5)}-*******-${digits[12]}';
  }
}
