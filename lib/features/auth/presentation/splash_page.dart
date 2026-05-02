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
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 180,
                    minHeight: 56,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.lg,
                    vertical: AppPadding.md,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: AppRadius.allLg,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 24,
                        color: AppColors.buttonTextLight,
                      ),
                      AppSpacing.hSm,
                      Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.buttonTextLight,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.vSm,
                const Text(
                  AppStrings.appTagline,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkTextMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.darkTextMuted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
