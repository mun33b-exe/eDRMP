import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routes/route_names.dart';
import '../../../theme/colors.dart';

class PtaDashboardPage extends StatelessWidget {
  const PtaDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'PTA · NATIONAL OVERVIEW',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.ptaPrimary,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
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
          Container(
            margin: const EdgeInsets.only(right: AppPadding.lg),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.inputFill,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
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
                AppSpacing.hSm,
                Text(
                  'Last 30 days',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                AppSpacing.hXs,
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 14,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPadding.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Grid Stats
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: [
                _buildStatTile(
                  'Total devices',
                  '2.41M',
                  '+4.2%',
                  Icons.devices,
                  AppColors.ptaPrimary,
                  isDark,
                ),
                _buildStatTile(
                  'Approvals',
                  '184K',
                  '+8.1%',
                  Icons.check,
                  AppColors.success,
                  isDark,
                ),
                _buildStatTile(
                  'Active FIRs',
                  '3,294',
                  '-2.3%',
                  Icons.shield,
                  AppColors.error,
                  isDark,
                ),
                _buildStatTile(
                  'Blocked',
                  '11,820',
                  '+0.4%',
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
                    title: 'Device Approvals',
                    icon: Icons.checklist,
                    color: AppColors.ptaPrimary,
                    isDark: isDark,
                    onTap: () => context.push(RouteNames.deviceApprovals),
                  ),
                ),
                AppSpacing.hMd,
                Expanded(
                  child: _buildActionCard(
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
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registrations vs. Blocks',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '30-day trend',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildLegendDot(
                            'Registered',
                            AppColors.analyticsViolet,
                            isDark,
                          ),
                          AppSpacing.hSm,
                          _buildLegendDot(
                            'Blocked',
                            AppColors.analyticsRed,
                            isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                  AppSpacing.vLg,
                  SizedBox(
                    height: 120,
                    child: _StaticChartPlaceholder(isDark: isDark),
                  ),
                ],
              ),
            ),
            AppSpacing.vLg,

            // Top Devices
            _buildCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top devices by registration',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.vLg,
                  _buildDeviceRow(
                    'Apple iPhone 15 / Pro',
                    '412K',
                    0.92,
                    AppColors.analyticsViolet,
                    isDark,
                  ),
                  _buildDeviceRow(
                    'Samsung Galaxy S24',
                    '318K',
                    0.71,
                    AppColors.analyticsViolet,
                    isDark,
                  ),
                  _buildDeviceRow(
                    'Xiaomi Redmi Note 13',
                    '267K',
                    0.59,
                    AppColors.error,
                    isDark,
                  ),
                  _buildDeviceRow(
                    'Tecno Camon 30',
                    '198K',
                    0.44,
                    AppColors.analyticsGreen,
                    isDark,
                  ),
                  _buildDeviceRow(
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
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Risk zones — Karachi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
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
                              ? AppColors.darkInput
                              : AppColors.scaffoldBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Tap to view hotspot map',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.vMd,
                  Row(
                    children: [
                      _buildRiskLegend('Low', AppColors.analyticsGreen, isDark),
                      AppSpacing.hMd,
                      _buildRiskLegend(
                        'Medium',
                        AppColors.analyticsOrange,
                        isDark,
                      ),
                      AppSpacing.hMd,
                      _buildRiskLegend('High', AppColors.analyticsRed, isDark),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(
    String label,
    String value,
    String delta,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: AppRadius.allMd,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: isDark
            ? null
            : [
                const BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 4,
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
              Icon(icon, size: 16, color: color),
              Text(
                delta,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
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
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
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
        padding: const EdgeInsets.all(AppPadding.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.card,
          borderRadius: AppRadius.allMd,
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            AppSpacing.hSm,
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: AppRadius.allMd,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: isDark
            ? null
            : [
                const BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }

  Widget _buildLegendDot(String label, Color color, bool isDark) {
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
            fontSize: 11,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskLegend(String label, Color color, bool isDark) {
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
            fontSize: 11,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceRow(
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
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkInput : AppColors.inputFill,
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
  const _StaticChartPlaceholder({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Custom paint a simple static chart
    return CustomPaint(
      painter: _ChartPainter(isDark: isDark),
      size: Size.infinite,
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({required this.isDark});
  final bool isDark;

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

    final data1 = [40, 55, 48, 70, 65, 82, 75, 92, 88, 98, 95, 110];
    final data2 = [22, 18, 25, 20, 28, 24, 30, 26, 22, 28, 24, 30];
    const maxVal = 120.0;

    final step = w / (data1.length - 1);

    final path1 = Path();
    for (var i = 0; i < data1.length; i++) {
      final x = i * step;
      final y = h - (data1[i] / maxVal) * h;
      if (i == 0) {
        path1.moveTo(x, y);
      } else {
        path1.lineTo(x, y);
      }
    }

    final path2 = Path();
    for (var i = 0; i < data2.length; i++) {
      final x = i * step;
      final y = h - (data2[i] / maxVal) * h;
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
          AppColors.analyticsViolet.withValues(alpha: 0.3),
          AppColors.analyticsViolet.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final fillPath = Path.from(path1)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(fillPath, gradientPaint);

    final line1Paint = Paint()
      ..color = AppColors.analyticsViolet
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path1, line1Paint);

    // Simple dashed line implementation
    final dashPaint = Paint()
      ..color = AppColors.analyticsRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    // Simplistic dash (not a real path dash, but sufficient for a placeholder)
    canvas.drawPath(path2, dashPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
