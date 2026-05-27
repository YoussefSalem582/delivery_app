import 'package:delivery_app/core/utils/map_config.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/delivery_map.dart';
import 'package:delivery_app/core/widgets/skeleton_trip_card.dart';
import 'package:delivery_app/features/trips/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:delivery_app/features/trips/tracking/presentation/widgets/tracking_bottom_sheet.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key, required this.tripId});

  final String tripId;

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final _mapKey = GlobalKey<DeliveryMapState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<TrackingBloc>()..add(TrackingLoadRequested(widget.tripId)),
      child: BlocListener<TrackingBloc, TrackingState>(
        listenWhen: (previous, current) => current is TrackingError,
        listener: (context, state) {
          if (state is TrackingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message.tr())),
            );
          }
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: Material(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                shape: const CircleBorder(),
                elevation: 2,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
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
              if (state is TrackingError) {
                return ErrorView(
                  message: state.message,
                  onRetry: () => context.read<TrackingBloc>().add(
                        TrackingLoadRequested(widget.tripId),
                      ),
                );
              }

              if (state is TrackingLoading || state is TrackingInitial) {
                return Skeletonizer(
                  enabled: true,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: const [SkeletonTripCard()],
                  ),
                );
              }

              final mapData = _MapTrackingData.fromState(state);
              if (mapData == null) {
                return const SizedBox.shrink();
              }

              final scheme = Theme.of(context).colorScheme;

              return Stack(
                children: [
                  DeliveryMap(
                    key: _mapKey,
                    center: mapData.driverPosition,
                    zoom: MapConfig.defaultZoom,
                    followCenter: state is TrackingActive,
                    fitRouteBounds: true,
                    traveledRoute: mapData.traveledRoute,
                    remainingRoute: mapData.remainingRoute,
                    markers: [
                      MapMarkerData(
                        point: mapData.route.first,
                        color: scheme.secondary,
                        icon: Icons.trip_origin,
                      ),
                      MapMarkerData(
                        point: mapData.driverPosition,
                        color: scheme.primary,
                        icon: Icons.local_taxi,
                        size: 36,
                        animate: state is TrackingActive,
                        rotation: mapData.driverBearing,
                      ),
                      MapMarkerData(
                        point: mapData.route.last,
                        color: scheme.error,
                        icon: Icons.location_on,
                      ),
                    ],
                  ),
                  Positioned(
                    right: AppSpacing.md,
                    bottom: 220,
                    child: FloatingActionButton(
                      onPressed: () =>
                          _mapKey.currentState?.recenter(mapData.driverPosition),
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: SafeArea(
                      top: false,
                      child: TrackingBottomSheet(
                        state: state,
                        tripId: widget.tripId,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MapTrackingData {
  const _MapTrackingData({
    required this.route,
    required this.driverPosition,
    required this.driverBearing,
    required this.traveledRoute,
    required this.remainingRoute,
  });

  final List<LatLng> route;
  final LatLng driverPosition;
  final double driverBearing;
  final List<LatLng> traveledRoute;
  final List<LatLng> remainingRoute;

  static _MapTrackingData? fromState(TrackingState state) {
    return switch (state) {
      TrackingActive active => _MapTrackingData(
          route: active.route,
          driverPosition: active.driverPosition,
          driverBearing: active.driverBearing,
          traveledRoute: active.traveledRoute,
          remainingRoute: active.remainingRoute,
        ),
      TrackingCompleted completed => _MapTrackingData(
          route: completed.route,
          driverPosition: completed.driverPosition,
          driverBearing: completed.driverBearing,
          traveledRoute: completed.traveledRoute,
          remainingRoute: completed.remainingRoute,
        ),
      _ => null,
    };
  }
}
