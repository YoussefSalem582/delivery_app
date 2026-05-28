import 'package:delivery_app/features/auth/onboarding/presentation/models/onboarding_slide_data.dart';
import 'package:delivery_app/features/auth/onboarding/presentation/widgets/onboarding_accent_colors.dart';
import 'package:delivery_app/shared/widgets/branding/app_brand_hero.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Illustration circle — [AppBrandHero] on slide 1, then empty placeholder.
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({
    super.key,
    required this.slide,
    this.showBrandCircle = false,
    this.showBrandHero = false,
    this.centerAnchorKey,
  });

  final OnboardingSlideData slide;
  final bool showBrandCircle;
  final bool showBrandHero;
  final GlobalKey? centerAnchorKey;

  static const brandLogoSize = 52.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconColor = OnboardingAccentColors.icon(slide.accent, scheme);
    final containerColor =
        OnboardingAccentColors.container(slide.accent, scheme);

    return Semantics(
      label: slide.titleKey.tr(),
      child: Container(
        key: centerAnchorKey,
        width: 200,
        height: 200,
        clipBehavior: Clip.none,
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
          child: showBrandHero
              ? const AppBrandHero(
                  size: brandLogoSize,
                  filled: false,
                )
              : showBrandCircle
                  ? const SizedBox(height: brandLogoSize)
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