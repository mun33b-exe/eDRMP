import 'package:flutter/material.dart';

import '../constants/app_padding.dart';
import '../constants/app_spacing.dart';

/// Inline spinner sized to fit alongside body text.
class AppLoading extends StatelessWidget {
  const AppLoading({this.size = 22, this.strokeWidth = 2.4, super.key});

  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(strokeWidth: strokeWidth),
    );
  }
}

/// Full-screen loading state with optional caption.
class AppFullScreenLoading extends StatelessWidget {
  const AppFullScreenLoading({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLoading(size: 36),
            if (message != null) ...[
              AppSpacing.vMd,
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
