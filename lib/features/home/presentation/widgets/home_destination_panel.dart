import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/widgets/nokta_bottom_nav_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomeDestinationPanel extends StatelessWidget {
  const HomeDestinationPanel({
    super.key,
    required this.onSearchTap,
    this.onQuickDestination,
  });

  final VoidCallback onSearchTap;
  final ValueChanged<String>? onQuickDestination;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      elevation: 0,
      color: isDark ? scheme.inverseSurface : scheme.surfaceContainerLowest,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(NoktaSpacing.radiusLg),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(NoktaSpacing.radiusLg),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 24,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(
          NoktaSpacing.md,
          NoktaSpacing.sm,
          NoktaSpacing.md,
          NoktaSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NoktaSheetHandle(),
            Text(
              'request_ride_title'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isDark ? scheme.onInverseSurface : scheme.onSurface,
                  ),
            ),
            const SizedBox(height: NoktaSpacing.md),
            Material(
              color: isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
              child: InkWell(
                onTap: onSearchTap,
                borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
                child: Container(
                  height: NoktaSpacing.inputHeight,
                  padding: const EdgeInsets.symmetric(horizontal: NoktaSpacing.md),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: scheme.primary),
                      const SizedBox(width: NoktaSpacing.sm),
                      Expanded(
                        child: Text(
                          'search_destination'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: scheme.outline,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: NoktaSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickChip(
                    icon: Icons.home_outlined,
                    label: 'quick_home'.tr(),
                    onTap: () => onQuickDestination?.call('quick_home'.tr()),
                  ),
                  const SizedBox(width: NoktaSpacing.sm),
                  _QuickChip(
                    icon: Icons.work_outline,
                    label: 'quick_work'.tr(),
                    onTap: () => onQuickDestination?.call('quick_work'.tr()),
                  ),
                  const SizedBox(width: NoktaSpacing.sm),
                  _QuickChip(
                    icon: Icons.flight_takeoff,
                    label: 'quick_airport'.tr(),
                    onTap: () => onQuickDestination?.call('quick_airport'.tr()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      shape: StadiumBorder(
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: scheme.secondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
