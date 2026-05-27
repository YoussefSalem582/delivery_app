import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/widgets/nokta_primary_button.dart';
import 'package:delivery_app/core/widgets/nokta_text_field.dart';
import 'package:delivery_app/features/auth/presentation/widgets/auth/auth_form_shell.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class RegisterFormCard extends StatelessWidget {
  const RegisterFormCard({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.nameErrorText,
    required this.emailErrorText,
    required this.passwordErrorText,
    required this.confirmPasswordErrorText,
    required this.acceptedTerms,
    required this.onTermsChanged,
    required this.loading,
    required this.onSubmit,
    this.onSignIn,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String? nameErrorText;
  final String? emailErrorText;
  final String? passwordErrorText;
  final String? confirmPasswordErrorText;
  final bool acceptedTerms;
  final ValueChanged<bool> onTermsChanged;
  final bool loading;
  final VoidCallback? onSubmit;
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AuthFormShell(
      titleKey: 'register_title'.tr(),
      subtitleKey: 'register_subtitle'.tr(),
      footer: onSignIn == null
          ? null
          : TextButton(
              onPressed: onSignIn,
              child: Text(
                'register_has_account'.tr(),
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
      children: [
        NoktaTextField(
          controller: nameController,
          labelText: 'full_name'.tr(),
          hintText: 'full_name_hint'.tr(),
          prefixIcon: Icons.person_outline,
          errorText: nameErrorText,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: NoktaSpacing.md),
        NoktaTextField(
          controller: emailController,
          labelText: 'email'.tr(),
          hintText: 'email_hint'.tr(),
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
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: NoktaSpacing.md),
        NoktaTextField(
          controller: confirmPasswordController,
          labelText: 'confirm_password'.tr(),
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          errorText: confirmPasswordErrorText,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: NoktaSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: acceptedTerms,
                onChanged: (v) => onTermsChanged(v ?? false),
                activeColor: scheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: NoktaSpacing.sm),
            Expanded(
              child: Text(
                'register_terms'.tr(),
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: NoktaSpacing.sm),
        Text(
          'register_hint'.tr(),
          style: textTheme.labelSmall?.copyWith(color: scheme.outline),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: NoktaSpacing.lg),
        NoktaPrimaryButton(
          label: 'register_cta'.tr(),
          loading: loading,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}
