import 'dart:ui';

import 'package:delivery_app/shared/widgets/branding/app_brand_icon.dart';
import 'package:delivery_app/features/auth/onboarding/presentation/widgets/onboarding_top_bar.dart';
import 'package:flutter/material.dart';

/// Animates the wordmark from the slide-1 circle anchor to the top-bar anchor.
class OnboardingLogoLayer extends StatelessWidget {
  const OnboardingLogoLayer({
    super.key,
    required this.stackKey,
    required this.centerAnchorKey,
    required this.topAnchorKey,
    required this.progress,
  });

  final GlobalKey stackKey;
  final GlobalKey centerAnchorKey;
  final GlobalKey topAnchorKey;
  final Animation<double> progress;

  static const slideLogoSize = 52.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final stackBox = _renderBox(stackKey);
        final from = _anchorCenter(centerAnchorKey);
        final to = _anchorCenter(topAnchorKey);

        if (stackBox == null || from == null || to == null) {
          return const SizedBox.shrink();
        }

        final t = Curves.easeInOutCubic.transform(progress.value);
        final center = Offset.lerp(from, to, t)!;
        final local = stackBox.globalToLocal(center);
        final size = lerpDouble(
          slideLogoSize,
          OnboardingTopBar.wordmarkHeight,
          t,
        )!;

        return Positioned(
          left: local.dx,
          top: local.dy,
          child: Transform.translate(
            offset: Offset(-(size * AppBrandIcon.wordmarkAspectRatio) / 2, -size / 2),
            child: AppBrandIcon(size: size, filled: false),
          ),
        );
      },
    );
  }

  static RenderBox? _renderBox(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return null;
    return context.findRenderObject() as RenderBox?;
  }

  static Offset? _anchorCenter(GlobalKey key) {
    final box = _renderBox(key);
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }
}
