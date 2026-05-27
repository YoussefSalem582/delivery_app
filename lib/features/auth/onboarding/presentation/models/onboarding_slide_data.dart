import 'package:flutter/material.dart';

enum OnboardingAccent { primary, secondary, tertiary, primaryContainer }

class OnboardingSlideData {
  const OnboardingSlideData({
    required this.titleKey,
    required this.bodyKey,
    required this.icon,
    required this.accent,
  });

  final String titleKey;
  final String bodyKey;
  final IconData icon;
  final OnboardingAccent accent;
}

const List<OnboardingSlideData> kOnboardingSlides = [
  OnboardingSlideData(
    titleKey: 'onboarding_slide_1_title',
    bodyKey: 'onboarding_slide_1_body',
    icon: Icons.near_me_outlined,
    accent: OnboardingAccent.primary,
  ),
  OnboardingSlideData(
    titleKey: 'onboarding_slide_2_title',
    bodyKey: 'onboarding_slide_2_body',
    icon: Icons.directions_car_outlined,
    accent: OnboardingAccent.secondary,
  ),
  OnboardingSlideData(
    titleKey: 'onboarding_slide_3_title',
    bodyKey: 'onboarding_slide_3_body',
    icon: Icons.route_outlined,
    accent: OnboardingAccent.primaryContainer,
  ),
  OnboardingSlideData(
    titleKey: 'onboarding_slide_4_title',
    bodyKey: 'onboarding_slide_4_body',
    icon: Icons.account_balance_wallet_outlined,
    accent: OnboardingAccent.tertiary,
  ),
];
