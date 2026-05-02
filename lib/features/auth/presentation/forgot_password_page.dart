import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/widgets/app_app_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input.dart';
import '../../../theme/colors.dart';
import '../logic/auth_controller.dart';
import '../logic/auth_failure.dart';
import 'widgets/auth_brand_header.dart';
import 'widgets/auth_scaffold.dart';

/// Password reset entry point.
///
/// On submit, asks the mock repository to "send a reset link" — which is
/// just a 400 ms delay plus an existence check. On success the form is
/// replaced with a confirmation panel; on failure (unknown email) the error
/// surfaces inline.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _submitted = false;
  bool _showInlineError = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _showInlineError = false);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    await ref
        .read(authControllerProvider.notifier)
        .forgotPassword(_emailCtrl.text.trim());
    if (!mounted) {
      return;
    }
    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      setState(() => _showInlineError = true);
      return;
    }
    setState(() => _submitted = true);
  }

  String _errorMessage(Object error) {
    if (error is AuthFailure) {
      return error.message;
    }
    return AppStrings.somethingWentWrong;
  }

  @override
  Widget build(BuildContext context) {
    final asyncAuth = ref.watch(authControllerProvider);
    final isLoading = asyncAuth.isLoading;

    return AuthScaffold(
      appBar: const AppAppBar(title: AppStrings.titleForgotPassword),
      child: _submitted
          ? _SuccessPanel(email: _emailCtrl.text.trim())
          : Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthBrandHeader(
                    title: AppStrings.authForgotTitle,
                    subtitle: AppStrings.authForgotSubtitle,
                  ),
                  AppSpacing.vXxl,
                  AppInput(
                    label: AppStrings.authLoginEmailLabel,
                    controller: _emailCtrl,
                    hintText: AppStrings.authLoginEmailHint,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.email],
                    prefixIcon: Icons.alternate_email,
                    validator: AppValidators.email,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (_showInlineError && asyncAuth.hasError) ...[
                    AppSpacing.vMd,
                    _InlineError(message: _errorMessage(asyncAuth.error!)),
                  ],
                  AppSpacing.vLg,
                  AppButton(
                    label: AppStrings.authForgotCta,
                    onPressed: isLoading ? null : _submit,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
    );
  }
}

class _SuccessPanel extends StatelessWidget {
  const _SuccessPanel({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final brightness = Theme.of(context).brightness;
    final iconBg = brightness == Brightness.dark
        ? AppColors.secondaryDark
        : AppColors.successLight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthBrandHeader(
          title: AppStrings.authForgotSuccessTitle,
          subtitle: AppStrings.authForgotSuccessBody,
        ),
        AppSpacing.vXxl,
        Container(
          padding: const EdgeInsets.all(AppPadding.lg),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: AppRadius.allLg,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                color: AppColors.success,
              ),
              AppSpacing.hMd,
              Expanded(child: Text(email, style: textTheme.bodyLarge)),
            ],
          ),
        ),
        AppSpacing.vXl,
        AppButton(
          label: AppStrings.authForgotBackToLogin,
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.md,
        vertical: AppPadding.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: AppRadius.allMd,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppColors.error),
          AppSpacing.hSm,
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
