import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class RideRequestDraft {
  const RideRequestDraft({
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
  });

  final String pickupAddress;
  final String dropoffAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
}

enum RideTier { economy, premium, delivery }

class RideOption {
  const RideOption({
    required this.tier,
    required this.nameKey,
    required this.subtitleKey,
    required this.icon,
    required this.price,
    required this.etaMinutes,
    this.capacity,
  });

  final RideTier tier;
  final String nameKey;
  final String subtitleKey;
  final IconData icon;
  final double price;
  final int etaMinutes;
  final int? capacity;

  static List<RideOption> defaults() => const [
        RideOption(
          tier: RideTier.economy,
          nameKey: 'ride_economy',
          subtitleKey: 'ride_economy_subtitle',
          icon: Icons.directions_car,
          price: 12.50,
          etaMinutes: 4,
          capacity: 4,
        ),
        RideOption(
          tier: RideTier.premium,
          nameKey: 'ride_premium',
          subtitleKey: 'ride_premium_subtitle',
          icon: Icons.local_taxi,
          price: 24.00,
          etaMinutes: 7,
          capacity: 3,
        ),
        RideOption(
          tier: RideTier.delivery,
          nameKey: 'ride_delivery',
          subtitleKey: 'ride_delivery_subtitle',
          icon: Icons.local_shipping,
          price: 8.00,
          etaMinutes: 15,
        ),
      ];
}

class NoktaRideOptionCard extends StatelessWidget {
  const NoktaRideOptionCard({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final RideOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eta = DateTime.now().add(Duration(minutes: option.etaMinutes));
    final etaLabel = '${option.etaMinutes} ${'minutes'.tr()} • ${TimeOfDay.fromDateTime(eta).format(context)}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NoktaSpacing.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(NoktaSpacing.md),
          decoration: BoxDecoration(
            color: selected
                ? (isDark
                    ? scheme.primary.withValues(alpha: 0.2)
                    : scheme.primaryFixed.withValues(alpha: 0.35))
                : (isDark ? scheme.surfaceContainerHigh : scheme.surface),
            borderRadius: BorderRadius.circular(NoktaSpacing.radiusLg),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 48,
                decoration: BoxDecoration(
                  color: selected ? scheme.surface : scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
                ),
                child: Icon(option.icon, size: 32, color: scheme.primary),
              ),
              const SizedBox(width: NoktaSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            option.nameKey.tr(),
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: scheme.onSurface,
                                ),
                          ),
                        ),
                        if (option.capacity != null) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.person, size: 14, color: scheme.outline),
                          Text(
                            '${option.capacity}',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      option.subtitleKey == 'ride_delivery_subtitle'
                          ? option.subtitleKey.tr()
                          : etaLabel,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Text(
                '${option.price.toStringAsFixed(2)} EGP',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
