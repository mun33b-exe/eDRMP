import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_app_bar.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(
        title: AppStrings.titleLogin,
        showBackButton: false,
      ),
      body: Center(
        child: Text(
          AppStrings.stubPhaseAuth,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
