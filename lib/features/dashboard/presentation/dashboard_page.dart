import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/utils/app_sizes.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../theme/colors.dart';
import '../../auth/logic/auth_controller.dart';
import '../../auth/logic/auth_user.dart';
import '../../devices/logic/device_provider.dart';
import '../../fir/logic/fir_provider.dart';
import '../../notifications/logic/notifications_provider.dart';
import '../logic/dashboard_stats_provider.dart';

/// Citizen home screen — pixel-faithful to `ScreenCitizenHome` variant 'a'
/// from `design/handoff/project/screens-citizen.jsx`.
///
/// Variant 'a' layout:
///   1. Navy gradient hero header with greeting + icon buttons
///   2. Semi-transparent REGISTERED DEVICES card with mini-stats inside hero
///   3. Quick Actions 2×2 grid
///   4. My Devices preview list (max 2 items)
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final stats = ref.watch(dashboardStatsProvider);
    final user = ref.watch(currentUserProvider);
    final unreadCount = ref.watch(
      notificationsProvider.select(
        (async) => async.valueOrNull?.where((n) => !n.isRead).length ?? 0,
      ),
    );

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(devicesProvider);
          ref.invalidate(firsProvider);
          await Future.wait([
            ref.read(devicesProvider.future),
            ref.read(firsProvider.future),
          ]);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _HeroHeader(
                user: user,
                stats: stats,
                unreadCount: unreadCount,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                context.responsiveHorizontalPadding,
                AppPadding.lg,
                context.responsiveHorizontalPadding,
                AppPadding.xl,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _SectionLabel(
                    AppStrings.dashboardQuickActions,
                    isDark: isDark,
                  ),
                  AppSpacing.vMd,
                  _QuickActionsGrid(isDark: isDark),
                  AppSpacing.vXl,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionLabel(
                        AppStrings.dashboardMyDevices,
                        isDark: isDark,
                      ),
                      GestureDetector(
                        onTap: () => context.push(RouteNames.myDevices),
                        child: Text(
                          AppStrings.dashboardSeeAll,
                          style: TextStyle(
                            fontSize: AppSizes.bodySmall(context),
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.successSoft
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vMd,
                  ...stats.devices.map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: AppPadding.sm),
                      child: _DeviceRow(device: d, isDark: isDark),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero header — gradient background + greeting + REGISTERED DEVICES card
// Matches JSX: variant === 'a' hero block
// ---------------------------------------------------------------------------

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.user,
    required this.stats,
    required this.unreadCount,
  });

  final AuthUser? user;
  final DashboardStats stats;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final displayName = user?.firstName ?? 'Hamza Khan';

    return Container(
      padding: AppSizes.heroPadding(context),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1, -0.8),
          end: Alignment(0.8, 1.2),
          stops: [0.0, 0.5, 1.0],
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting row + icon buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.dashboardGreeting,
                        style: TextStyle(
                          fontSize: AppSizes.bodySmall(context),
                          fontWeight: FontWeight.w400,
                          color: const Color(0xB3FFFFFF),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: AppSizes.bodyLarge(context) + 2,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _IconBtn(
                      icon: Icons.notifications_outlined,
                      badge: unreadCount > 0,
                      onTap: () => context.push(RouteNames.notifications),
                    ),
                    AppSpacing.hSm,
                    _IconBtn(
                      icon: Icons.person_outline,
                      onTap: () => context.push(RouteNames.profile),
                    ),
                  ],
                ),
              ],
            ),
            AppSpacing.vLg,
            // REGISTERED DEVICES glassmorphism card
            _RegisteredDevicesCard(stats: stats),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Icon button in hero (on = white bg variant from JSX IconBtn)
// ---------------------------------------------------------------------------

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap, this.badge = false});

  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.iconSm(context),
        height: AppSizes.iconSm(context),
        decoration: BoxDecoration(
          color: const Color(0x14FFFFFF),
          borderRadius: AppRadius.allMd,
          border: Border.all(color: const Color(0x1AFFFFFF)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            if (badge)
              Positioned(
                top: 8,
                right: 9,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Semi-transparent "REGISTERED DEVICES" card inside hero gradient
// JSX: <Card dark={false} style={{ background:'rgba(255,255,255,0.10)', ... }}>
// ---------------------------------------------------------------------------

class _RegisteredDevicesCard extends StatelessWidget {
  const _RegisteredDevicesCard({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.lg),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: AppRadius.allLg,
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.dashboardRegisteredDevices,
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(10),
                      fontWeight: FontWeight.w500,
                      color: const Color(0x99FFFFFF),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${stats.totalDevices}',
                    style: TextStyle(
                      fontSize: AppSizes.h1(context),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.sm + 2,
                  vertical: AppPadding.xs + 1,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x26FFFFFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.dashboardAllActive,
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(11),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xCCFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Divider
          Container(height: 1, color: const Color(0x1EFFFFFF)),
          const SizedBox(height: 14),
          // Mini stats row — Approved / Pending / FIRs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniStat(
                label: AppStrings.dashboardApproved,
                value: '${stats.approved}',
                color: AppColors.approved,
              ),
              _MiniStat(
                label: AppStrings.dashboardPending,
                value: '${stats.pending}',
                color: AppColors.pending,
              ),
              _MiniStat(
                label: AppStrings.dashboardFirs,
                value: '${stats.firs}',
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mini stat inside the hero card — JSX Mini component
// ---------------------------------------------------------------------------

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: context.responsiveFontSize(10),
            color: const Color(0x80FFFFFF),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: context.responsiveFontSize(18),
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.isDark});

  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: AppSizes.bodyRegular(context),
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Actions 2×2 grid — JSX QuickAction component
// tone → color mapping mirrors the JSX
// ---------------------------------------------------------------------------

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: context.isMobile ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppPadding.sm,
      crossAxisSpacing: AppPadding.sm,
      childAspectRatio: AppSizes.quickActionAspect(context),
      children: [
        _QuickActionTile(
          icon: Icons.add_outlined,
          label: AppStrings.dashboardRegisterDevice,
          toneColor: AppColors.primary,
          isDark: isDark,
          onTap: () => context.push(RouteNames.addDevice),
        ),
        _QuickActionTile(
          icon: Icons.shield_outlined,
          label: AppStrings.dashboardReportFir,
          toneColor: AppColors.error,
          isDark: isDark,
          onTap: () => context.push(RouteNames.submitFir),
        ),
        _QuickActionTile(
          icon: Icons.swap_horiz_outlined,
          label: AppStrings.dashboardTransfer,
          toneColor: AppColors.primaryAccent,
          isDark: isDark,
          onTap: () => context.push(RouteNames.transferDevice),
        ),
        _QuickActionTile(
          icon: Icons.qr_code_scanner_outlined,
          label: AppStrings.dashboardVerifyImei,
          toneColor: AppColors.success,
          isDark: isDark,
          onTap: () => context.push(RouteNames.verifyImei),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.toneColor,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color toneColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurfaceElevated : AppColors.card;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Material(
      color: bg,
      borderRadius: AppRadius.allLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.allLg,
        child: Container(
          padding: const EdgeInsets.all(AppPadding.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.allLg,
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: AppSizes.iconMd(context),
                height: AppSizes.iconMd(context),
                decoration: BoxDecoration(
                  color: toneColor.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: AppRadius.allMd,
                ),
                child: Icon(icon, size: 20, color: toneColor),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: AppSizes.bodySmall(context),
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Device preview row — JSX DeviceCard variant 'a'
// ---------------------------------------------------------------------------

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({required this.device, required this.isDark});

  final DashboardDevice device;
  final bool isDark;

  StatusBadgeVariant get _variant {
    switch (device.status) {
      case 'approved':
        return StatusBadgeVariant.approved;
      case 'pending':
        return StatusBadgeVariant.pending;
      case 'rejected':
        return StatusBadgeVariant.rejected;
      case 'blocked':
        return StatusBadgeVariant.blocked;
      case 'unblocked':
        return StatusBadgeVariant.approved;
      default:
        return StatusBadgeVariant.active;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurfaceElevated : AppColors.card;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final iconBg = isDark ? AppColors.darkSurface : AppColors.primarySoft;

    return Container(
      padding: const EdgeInsets.all(AppPadding.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.allLg,
        border: Border.all(color: borderColor, width: 0.5),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 1,
                ),
              ],
      ),
      child: Row(
        children: [
          // Phone glyph — JSX PhoneGlyph
          Container(
            width: AppSizes.iconMd(context),
            height: AppSizes.iconMd(context),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.smartphone_outlined,
              size: 20,
              color: isDark ? AppColors.darkTextSecondary : AppColors.primary,
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.model,
                  style: TextStyle(
                    fontSize: AppSizes.bodyRegular(context),
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'IMEI ${device.imei}',
                  style: TextStyle(
                    fontSize: AppSizes.bodySmall(context),
                    fontFamily: 'monospace',
                    letterSpacing: 0.2,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${device.date} · ${device.operator}',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(11),
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hSm,
          StatusBadge(label: device.status, variant: _variant),
        ],
      ),
    );
  }
}
