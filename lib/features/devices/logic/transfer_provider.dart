import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/transfer_model.dart';
import '../data/transfer_repository.dart';
import 'device_provider.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final transferRepositoryProvider = Provider<TransferRepository>(
  (_) => TransferRepository(),
);

// ---------------------------------------------------------------------------
// Transfers list — AsyncNotifier
// ---------------------------------------------------------------------------

class TransfersNotifier extends AsyncNotifier<List<TransferModel>> {
  TransferRepository get _repo => ref.read(transferRepositoryProvider);

  @override
  Future<List<TransferModel>> build() => _repo.fetchAll();

  Future<TransferModel> create({
    required String deviceId,
    required String recipientCnic,
    String? note,
  }) async {
    final transfer = await _repo.create(
      deviceId: deviceId,
      recipientCnic: recipientCnic,
      note: note,
    );
    ref.invalidateSelf();
    return transfer;
  }

  Future<void> accept(String transferId) async {
    await _repo.accept(transferId);
    ref.invalidateSelf();
    ref.invalidate(devicesProvider);
  }

  Future<void> reject(String transferId) async {
    await _repo.reject(transferId);
    ref.invalidateSelf();
  }

  Future<void> cancel(String transferId) async {
    await _repo.cancel(transferId);
    ref.invalidateSelf();
  }
}

final transfersProvider =
    AsyncNotifierProvider<TransfersNotifier, List<TransferModel>>(
      TransfersNotifier.new,
    );
