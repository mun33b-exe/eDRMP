import 'package:flutter/material.dart';

import '../constants/app_padding.dart';
import '../constants/app_strings.dart';
import '../../theme/colors.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({required this.isOnline, super.key});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return SizeTransition(
          sizeFactor: animation,
          axisAlignment: -1,
          child: child,
        );
      },
      child: isOnline
          ? const SizedBox.shrink()
          : Container(
              key: const ValueKey('offline-banner'),
              width: double.infinity,
              color: AppColors.error,
              padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.lg,
                vertical: AppPadding.xs,
              ),
              child: const Text(
                AppStrings.connectivityOffline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.buttonTextLight,
                ),
              ),
            ),
    );
  }
}
