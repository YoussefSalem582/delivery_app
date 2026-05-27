import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/widgets/nokta_primary_button.dart';
import 'package:delivery_app/core/widgets/nokta_text_field.dart';
import 'package:delivery_app/features/auth/presentation/widgets/auth/auth_form_shell.dart';
import 'package:delivery_app/features/auth/presentation/widgets/auth/register_demo_chip.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RegisterFormCard extends StatelessWidget {
  const RegisterFormCard({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.nameFocusNode,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.confirmFocusNode,
    required this.nameErrorText,
    required this.emailErrorText,
    required this.passwordErrorText,
    required this.confirmPasswordErrorText,
    required this.acceptedTerms,
    required this.onTermsChanged,
    required this.loading,
    required this.onSubmit,
    required this.onFillDemo,
    this.onSignIn,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode nameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode confirmFocusNode;
  final String? nameErrorText;
  final String? emailErrorText;
  final String? passwordErrorText;
  final String? confirmPasswordErrorText;
  final bool acceptedTerms;
  final ValueChanged<bool> onTermsChanged;
  final bool loading;
  final VoidCallback? onSubmit;
  final VoidCallback onFillDemo;
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AuthFormShell(
      showHeader: false,
      children: [
        RegisterDemoChip(onFillDemo: onFillDemo),
        const SizedBox(height: NoktaSpacing.lg),
        NoktaTextField(
          controller: nameController,
          focusNode: nameFocusNode,
          labelText: 'full_name'.tr(),
          hintText: 'full_name_hint'.tr(),
          prefixIcon: Icons.person_outline_rounded,
          autofillHints: const [AutofillHints.name],
          errorText: nameErrorText,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => emailFocusNode.requestFocus(),
        ),
        const SizedBox(height: NoktaSpacing.md),
        NoktaTextField(
          controller: emailController,
          focusNode: emailFocusNode,
          labelText: 'email'.tr(),
          hintText: 'email_hint'.tr(),
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          errorText: emailErrorText,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => passwordFocusNode.requestFocus(),
        ),
        const SizedBox(height: NoktaSpacing.md),
        NoktaTextField(
          controller: passwordController,
          focusNode: passwordFocusNode,
          labelText: 'password'.tr(),
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: true,
          autofillHints: const [AutofillHints.newPassword],
          errorText: passwordErrorText,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => confirmFocusNode.requestFocus(),
        ),
        const SizedBox(height: NoktaSpacing.md),
        NoktaTextField(
          controller: confirmPasswordController,
          focusNode: confirmFocusNode,
          labelText: 'confirm_password'.tr(),
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: true,
          autofillHints: const [AutofillHints.newPassword],
          errorText: confirmPasswordErrorText,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (!loading) onSubmit?.call();
          },
        ),
        const SizedBox(height: NoktaSpacing.md),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onTermsChanged(!acceptedTerms),
            borderRadius: BorderRadius.circular(NoktaSpacing.radiusSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: NoktaSpacing.xs),
              child: Row(
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
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
            ),
          ),
        ),
        const SizedBox(height: NoktaSpacing.lg),
        NoktaPrimaryButton(
          label: 'register_cta'.tr(),
          icon: Icons.person_add_rounded,
          loading: loading,
          onPressed: onSubmit,
        ),
        if (onSignIn != null) ...[
          const SizedBox(height: NoktaSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: scheme.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: NoktaSpacing.md),
                child: Text(
                  'login_or'.tr(),
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.outline,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: scheme.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: NoktaSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: NoktaSpacing.buttonHeight,
            child: OutlinedButton(
              onPressed: onSignIn,
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.primary,
                side: BorderSide(
                  color: scheme.primary.withValues(alpha: 0.45),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
                ),
              ),
              child: Text(
                'register_sign_in'.tr(),
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.06, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }
}
