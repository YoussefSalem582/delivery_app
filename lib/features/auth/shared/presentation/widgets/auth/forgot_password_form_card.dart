import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:delivery_app/shared/widgets/inputs/app_text_field.dart';
import 'package:delivery_app/features/auth/shared/presentation/widgets/auth/auth_form_shell.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ForgotPasswordFormCard extends StatelessWidget {
  const ForgotPasswordFormCard({
    super.key,
    required this.emailController,
    required this.emailErrorText,
    required this.loading,
    required this.onSubmit,
    this.emailSent = false,
    this.onBackToLogin,
  });

  final TextEditingController emailController;
  final String? emailErrorText;
  final bool loading;
  final VoidCallback? onSubmit;
  final bool emailSent;
  final VoidCallback? onBackToLogin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (emailSent) {
      return AuthFormShell(
        titleKey: 'forgot_password_sent_title'.tr(),
        subtitleKey: 'forgot_password_sent_subtitle'.tr(),
        children: [
          Icon(
            Icons.mark_email_read_outlined,
            size: 56,
            color: scheme.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'back_to_login'.tr(),
            onPressed: onBackToLogin,
          ),
        ],
      );
    }

    return AuthFormShell(
      titleKey: 'forgot_password_title'.tr(),
      subtitleKey: 'forgot_password_subtitle'.tr(),
      footer: onBackToLogin == null
          ? null
          : TextButton(
              onPressed: onBackToLogin,
              child: Text(
                'back_to_login'.tr(),
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
      children: [
        AppTextField(
          controller: emailController,
          labelText: 'email'.tr(),
          hintText: 'email_hint'.tr(),
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          errorText: emailErrorText,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'forgot_password_hint'.tr(),
          style: textTheme.labelSmall?.copyWith(color: scheme.outline),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'send_reset_link'.tr(),
          loading: loading,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}
