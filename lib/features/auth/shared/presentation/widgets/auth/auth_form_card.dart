import 'package:delivery_app/core/constants/app_constants.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:delivery_app/shared/widgets/inputs/app_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    super.key,
    required this.titleKey,
    required this.subtitleKey,
    required this.hintKey,
    required this.buttonKey,
    required this.emailController,
    required this.passwordController,
    required this.emailErrorText,
    required this.passwordErrorText,
    required this.loading,
    required this.onSubmit,
    this.footer,
  });

  final String titleKey;
  final String subtitleKey;
  final String hintKey;
  final String buttonKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? emailErrorText;
  final String? passwordErrorText;
  final bool loading;
  final VoidCallback? onSubmit;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSheet),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            titleKey.tr(),
            style: textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitleKey.tr(),
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: emailController,
            hintText: AppConstants.demoEmail,
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            errorText: emailErrorText,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: passwordController,
            hintText: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            errorText: passwordErrorText,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hintKey.tr(),
            style: textTheme.labelSmall?.copyWith(color: scheme.outline),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: buttonKey.tr(),
            loading: loading,
            onPressed: onSubmit,
          ),
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.md),
            footer!,
          ],
        ],
      ),
    );
  }
}
