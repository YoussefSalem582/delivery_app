import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/features/auth/shared/presentation/widgets/auth/login_demo_chip.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// One-tap demo profile for the MVP register flow.
class RegisterDemoChip extends StatelessWidget {
  const RegisterDemoChip({
    super.key,
    required this.onFillDemo,
  });

  static const demoName = 'Demo Rider';

  final VoidCallback onFillDemo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: 'register_demo_fill'.tr(),
      child: Material(
        color: scheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: onFillDemo,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.bolt_rounded,
                  size: 20,
                  color: scheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'register_demo_fill'.tr(),
                        style: textTheme.labelLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$demoName · ${LoginDemoChip.demoEmail}',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.touch_app_outlined,
                  size: 18,
                  color: scheme.primary.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
