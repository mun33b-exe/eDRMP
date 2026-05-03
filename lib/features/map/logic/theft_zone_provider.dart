import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../data/theft_zone_model.dart';
import '../data/theft_zone_repository.dart';

class TheftZonesNotifier extends AsyncNotifier<List<TheftZone>> {
  RealtimeChannel? _channel;

  @override
  Future<List<TheftZone>> build() async {
    final zones = await const TheftZoneRepository().fetchAll();
    _subscribeRealtime();
    ref.onDispose(() => _channel?.unsubscribe());
    return zones;
  }

  void _subscribeRealtime() {
    _channel = SupabaseService.client
        .channel('theft_zones_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'theft_zones',
          callback: (_) => ref.invalidateSelf(),
        )
        .subscribe();
  }
}

final theftZoneProvider =
    AsyncNotifierProvider<TheftZonesNotifier, List<TheftZone>>(
      TheftZonesNotifier.new,
    );
