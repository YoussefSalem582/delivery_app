import 'package:delivery_app/shared/widgets/branding/app_brand_icon.dart';
import 'package:delivery_app/features/auth/onboarding/presentation/models/onboarding_slide_data.dart';
import 'package:delivery_app/features/auth/onboarding/presentation/widgets/onboarding_accent_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Hero visual for each onboarding slide (brand logo or feature icon).
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({
    super.key,
    required this.slide,
    this.showBrandLogo = false,
  });

  final OnboardingSlideData slide;
  final bool showBrandLogo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconColor = OnboardingAccentColors.icon(slide.accent, scheme);
    final containerColor =
        OnboardingAccentColors.container(slide.accent, scheme);

    return Semantics(
      label: slide.titleKey.tr(),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: containerColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.18),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: showBrandLogo
              ? Hero(
                  tag: 'app_logo',
                  child: AppBrandIcon(size: 52, filled: false),
                )
              : Icon(
                  slide.icon,
                  size: 80,
                  color: iconColor,
                ),
        ),
      ),
    );
  }
}
