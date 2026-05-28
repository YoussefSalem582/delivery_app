import 'package:delivery_app/features/auth/splash/presentation/splash_config.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/branding/app_brand_icon.dart';
import 'package:delivery_app/shared/widgets/feedback/app_loading_ring.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Centered splash branding, loading feedback, and timed progress bar.
class SplashContent extends StatelessWidget {
  const SplashContent({
    super.key,
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: 'app_logo',
                      child: AppBrandIcon(
                        size: SplashConfig.wordmarkHeight,
                        filled: false,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                        .scale(
                          begin: const Offset(0.92, 0.92),
                          end: const Offset(1, 1),
                          duration: 650.ms,
                          curve: Curves.easeOutBack,
                        )
                        .slideY(
                          begin: 0.08,
                          end: 0,
                          duration: 650.ms,
                          curve: Curves.easeOutCubic,
                        ),
                    const SizedBox(height: AppSpacing.xl),
                    const AppLoadingRing()
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .scale(
                          begin: const Offset(0.85, 0.85),
                          end: const Offset(1, 1),
                          delay: 200.ms,
                          duration: 450.ms,
                          curve: Curves.easeOut,
                        ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'splash_loading'.tr(),
                      style: textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 350.ms, duration: 450.ms)
                        .slideY(
                          begin: 0.12,
                          end: 0,
                          delay: 350.ms,
                          duration: 450.ms,
                          curve: Curves.easeOut,
                        ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 3,
                backgroundColor: scheme.primaryContainer.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(scheme.primaryContainer),
              ),
            )
                .animate()
                .fadeIn(delay: 250.ms, duration: 350.ms),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
