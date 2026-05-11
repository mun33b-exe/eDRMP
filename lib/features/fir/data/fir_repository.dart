import 'dart:io';
import 'dart:typed_data';

import '../../../core/services/supabase_service.dart';
import 'fir_model.dart';

class FirRepository {
  FirRepository();

  static const String _firDocsBucket = 'fir-documents';

  // ---------------------------------------------------------------------------
  // Queries — RLS ensures role-appropriate visibility
  // ---------------------------------------------------------------------------

  /// Fetches FIRs for the current session with device info joined.
  /// Citizens see only their own; police/PTA see all (via RLS).
  Future<List<FirModel>> fetchUserFirs() async {
    final rows = await SupabaseService.client
        .from('firs')
        .select('*, devices(brand, model, imei1)')
        .order('created_at', ascending: false);
    return rows.map(FirModel.fromJson).toList();
  }

  Future<FirModel> fetchFirById(String id) async {
    final row = await SupabaseService.client
        .from('firs')
        .select('*, devices(brand, model, imei1)')
        .eq('id', id)
        .single();
    return FirModel.fromJson(row);
  }

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  /// Inserts a new FIR. If [proofBytes] is provided, uploads to Storage first
  /// (3 retries, 100/200/400 ms exponential back-off).
  Future<FirModel> submitFir({
    required String deviceId,
    required String firNumber,
    required String policeStation,
    required DateTime incidentDate,
    required String description,
    String? proofFilePath,
    Uint8List? proofBytes,
    String? proofFileName,
    double? incidentLat,
    double? incidentLng,
    String? incidentAddress,
  }) async {
    String? proofUrl;

    if (proofFilePath != null) {
      final file = File(proofFilePath);
      final bytes = await file.readAsBytes();
      final name = proofFilePath.split('/').last;
      proofUrl = await _uploadWithRetry(bytes, name);
    } else if (proofBytes != null && proofFileName != null) {
      proofUrl = await _uploadWithRetry(proofBytes, proofFileName);
    }

    final userId = SupabaseService.client.auth.currentUser!.id;
    final payload = {
      'owner_id': userId,
      'device_id': deviceId,
      'fir_number': firNumber.isEmpty ? 'N/A' : firNumber,
      'police_station': policeStation,
      'incident_date': incidentDate.toIso8601String().split('T').first,
      'description': description,
      'status': 'pending_review',
      'proof_url': ?proofUrl,
      'incident_lat': ?incidentLat,
      'incident_lng': ?incidentLng,
      'incident_address': ?incidentAddress,
    };

    final row = await SupabaseService.client
        .from('firs')
        .insert(payload)
        .select('*, devices(brand, model, imei1)')
        .single();
    return FirModel.fromJson(row);
  }

  /// Finds the most recent blocked FIR for [deviceId] and submits an
  /// unblock_request on behalf of the current user.
  /// Returns the FIR id if successful, throws if no eligible FIR exists.
  Future<String> requestReactivation(String deviceId) async {
    final rows = await SupabaseService.client
        .from('firs')
        .select('id')
        .eq('device_id', deviceId)
        .eq('status', 'blocked')
        .order('created_at', ascending: false)
        .limit(1);

    if (rows.isEmpty) {
      throw Exception('no_fir');
    }

    final firId = rows.first['id'] as String;
    final userId = SupabaseService.client.auth.currentUser!.id;

    final existing = await SupabaseService.client
        .from('unblock_requests')
        .select('id')
        .eq('fir_id', firId)
        .eq('requested_by', userId)
        .inFilter('status', ['pending_police', 'police_approved'])
        .limit(1);

    if (existing.isNotEmpty) {
      throw Exception('already_pending');
    }

    await SupabaseService.client
        .from('unblock_requests')
        .insert({
          'fir_id': firId,
          'device_id': deviceId,
          'requested_by': userId,
          'status': 'pending_police',
        });

    return firId;
  }

  Future<void> updateFirStatus(
    String id,
    CaseStatus status, [
    String? rejectReason,
  ]) async {
    final update = <String, dynamic>{
      'status': status.toDbString(),
      'updated_at': DateTime.now().toIso8601String(),
      'rejection_reason': ?rejectReason,
    };
    await SupabaseService.client.from('firs').update(update).eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // Storage upload with 3-attempt exponential back-off
  // ---------------------------------------------------------------------------

  Future<String> _uploadWithRetry(Uint8List bytes, String fileName) async {
    final userId = SupabaseService.client.auth.currentUser!.id;
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    const delays = [100, 200, 400];
    Exception? last;

    for (var i = 0; i <= delays.length; i++) {
      try {
        await SupabaseService.client.storage
            .from(_firDocsBucket)
            .uploadBinary(path, bytes);
        return path;
      } on Exception catch (e) {
        last = e;
        if (i < delays.length) {
          await Future<void>.delayed(Duration(milliseconds: delays[i]));
        }
      }
    }

    throw last!;
  }
}
