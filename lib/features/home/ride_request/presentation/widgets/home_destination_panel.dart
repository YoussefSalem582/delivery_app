import 'package:delivery_app/features/home/ride_request/domain/entities/quick_destination_type.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/navigation/app_bottom_nav_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomeDestinationPanel extends StatelessWidget {
  const HomeDestinationPanel({
    super.key,
    required this.onSearchTap,
    this.onQuickDestination,
  });

  final VoidCallback onSearchTap;
  final ValueChanged<QuickDestinationType>? onQuickDestination;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      elevation: 0,
      color: scheme.surfaceContainerLowest,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLg),
          ),
          border: isDark
              ? Border(top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)))
              : null,
          boxShadow: isDark
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 24,
                    offset: Offset(0, -4),
                  ),
                ],
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppSheetHandle(),
            Text(
              'request_ride_title'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Material(
              color: isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: InkWell(
                onTap: onSearchTap,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Container(
                  height: AppSpacing.inputHeight,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: scheme.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'search_locations'.tr(),
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
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickChip(
                    icon: Icons.home_outlined,
                    label: 'quick_home'.tr(),
                    onTap: () => onQuickDestination?.call(QuickDestinationType.home),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _QuickChip(
                    icon: Icons.work_outline,
                    label: 'quick_work'.tr(),
                    onTap: () => onQuickDestination?.call(QuickDestinationType.work),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _QuickChip(
                    icon: Icons.flight_takeoff,
                    label: 'quick_airport'.tr(),
                    onTap: () => onQuickDestination?.call(QuickDestinationType.airport),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? scheme.surfaceContainerHigh : scheme.surface,
      shape: StadiumBorder(
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 1)),
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
