import 'package:flutter/material.dart';

class UserDashboardModel {
  const UserDashboardModel({
    required this.userName,
    required this.summary,
    required this.quickActions,
    required this.recentActivities,
    required this.statusOverview,
  });

  final String userName;
  final DashboardSummary summary;
  final List<DashboardQuickAction> quickActions;
  final List<DashboardActivity> recentActivities;
  final List<DashboardStatusItem> statusOverview;
}

class DashboardSummary {
  const DashboardSummary({
    required this.registeredDevices,
    required this.pendingRequests,
    required this.firReports,
  });

  final int registeredDevices;
  final int pendingRequests;
  final int firReports;
}

class DashboardQuickAction {
  const DashboardQuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class DashboardActivity {
  const DashboardActivity({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isUnread,
  });

  final String title;
  final String description;
  final String timestamp;
  final bool isUnread;
}

class DashboardStatusItem {
  const DashboardStatusItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;
}
