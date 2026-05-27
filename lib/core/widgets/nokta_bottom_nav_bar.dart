import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:flutter/material.dart';

class NoktaBottomNavBar extends StatelessWidget {
  const NoktaBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NoktaNavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? scheme.inverseSurface
            : scheme.surfaceContainerLowest,
        boxShadow: const [
          BoxShadow(
            color: NoktaColors.elevationShadow,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: NoktaSpacing.bottomNavHeight,
          child: Row(
            children: List.generate(destinations.length, (index) {
              final dest = destinations[index];
              final selected = index == selectedIndex;
              final color = selected
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? scheme.inversePrimary
                      : scheme.primary)
                  : scheme.onSurfaceVariant;

              return Expanded(
                child: InkWell(
                  onTap: () => onDestinationSelected(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? dest.selectedIcon : dest.icon,
                        color: color,
                        size: 24,
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
                            color: Theme.of(context).brightness == Brightness.dark
                                ? scheme.inversePrimary
                                : scheme.primary,
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

class NoktaNavDestination {
  const NoktaNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class NoktaSheetHandle extends StatelessWidget {
  const NoktaSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 32,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: NoktaSpacing.sm),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
