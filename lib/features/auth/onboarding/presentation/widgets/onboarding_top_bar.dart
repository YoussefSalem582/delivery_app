import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/branding/app_brand_icon.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Skip row — reserves space for the animated logo anchor on the left.
class OnboardingTopBar extends StatelessWidget {
  const OnboardingTopBar({
    super.key,
    required this.onSkip,
    required this.topAnchorKey,
  });

  final VoidCallback onSkip;
  final GlobalKey topAnchorKey;

  static const wordmarkHeight = 32.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            key: topAnchorKey,
            height: wordmarkHeight,
            width: wordmarkHeight * AppBrandIcon.wordmarkAspectRatio,
          ),
          const Spacer(),
          _OnboardingSkipButton(onPressed: onSkip),
        ],
      ),
    );
  }
}

class _OnboardingSkipButton extends StatelessWidget {
  const _OnboardingSkipButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final skipColor = scheme.brightness == Brightness.light
        ? AppColors.onSurface
        : scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      label: 'onboarding_skip'.tr(),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: skipColor,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(48, 44),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'onboarding_skip'.tr(),
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: skipColor,
          ),
        ),
      ),
    );
  }
}
