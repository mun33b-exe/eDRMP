import '../../../core/services/supabase_service.dart';
import 'block_request_model.dart';

class BlockRequestRepository {
  BlockRequestRepository();

  Future<List<BlockRequestModel>> fetchByFirId(String firId) async {
    final rows = await SupabaseService.client
        .from('block_requests')
        .select()
        .eq('fir_id', firId)
        .order('created_at', ascending: false);
    return rows.map(BlockRequestModel.fromJson).toList();
  }

  Future<BlockRequestModel> create({
    required String firId,
    required String deviceId,
  }) async {
    final row = await SupabaseService.client
        .from('block_requests')
        .insert({
          'fir_id': firId,
          'device_id': deviceId,
          'requested_by': SupabaseService.client.auth.currentUser!.id,
          'status': 'pending',
        })
        .select()
        .single();
    return BlockRequestModel.fromJson(row);
  }

  Future<void> approve(String id) async {
    await SupabaseService.client
        .from('block_requests')
        .update({'status': 'approved'})
        .eq('id', id);
  }

  Future<void> reject(String id, String reason) async {
    await SupabaseService.client
        .from('block_requests')
        .update({'status': 'rejected', 'rejection_reason': reason})
        .eq('id', id);
  }
}
