import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/branding/app_brand_icon.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AuthChoiceHeader extends StatelessWidget {
  const AuthChoiceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: AppBrandIcon(size: 72, filled: false),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1, 1),
              duration: 450.ms,
              curve: Curves.easeOutBack,
            ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'auth_choice_title'.tr(),
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'auth_choice_subtitle'.tr(),
          style: textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
