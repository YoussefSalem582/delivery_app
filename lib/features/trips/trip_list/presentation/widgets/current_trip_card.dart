import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/core/widgets/avatar_image.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/presentation/widgets/active_trip_section.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
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

    Widget? footer;
    if (isWaitingForDriver) {
      footer = Row(
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
      );
    } else if (driverName != null && driverName.isNotEmpty) {
      footer = Row(
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
                if (trip.driverVehicle != null && trip.driverVehicle!.isNotEmpty)
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
      );
    }

    return ActiveTripSection(
      title: 'current_trip'.tr(),
      trip: trip,
      pendingRetryCount: pendingRetryCount,
      actionLabel: isWaitingForDriver
          ? 'waiting_for_driver'.tr()
          : 'track_trip'.tr(),
      actionIcon: isWaitingForDriver ? Icons.hourglass_top : Icons.navigation,
      onCardTap: () => context.pushNamed(
        RouteNames.tripDetail,
        pathParameters: {'tripId': trip.id},
      ),
      onAction: () => context.pushNamed(
        RouteNames.tracking,
        pathParameters: {'tripId': trip.id},
      ),
      footer: footer,
    );
  }
}
