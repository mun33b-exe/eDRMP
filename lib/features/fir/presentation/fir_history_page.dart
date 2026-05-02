import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_app_bar.dart';

class FirHistoryPage extends StatelessWidget {
  const FirHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: AppStrings.titleFirHistory),
      body: Center(
        child: Text(
          AppStrings.stubPhaseFir,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
