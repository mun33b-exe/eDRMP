import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fir_model.dart';
import '../data/fir_repository.dart';

final firRepositoryProvider = Provider<FirRepository>((ref) {
  return FirRepository();
});

final firsProvider = AsyncNotifierProvider<FirsNotifier, List<FirModel>>(() {
  return FirsNotifier();
});

class FirsNotifier extends AsyncNotifier<List<FirModel>> {
  @override
  Future<List<FirModel>> build() async {
    return ref.watch(firRepositoryProvider).fetchUserFirs();
  }

  Future<void> submitFir({
    required String deviceId,
    required String deviceInfo,
    required String policeStation,
    required DateTime incidentDate,
    required String description,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(firRepositoryProvider)
          .submitFir(
            deviceId: deviceId,
            deviceInfo: deviceInfo,
            policeStation: policeStation,
            incidentDate: incidentDate,
            description: description,
          );
      state = AsyncValue.data(
        await ref.read(firRepositoryProvider).fetchUserFirs(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final firByIdProvider = FutureProvider.family<FirModel, String>((
  ref,
  id,
) async {
  return ref.watch(firRepositoryProvider).fetchFirById(id);
});
