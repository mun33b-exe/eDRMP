import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_app_bar.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: AppStrings.titleNotifications),
      body: Center(
        child: Text(
          AppStrings.stubPhaseNotifications,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
