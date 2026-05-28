import 'package:delivery_app/core/utils/map_config.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/delivery_map.dart';
import 'package:delivery_app/core/widgets/map_trip_scaffold.dart';
import 'package:delivery_app/core/widgets/skeleton_trip_card.dart';
import 'package:delivery_app/features/trips/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:delivery_app/features/trips/tracking/presentation/widgets/tracking_bottom_sheet.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:skeletonizer/skeletonizer.dart';

class LiveTrackingPage extends StatefulWidget {
  const LiveTrackingPage({
    super.key,
    required this.tripId,
    required this.titleKey,
    required this.role,
    required this.onBack,
    this.onDriverTripCompleted,
  });

  final String tripId;
  final String titleKey;
  final TrackingRole role;
  final VoidCallback onBack;
  final VoidCallback? onDriverTripCompleted;

  @override
  State<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> {
  final _mapKey = GlobalKey<DeliveryMapState>();
  late final TrackingBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<TrackingBloc>()
      ..add(
        TrackingLoadRequested(
          widget.tripId,
          role: widget.role,
        ),
      );
  }

  @override
  void dispose() {
    _bloc.add(const TrackingStopped());
    _bloc.close();
    super.dispose();
  }

  void _reload() {
    _bloc.add(
      TrackingLoadRequested(
        widget.tripId,
        role: widget.role,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<TrackingBloc, TrackingState>(
        listenWhen: (previous, current) =>
            current is TrackingError ||
            (widget.role == TrackingRole.driver &&
                current is TrackingCompleted),
        listener: (context, state) {
          if (state is TrackingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message.tr())),
            );
          }
          if (state is TrackingCompleted &&
              widget.role == TrackingRole.driver) {
            widget.onDriverTripCompleted?.call();
          }
        },
        child: BlocBuilder<TrackingBloc, TrackingState>(
          builder: (context, state) {
            final title = widget.titleKey.tr();

            if (state is TrackingError) {
              return MapTripScaffold(
                title: title,
                onBack: widget.onBack,
                useOverlayAppBar: false,
                body: ErrorView(
                  message: state.message,
                  onRetry: _reload,
                ),
              );
            }

            if (state is TrackingLoading || state is TrackingInitial) {
              return MapTripScaffold(
                title: title,
                onBack: widget.onBack,
                useOverlayAppBar: false,
                body: Skeletonizer(
                  enabled: true,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: const [SkeletonTripCard()],
                  ),
                ),
              );
            }

            final mapData = MapTrackingData.fromState(state);
            if (mapData == null) {
              return const SizedBox.shrink();
            }

            final scheme = Theme.of(context).colorScheme;

            return MapTripScaffold(
              title: title,
              onBack: widget.onBack,
              body: Stack(
                children: [
                  Positioned.fill(
                    child: DeliveryMap(
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
                        role: widget.role,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class MapTrackingData {
  const MapTrackingData({
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

  static MapTrackingData? fromState(TrackingState state) {
    return switch (state) {
      TrackingActive active => MapTrackingData(
          route: active.route,
          driverPosition: active.driverPosition,
          driverBearing: active.driverBearing,
          traveledRoute: active.traveledRoute,
          remainingRoute: active.remainingRoute,
        ),
      TrackingCompleted completed => MapTrackingData(
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
