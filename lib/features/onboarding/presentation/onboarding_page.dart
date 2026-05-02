import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/widgets/app_button.dart';
import '../../../theme/colors.dart';
import '../logic/onboarding_controller.dart';
import 'widgets/onboarding_logo.dart';
import 'widgets/shield_illustration.dart';

/// First-launch onboarding screen.
///
/// Single-slide, pixel-faithful match to `ScreenOnboarding` in
/// `design/handoff/project/screens-citizen.jsx` (~lines 7–46). The 3-dot
/// indicator is decorative for Phase 1.5 — the JSX hints at a multi-slide
/// carousel, but only one slide is rendered there. Per CLAUDE.md §8 Phase 1.5
/// Deliverable #2, this is built as a single slide.
class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  void _proceedToLogin(
    BuildContext context,
    WidgetRef ref, {
    required bool markSeen,
  }) {
    if (markSeen) {
      ref.read(onboardingControllerProvider.notifier).markSeen();
    }
    context.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final background = isDark
        ? AppColors.darkBackground
        : AppColors.scaffoldBackground;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final bodyColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final inactiveDot = isDark ? AppColors.darkBorder : AppColors.inactiveDot;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar — Logo (left) + Skip (right). Padding mirrors the JSX
            // (8px top, 22px sides) for visual fidelity to the handoff.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppPadding.xxl - AppPadding.xs, // ≈ 22 (handoff: 22)
                AppPadding.sm,
                AppPadding.xxl - AppPadding.xs,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OnboardingLogo(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.primary,
                  ),
                  TextButton(
                    onPressed: () =>
                        _proceedToLogin(context, ref, markSeen: true),
                    style: TextButton.styleFrom(
                      foregroundColor: mutedColor,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text(AppStrings.onboardingSkip),
                  ),
                ],
              ),
            ),

            // Centre — illustration + title + body.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.xxl + AppPadding.xs, // ≈ 28
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ShieldIllustration(),
                    AppSpacing.vXl, // 22-ish, handoff uses 22
                    Text(
                      AppStrings.onboardingTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: AppPadding.sm + 2),
                    Text(
                      AppStrings.onboardingBody,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: bodyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom — page indicator, primary CTA, "Already registered? Sign in".
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppPadding.xxl - AppPadding.xs, // 22
                0,
                AppPadding.xxl - AppPadding.xs,
                AppPadding.xxl + AppPadding.xs, // 28
              ),
              child: Column(
                children: [
                  _PageIndicator(
                    activeColor: AppColors.primary,
                    inactiveColor: inactiveDot,
                  ),
                  AppSpacing.vMd,
                  AppButton(
                    label: AppStrings.onboardingCta,
                    icon: Icons.arrow_forward,
                    onPressed: () =>
                        _proceedToLogin(context, ref, markSeen: true),
                  ),
                  AppSpacing.vSm,
                  _SignInRow(
                    onTap: () => _proceedToLogin(context, ref, markSeen: false),
                    mutedColor: mutedColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 3-dot pagination indicator. The first dot is the wide pill (24×6); the
/// other two are 6×6 inactive markers. Decorative for Phase 1.5 — there's
/// only one onboarding slide.
class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.activeColor,
    required this.inactiveColor,
  });

  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Dot(width: 24, height: 6, color: activeColor),
          const SizedBox(width: 6),
          _Dot(width: 6, height: 6, color: inactiveColor),
          const SizedBox(width: 6),
          _Dot(width: 6, height: 6, color: inactiveColor),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.width, required this.height, required this.color});

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.allPill),
    );
  }
}

class _SignInRow extends StatelessWidget {
  const _SignInRow({required this.onTap, required this.mutedColor});

  final VoidCallback onTap;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppPadding.xs),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: 12, color: mutedColor),
            children: const [
              TextSpan(text: '${AppStrings.onboardingAlreadyRegistered} '),
              TextSpan(
                text: AppStrings.onboardingSignInLink,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
