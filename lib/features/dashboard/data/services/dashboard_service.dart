import 'package:flutter/material.dart';

import '../../../../theme/colors.dart';
import '../../data/models/user_dashboard_model.dart';

class DashboardService {
  Future<UserDashboardModel> fetchUserDashboard({
    required String userName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    return UserDashboardModel(
      userName: userName,
      summary: const DashboardSummary(
        registeredDevices: 3,
        pendingRequests: 2,
        firReports: 1,
      ),
      quickActions: const [
        DashboardQuickAction(
          title: 'Add Device',
          subtitle: 'Register a new device',
          icon: Icons.add_card_rounded,
        ),
        DashboardQuickAction(
          title: 'Report Theft',
          subtitle: 'Submit FIR details',
          icon: Icons.gpp_bad_rounded,
        ),
        DashboardQuickAction(
          title: 'View Devices',
          subtitle: 'Track all statuses',
          icon: Icons.phone_android_rounded,
        ),
      ],
      recentActivities: const [
        DashboardActivity(
          title: 'Device registration received',
          description: 'iPhone 14 Pro has been submitted for review.',
          timestamp: '2h ago',
          isUnread: true,
        ),
        DashboardActivity(
          title: 'FIR verification in progress',
          description: 'Your case #FIR-2026-078 is under review.',
          timestamp: 'Yesterday',
          isUnread: false,
        ),
        DashboardActivity(
          title: 'Security recommendation',
          description: 'Enable app notifications to stay updated.',
          timestamp: '2 days ago',
          isUnread: false,
        ),
      ],
      statusOverview: const [
        DashboardStatusItem(
          label: 'Approved',
          value: 1,
          color: AppColors.success,
        ),
        DashboardStatusItem(
          label: 'Pending',
          value: 2,
          color: AppColors.pending,
        ),
        DashboardStatusItem(
          label: 'Rejected',
          value: 0,
          color: AppColors.rejected,
        ),
      ],
    );
  }
}
