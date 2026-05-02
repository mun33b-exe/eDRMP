import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_app_bar.dart';

class PtaDashboardPage extends StatelessWidget {
  const PtaDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: AppStrings.titlePtaDashboard),
      body: Center(
        child: Text(
          AppStrings.stubPhasePta,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
