import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/route_names.dart';

/// Lightweight splash placeholder.
///
/// Phase 0 hands off to `/login` after a short brand pause. Phase 1 will
/// extend this with the real auth-state probe.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(AppDurations.splash, () {
      if (!mounted) {
        return;
      }
      context.go(RouteNames.login);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppStrings.appName, style: textTheme.displayLarge),
            AppSpacing.vSm,
            Text(AppStrings.appTagline, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
