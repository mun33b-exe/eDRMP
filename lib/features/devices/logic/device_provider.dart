import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/block_request_model.dart';
import '../data/block_request_repository.dart';
import '../data/device_model.dart';
import '../data/device_repository.dart';
import '../data/unblock_request_model.dart';
import '../data/unblock_request_repository.dart';

// ---------------------------------------------------------------------------
// Repository providers
// ---------------------------------------------------------------------------

final deviceRepositoryProvider = Provider<DeviceRepository>(
  (_) => DeviceRepository(),
);

final blockRequestRepositoryProvider = Provider<BlockRequestRepository>(
  (_) => BlockRequestRepository(),
);

final unblockRequestRepositoryProvider = Provider<UnblockRequestRepository>(
  (_) => UnblockRequestRepository(),
);

// ---------------------------------------------------------------------------
// Devices list — AsyncNotifier
// ---------------------------------------------------------------------------

class DevicesNotifier extends AsyncNotifier<List<DeviceModel>> {
  DeviceRepository get _repo => ref.read(deviceRepositoryProvider);

  @override
  Future<List<DeviceModel>> build() => _repo.fetchAll();

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
// Single device — reads from the shared list
// ---------------------------------------------------------------------------

final deviceByIdProvider = Provider.family<DeviceModel?, String>((ref, id) {
  final asyncDevices = ref.watch(devicesProvider);
  return asyncDevices.valueOrNull?.where((d) => d.id == id).firstOrNull;
});

// ---------------------------------------------------------------------------
// Block / Unblock request list providers
// ---------------------------------------------------------------------------

final blockRequestsByFirProvider =
    FutureProvider.family<List<BlockRequestModel>, String>((ref, firId) {
      return ref.read(blockRequestRepositoryProvider).fetchByFirId(firId);
    });

final unblockRequestsByFirProvider =
    FutureProvider.family<List<UnblockRequestModel>, String>((ref, firId) {
      return ref.read(unblockRequestRepositoryProvider).fetchByFirId(firId);
    });
