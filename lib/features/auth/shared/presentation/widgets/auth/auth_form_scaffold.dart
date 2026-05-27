import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/features/auth/onboarding/presentation/widgets/onboarding_background.dart';
import 'package:flutter/material.dart';

class AuthFormDotBackground extends StatelessWidget {
  const AuthFormDotBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _AuthDotPatternPainter(
            color: scheme.primary.withValues(alpha: 0.03),
          ),
        ),
      ),
    );
  }
}

enum AuthFormBackground { dots, gradient }

class AuthFormScaffold extends StatelessWidget {
  const AuthFormScaffold({
    super.key,
    required this.appBar,
    required this.form,
    this.background = AuthFormBackground.dots,
    this.alignTop = false,
  });

  final PreferredSizeWidget appBar;
  final Widget form;
  final AuthFormBackground background;
  final bool alignTop;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final bg = switch (background) {
      AuthFormBackground.dots => const AuthFormDotBackground(),
      AuthFormBackground.gradient => const OnboardingBackground(),
    };

    final scrollChild = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: form,
    );

    return Scaffold(
      backgroundColor: scheme.surface,
      extendBodyBehindAppBar: background == AuthFormBackground.gradient,
      appBar: appBar,
      body: Stack(
        children: [
          bg,
          SafeArea(
            child: alignTop
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - AppSpacing.md * 2,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Spacer(flex: 1),
                                scrollChild,
                                const Spacer(flex: 2),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: scrollChild,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AuthDotPatternPainter extends CustomPainter {
  _AuthDotPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 16.0;
    const radius = 1.0;

    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
