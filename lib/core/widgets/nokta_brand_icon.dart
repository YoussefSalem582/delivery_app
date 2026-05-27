import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Nokta wordmark from [assetPath] (wide SVG, ~3.28:1).
class NoktaBrandIcon extends StatelessWidget {
  const NoktaBrandIcon({
    super.key,
    this.size = 64,
    this.filled = true,
  });

  static const assetPath = 'assets/logo.svg';

  /// Matches `viewBox` in assets/logo.svg (888.75 × 270.75).
  static const aspectRatio = 888.75 / 270.75;

  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final logoHeight = filled ? size * 0.38 : size;
    final logo = _LogoSvg(height: logoHeight);

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
              color: NoktaColors.elevationShadow,
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

class _LogoSvg extends StatelessWidget {
  const _LogoSvg({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = height * NoktaBrandIcon.aspectRatio;

    return RepaintBoundary(
      child: SvgPicture.asset(
        NoktaBrandIcon.assetPath,
        width: width,
        height: height,
        fit: BoxFit.contain,
        semanticsLabel: 'Nokta',
        placeholderBuilder: (_) => SizedBox(
          width: width,
          height: height,
          child: Center(
            child: SizedBox(
              width: height * 0.4,
              height: height * 0.4,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.primary.withValues(alpha: 0.35),
              ),
            ),
          ),
        ),
        errorBuilder: (_, _, _) => Icon(
          Icons.directions_car,
          size: height * 0.6,
          color: scheme.primary,
        ),
      ),
    );
  }
}
