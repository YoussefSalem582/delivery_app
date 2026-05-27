import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/features/auth/onboarding/presentation/models/onboarding_slide_data.dart';
import 'package:flutter/material.dart';

class OnboardingAccentColors {
  OnboardingAccentColors._();

  static Color container(OnboardingAccent accent, ColorScheme scheme) {
    return switch (accent) {
      OnboardingAccent.primary => scheme.primary.withValues(alpha: 0.12),
      OnboardingAccent.secondary => AppColors.secondary.withValues(alpha: 0.14),
      OnboardingAccent.tertiary => AppColors.tertiary.withValues(alpha: 0.12),
      OnboardingAccent.primaryContainer =>
        AppColors.primaryContainer.withValues(alpha: 0.14),
    };
  }

  static Color icon(OnboardingAccent accent, ColorScheme scheme) {
    return switch (accent) {
      OnboardingAccent.primary => scheme.primary,
      OnboardingAccent.secondary => AppColors.secondary,
      OnboardingAccent.tertiary => AppColors.tertiary,
      OnboardingAccent.primaryContainer => AppColors.primaryContainer,
    };
  }
}
