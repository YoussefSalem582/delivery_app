import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/branding/app_brand_icon.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Logo + title + subtitle above login/register credential forms.
class AuthCredentialHeader extends StatelessWidget {
  const AuthCredentialHeader({
    super.key,
    required this.titleKey,
    required this.subtitleKey,
  });

  final String titleKey;
  final String subtitleKey;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: AppBrandIcon(size: 64, filled: false),
        )
            .animate()
            .fadeIn(duration: 350.ms)
            .scale(
              begin: const Offset(0.92, 0.92),
              end: const Offset(1, 1),
              duration: 400.ms,
              curve: Curves.easeOutBack,
            ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          titleKey.tr(),
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 80.ms, duration: 350.ms)
            .slideY(begin: 0.08, end: 0, duration: 350.ms),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitleKey.tr(),
          style: textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 140.ms, duration: 350.ms)
            .slideY(begin: 0.08, end: 0, duration: 350.ms),
      ],
    );
  }
}
