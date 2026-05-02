import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_app_bar.dart';

class TheftMapPage extends StatelessWidget {
  const TheftMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: AppStrings.titleTheftMap),
      body: Center(
        child: Text(
          AppStrings.stubPhaseMap,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
