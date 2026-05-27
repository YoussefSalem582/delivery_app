import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/presentation/widgets/trip_widgets.dart';
import 'package:delivery_app/features/trips/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:delivery_app/features/trips/tracking/presentation/widgets/tracking_driver_row.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class TrackingBottomSheet extends StatelessWidget {
  const TrackingBottomSheet({
    super.key,
    required this.state,
    required this.tripId,
  });

  final TrackingState state;
  final String tripId;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      TrackingActive active => _ActiveSheet(active: active),
      TrackingCompleted completed => _CompletedSheet(
          completed: completed,
          tripId: tripId,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _ActiveSheet extends StatelessWidget {
  const _ActiveSheet({required this.active});

  final TrackingActive active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final driverName = active.trip.driverName ?? 'driver'.tr();

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
          TrackingDriverRow(
            driverName: driverName,
            avatarUrl: active.trip.driverAvatarUrl,
            rating: active.driverRating,
            vehicle: active.driverVehicle,
            phone: active.driverPhone,
          ),
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
  });

  final TrackingCompleted completed;
  final String tripId;

  @override
  Widget build(BuildContext context) {
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
            driverName: driverName,
            avatarUrl: completed.trip.driverAvatarUrl,
            rating: completed.driverRating,
            vehicle: completed.driverVehicle,
            phone: completed.driverPhone,
          ),
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
