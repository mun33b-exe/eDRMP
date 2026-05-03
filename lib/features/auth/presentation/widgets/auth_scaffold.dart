import 'package:flutter/material.dart';

import '../../../../core/constants/app_padding.dart';
import '../../../../core/utils/responsive.dart';

/// Common scaffold for all four auth screens.
///
/// Provides the consistent vertical padding, horizontal margin, scrollable
/// body, and SafeArea behaviour the design system mandates. Each screen just
/// supplies its own [child] column.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.child,
    this.bottom,
    this.appBar,
    super.key,
  });

  final Widget child;
  final Widget? bottom;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    final hPad = context.responsiveHorizontalPadding;
    final maxW = context.maxContentWidth;
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                hPad,
                AppPadding.xl,
                hPad,
                AppPadding.xxl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        constraints.maxHeight - AppPadding.xl - AppPadding.xxl,
                    maxWidth: maxW,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        child,
                        if (bottom != null) ...[const Spacer(), bottom!],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
