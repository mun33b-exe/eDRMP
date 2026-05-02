import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_app_bar.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: AppStrings.titleRegister),
      body: Center(
        child: Text(
          AppStrings.stubPhaseAuth,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
