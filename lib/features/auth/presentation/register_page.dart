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
import '../../../core/widgets/app_password_input.dart';
import '../../../theme/colors.dart';
import '../logic/auth_controller.dart';
import '../logic/auth_failure.dart';
import 'widgets/auth_brand_header.dart';
import 'widgets/auth_input_formatters.dart';
import 'widgets/auth_scaffold.dart';

/// Citizen registration screen.
///
/// Phase 1 only registers `UserRole.user` accounts; admin accounts (police /
/// PTA) come pre-provisioned via the mock repository's seed data — there is
/// no admin self-signup flow.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _termsAccepted = false;
  bool _termsTouched = false;
  bool _showInlineError = false;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _cnicCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _showInlineError = false;
      _termsTouched = true;
    });
    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk || !_termsAccepted) {
      return;
    }
    FocusScope.of(context).unfocus();
    await ref
        .read(authControllerProvider.notifier)
        .register(
          fullName: _fullNameCtrl.text.trim(),
          cnic: _cnicCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: '${AppStrings.authPhonePrefix}${_phoneCtrl.text.trim()}',
          password: _passwordCtrl.text,
        );
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

  String? _validateConfirmPassword(String? value) {
    return AppValidators.confirmPassword(value, _passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final asyncAuth = ref.watch(authControllerProvider);
    final isLoading = asyncAuth.isLoading;

    return AuthScaffold(
      appBar: const AppAppBar(title: AppStrings.titleRegister),
      bottom: Padding(
        padding: const EdgeInsets.only(top: AppPadding.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.authHasAccountPrompt,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: isLoading ? null : () => context.pop(),
              child: const Text(AppStrings.authHasAccountCta),
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
              title: AppStrings.authRegisterTitle,
              subtitle: AppStrings.authRegisterSubtitle,
            ),
            AppSpacing.vXxl,
            AppInput(
              label: AppStrings.authFullNameLabel,
              controller: _fullNameCtrl,
              hintText: AppStrings.authFullNameHint,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              prefixIcon: Icons.person_outline,
              validator: AppValidators.fullName,
            ),
            AppSpacing.vMd,
            AppInput(
              label: AppStrings.authCnicLabel,
              controller: _cnicCtrl,
              hintText: AppStrings.authCnicHint,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.badge_outlined,
              validator: AppValidators.cnic,
              inputFormatters: const [CnicInputFormatter()],
            ),
            AppSpacing.vMd,
            AppInput(
              label: AppStrings.authLoginEmailLabel,
              controller: _emailCtrl,
              hintText: AppStrings.authLoginEmailHint,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              prefixIcon: Icons.alternate_email,
              validator: AppValidators.email,
            ),
            AppSpacing.vMd,
            AppInput(
              label: AppStrings.authPhoneLabel,
              controller: _phoneCtrl,
              hintText: AppStrings.authPhoneHint,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumberNational],
              prefixIcon: Icons.phone_outlined,
              suffix: const Padding(
                padding: EdgeInsets.only(right: AppPadding.md),
                child: Text(AppStrings.authPhonePrefix),
              ),
              inputFormatters: const [PhonePkInputFormatter()],
              validator: (raw) => AppValidators.phone(
                raw == null ? null : '${AppStrings.authPhonePrefix}$raw',
              ),
            ),
            AppSpacing.vMd,
            AppPasswordInput(
              label: AppStrings.authPasswordLabel,
              controller: _passwordCtrl,
              hintText: AppStrings.authPasswordHint,
              helperText: AppStrings.authPasswordRules,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: AppValidators.password,
            ),
            AppSpacing.vMd,
            AppPasswordInput(
              label: AppStrings.authConfirmPasswordLabel,
              controller: _confirmPasswordCtrl,
              hintText: AppStrings.authConfirmPasswordHint,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              validator: _validateConfirmPassword,
            ),
            AppSpacing.vLg,
            _TermsCheckbox(
              value: _termsAccepted,
              showError: _termsTouched && !_termsAccepted,
              onChanged: isLoading
                  ? null
                  : (v) => setState(() {
                      _termsAccepted = v ?? false;
                      _termsTouched = true;
                    }),
            ),
            if (_showInlineError && asyncAuth.hasError) ...[
              AppSpacing.vMd,
              _InlineError(message: _errorMessage(asyncAuth.error!)),
            ],
            AppSpacing.vLg,
            AppButton(
              label: AppStrings.authRegisterCta,
              onPressed: isLoading ? null : _submit,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({
    required this.value,
    required this.onChanged,
    required this.showError,
  });

  final bool value;
  final bool showError;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: AppRadius.allMd,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppPadding.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            AppSpacing.hSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.authTermsAccept, style: textTheme.bodyMedium),
                  if (showError) ...[
                    AppSpacing.vXs,
                    Text(
                      const TermsNotAcceptedFailure().message,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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
        color: AppColors.errorSoft,
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
