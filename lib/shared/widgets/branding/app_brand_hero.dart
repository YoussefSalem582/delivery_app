import 'package:flutter/material.dart';

import 'app_brand_icon.dart';

/// Theme-aware wordmark wrapped for [Hero] flights.
class AppBrandHero extends StatelessWidget {
  const AppBrandHero({
    super.key,
    required this.size,
    this.filled = false,
  });

  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: AppBrandIcon.heroTag,
      child: Material(
        type: MaterialType.transparency,
        child: AppBrandIcon(
          size: size,
          filled: filled,
        ),
      ),
    );
  }
}
