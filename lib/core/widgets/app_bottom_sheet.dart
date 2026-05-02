import 'package:flutter/material.dart';

import '../constants/app_padding.dart';
import '../constants/app_spacing.dart';

/// Helpers for presenting modal bottom sheets that respect the app theme.
class AppBottomSheet {
  AppBottomSheet._();

  /// Present [child] inside a themed modal bottom sheet.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: true,
      builder: (ctx) => _SheetBody(title: title, child: child),
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: AppPadding.xl,
        right: AppPadding.xl,
        top: AppPadding.lg,
        bottom: AppPadding.xl + mediaQuery.viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(title!, style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.vMd,
          ],
          child,
        ],
      ),
    );
  }
}
