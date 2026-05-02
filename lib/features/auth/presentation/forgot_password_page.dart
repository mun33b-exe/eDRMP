import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_app_bar.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: AppStrings.titleForgotPassword),
      body: Center(
        child: Text(
          AppStrings.stubPhaseAuth,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
