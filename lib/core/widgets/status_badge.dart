import 'package:flutter/material.dart';

import '../constants/app_padding.dart';
import '../constants/app_radius.dart';
import '../../theme/colors.dart';

/// Workflow status pill used to surface device, FIR, and block states.
enum StatusBadgeVariant {
  pending,
  approved,
  rejected,
  verified,
  blocked,
  active,
  info,
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.label, required this.variant, super.key});

  final String label;
  final StatusBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final palette = _palette();
    final textTheme = Theme.of(context).textTheme;
    final badge = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.sm + 2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: AppRadius.allPill,
        border: Border.all(color: palette.foreground.withValues(alpha: 0.12)),
      ),
      child: Text(
        _formatLabel(label),
        style: textTheme.labelSmall?.copyWith(
          color: palette.foreground,
          fontWeight: FontWeight.w600,
          fontSize: 10.5,
          letterSpacing: 0.3,
        ),
      ),
    );

    if (variant != StatusBadgeVariant.pending) {
      return badge;
    }

    return _PendingPulse(child: badge);
  }

  static String _formatLabel(String label) {
    if (label.isEmpty) return label;
    final lower = label.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  _BadgePalette _palette() {
    switch (variant) {
      case StatusBadgeVariant.pending:
        return const _BadgePalette(
          background: AppColors.warningSoft,
          foreground: AppColors.pending,
        );
      case StatusBadgeVariant.approved:
      case StatusBadgeVariant.verified:
      case StatusBadgeVariant.active:
        return const _BadgePalette(
          background: AppColors.successSoft,
          foreground: AppColors.approved,
        );
      case StatusBadgeVariant.rejected:
        return const _BadgePalette(
          background: AppColors.errorSoft,
          foreground: AppColors.rejected,
        );
      case StatusBadgeVariant.blocked:
        return const _BadgePalette(
          background: AppColors.blockedBg,
          foreground: AppColors.blocked,
        );
      case StatusBadgeVariant.info:
        return const _BadgePalette(
          background: AppColors.primarySoft,
          foreground: AppColors.primary,
        );
    }
  }
}

class _BadgePalette {
  const _BadgePalette({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}

class _PendingPulse extends StatefulWidget {
  const _PendingPulse({required this.child});

  final Widget child;

  @override
  State<_PendingPulse> createState() => _PendingPulseState();
}

class _PendingPulseState extends State<_PendingPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}
