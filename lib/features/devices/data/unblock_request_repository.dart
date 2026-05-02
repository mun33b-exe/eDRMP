import '../../../core/services/supabase_service.dart';
import 'unblock_request_model.dart';

class UnblockRequestRepository {
  UnblockRequestRepository();

  Future<List<UnblockRequestModel>> fetchByFirId(String firId) async {
    final rows = await SupabaseService.client
        .from('unblock_requests')
        .select()
        .eq('fir_id', firId)
        .order('created_at', ascending: false);
    return rows.map(UnblockRequestModel.fromJson).toList();
  }

  Future<UnblockRequestModel> create({
    required String firId,
    required String deviceId,
  }) async {
    final row = await SupabaseService.client
        .from('unblock_requests')
        .insert({
          'fir_id': firId,
          'device_id': deviceId,
          'requested_by': SupabaseService.client.auth.currentUser!.id,
          'status': 'pending_police',
        })
        .select()
        .single();
    return UnblockRequestModel.fromJson(row);
  }

  /// Police approves the unblock request.
  Future<void> policeApprove(String id) async {
    await SupabaseService.client
        .from('unblock_requests')
        .update({
          'status': 'police_approved',
          'police_approved_at': DateTime.now().toIso8601String(),
          'police_approved_by': SupabaseService.client.auth.currentUser!.id,
        })
        .eq('id', id);
  }

  /// PTA completes the unblock.
  Future<void> ptaUnblock(String id) async {
    await SupabaseService.client
        .from('unblock_requests')
        .update({'status': 'pta_unblocked'})
        .eq('id', id);
  }

  Future<void> reject(String id, String reason) async {
    await SupabaseService.client
        .from('unblock_requests')
        .update({'status': 'rejected', 'rejection_reason': reason})
        .eq('id', id);
  }
}
