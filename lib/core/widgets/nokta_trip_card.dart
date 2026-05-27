import 'package:delivery_app/core/architecture/entities/trip_entity.dart';
import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/widgets/nokta_trip_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Shared trip summary used in list cards and detail hero transitions.
class NoktaTripHeroCard extends StatelessWidget {
  const NoktaTripHeroCard({
    super.key,
    required this.trip,
    this.highlighted = false,
    this.pendingRetryCount = 0,
  });

  final TripEntity trip;
  final bool highlighted;
  final int pendingRetryCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(NoktaSpacing.md),
        decoration: BoxDecoration(
          color: highlighted
              ? scheme.surfaceContainerLowest
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
          border: Border.all(
            color: highlighted ? scheme.primaryContainer : scheme.outlineVariant,
          ),
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: scheme.primaryContainer.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NoktaStatusChip(status: trip.status, compact: true),
                      const SizedBox(height: NoktaSpacing.sm),
                      Text(
                        formatTripDate(trip.createdAt),
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: scheme.outline),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: NoktaSpacing.sm),
                Text(
                  '${trip.fare.toStringAsFixed(2)} EGP',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: NoktaSpacing.md),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: NoktaTripRouteColumn(
                pickup: trip.pickupAddress,
                dropoff: trip.dropoffAddress,
                dimmed: !highlighted,
              ),
            ),
            if (trip.isPendingSync) ...[
              const SizedBox(height: NoktaSpacing.sm),
              Row(
                children: [
                  Icon(Icons.cloud_off, size: 14, color: scheme.error),
                  const SizedBox(width: 4),
                  Text(
                    pendingRetryCount > 0
                        ? '${'offline_mode'.tr()} ($pendingRetryCount)'
                        : 'offline_mode'.tr(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.error,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NoktaTripCard extends StatelessWidget {
  const NoktaTripCard({
    super.key,
    required this.trip,
    this.onTap,
    this.pendingRetryCount = 0,
  });

  final TripEntity trip;
  final VoidCallback? onTap;
  final int pendingRetryCount;

  bool get _highlighted =>
      trip.status == TripStatus.inProgress ||
      trip.status == TripStatus.accepted ||
      trip.status == TripStatus.driverArrived;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Hero(
      tag: 'trip_${trip.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              NoktaTripHeroCard(
                trip: trip,
                highlighted: _highlighted,
                pendingRetryCount: pendingRetryCount,
              ),
              if (_highlighted)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(NoktaSpacing.radiusMd),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoktaOfflineTripsBanner extends StatelessWidget {
  const NoktaOfflineTripsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: NoktaSpacing.md),
      padding: const EdgeInsets.all(NoktaSpacing.md),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: scheme.onErrorContainer),
          const SizedBox(width: NoktaSpacing.sm),
          Expanded(
            child: Text(
              'offline_trips_banner'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onErrorContainer,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
