import 'package:flutter/material.dart';

/// Soft gradient + dot pattern behind the splash screen.
class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key});

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
                scheme.primary.withValues(alpha: 0.08),
                scheme.surface,
                scheme.surface,
              ],
            ),
          ),
        ),
        CustomPaint(
          painter: _SplashDotPainter(
            color: scheme.primary.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }
}

class _SplashDotPainter extends CustomPainter {
  _SplashDotPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 22.0;
    const radius = 1.4;

    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
