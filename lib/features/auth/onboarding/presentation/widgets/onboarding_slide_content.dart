import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/features/auth/onboarding/presentation/models/onboarding_slide_data.dart';
import 'package:delivery_app/features/auth/onboarding/presentation/widgets/onboarding_illustration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Single onboarding page: illustration, title, and body copy.
class OnboardingSlideContent extends StatelessWidget {
  const OnboardingSlideContent({
    super.key,
    required this.slide,
    required this.pageIndex,
    this.showBrandLogo = false,
  });

  final OnboardingSlideData slide;
  final int pageIndex;
  final bool showBrandLogo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OnboardingIllustration(
            slide: slide,
            showBrandLogo: showBrandLogo,
          )
              .animate(key: ValueKey(pageIndex))
              .fadeIn(duration: 350.ms, curve: Curves.easeOut)
              .scale(
                begin: const Offset(0.92, 0.92),
                end: const Offset(1, 1),
                duration: 450.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            slide.titleKey.tr(),
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
            textAlign: TextAlign.center,
          )
              .animate(key: ValueKey('title_$pageIndex'))
              .fadeIn(delay: 80.ms, duration: 300.ms)
              .slideY(begin: 0.08, end: 0, duration: 350.ms),
          const SizedBox(height: AppSpacing.md),
          Text(
            slide.bodyKey.tr(),
            style: textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          )
              .animate(key: ValueKey('body_$pageIndex'))
              .fadeIn(delay: 140.ms, duration: 300.ms)
              .slideY(begin: 0.06, end: 0, duration: 350.ms),
        ],
      ),
    );
  }
}
