import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/architecture/entities/trip_entity.dart';
import 'package:delivery_app/core/architecture/repositories/trip_repository.dart';
import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/utils/map_config.dart';
import 'package:delivery_app/core/utils/map_launcher.dart';
import 'package:delivery_app/core/widgets/avatar_image.dart';
import 'package:delivery_app/core/widgets/delivery_map.dart';
import 'package:delivery_app/core/widgets/nokta_trip_widgets.dart';
import 'package:delivery_app/core/widgets/skeleton_trip_card.dart';
import 'package:delivery_app/features/home/presentation/bloc/map_bloc.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

@RoutePage()
class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key, @PathParam('tripId') required this.tripId});

  final String tripId;

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  TripEntity? _trip;
  late final TrackingBloc _trackingBloc;
  final _mapKey = GlobalKey<DeliveryMapState>();

  @override
  void initState() {
    super.initState();
    _trackingBloc = sl<TrackingBloc>();
    _loadTrip();
  }

  @override
  void dispose() {
    _trackingBloc.add(const TrackingStopped());
    _trackingBloc.close();
    super.dispose();
  }

  Future<void> _loadTrip() async {
    final trip = await sl<TripRepository>().getTripById(widget.tripId);
    if (!mounted) return;
    setState(() => _trip = trip);
    if (trip != null) {
      _trackingBloc.add(TrackingStarted(trip));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_trip == null) {
      return Scaffold(
        appBar: AppBar(title: Text('tracking_title'.tr())),
        body: Skeletonizer(
          enabled: true,
          child: ListView(
            padding: const EdgeInsets.all(NoktaSpacing.md),
            children: const [SkeletonTripCard(), SkeletonTripCard()],
          ),
        ),
      );
    }

    return BlocProvider.value(
      value: _trackingBloc,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: NoktaSpacing.sm),
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              shape: const CircleBorder(),
              elevation: 2,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.router.maybePop(),
              ),
            ),
          ),
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerLowest
                  .withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'tracking_title'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<TrackingBloc, TrackingState>(
          builder: (context, state) {
            if (state is TrackingLoading) {
              return Skeletonizer(
                enabled: true,
                child: ListView(
                  padding: const EdgeInsets.all(NoktaSpacing.md),
                  children: const [SkeletonTripCard()],
                ),
              );
            }

            if (state is! TrackingActive) {
              return Skeletonizer(
                enabled: true,
                child: ListView(
                  padding: const EdgeInsets.all(NoktaSpacing.md),
                  children: const [SkeletonTripCard()],
                ),
              );
            }

            final active = state;
            final scheme = Theme.of(context).colorScheme;
            final driverName = active.trip.driverName ?? 'driver'.tr();

            return Stack(
              children: [
                DeliveryMap(
                  key: _mapKey,
                  center: active.driverPosition,
                  zoom: MapConfig.defaultZoom,
                  followCenter: true,
                  fitRouteBounds: true,
                  polylines: active.route,
                  markers: [
                    MapMarkerData(
                      point: active.route.first,
                      color: scheme.secondary,
                      icon: Icons.trip_origin,
                    ),
                    MapMarkerData(
                      point: active.driverPosition,
                      color: scheme.primary,
                      icon: Icons.local_taxi,
                      size: 36,
                      animate: true,
                    ),
                    MapMarkerData(
                      point: active.route.last,
                      color: scheme.error,
                      icon: Icons.location_on,
                    ),
                  ],
                ),
                Positioned(
                  right: NoktaSpacing.md,
                  bottom: 260,
                  child: FloatingActionButton(
                    onPressed: () =>
                        _mapKey.currentState?.recenter(active.driverPosition),
                    child: const Icon(Icons.my_location),
                  ),
                ),
                Positioned(
                  left: NoktaSpacing.md,
                  right: NoktaSpacing.md,
                  bottom: NoktaSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.all(NoktaSpacing.md),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(NoktaSpacing.radiusLg),
                      border: Border.all(color: scheme.outlineVariant),
                      boxShadow: const [
                        BoxShadow(
                          color: NoktaColors.elevationShadow,
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          letterSpacing: 1,
                                        ),
                                  ),
                                  Text(
                                    '${active.etaMinutes} ${'minutes'.tr()}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                          color: scheme.primary,
                                          fontSize: 40,
                                          height: 1,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            NoktaStatusChip(
                              status: active.trip.status,
                              compact: true,
                            ),
                          ],
                        ),
                        Divider(
                          color: scheme.outlineVariant.withValues(alpha: 0.3),
                          height: NoktaSpacing.lg,
                        ),
                        Row(
                          children: [
                            AvatarImage(
                              imageUrl: active.trip.driverAvatarUrl,
                              fallback: driverName,
                              radius: 24,
                            ),
                            const SizedBox(width: NoktaSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${'driver'.tr()}: $driverName',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: scheme.onSurface,
                                        ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: NoktaColors.tertiaryFixedDim,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '4.9',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: NoktaSpacing.md),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: active.progress,
                            minHeight: 6,
                            backgroundColor: scheme.surfaceContainer,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(height: NoktaSpacing.md),
                        OutlinedButton.icon(
                          onPressed: () => openExternalMaps(
                            lat: active.trip.dropoffLat,
                            lng: active.trip.dropoffLng,
                            label: active.trip.dropoffAddress,
                          ),
                          icon: const Icon(Icons.map_outlined),
                          label: Text('open_in_maps'.tr()),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
              ],
            );
          },
        ),
      ),
    );
  }
}
