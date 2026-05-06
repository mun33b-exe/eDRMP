import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/utils/app_sizes.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../theme/colors.dart';
import '../../auth/logic/auth_controller.dart';
import '../logic/pta_stats_provider.dart';

class PtaDashboardPage extends ConsumerWidget {
  const PtaDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final liveStats = ref.watch(ptaStatsProvider).valueOrNull;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'PTA · NATIONAL OVERVIEW',
              style: TextStyle(
                fontSize: AppSizes.bodySmall(context),
                fontWeight: FontWeight.w500,
                color: AppColors.success,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'Analytics',
              style: TextStyle(
                fontSize: AppSizes.h3(context),
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_outlined),
            tooltip: AppStrings.verifyImeiTitle,
            onPressed: () => context.push(RouteNames.verifyImei),
          ),
          IconButton(
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
            icon: Icon(
              Icons.logout,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ptaStatsProvider);
          await ref.read(ptaStatsProvider.future);
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveHorizontalPadding,
            vertical: AppPadding.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Grid Stats
              GridView.count(
                crossAxisCount: context.isMobile ? 2 : 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppPadding.sm,
                mainAxisSpacing: AppPadding.sm,
                childAspectRatio: context.responsive(mobile: 1.4, tablet: 1.8, desktop: 2.0),
                children: [
                  _buildStatTile(
                    context,
                    'Total devices',
                    liveStats?.totalDevices.toString() ?? '—',
                    ' ',
                    Icons.devices,
                    AppColors.success,
                    isDark,
                    onTap: () => context.push(RouteNames.deviceApprovals),
                  ),
                  _buildStatTile(
                    context,
                    'Approvals',
                    liveStats?.approvals.toString() ?? '—',
                    ' ',
                    Icons.check,
                    AppColors.success,
                    isDark,
                  ),
                  _buildStatTile(
                    context,
                    'Active FIRs',
                    liveStats?.activeFirs.toString() ?? '—',
                    ' ',
                    Icons.shield,
                    AppColors.error,
                    isDark,
                    onTap: () => context.push(RouteNames.blockRequests),
                  ),
                  _buildStatTile(
                    context,
                    'Blocked',
                    liveStats?.blocked.toString() ?? '—',
                    ' ',
                    Icons.block,
                    AppColors.warning,
                    isDark,
                  ),
                ],
              ),
              AppSpacing.vLg,

              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context: context,
                      title: 'Device Approvals',
                      icon: Icons.checklist,
                      color: AppColors.success,
                      isDark: isDark,
                      onTap: () => context.push(RouteNames.deviceApprovals),
                    ),
                  ),
                  AppSpacing.hMd,
                  Expanded(
                    child: _buildActionCard(
                      context: context,
                      title: 'Block Requests',
                      icon: Icons.gavel,
                      color: AppColors.error,
                      isDark: isDark,
                      onTap: () => context.push(RouteNames.blockRequests),
                    ),
                  ),
                ],
              ),
              AppSpacing.vLg,

              // Registrations vs Blocks Chart
              _buildCard(
                context: context,
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Registrations vs. Blocks',
                                style: TextStyle(
                                  fontSize: AppSizes.bodyRegular(context),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '30-day trend',
                                style: TextStyle(
                                  fontSize: AppSizes.bodySmall(context),
                                  color: isDark
                                      ? AppColors.darkTextTertiary
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _buildLegendDot(
                              context,
                              'Registered',
                              AppColors.primaryAccent,
                              isDark,
                            ),
                            AppSpacing.hSm,
                            _buildLegendDot(
                              context,
                              'Blocked',
                              AppColors.error,
                              isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                    AppSpacing.vLg,
                    SizedBox(
                      height: 120,
                      child: _StaticChartPlaceholder(
                        isDark: isDark,
                        registrations: liveStats?.dailyRegistrations,
                        blocks: liveStats?.dailyBlocks,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.vLg,

              // Top Devices
              _buildCard(
                context: context,
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top devices by registration',
                      style: TextStyle(
                        fontSize: AppSizes.bodyRegular(context),
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    AppSpacing.vLg,
                    _buildDeviceRow(
                      context,
                      'Apple iPhone 15 / Pro',
                      '412K',
                      0.92,
                      AppColors.primaryAccent,
                      isDark,
                    ),
                    _buildDeviceRow(
                      context,
                      'Samsung Galaxy S24',
                      '318K',
                      0.71,
                      AppColors.primaryAccent,
                      isDark,
                    ),
                    _buildDeviceRow(
                      context,
                      'Xiaomi Redmi Note 13',
                      '267K',
                      0.59,
                      AppColors.error,
                      isDark,
                    ),
                    _buildDeviceRow(
                      context,
                      'Tecno Camon 30',
                      '198K',
                      0.44,
                      AppColors.success,
                      isDark,
                    ),
                    _buildDeviceRow(
                      context,
                      'Other',
                      '1.21M',
                      0.32,
                      isDark ? AppColors.darkBorder : AppColors.border,
                      isDark,
                    ),
                  ],
                ),
              ),
              AppSpacing.vLg,

              // Risk Map
              _buildCard(
                context: context,
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risk zones',
                      style: TextStyle(
                        fontSize: AppSizes.bodyRegular(context),
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    AppSpacing.vMd,
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push(RouteNames.theftMap),
                        borderRadius: BorderRadius.circular(8),
                        child: Ink(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Tap to view hotspot map',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.vMd,
                    Row(
                      children: [
                        _buildRiskLegend(
                          context,
                          'Low',
                          AppColors.success,
                          isDark,
                        ),
                        AppSpacing.hMd,
                        _buildRiskLegend(
                          context,
                          'Medium',
                          AppColors.warning,
                          isDark,
                        ),
                        AppSpacing.hMd,
                        _buildRiskLegend(
                          context,
                          'High',
                          AppColors.error,
                          isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context,
    String label,
    String value,
    String delta,
    IconData icon,
    Color color,
    bool isDark, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.responsive(mobile: AppPadding.sm + 4, tablet: AppPadding.lg)),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceElevated : AppColors.card,
          borderRadius: AppRadius.allMd,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 0.5,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(icon, size: 14, color: color),
                ),
                Text(
                  delta,
                  style: TextStyle(
                    fontSize: AppSizes.bodySmall(context),
                    fontWeight: FontWeight.w600,
                    color: delta.startsWith('+')
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: AppSizes.h3(context),
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppSizes.bodySmall(context),
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.allMd,
      child: Container(
        padding: EdgeInsets.all(context.responsive(mobile: AppPadding.md, tablet: AppPadding.lg)),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceElevated : AppColors.card,
          borderRadius: AppRadius.allMd,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            AppSpacing.hMd,
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: AppSizes.bodyRegular(context),
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required BuildContext context, required Widget child, required bool isDark}) {
    return Container(
      padding: EdgeInsets.all(context.responsive(mobile: AppPadding.lg, tablet: AppPadding.xl)),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.card,
        borderRadius: AppRadius.allMd,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 0.5,
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
      child: child,
    );
  }

  Widget _buildLegendDot(BuildContext context, String label, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.bodySmall(context),
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskLegend(BuildContext context, String label, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.bodySmall(context),
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceRow(
    BuildContext context,
    String label,
    String value,
    double percent,
    Color color,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: AppSizes.bodySmall(context),
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: AppSizes.bodySmall(context),
                  fontFamily: 'monospace',
                  color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.inputFill,
              borderRadius: BorderRadius.circular(99),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: percent,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticChartPlaceholder extends StatelessWidget {
  const _StaticChartPlaceholder({
    required this.isDark,
    this.registrations,
    this.blocks,
  });
  final bool isDark;
  final List<int>? registrations;
  final List<int>? blocks;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ChartPainter(
        isDark: isDark,
        registrations: registrations ?? List<int>.filled(30, 0),
        blocks: blocks ?? List<int>.filled(30, 0),
      ),
      size: Size.infinite,
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.isDark,
    required this.registrations,
    required this.blocks,
  });
  final bool isDark;
  final List<int> registrations;
  final List<int> blocks;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final gridPaint = Paint()
      ..color = isDark ? AppColors.darkBorder : AppColors.border
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = h * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Build cumulative totals so the line shows running sum over 30 days
    final cumRegs = <double>[];
    final cumBlks = <double>[];
    var sumRegs = 0;
    var sumBlks = 0;
    for (var i = 0; i < registrations.length; i++) {
      sumRegs += registrations[i];
      sumBlks += blocks[i];
      cumRegs.add(sumRegs.toDouble());
      cumBlks.add(sumBlks.toDouble());
    }

    // Determine max value for scaling (at least 1 to avoid division by zero)
    final maxVal = <double>[
      ...cumRegs,
      ...cumBlks,
      1,
    ].reduce((a, b) => a > b ? a : b) * 1.1;

    if (cumRegs.isEmpty) return;

    final step = w / (cumRegs.length - 1).clamp(1, cumRegs.length);

    final path1 = Path();
    for (var i = 0; i < cumRegs.length; i++) {
      final x = i * step;
      final y = h - (cumRegs[i] / maxVal) * h;
      if (i == 0) {
        path1.moveTo(x, y);
      } else {
        path1.lineTo(x, y);
      }
    }

    final path2 = Path();
    for (var i = 0; i < cumBlks.length; i++) {
      final x = i * step;
      final y = h - (cumBlks[i] / maxVal) * h;
      if (i == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primaryAccent.withValues(alpha: 0.3),
          AppColors.primaryAccent.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final fillPath = Path.from(path1)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(fillPath, gradientPaint);

    final line1Paint = Paint()
      ..color = AppColors.primaryAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path1, line1Paint);

    final dashPaint = Paint()
      ..color = AppColors.error.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path2, dashPaint);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) =>
      oldDelegate.registrations != registrations ||
      oldDelegate.blocks != blocks ||
      oldDelegate.isDark != isDark;
}
