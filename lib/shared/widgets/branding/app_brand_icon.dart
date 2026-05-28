import 'package:delivery_app/core/constants/app_constants.dart';
import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/shared/assets/app_assets.dart';
import 'package:flutter/material.dart';

/// App wordmark — [AppAssets.logoLightTheme] in light mode,
/// [AppAssets.logoDarkTheme] in dark mode.
class AppBrandIcon extends StatelessWidget {
  const AppBrandIcon({
    super.key,
    this.size = 64,
    this.filled = true,
  });

  static String assetPathFor(Brightness brightness) =>
      AppAssets.logoFor(brightness);

  static const heroTag = 'app_logo';

  /// Width ÷ height for `assets/logo.png` wordmark.
  static const wordmarkAspectRatio = 1185 / 361;

  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final logoHeight = filled ? size * 0.38 : size;
    final logo = _LogoImage(height: logoHeight);

    if (filled) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          shape: BoxShape.circle,
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.35),
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.elevationShadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: logo,
      );
    }

    return logo;
  }
}

class _LogoImage extends StatelessWidget {
  const _LogoImage({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final assetPath = AppBrandIcon.assetPathFor(scheme.brightness);

    return RepaintBoundary(
      child: Image.asset(
        assetPath,
        height: height,
        fit: BoxFit.contain,
        semanticLabel: AppConstants.appName,
        errorBuilder: (_, _, _) => Icon(
          Icons.directions_car,
          size: height * 0.6,
          color: scheme.primary,
        ),
      ),
    );
  }
}
