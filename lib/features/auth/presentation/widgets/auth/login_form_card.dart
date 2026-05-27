import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/widgets/nokta_primary_button.dart';
import 'package:delivery_app/core/widgets/nokta_text_field.dart';
import 'package:delivery_app/features/auth/presentation/widgets/auth/auth_form_shell.dart';
import 'package:delivery_app/features/auth/presentation/widgets/auth/login_demo_chip.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.emailErrorText,
    required this.passwordErrorText,
    required this.loading,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onFillDemo,
    this.onCreateAccount,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final String? emailErrorText;
  final String? passwordErrorText;
  final bool loading;
  final VoidCallback? onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onFillDemo;
  final VoidCallback? onCreateAccount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AuthFormShell(
      showHeader: false,
      children: [
        LoginDemoChip(onFillDemo: onFillDemo),
        const SizedBox(height: NoktaSpacing.lg),
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
          autofillHints: const [AutofillHints.password],
          errorText: passwordErrorText,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (!loading) onSubmit?.call();
          },
        ),
        const SizedBox(height: NoktaSpacing.xs),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: onForgotPassword,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: NoktaSpacing.sm,
                vertical: NoktaSpacing.xs,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'forgot_password'.tr(),
              style: textTheme.labelLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: NoktaSpacing.lg),
        NoktaPrimaryButton(
          label: 'login'.tr(),
          icon: Icons.login_rounded,
          loading: loading,
          onPressed: onSubmit,
        ),
        if (onCreateAccount != null) ...[
          const SizedBox(height: NoktaSpacing.lg),
          Row(
            children: [
              Expanded(child: Divider(color: scheme.outlineVariant.withValues(alpha: 0.6))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: NoktaSpacing.md),
                child: Text(
                  'login_or'.tr(),
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.outline,
                  ),
                ),
              ),
              Expanded(child: Divider(color: scheme.outlineVariant.withValues(alpha: 0.6))),
            ],
          ),
          const SizedBox(height: NoktaSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: NoktaSpacing.buttonHeight,
            child: OutlinedButton(
              onPressed: onCreateAccount,
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
                'login_sign_up'.tr(),
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
