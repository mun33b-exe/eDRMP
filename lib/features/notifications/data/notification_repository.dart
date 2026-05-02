import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import 'notification_model.dart';

class NotificationRepository {
  NotificationRepository();

  Future<List<NotificationModel>> fetchAll() async {
    final userId = SupabaseService.client.auth.currentUser!.id;
    final rows = await SupabaseService.client
        .from('notifications')
        .select()
        .eq('recipient_id', userId)
        .order('created_at', ascending: false);
    return rows.map(NotificationModel.fromJson).toList();
  }

  Future<void> markRead(String id) async {
    await SupabaseService.client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);
  }

  Future<void> markAllRead() async {
    final userId = SupabaseService.client.auth.currentUser!.id;
    await SupabaseService.client
        .from('notifications')
        .update({'is_read': true})
        .eq('recipient_id', userId)
        .eq('is_read', false);
  }

  /// Realtime subscription — notifies [onNew] when a new notification arrives.
  RealtimeChannel subscribe({required void Function(NotificationModel) onNew}) {
    final userId = SupabaseService.client.auth.currentUser!.id;
    return SupabaseService.client
        .channel('notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'recipient_id',
            value: userId,
          ),
          callback: (payload) {
            final notification = NotificationModel.fromJson(payload.newRecord);
            onNew(notification);
          },
        )
        .subscribe();
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (_) => NotificationRepository(),
);
