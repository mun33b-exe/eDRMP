import 'package:flutter/material.dart';

import '../../../../theme/colors.dart';

/// `Logo` from `design/handoff/project/components.jsx` (~lines 57–71).
///
/// A rounded-square mark containing the eDRMP "R" glyph plus a small gold
/// accent dot, followed by the "eDRMP" wordmark. The rendered SVG is
/// re-implemented as a Flutter `CustomPaint` so the mark survives cold
/// boots without an asset bundle.
class OnboardingLogo extends StatelessWidget {
  const OnboardingLogo({this.size = 26, this.color, super.key});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final brand = color ?? AppColors.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _LogoMarkPainter(color: brand)),
        ),
        SizedBox(width: size * 0.32),
        Text(
          'eDRMP',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: size * 0.55,
            color: brand,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _LogoMarkPainter extends CustomPainter {
  _LogoMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 32.0;

    final markRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2 * scale, 2 * scale, 28 * scale, 28 * scale),
      Radius.circular(7 * scale),
    );
    canvas.drawRRect(markRect, Paint()..color = color);

    // Stylised "R" glyph.
    final r = Path()
      ..moveTo(9 * scale, 9 * scale)
      ..lineTo(19 * scale, 9 * scale)
      ..cubicTo(
        21.76 * scale,
        9 * scale,
        24 * scale,
        11.24 * scale,
        24 * scale,
        14 * scale,
      )
      ..cubicTo(
        24 * scale,
        16.76 * scale,
        21.76 * scale,
        19 * scale,
        19 * scale,
        19 * scale,
      )
      ..lineTo(15 * scale, 19 * scale)
      ..lineTo(19 * scale, 24 * scale)
      ..lineTo(15 * scale, 24 * scale)
      ..lineTo(11 * scale, 19 * scale)
      ..lineTo(13 * scale, 19 * scale)
      ..lineTo(13 * scale, 24 * scale)
      ..lineTo(9 * scale, 24 * scale)
      ..close()
      ..moveTo(13 * scale, 12 * scale)
      ..lineTo(13 * scale, 16 * scale)
      ..lineTo(19 * scale, 16 * scale)
      ..cubicTo(
        20.1 * scale,
        16 * scale,
        21 * scale,
        15.1 * scale,
        21 * scale,
        14 * scale,
      )
      ..cubicTo(
        21 * scale,
        12.9 * scale,
        20.1 * scale,
        12 * scale,
        19 * scale,
        12 * scale,
      )
      ..close();
    canvas.drawPath(
      r,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );

    canvas.drawCircle(
      Offset(24 * scale, 9 * scale),
      2.5 * scale,
      Paint()..color = AppColors.warning,
    );
  }

  @override
  bool shouldRepaint(covariant _LogoMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
