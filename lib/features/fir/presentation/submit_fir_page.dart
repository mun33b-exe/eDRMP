import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_app_bar.dart';

class SubmitFirPage extends StatelessWidget {
  const SubmitFirPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: AppStrings.titleSubmitFir),
      body: Center(
        child: Text(
          AppStrings.stubPhaseFir,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
