import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_app_bar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: AppStrings.titleDashboard),
      body: Center(
        child: Text(
          AppStrings.stubPhaseShell,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
