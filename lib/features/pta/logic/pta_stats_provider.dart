import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';

@immutable
class TopModel {
  const TopModel({required this.label, required this.count});
  final String label;
  final int count;
}

@immutable
class PtaStats {
  const PtaStats({
    required this.totalDevices,
    required this.approvals,
    required this.activeFirs,
    required this.blocked,
    required this.dailyRegistrations,
    required this.dailyBlocks,
    required this.topModels,
  });

  final int totalDevices;
  final int approvals;
  final int activeFirs;
  final int blocked;

  /// 30-day daily counts: index 0 = 29 days ago, index 29 = today.
  final List<int> dailyRegistrations;
  final List<int> dailyBlocks;

  /// Top 5 device models by registration count.
  final List<TopModel> topModels;
}

class PtaStatsNotifier extends AsyncNotifier<PtaStats> {
  @override
  Future<PtaStats> build() async {
    final client = SupabaseService.client;

    final devices = await client.from('devices').select('id, status, registered_at, brand, model');
    final firs = await client.from('firs').select('id, status');

    final total = devices.length;
    final approved = devices.where((d) => d['status'] == 'approved').length;
    final activeFirsCount = firs.where((f) {
      final s = f['status'] as String;
      return s != 'rejected' && s != 'unblocked';
    }).length;
    final blockedCount = devices.where((d) => d['status'] == 'blocked').length;

    debugPrint('PTA Stats: $total devices, $approved approved, '
        '$activeFirsCount active FIRs, $blockedCount blocked');
    for (final d in devices) {
      debugPrint('  Device ${(d['id'] as String).substring(0, 8)} → ${d['status']}');
    }
    for (final f in firs) {
      debugPrint('  FIR ${(f['id'] as String).substring(0, 8)} → ${f['status']}');
    }

    // Build 30-day trend from actual data
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 29));
    final dailyRegs = List<int>.filled(30, 0);
    final dailyBlks = List<int>.filled(30, 0);

    for (final d in devices) {
      final raw = d['registered_at'] as String?;
      if (raw == null) continue;
      final date = DateTime.tryParse(raw);
      if (date == null || date.isBefore(thirtyDaysAgo)) continue;
      final dayIndex = date.difference(thirtyDaysAgo).inDays.clamp(0, 29);
      dailyRegs[dayIndex]++;
      if (d['status'] == 'blocked') {
        dailyBlks[dayIndex]++;
      }
    }

    // Compute top models
    final modelCounts = <String, int>{};
    for (final d in devices) {
      final brand = (d['brand'] as String? ?? '').trim();
      final model = (d['model'] as String? ?? '').trim();
      final label = [brand, model].where((s) => s.isNotEmpty).join(' ');
      if (label.isEmpty) continue;
      modelCounts[label] = (modelCounts[label] ?? 0) + 1;
    }
    final sorted = modelCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topModels = sorted.take(5).map((e) => TopModel(label: e.key, count: e.value)).toList();

    return PtaStats(
      totalDevices: total,
      approvals: approved,
      activeFirs: activeFirsCount,
      blocked: blockedCount,
      dailyRegistrations: dailyRegs,
      dailyBlocks: dailyBlks,
      topModels: topModels,
    );
  }
}

final ptaStatsProvider = AsyncNotifierProvider<PtaStatsNotifier, PtaStats>(
  PtaStatsNotifier.new,
);
