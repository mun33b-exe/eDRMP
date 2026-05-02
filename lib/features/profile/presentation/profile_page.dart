import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_app_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: AppStrings.titleProfile),
      body: Center(
        child: Text(
          AppStrings.stubPhaseProfile,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
