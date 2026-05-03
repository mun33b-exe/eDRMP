import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_durations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/route_helpers.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/utils/app_sizes.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
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
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.darkBackground, AppColors.darkSurface]
                : [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // eDRMP Logo / Brand
                  Builder(
                    builder: (context) {
                      final sz = AppSizes.iconLg(context);
                      return Container(
                        width: sz,
                        height: sz,
                        decoration: BoxDecoration(
                          color: AppColors.textInverse.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.shield_outlined,
                          size: sz * 0.6,
                          color: AppColors.textInverse,
                        ),
                      );
                    },
                  ),
                  AppSpacing.vLg,
                  // eDRMP Title — Poppins Bold, 48px, white
                  Text(
                    AppStrings.appName,
                    style: AppTextStyles.h1(color: AppColors.textInverse),
                  ),
                  AppSpacing.vSm,
                  // Tagline — Body Small, white, opacity 0.8
                  Text(
                    'Device Registration & Management Platform',
                    style: AppTextStyles.bodySmall(
                      color: AppColors.textInverse.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Loading indicator at bottom
            Positioned(
              bottom: MediaQuery.paddingOf(context).bottom + 48,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.textInverse.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
