import 'package:flutter/material.dart';

import '../../../../theme/colors.dart';

/// Shield illustration matching `Illustration kind="shield"` in
/// `design/handoff/project/components.jsx` (~lines 528–539).
///
/// Concentric shields (navy outer, navyDark inner), an emerald checkmark, a
/// gold accent dot, all on a soft circular wash. Phase 8 may swap this for a
/// rasterised asset; the geometry stays the same.
class ShieldIllustration extends StatelessWidget {
  const ShieldIllustration({this.size = 180, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final wash = brightness == Brightness.dark
        ? AppColors.darkCard
        : AppColors.illustrationBg;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ShieldPainter(wash: wash)),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  _ShieldPainter({required this.wash});

  final Color wash;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 200.0;
    Offset p(double x, double y) => Offset(x * scale, y * scale);

    canvas.drawCircle(p(100, 100), 90 * scale, Paint()..color = wash);

    final outerShield = Path()
      ..moveTo(100 * scale, 40 * scale)
      ..lineTo(150 * scale, 60 * scale)
      ..lineTo(150 * scale, 110 * scale)
      ..cubicTo(
        150 * scale,
        140 * scale,
        130 * scale,
        160 * scale,
        100 * scale,
        170 * scale,
      )
      ..cubicTo(
        70 * scale,
        160 * scale,
        50 * scale,
        140 * scale,
        50 * scale,
        110 * scale,
      )
      ..lineTo(50 * scale, 60 * scale)
      ..close();
    canvas.drawPath(outerShield, Paint()..color = AppColors.primary);

    final innerShield = Path()
      ..moveTo(100 * scale, 50 * scale)
      ..lineTo(142 * scale, 67 * scale)
      ..lineTo(142 * scale, 108 * scale)
      ..cubicTo(
        142 * scale,
        132 * scale,
        126 * scale,
        148 * scale,
        100 * scale,
        158 * scale,
      )
      ..cubicTo(
        74 * scale,
        148 * scale,
        58 * scale,
        132 * scale,
        58 * scale,
        108 * scale,
      )
      ..lineTo(58 * scale, 67 * scale)
      ..close();
    canvas.drawPath(innerShield, Paint()..color = AppColors.primaryDark);

    final tick = Path()
      ..moveTo(80 * scale, 100 * scale)
      ..lineTo(95 * scale, 115 * scale)
      ..lineTo(122 * scale, 88 * scale);
    canvas.drawPath(
      tick,
      Paint()
        ..color = AppColors.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6 * scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawCircle(p(100, 38), 6 * scale, Paint()..color = AppColors.accent);
  }

  @override
  bool shouldRepaint(covariant _ShieldPainter oldDelegate) =>
      oldDelegate.wash != wash;
}
