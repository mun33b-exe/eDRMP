import 'package:flutter/material.dart';

import '../../../../theme/colors.dart';

class AuthLogoBadge extends StatelessWidget {
  const AuthLogoBadge({super.key, this.showTagline = true});

  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 88,
          width: 88,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.verified_user_rounded,
            color: AppColors.secondary,
            size: 40,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'eDRMP',
          style: textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            'Secure Device Registration Portal',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
