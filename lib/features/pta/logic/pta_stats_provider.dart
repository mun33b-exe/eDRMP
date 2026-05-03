import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';

@immutable
class PtaStats {
  const PtaStats({
    required this.totalDevices,
    required this.approvals,
    required this.activeFirs,
    required this.blocked,
  });

  final int totalDevices;
  final int approvals;
  final int activeFirs;
  final int blocked;
}

class PtaStatsNotifier extends AsyncNotifier<PtaStats> {
  @override
  Future<PtaStats> build() async {
    final client = SupabaseService.client;

    final devices = await client.from('devices').select('id, status');
    final firs = await client.from('firs').select('id, status');

    final total = devices.length;
    final approved = devices.where((d) => d['status'] == 'approved').length;
    final activeFirsCount = firs.where((f) {
      final s = f['status'] as String;
      return s != 'rejected' && s != 'unblocked';
    }).length;
    final blockedCount = devices.where((d) => d['status'] == 'blocked').length;

    return PtaStats(
      totalDevices: total,
      approvals: approved,
      activeFirs: activeFirsCount,
      blocked: blockedCount,
    );
  }
}

final ptaStatsProvider = AsyncNotifierProvider<PtaStatsNotifier, PtaStats>(
  PtaStatsNotifier.new,
);
