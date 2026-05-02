import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import 'case_status_entry.dart';

class CaseStatusRepository {
  CaseStatusRepository();

  Future<List<CaseStatusEntry>> fetchForEntity(String entityId) async {
    final rows = await SupabaseService.client
        .from('case_status_log')
        .select()
        .eq('entity_id', entityId)
        .order('created_at', ascending: true);
    return rows.map(CaseStatusEntry.fromJson).toList();
  }

  /// Opens a Realtime subscription on the citizen's own case_status_log rows.
  /// Calls [onUpdate] whenever a new entry is inserted for [entityId].
  RealtimeChannel subscribeToEntity({
    required String entityId,
    required void Function(CaseStatusEntry) onUpdate,
  }) {
    return SupabaseService.client
        .channel('case_log_$entityId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'case_status_log',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'entity_id',
            value: entityId,
          ),
          callback: (payload) {
            final entry = CaseStatusEntry.fromJson(payload.newRecord);
            onUpdate(entry);
          },
        )
        .subscribe();
  }
}

final caseStatusRepositoryProvider = Provider<CaseStatusRepository>(
  (_) => CaseStatusRepository(),
);
