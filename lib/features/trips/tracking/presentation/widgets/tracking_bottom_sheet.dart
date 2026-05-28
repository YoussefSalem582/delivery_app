import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/presentation/widgets/trip_meta_row.dart';
import 'package:delivery_app/features/trips/shared/presentation/widgets/trip_widgets.dart';
import 'package:delivery_app/features/trips/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:delivery_app/features/trips/tracking/presentation/widgets/tracking_driver_row.dart';
import 'package:delivery_app/features/trips/tracking/presentation/widgets/tracking_rider_row.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TrackingBottomSheet extends StatelessWidget {
  const TrackingBottomSheet({
    super.key,
    required this.state,
    required this.tripId,
    this.role = TrackingRole.rider,
  });

  final TrackingState state;
  final String tripId;
  final TrackingRole role;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      TrackingActive active => _ActiveSheet(
          active: active,
          tripId: tripId,
          role: role,
        ),
      TrackingCompleted completed => _CompletedSheet(
          completed: completed,
          tripId: tripId,
          role: role,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _ActiveSheet extends StatelessWidget {
  const _ActiveSheet({
    required this.active,
    required this.tripId,
    required this.role,
  });

  final TrackingActive active;
  final String tripId;
  final TrackingRole role;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final driverName = active.trip.driverName ?? 'driver'.tr();
    final isDriver = role == TrackingRole.driver;

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
                      '${active.etaMinutes} ${'minutes'.tr()}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: scheme.primary,
                            fontSize: 40,
                            height: 1,
                          ),
                    ),
                    Text(
                      active.phase == TrackingPhase.approach
                          ? 'tracking_phase_approach'.tr()
                          : 'tracking_phase_on_trip'.tr(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: scheme.secondary,
                          ),
                    ),
                    Text(
                      'tracking_remaining_km'.tr(
                        namedArgs: {
                          'distance':
                              active.remainingDistanceKm.toStringAsFixed(1),
                        },
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${active.trip.fare.toStringAsFixed(2)} EGP',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              TripStatusChip(
                status: active.trip.status,
                compact: true,
                live: true,
              ),
            ],
          ),
          Divider(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
            height: AppSpacing.lg,
          ),
          if (!isDriver) ...[
            TrackingDriverRow(
              tripId: tripId,
              driverName: driverName,
              avatarUrl: active.trip.driverAvatarUrl,
              rating: active.driverRating ?? active.trip.driverRating,
              vehicle: active.driverVehicle ?? active.trip.driverVehicle,
              phone: active.driverPhone ?? active.trip.driverPhone,
            ),
          ],
          if (isDriver) ...[
            TrackingRiderRow(
              tripId: tripId,
              riderName: active.riderName ?? 'passenger'.tr(),
              avatarUrl: active.riderAvatarUrl,
              rating: active.riderRating,
              phone: active.riderPhone,
            ),
          ],
          TripMetaRow(trip: active.trip, compact: true),
          if (isDriver) ...[
            const SizedBox(height: AppSpacing.md),
            if (active.canDriverMarkArrived)
              AppButton(
                label: 'driver_mark_arrived'.tr(),
                loading: active.isUpdating,
                onPressed: active.isUpdating
                    ? null
                    : () => context.read<TrackingBloc>().add(
                          TrackingDriverStatusRequested(
                            tripId: tripId,
                            status: TripStatus.driverArrived,
                          ),
                        ),
              ),
            if (active.canDriverStartTrip)
              AppButton(
                label: 'driver_start_trip'.tr(),
                loading: active.isUpdating,
                onPressed: active.isUpdating
                    ? null
                    : () => context.read<TrackingBloc>().add(
                          TrackingDriverStatusRequested(
                            tripId: tripId,
                            status: TripStatus.inProgress,
                          ),
                        ),
              ),
            if (active.canDriverCompleteTrip)
              AppButton(
                label: 'driver_complete_trip'.tr(),
                loading: active.isUpdating,
                onPressed: active.isUpdating
                    ? null
                    : () => context.read<TrackingBloc>().add(
                          TrackingDriverStatusRequested(
                            tripId: tripId,
                            status: TripStatus.completed,
                          ),
                        ),
              ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
  }
}

class _CompletedSheet extends StatelessWidget {
  const _CompletedSheet({
    required this.completed,
    required this.tripId,
    required this.role,
  });

  final TrackingCompleted completed;
  final String tripId;
  final TrackingRole role;

  @override
  Widget build(BuildContext context) {
    if (role == TrackingRole.driver) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final driverName = completed.trip.driverName ?? 'driver'.tr();

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
                      'tracking_arrived'.tr(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'tracking_completed_subtitle'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              TripStatusChip(
                status: TripStatus.completed,
                compact: true,
              ),
            ],
          ),
          Divider(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
            height: AppSpacing.lg,
          ),
          TrackingDriverRow(
            tripId: tripId,
            driverName: driverName,
            avatarUrl: completed.trip.driverAvatarUrl,
            rating: completed.driverRating ?? completed.trip.driverRating,
            vehicle: completed.driverVehicle ?? completed.trip.driverVehicle,
            phone: completed.driverPhone ?? completed.trip.driverPhone,
          ),
          TripMetaRow(trip: completed.trip, compact: true),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'view_trip_details'.tr(),
            icon: Icons.receipt_long_outlined,
            onPressed: () => context.pushNamed(
              RouteNames.tripDetail,
              pathParameters: {'tripId': tripId},
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => context.goNamed(RouteNames.home),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: Text('back_to_home'.tr()),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
  }
}
