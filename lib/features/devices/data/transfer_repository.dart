import '../../../core/services/supabase_service.dart';
import 'transfer_model.dart';

class TransferRepository {
  TransferRepository();

  /// Fetch all transfers relevant to the current user (sent + received).
  Future<List<TransferModel>> fetchAll() async {
    final userId = SupabaseService.client.auth.currentUser!.id;

    // Fetch outgoing transfers
    final outgoing = await SupabaseService.client
        .from('device_transfers')
        .select(
          '*, devices(brand, model, imei1), '
          'from_profile:profiles!device_transfers_from_owner_id_fkey(full_name), '
          'to_profile:profiles!device_transfers_to_owner_id_fkey!left(full_name)',
        )
        .eq('from_owner_id', userId)
        .order('created_at', ascending: false);

    // Fetch incoming transfers (by CNIC match)
    final profile = await SupabaseService.client
        .from('profiles')
        .select('cnic')
        .eq('id', userId)
        .single();
    final cnic = profile['cnic'] as String;

    final incoming = await SupabaseService.client
        .from('device_transfers')
        .select(
          '*, devices(brand, model, imei1), '
          'from_profile:profiles!device_transfers_from_owner_id_fkey(full_name), '
          'to_profile:profiles!device_transfers_to_owner_id_fkey!left(full_name)',
        )
        .eq('to_cnic', cnic)
        .order('created_at', ascending: false);

    // Merge and deduplicate
    final allIds = <String>{};
    final results = <TransferModel>[];
    for (final row in [...outgoing, ...incoming]) {
      final id = row['id'] as String;
      if (allIds.add(id)) {
        results.add(TransferModel.fromJson(row));
      }
    }
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  /// Create a new transfer request.
  Future<TransferModel> create({
    required String deviceId,
    required String recipientCnic,
    String? note,
  }) async {
    final userId = SupabaseService.client.auth.currentUser!.id;

    // Resolve recipient's profile ID via SECURITY DEFINER function
    // (bypasses RLS so we can look up other users by CNIC)
    final lookupResult = await SupabaseService.client
        .rpc<String?>('lookup_profile_by_cnic', params: {'target_cnic': recipientCnic});
    final recipientId = lookupResult;

    final row = await SupabaseService.client
        .from('device_transfers')
        .insert({
          'device_id': deviceId,
          'from_owner_id': userId,
          'to_cnic': recipientCnic,
          'to_owner_id': recipientId,
          'note': note,
        })
        .select()
        .single();

    return TransferModel.fromJson(row);
  }

  /// Accept a transfer — uses SECURITY DEFINER RPC to atomically update
  /// both the transfer status and the device owner_id.
  Future<void> accept(String transferId) async {
    await SupabaseService.client
        .rpc<void>('accept_device_transfer', params: {'transfer_id': transferId});
  }

  /// Reject a transfer request.
  Future<void> reject(String transferId) async {
    await SupabaseService.client
        .from('device_transfers')
        .update({
          'status': 'rejected',
          'resolved_at': DateTime.now().toIso8601String(),
        })
        .eq('id', transferId);
  }

  /// Cancel a transfer request (by sender).
  Future<void> cancel(String transferId) async {
    await SupabaseService.client
        .from('device_transfers')
        .update({
          'status': 'cancelled',
          'resolved_at': DateTime.now().toIso8601String(),
        })
        .eq('id', transferId);
  }
}
