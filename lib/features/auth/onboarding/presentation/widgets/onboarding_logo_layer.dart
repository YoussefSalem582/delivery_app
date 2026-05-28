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
  static const _atTopThreshold = 0.98;
  static const _atCenterThreshold = 0.02;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final stackBox = _renderBox(stackKey);
        final from = _anchorCenter(centerAnchorKey);
        final to = _anchorCenter(topAnchorKey);

        if (stackBox == null || to == null) {
          return const SizedBox.shrink();
        }

        final t = Curves.easeInOutCubic.transform(progress.value);
        final globalCenter = _resolvePosition(from: from, to: to, t: t);
        if (globalCenter == null) {
          return const SizedBox.shrink();
        }

        final local = stackBox.globalToLocal(globalCenter);
        final size = lerpDouble(
          slideLogoSize,
          OnboardingTopBar.wordmarkHeight,
          t,
        )!;

        return Positioned(
          left: local.dx,
          top: local.dy,
          child: Transform.translate(
            offset: Offset(
              -(size * AppBrandIcon.wordmarkAspectRatio) / 2,
              -size / 2,
            ),
            child: AppBrandIcon(size: size, filled: false),
          ),
        );
      },
    );
  }

  /// Slide 1 may leave the tree on later pages — fall back to the top anchor.
  static Offset? _resolvePosition({
    required Offset? from,
    required Offset to,
    required double t,
  }) {
    if (t >= _atTopThreshold) return to;
    if (t <= _atCenterThreshold) return from;
    if (from != null) return Offset.lerp(from, to, t);
    return to;
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
