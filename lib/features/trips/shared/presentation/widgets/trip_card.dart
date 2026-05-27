import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/presentation/widgets/trip_widgets.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Shared trip summary used in list cards and detail hero transitions.
class TripHeroCard extends StatelessWidget {
  const TripHeroCard({
    super.key,
    required this.trip,
    this.highlighted = false,
    this.liveStatus = false,
    this.pendingRetryCount = 0,
  });

  final TripEntity trip;
  final bool highlighted;
  final bool liveStatus;
  final int pendingRetryCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: highlighted
              ? scheme.surfaceContainerLowest
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
                      TripStatusChip(
                        status: trip.status,
                        compact: true,
                        live: liveStatus,
                      ),
                      const SizedBox(height: AppSpacing.sm),
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
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${trip.fare.toStringAsFixed(2)} EGP',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: TripRouteColumn(
                pickup: trip.pickupAddress,
                dropoff: trip.dropoffAddress,
                dimmed: !highlighted,
              ),
            ),
            if (trip.isPendingSync) ...[
              const SizedBox(height: AppSpacing.sm),
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

class TripCard extends StatelessWidget {
  const TripCard({
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
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              TripHeroCard(
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
                        left: Radius.circular(AppSpacing.radiusMd),
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
