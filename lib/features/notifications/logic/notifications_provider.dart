import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/notification_model.dart';
import '../data/notification_repository.dart';

class NotificationsNotifier extends AsyncNotifier<List<NotificationModel>> {
  RealtimeChannel? _channel;

  NotificationRepository get _repo => ref.read(notificationRepositoryProvider);

  @override
  Future<List<NotificationModel>> build() async {
    final notifications = await _repo.fetchAll();
    _subscribeRealtime();
    ref.onDispose(() => _channel?.unsubscribe());
    return notifications;
  }

  void _subscribeRealtime() {
    _channel = _repo.subscribe(
      onNew: (notification) {
        final current = state.valueOrNull ?? [];
        state = AsyncValue.data([notification, ...current]);
      },
    );
  }

  Future<void> markRead(String id) async {
    await _repo.markRead(id);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
    );
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
      NotificationsNotifier.new,
    );

final unreadCountProvider = Provider<int>((ref) {
  return ref
          .watch(notificationsProvider)
          .valueOrNull
          ?.where((n) => !n.isRead)
          .length ??
      0;
});
