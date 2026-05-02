import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_app_bar.dart';
import '../../../core/widgets/app_timeline.dart';
import '../data/fir_model.dart';
import '../logic/fir_provider.dart';

class CaseTrackingPage extends ConsumerWidget {
  const CaseTrackingPage({super.key, required this.firId});

  final String firId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firAsync = ref.watch(firByIdProvider(firId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const AppAppBar(title: AppStrings.titleCaseTracking),
      body: firAsync.when(
        data: (fir) {
          final items = _buildTimelineItems(fir);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppPadding.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Case Meta
                Text(
                  'Case ${fir.id.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                AppSpacing.vSm,
                Text(
                  fir.deviceInfo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.vXl,

                // Timeline
                AppTimeline(items: items, isDark: isDark),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  List<AppTimelineItemData> _buildTimelineItems(FirModel fir) {
    final df = DateFormat('dd MMM yyyy · hh:mm a');
    final submittedDate = df.format(fir.createdAt);

    // Base timeline states mapping
    final statusIndex = _getStatusIndex(fir.caseStatus);

    return [
      AppTimelineItemData(
        state: statusIndex >= 0 ? 'done' : 'pending',
        title: AppStrings.caseTimelineDeviceRegistered,
        meta: 'Verified via DIRBS',
      ),
      AppTimelineItemData(
        state: statusIndex >= 1 ? 'done' : 'pending',
        title: AppStrings.caseTimelineFirSubmitted,
        meta: statusIndex >= 1 ? submittedDate : '—',
      ),
      AppTimelineItemData(
        state: statusIndex > 2
            ? 'done'
            : (statusIndex == 2 ? 'active' : 'pending'),
        title: AppStrings.caseTimelineFirUnderReview,
        meta: statusIndex >= 2 ? 'Police review in progress' : '—',
      ),
      // Branching logic for Review -> Verification
      if (fir.caseStatus == CaseStatus.firRejected)
        AppTimelineItemData(
          state: 'rejected',
          title: AppStrings.caseTimelineFirRejected,
          meta: 'Application closed',
          note: fir.rejectReason,
        )
      else ...[
        AppTimelineItemData(
          state: statusIndex > 3
              ? 'done'
              : (statusIndex == 3 ? 'active' : 'pending'),
          title: AppStrings.caseTimelineFirVerified,
          meta: statusIndex >= 3 ? 'FIR validated' : '—',
        ),
        AppTimelineItemData(
          state: statusIndex > 5
              ? 'done'
              : ((statusIndex == 4 || statusIndex == 5) ? 'active' : 'pending'),
          title: AppStrings.caseTimelineBlockPending,
          meta: statusIndex >= 4 ? 'Sent to PTA' : '—',
        ),
        if (fir.caseStatus == CaseStatus.blockRejected)
          AppTimelineItemData(
            state: 'rejected',
            title: AppStrings.caseTimelineBlockRejected,
            meta: 'Device block declined by PTA',
            note: fir.rejectReason,
          )
        else ...[
          AppTimelineItemData(
            state: statusIndex > 6
                ? 'done'
                : (statusIndex == 6 ? 'active' : 'pending'),
            title: AppStrings.caseTimelineBlockApproved,
            meta: statusIndex >= 6 ? 'PTA approved block' : '—',
          ),
          AppTimelineItemData(
            state: statusIndex >= 8 ? 'done' : 'pending',
            title: fir.caseStatus == CaseStatus.deviceRecovered
                ? AppStrings.caseTimelineDeviceRecovered
                : AppStrings.caseTimelineDeviceBlocked,
            meta: statusIndex >= 8 ? 'Action completed' : '—',
          ),
        ],
      ],
    ];
  }

  int _getStatusIndex(CaseStatus s) {
    switch (s) {
      case CaseStatus.deviceRegistered:
        return 0;
      case CaseStatus.firSubmitted:
        return 1;
      case CaseStatus.firUnderReview:
        return 2;
      case CaseStatus.firVerified:
        return 3;
      case CaseStatus.firRejected:
        return 2; // the next step shows as rejected
      case CaseStatus.blockPending:
        return 4;
      case CaseStatus.blockApproved:
        return 6;
      case CaseStatus.blockRejected:
        return 5;
      case CaseStatus.deviceBlocked:
        return 8;
      case CaseStatus.deviceRecovered:
        return 9;
    }
  }
}
