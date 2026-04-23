import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../auth/logic/auth_controller.dart';
import '../data/models/user_dashboard_model.dart';
import '../data/services/dashboard_service.dart';
import 'widgets/activity_tile.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_stat_card.dart';
import 'widgets/quick_action_tile.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardService _dashboardService = DashboardService();
  late Future<UserDashboardModel> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  Future<UserDashboardModel> _loadDashboard() {
    final userName =
        AuthController.instance.state.user?.fullName ?? 'eDRMP User';
    return _dashboardService.fetchUserDashboard(userName: userName);
  }

  Future<void> _refresh() async {
    final next = _loadDashboard();
    setState(() => _dashboardFuture = next);
    await next;
  }

  void _onQuickActionTap(String title) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$title will be available in upcoming phases.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<UserDashboardModel>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 36),
                  const SizedBox(height: 10),
                  const Text('Unable to load dashboard data.'),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: _refresh,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                DashboardHeader(userName: data.userName),
                const SizedBox(height: 16),
                Text(
                  'Quick Summary',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.9,
                  children: [
                    DashboardStatCard(
                      title: 'Registered Devices',
                      value: data.summary.registeredDevices,
                      color: AppColors.info,
                    ),
                    DashboardStatCard(
                      title: 'Pending Requests',
                      value: data.summary.pendingRequests,
                      color: AppColors.pending,
                    ),
                    DashboardStatCard(
                      title: 'FIR Reports',
                      value: data.summary.firReports,
                      color: AppColors.error,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                ...data.quickActions.map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: QuickActionTile(
                      title: action.title,
                      subtitle: action.subtitle,
                      icon: action.icon,
                      onTap: () => _onQuickActionTap(action.title),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                ...data.recentActivities.map(
                  (activity) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ActivityTile(
                      title: activity.title,
                      description: activity.description,
                      timestamp: activity.timestamp,
                      isUnread: activity.isUnread,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Status Overview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: data.statusOverview
                      .map(
                        (item) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('${item.label}: ${item.value}'),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
