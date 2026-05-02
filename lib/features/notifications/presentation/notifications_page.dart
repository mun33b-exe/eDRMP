import 'package:flutter/material.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../theme/colors.dart';

/// Notification shell — empty state only for Phase 2.
///
/// Phase 4 will inject the FCM notification list here.
// TODO(Phase 9): replace empty shell with real notification list from Supabase.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.titleNotifications,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // No-op for now.
                    await Future<void>.delayed(
                      const Duration(milliseconds: 500),
                    );
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: const EmptyState(
                          icon: Icons.notifications_none_outlined,
                          title: AppStrings.notificationsEmptyTitle,
                          message: AppStrings.notificationsEmptyBody,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
