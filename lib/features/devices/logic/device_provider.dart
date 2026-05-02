import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/device_model.dart';
import '../data/device_repository.dart';

// ---------------------------------------------------------------------------
// Repository provider — singleton for the current session.
// ---------------------------------------------------------------------------

/// Single shared [DeviceRepository] instance. All features (citizen, police,
/// PTA) read from this provider so mock state is consistent across modules.
final deviceRepositoryProvider = Provider<DeviceRepository>(
  (_) => DeviceRepository(),
);

// ---------------------------------------------------------------------------
// Devices list — AsyncNotifier so we can expose add + refresh.
// ---------------------------------------------------------------------------

class DevicesNotifier extends AsyncNotifier<List<DeviceModel>> {
  DeviceRepository get _repo => ref.read(deviceRepositoryProvider);

  @override
  Future<List<DeviceModel>> build() => _repo.fetchAll();

  /// Adds a new device registration and refreshes the list.
  Future<DeviceModel> register({
    required String imei,
    String? imei2,
    required String brand,
    required String model,
    required String operator,
  }) async {
    final device = await _repo.register(
      imei: imei,
      imei2: imei2,
      brand: brand,
      model: model,
      operator: operator,
    );
    // Optimistic refresh — re-read the full list from the repo.
    ref.invalidateSelf();
    return device;
  }

  Future<void> updateDeviceStatus(String id, DeviceStatus status) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateDeviceStatus(id, status);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final devicesProvider =
    AsyncNotifierProvider<DevicesNotifier, List<DeviceModel>>(
      DevicesNotifier.new,
    );

// ---------------------------------------------------------------------------
// Single device — reads from the shared list to avoid duplicate fetches.
// ---------------------------------------------------------------------------

final deviceByIdProvider = Provider.family<DeviceModel?, String>((ref, id) {
  final asyncDevices = ref.watch(devicesProvider);
  return asyncDevices.valueOrNull?.where((d) => d.id == id).firstOrNull;
});
