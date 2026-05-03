import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/utils/app_sizes.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../theme/colors.dart';
import '../../auth/logic/auth_controller.dart';
import '../../auth/logic/auth_user.dart';

/// Read-only citizen profile page.
///
/// Displays name, masked CNIC, email, phone, role badge, member-since date.
/// A "Sign out" button triggers a confirmation dialog and calls
/// [AuthController.logout].
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPadding.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page heading
              Text(
                AppStrings.titleProfile,
                style: TextStyle(
                  fontSize: AppSizes.h2(context),
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              AppSpacing.vXl,
              // Avatar + name chip
              _AvatarSection(user: user, isDark: isDark),
              AppSpacing.vXl,
              // Profile fields card
              _ProfileCard(user: user, isDark: isDark),
              AppSpacing.vXl,
              // Sign out
              _SignOutButton(isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatar + name + role badge
// ---------------------------------------------------------------------------

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({required this.user, required this.isDark});

  final AuthUser? user;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final name = user?.fullName ?? 'Hamza Ali Khan';
    final role = user?.role.displayName ?? 'Citizen';

    return Row(
      children: [
        Builder(
          builder: (context) {
            final sz = AppSizes.avatar(context);
            return Container(
          width: sz,
          height: sz,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: AppRadius.allLg,
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: AppSizes.h2(context),
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
            );
          },
        ),
        AppSpacing.hLg,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: AppSizes.h3(context),
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.vXs,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.md,
                  vertical: 4,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: AppRadius.allPill,
                ),
                child: Text(
                  role,
                  style: TextStyle(
                    fontSize: AppSizes.bodySmall(context),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Profile information card with labelled rows
// ---------------------------------------------------------------------------

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user, required this.isDark});

  final AuthUser? user;
  final bool isDark;

  /// Masks all but the last 4 digits of the CNIC: 35202-xxxxxxx-9
  String _maskedCnic(String cnic) {
    if (cnic.length < 4) return cnic;
    final digits = cnic.replaceAll('-', '');
    final masked =
        '${'*' * (digits.length - 4)}${digits.substring(digits.length - 4)}';
    // Reformat as 5-7-1
    if (masked.length == 13) {
      return '${masked.substring(0, 5)}-${masked.substring(5, 12)}-${masked.substring(12)}';
    }
    return masked;
  }

  @override
  Widget build(BuildContext context) {
    final name = user?.fullName ?? 'Hamza Ali Khan';
    final cnic = _maskedCnic(user?.cnic ?? '42101-XXXXXXX-8');
    final email = user?.email ?? 'hamza@edrmp.pk';
    final phone = user?.phone ?? '+92 300 1234567';

    final rows = [
      (AppStrings.profileFullName, name, false),
      (AppStrings.profileCnic, cnic, true),
      (AppStrings.profileEmail, email, false),
      (AppStrings.profilePhone, phone, true),
      (AppStrings.profileMemberSince, 'Mar 2026', false),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.card,
        borderRadius: AppRadius.allLg,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: List.generate(rows.length, (i) {
          final (label, value, mono) = rows[i];
          final isLast = i == rows.length - 1;
          return _ProfileRow(
            label: label,
            value: value,
            mono: mono,
            isDark: isDark,
            isLast: isLast,
          );
        }),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.label,
    required this.value,
    required this.isDark,
    required this.isLast,
    this.mono = false,
  });

  final String label;
  final String value;
  final bool isDark;
  final bool isLast;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.lg,
        vertical: AppPadding.md,
      ),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.divider,
                ),
              ),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppSizes.bodySmall(context),
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppSizes.bodyRegular(context),
                fontWeight: FontWeight.w600,
                fontFamily: mono ? 'monospace' : null,
                letterSpacing: mono ? 0.3 : 0,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sign-out button
// ---------------------------------------------------------------------------

class _SignOutButton extends ConsumerWidget {
  const _SignOutButton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => const ConfirmDialog(
              title: AppStrings.profileSignOut,
              message: AppStrings.profileSignOutConfirm,
              confirmLabel: AppStrings.profileSignOut,
              isDestructive: true,
            ),
          );
          if (confirmed == true && context.mounted) {
            await ref.read(authControllerProvider.notifier).logout();
            if (context.mounted) {
              context.go(RouteNames.login);
            }
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.allMd),
        ),
        icon: const Icon(Icons.logout_outlined, size: 18),
        label: const Text(AppStrings.profileSignOut),
      ),
    );
  }
}
