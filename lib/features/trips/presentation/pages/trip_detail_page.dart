import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/architecture/entities/trip_entity.dart';
import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/nokta_primary_button.dart';
import 'package:delivery_app/core/widgets/nokta_trip_card.dart';
import 'package:delivery_app/core/widgets/nokta_trip_widgets.dart';
import 'package:delivery_app/features/trips/presentation/bloc/trip_detail_bloc.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/routes/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class TripDetailPage extends StatelessWidget {
  const TripDetailPage({super.key, @PathParam('tripId') required this.tripId});

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
            onPressed: () => context.router.maybePop(),
          ),
          title: Text('trip_detail'.tr()),
        ),
        body: BlocBuilder<TripDetailBloc, TripDetailState>(
          builder: (context, state) {
            if (state is TripDetailLoading) {
              return LoadingView(message: 'loading');
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
      padding: const EdgeInsets.all(NoktaSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Hero(
            tag: 'trip_${trip.id}',
            child: NoktaTripHeroCard(
              trip: trip,
              highlighted: trip.status == TripStatus.inProgress ||
                  trip.status == TripStatus.accepted ||
                  trip.status == TripStatus.driverArrived,
            ),
          ),
          const SizedBox(height: NoktaSpacing.md),
          _DriverCard(
            name: trip.driverName ?? 'driver'.tr(),
            phone: trip.driverPhone,
          ),
          const SizedBox(height: NoktaSpacing.md),
          _StatusTimeline(status: trip.status),
          const SizedBox(height: NoktaSpacing.lg),
          NoktaPrimaryButton(
            label: 'track_trip'.tr(),
            icon: Icons.navigation,
            onPressed: () => context.router.push(TrackingRoute(tripId: trip.id)),
          ),
          if (trip.status != TripStatus.completed &&
              trip.status != TripStatus.cancelled) ...[
            const SizedBox(height: NoktaSpacing.sm),
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
                minimumSize: const Size.fromHeight(NoktaSpacing.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
                ),
              ),
              child: Text('simulate_driver_arrived'.tr()),
            ),
            const SizedBox(height: NoktaSpacing.sm),
            NoktaPrimaryButton(
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
  const _DriverCard({required this.name, this.phone});

  final String name;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(NoktaSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(NoktaSpacing.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: scheme.surfaceContainer,
            child: Icon(Icons.person, color: scheme.outline),
          ),
          const SizedBox(width: NoktaSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.onSurface,
                    )),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: NoktaColors.tertiaryFixedDim),
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
          const SizedBox(width: NoktaSpacing.sm),
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
      padding: const EdgeInsets.all(NoktaSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(NoktaSpacing.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('status'.tr(), style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: NoktaSpacing.lg),
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
          const SizedBox(width: NoktaSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : NoktaSpacing.lg),
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

