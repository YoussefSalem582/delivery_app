import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/core/widgets/avatar_image.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/presentation/widgets/trip_card.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CurrentTripCard extends StatelessWidget {
  const CurrentTripCard({
    super.key,
    required this.trip,
    this.pendingRetryCount = 0,
  });

  final TripEntity trip;
  final int pendingRetryCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final driverName = trip.driverName;
    final isWaitingForDriver = trip.status == TripStatus.requested;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            onTap: () => context.pushNamed(
              RouteNames.tripDetail,
              pathParameters: {'tripId': trip.id},
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                TripHeroCard(
                  trip: trip,
                  highlighted: true,
                  liveStatus: true,
                  pendingRetryCount: pendingRetryCount,
                ),
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
        if (isWaitingForDriver) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'waiting_for_driver'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ] else if (driverName != null && driverName.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              AvatarImage(
                imageUrl: trip.driverAvatarUrl,
                fallback: driverName,
                radius: 16,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (trip.driverRating != null)
                      Text(
                        trip.driverRating!.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.outline,
                            ),
                      ),
                    if (trip.driverVehicle != null &&
                        trip.driverVehicle!.isNotEmpty)
                      Text(
                        trip.driverVehicle!,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: scheme.outline),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: isWaitingForDriver
              ? 'waiting_for_driver'.tr()
              : 'track_trip'.tr(),
          icon: isWaitingForDriver ? Icons.hourglass_top : Icons.navigation,
          onPressed: () => context.pushNamed(
            RouteNames.tracking,
            pathParameters: {'tripId': trip.id},
          ),
        ),
      ],
    );
  }
}
