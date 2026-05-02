import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_app_bar.dart';

class MyDevicesPage extends StatelessWidget {
  const MyDevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: AppStrings.titleMyDevices),
      body: Center(
        child: Text(
          AppStrings.stubPhaseDevices,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
