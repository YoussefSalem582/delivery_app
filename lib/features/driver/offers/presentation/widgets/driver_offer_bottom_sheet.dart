import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/core/network/route_service.dart';
import 'package:delivery_app/features/driver/offers/presentation/cubit/driver_offer_preview_cubit.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/presentation/widgets/trip_meta_row.dart';
import 'package:delivery_app/features/trips/shared/presentation/widgets/trip_widgets.dart';
import 'package:delivery_app/features/trips/tracking/presentation/widgets/tracking_rider_row.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DriverOfferBottomSheet extends StatelessWidget {
  const DriverOfferBottomSheet({
    super.key,
    required this.loaded,
    required this.isBusy,
    required this.onAccept,
    required this.onDecline,
  });

  final DriverOfferPreviewLoaded loaded;
  final bool isBusy;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final trip = loaded.trip;
    final plan = loaded.routePlan;
    final rider = loaded.rider;
    final riderName = rider?.name ?? 'passenger'.tr();
    final totalKm = plan.totalDistanceMeters / 1000;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: AppColors.elevationShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'eta'.tr().toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 1,
                          ),
                    ),
                    Text(
                      '${plan.totalEtaMinutes} ${'minutes'.tr()}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: scheme.primary,
                            fontSize: 40,
                            height: 1,
                          ),
                    ),
                    Text(
                      'driver_offer_approach_eta'.tr(
                        namedArgs: {
                          'minutes': '${plan.approachLeg.etaMinutes}',
                        },
                      ),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: scheme.secondary,
                          ),
                    ),
                    Text(
                      'driver_offer_trip_eta'.tr(
                        namedArgs: {'minutes': '${plan.tripLeg.etaMinutes}'},
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'tracking_remaining_km'.tr(
                        namedArgs: {'distance': totalKm.toStringAsFixed(1)},
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${trip.fare.toStringAsFixed(2)} EGP',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              TripStatusChip(
                status: TripStatus.requested,
                compact: true,
              ),
            ],
          ),
          Divider(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
            height: AppSpacing.lg,
          ),
          TrackingRiderRow(
            tripId: trip.id,
            riderName: riderName,
            avatarUrl: rider?.avatarUrl,
            rating: rider?.rating,
            phone: rider?.phone,
          ),
          TripMetaRow(trip: trip, compact: true),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'driver_accept_offer'.tr(),
            loading: isBusy,
            onPressed: isBusy ? null : onAccept,
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: isBusy ? null : onDecline,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: Text('driver_decline_offer'.tr()),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
  }
}
