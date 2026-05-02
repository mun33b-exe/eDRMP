import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: AppStrings.titleSettings),
      body: Center(
        child: Text(
          AppStrings.stubPhaseSettings,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
