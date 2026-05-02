import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input.dart';
import '../../../core/widgets/app_password_input.dart';
import '../../../theme/colors.dart';
import '../logic/auth_controller.dart';
import '../logic/auth_failure.dart';
import 'widgets/auth_brand_header.dart';
import 'widgets/auth_scaffold.dart';

/// Sign-in screen.
///
/// Citizen / police / PTA all share this entry point — the role is read off
/// the matched mock account and the auth-gate redirect routes accordingly.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showInlineError = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
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
        .login(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
    if (!mounted) {
      return;
    }
    if (ref.read(authControllerProvider).hasError) {
      setState(() => _showInlineError = true);
    }
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
      bottom: Padding(
        padding: const EdgeInsets.only(top: AppPadding.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.authNoAccountPrompt,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => context.push(RouteNames.register),
              child: const Text(AppStrings.authNoAccountCta),
            ),
          ],
        ),
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthBrandHeader(
              title: AppStrings.authLoginTitle,
              subtitle: AppStrings.authLoginSubtitle,
            ),
            AppSpacing.vXxl,
            AppInput(
              label: AppStrings.authLoginEmailLabel,
              controller: _emailCtrl,
              hintText: AppStrings.authLoginEmailHint,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              prefixIcon: Icons.alternate_email,
              validator: AppValidators.email,
              inputFormatters: const [_NoWhitespaceFormatter()],
            ),
            AppSpacing.vMd,
            AppPasswordInput(
              label: AppStrings.authPasswordLabel,
              controller: _passwordCtrl,
              hintText: AppStrings.authPasswordHint,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: AppValidators.password,
              onFieldSubmitted: (_) => _submit(),
            ),
            AppSpacing.vSm,
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isLoading
                    ? null
                    : () => context.push(RouteNames.forgotPassword),
                child: const Text(AppStrings.authForgotPasswordLink),
              ),
            ),
            if (_showInlineError && asyncAuth.hasError) ...[
              AppSpacing.vSm,
              _InlineError(message: _errorMessage(asyncAuth.error!)),
            ],
            AppSpacing.vLg,
            AppButton(
              label: AppStrings.authLoginCta,
              onPressed: isLoading ? null : _submit,
              isLoading: isLoading,
            ),
            AppSpacing.vLg,
            const _DemoAccountsCard(),
          ],
        ),
      ),
    );
  }
}

class _NoWhitespaceFormatter extends TextInputFormatter {
  const _NoWhitespaceFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.text.contains(RegExp(r'\s'))) {
      return newValue;
    }
    final cleaned = newValue.text.replaceAll(RegExp(r'\s'), '');
    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
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

class _DemoAccountsCard extends ConsumerWidget {
  const _DemoAccountsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final brightness = Theme.of(context).brightness;
    final bg = brightness == Brightness.dark
        ? AppColors.darkCard
        : AppColors.infoLight;
    final fg = brightness == Brightness.dark
        ? AppColors.darkTextPrimary
        : AppColors.info;
    return Container(
      padding: const EdgeInsets.all(AppPadding.lg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.allLg,
        border: Border.all(color: fg.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science_outlined, size: 18, color: fg),
              AppSpacing.hSm,
              Text(
                AppStrings.authDemoAccountsTitle,
                style: textTheme.bodyLarge?.copyWith(color: fg),
              ),
            ],
          ),
          AppSpacing.vSm,
          Text(AppStrings.authDemoAccountsBody, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
