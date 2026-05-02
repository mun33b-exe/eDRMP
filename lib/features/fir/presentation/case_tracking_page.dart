import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_app_bar.dart';

class CaseTrackingPage extends StatelessWidget {
  const CaseTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: AppStrings.titleCaseTracking),
      body: Center(
        child: Text(
          AppStrings.stubPhaseFir,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
