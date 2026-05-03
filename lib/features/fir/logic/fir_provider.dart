import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fir_model.dart';
import '../data/fir_repository.dart';

final firRepositoryProvider = Provider<FirRepository>((_) => FirRepository());

final firsProvider = AsyncNotifierProvider<FirsNotifier, List<FirModel>>(
  FirsNotifier.new,
);

class FirsNotifier extends AsyncNotifier<List<FirModel>> {
  FirRepository get _repo => ref.read(firRepositoryProvider);

  @override
  Future<List<FirModel>> build() => _repo.fetchUserFirs();

  Future<void> submitFir({
    required String deviceId,
    required String firNumber,
    required String policeStation,
    required DateTime incidentDate,
    required String description,
    String? proofFilePath,
    double? incidentLat,
    double? incidentLng,
    String? incidentAddress,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.submitFir(
        deviceId: deviceId,
        firNumber: firNumber,
        policeStation: policeStation,
        incidentDate: incidentDate,
        description: description,
        proofFilePath: proofFilePath,
        incidentLat: incidentLat,
        incidentLng: incidentLng,
        incidentAddress: incidentAddress,
      );
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateFirStatus(
    String id,
    CaseStatus status, [
    String? rejectReason,
  ]) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateFirStatus(id, status, rejectReason);
      ref.invalidate(firByIdProvider(id));
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final firByIdProvider = FutureProvider.family<FirModel, String>((ref, id) {
  return ref.watch(firRepositoryProvider).fetchFirById(id);
});
