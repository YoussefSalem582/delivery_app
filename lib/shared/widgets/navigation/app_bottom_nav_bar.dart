import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AppNavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: isDark
            ? Border(
                top: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.4),
                ),
              )
            : null,
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: AppColors.elevationShadow,
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSpacing.bottomNavHeight,
          child: Row(
            children: List.generate(destinations.length, (index) {
              final dest = destinations[index];
              final selected = index == selectedIndex;
              final color =
                  selected ? scheme.primary : scheme.onSurfaceVariant;

              return Expanded(
                child: InkWell(
                  onTap: () => onDestinationSelected(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _NavIcon(
                        destination: dest,
                        selected: selected,
                        color: color,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dest.label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: color,
                            ),
                      ),
                      if (selected) ...[
                        const SizedBox(height: 2),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class AppNavDestination {
  const AppNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badgeCount,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int? badgeCount;
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.destination,
    required this.selected,
    required this.color,
  });

  final AppNavDestination destination;
  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      selected ? destination.selectedIcon : destination.icon,
      color: color,
      size: 24,
    );

    final count = destination.badgeCount;
    if (count == null || count <= 0) return icon;

    return Badge(
      label: Text(count > 99 ? '99+' : '$count'),
      child: icon,
    );
  }
}

class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 32,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
