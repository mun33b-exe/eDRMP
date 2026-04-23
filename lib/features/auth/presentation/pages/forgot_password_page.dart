import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/app_validators.dart';
import '../../logic/auth_controller.dart';
import '../widgets/auth_page_scaffold.dart';
import '../widgets/auth_submit_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  AuthController get _authController => AuthController.instance;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await _authController.forgotPassword(
      email: _emailController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Password reset link sent. Please check your inbox.',
            ),
          ),
        );
      return;
    }

    final message = _authController.state.errorMessage ??
        'Unable to send reset link. Please try again.';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authController,
      builder: (context, _) {
        final isLoading = _authController.state.isLoading;

        return AuthPageScaffold(
          leading: IconButton(
            onPressed: isLoading ? null : () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_rounded),
          ),
          title: 'Reset your password',
          subtitle:
              'Enter your account email and we will send a secure reset link.',
          footer: TextButton(
            onPressed: isLoading ? null : () => context.go(AppRoutes.login),
            child: const Text('Back to login'),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.mark_email_read_outlined),
                  ),
                  validator: AppValidators.email,
                ),
                AppSpacing.vL,
                AuthSubmitButton(
                  label: 'Send Reset Link',
                  isLoading: isLoading,
                  onPressed: _handleSendResetLink,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
