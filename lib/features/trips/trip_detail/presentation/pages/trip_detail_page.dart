import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/core/utils/map_launcher.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/avatar_image.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:delivery_app/features/trips/shared/presentation/widgets/trip_card.dart';
import 'package:delivery_app/features/trips/shared/presentation/widgets/trip_widgets.dart';
import 'package:delivery_app/core/widgets/skeleton_trip_card.dart';
import 'package:delivery_app/features/trips/trip_detail/presentation/bloc/trip_detail_bloc.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TripDetailPage extends StatelessWidget {
  const TripDetailPage({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<TripDetailBloc>()..add(TripDetailLoadRequested(tripId)),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text('trip_detail'.tr()),
        ),
        body: BlocBuilder<TripDetailBloc, TripDetailState>(
          builder: (context, state) {
            if (state is TripDetailLoading) {
              return Skeletonizer(
                enabled: true,
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: const [SkeletonTripCard(), SkeletonTripCard()],
                ),
              );
            }
            if (state is TripDetailError) {
              return ErrorView(message: state.message);
            }
            if (state is TripDetailLoaded) {
              return _TripDetailBody(trip: state.trip);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _TripDetailBody extends StatelessWidget {
  const _TripDetailBody({required this.trip});

  final TripEntity trip;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Hero(
            tag: 'trip_${trip.id}',
            child: TripHeroCard(
              trip: trip,
              highlighted: trip.status == TripStatus.inProgress ||
                  trip.status == TripStatus.accepted ||
                  trip.status == TripStatus.driverArrived,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _DriverCard(
            name: trip.driverName ?? 'driver'.tr(),
            phone: trip.driverPhone,
            avatarUrl: trip.driverAvatarUrl,
          ),
          const SizedBox(height: AppSpacing.md),
          _StatusTimeline(status: trip.status),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'track_trip'.tr(),
            icon: Icons.navigation,
            onPressed: () => context.pushNamed(
              RouteNames.tracking,
              pathParameters: {'tripId': trip.id},
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => openExternalMaps(
              lat: trip.dropoffLat,
              lng: trip.dropoffLng,
              label: trip.dropoffAddress,
            ),
            icon: const Icon(Icons.map_outlined),
            label: Text('open_in_maps'.tr()),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
          if (trip.status != TripStatus.completed &&
              trip.status != TripStatus.cancelled) ...[
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () {
                context.read<TripDetailBloc>().add(
                      TripDetailStatusUpdateRequested(
                        trip.id,
                        TripStatus.driverArrived,
                      ),
                    );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text('simulate_driver_arrived'.tr()),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'complete_trip'.tr(),
              usePrimaryContainer: true,
              onPressed: () {
                context.read<TripDetailBloc>().add(
                      TripDetailCompleteRequested(trip.id),
                    );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({
    required this.name,
    this.phone,
    this.avatarUrl,
  });

  final String name;
  final String? phone;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          AvatarImage(
            imageUrl: avatarUrl,
            fallback: name,
            radius: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.onSurface,
                    )),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: AppColors.tertiaryFixedDim),
                    const SizedBox(width: 4),
                    Text('4.9 • 124 rides', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                if (phone != null && phone!.isNotEmpty)
                  Text(phone!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          _DriverActionButton(icon: Icons.chat_bubble_outline, onPressed: () {}),
          const SizedBox(width: AppSpacing.sm),
          _DriverActionButton(icon: Icons.call, onPressed: () {}),
        ],
      ),
    );
  }
}

class _DriverActionButton extends StatelessWidget {
  const _DriverActionButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainer,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: scheme.primary),
        ),
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.status});

  final TripStatus status;

  @override
  Widget build(BuildContext context) {
    final steps = [
      TripStatus.requested,
      TripStatus.accepted,
      TripStatus.driverArrived,
      TripStatus.inProgress,
      TripStatus.completed,
    ];
    final currentIndex = steps.indexOf(status).clamp(0, steps.length - 1);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('status'.tr(), style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.lg),
          ...List.generate(steps.length, (index) {
            final active = index <= currentIndex;
            final current = index == currentIndex;
            final isLast = index == steps.length - 1;

            return _TimelineStep(
              label: tripStatusLabel(steps[index]),
              subtitle: active ? formatTripDate(DateTime.now()) : null,
              active: active,
              current: current,
              isLast: isLast,
              icon: _stepIcon(steps[index], active),
            );
          }),
        ],
      ),
    );
  }

  IconData _stepIcon(TripStatus step, bool active) {
    if (!active) return Icons.radio_button_unchecked;
    return switch (step) {
      TripStatus.inProgress => Icons.directions_car,
      TripStatus.completed => Icons.check,
      _ => Icons.check,
    };
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.active,
    required this.current,
    required this.isLast,
    required this.icon,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final bool active;
  final bool current;
  final bool isLast;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: active ? scheme.primary : scheme.surfaceContainer,
                    shape: BoxShape.circle,
                    border: current
                        ? Border.all(
                            color: scheme.primary.withValues(alpha: 0.3),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Icon(
                    icon,
                    size: 14,
                    color: active ? scheme.onPrimary : scheme.outline,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: active ? scheme.primary : scheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: current ? scheme.primary : scheme.onSurface,
                        ),
                  ),
                  if (subtitle != null)
                    Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

