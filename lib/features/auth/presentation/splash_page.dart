import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/route_helpers.dart';
import '../../../core/routes/route_names.dart';
import '../../../theme/colors.dart';
import '../../onboarding/logic/onboarding_controller.dart';
import '../logic/auth_controller.dart';

/// Brand splash. Holds for [AppDurations.splash], then routes the user to
/// the appropriate landing page.
///
/// Routing precedence (Phase 1.5):
///   1. First-launch (`!hasSeenOnboarding`) → `/onboarding`.
///   2. Authenticated → role-specific home.
///   3. Otherwise → `/login`.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(AppDurations.splash, _routeAway);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _routeAway() {
    if (!mounted) {
      return;
    }
    final hasSeenOnboarding = ref.read(onboardingControllerProvider);
    if (!hasSeenOnboarding) {
      context.go(RouteNames.onboarding);
      return;
    }
    final auth = ref.read(authControllerProvider).valueOrNull;
    if (auth == null || !auth.isAuthenticated) {
      context.go(RouteNames.login);
      return;
    }
    context.go(homeRouteForRole(auth.role!));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final brightness = Theme.of(context).brightness;
    final chipBg = brightness == Brightness.dark
        ? AppColors.primaryDark
        : AppColors.primarySoft;
    final chipFg = brightness == Brightness.dark
        ? AppColors.buttonTextLight
        : AppColors.primary;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.xxl),
          child: Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.lg,
                  vertical: AppPadding.md,
                ),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: AppRadius.allLg,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, size: 22, color: chipFg),
                    AppSpacing.hSm,
                    Text(
                      AppStrings.appName,
                      style: textTheme.titleLarge?.copyWith(color: chipFg),
                    ),
                  ],
                ),
              ),
              AppSpacing.vLg,
              Text(
                AppStrings.appTagline,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
