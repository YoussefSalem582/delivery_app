import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/widgets/nokta_primary_button.dart';
import 'package:delivery_app/core/widgets/nokta_text_field.dart';
import 'package:delivery_app/features/auth/presentation/widgets/auth/auth_form_shell.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.emailErrorText,
    required this.passwordErrorText,
    required this.loading,
    required this.onSubmit,
    required this.onForgotPassword,
    this.onCreateAccount,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? emailErrorText;
  final String? passwordErrorText;
  final bool loading;
  final VoidCallback? onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback? onCreateAccount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AuthFormShell(
      titleKey: 'login_title'.tr(),
      subtitleKey: 'login_subtitle'.tr(),
      footer: onCreateAccount == null
          ? null
          : TextButton(
              onPressed: onCreateAccount,
              child: Text(
                'login_create_account'.tr(),
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
      children: [
        NoktaTextField(
          controller: emailController,
          labelText: 'email'.tr(),
          hintText: 'demo@delivery.app',
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          errorText: emailErrorText,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: NoktaSpacing.md),
        NoktaTextField(
          controller: passwordController,
          labelText: 'password'.tr(),
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          errorText: passwordErrorText,
          textInputAction: TextInputAction.done,
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: onForgotPassword,
            child: Text(
              'forgot_password'.tr(),
              style: textTheme.labelLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: NoktaSpacing.sm),
        Text(
          'login_hint'.tr(),
          style: textTheme.labelSmall?.copyWith(color: scheme.outline),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: NoktaSpacing.lg),
        NoktaPrimaryButton(
          label: 'login'.tr(),
          loading: loading,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}
