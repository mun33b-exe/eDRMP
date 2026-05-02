import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_app_bar.dart';

class PoliceDashboardPage extends StatelessWidget {
  const PoliceDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: AppStrings.titlePoliceDashboard),
      body: Center(
        child: Text(
          AppStrings.stubPhasePolice,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
