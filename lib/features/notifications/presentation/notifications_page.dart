import 'package:flutter/material.dart';

import '../../../theme/colors.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<_NotificationItem> _notifications = [
    const _NotificationItem(
      title: 'FIR update received',
      body: 'Your FIR case #FIR-2026-078 has moved to under review.',
      time: '1h ago',
      isRead: false,
    ),
    const _NotificationItem(
      title: 'Security tip',
      body: 'Keep your profile and recovery details updated.',
      time: 'Yesterday',
      isRead: true,
    ),
  ];

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _notifications.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 130),
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 54,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(height: 12),
                  Center(
                    child: Text(
                      'No notifications yet',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Important status updates will appear here.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final notification = _notifications[index];

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: notification.isRead
                            ? AppColors.border
                            : AppColors.secondary,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          notification.isRead
                              ? Icons.mark_email_read_outlined
                              : Icons.mark_email_unread_outlined,
                          color: notification.isRead
                              ? AppColors.textMuted
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification.body,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                notification.time,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemCount: _notifications.length,
              ),
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
  });

  final String title;
  final String body;
  final String time;
  final bool isRead;
}
