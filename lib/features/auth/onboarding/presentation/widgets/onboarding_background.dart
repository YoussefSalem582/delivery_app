import 'package:flutter/material.dart';

/// Soft gradient + dot pattern behind onboarding slides.
class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.primary.withValues(alpha: 0.06),
                scheme.surface,
                scheme.surface,
              ],
            ),
          ),
        ),
        CustomPaint(
          painter: _OnboardingDotPainter(
            color: scheme.primary.withValues(alpha: 0.04),
          ),
        ),
      ],
    );
  }
}

class _OnboardingDotPainter extends CustomPainter {
  _OnboardingDotPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 20.0;
    const radius = 1.2;

    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
