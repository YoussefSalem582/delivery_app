import 'dart:async';

import 'package:delivery_app/core/utils/map_config.dart';
import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/delivery_map.dart';
import 'package:delivery_app/features/driver/active_trip/presentation/bloc/driver_active_trip_bloc.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/presentation/widgets/trip_card.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class DriverActiveTripPage extends StatefulWidget {
  const DriverActiveTripPage({super.key, required this.tripId});

  final String tripId;

  @override
  State<DriverActiveTripPage> createState() => _DriverActiveTripPageState();
}

class _DriverActiveTripPageState extends State<DriverActiveTripPage> {
  Timer? _locationTimer;
  double _routeProgress = 0;

  @override
  void initState() {
    super.initState();
    _locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _publishMockLocation(),
    );
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _publishMockLocation() {
    if (!mounted) return;

    final bloc = context.read<DriverActiveTripBloc>();
    final state = bloc.state;
    if (state is! DriverActiveTripLoaded) return;

    final trip = state.trip;
    if (trip.status == TripStatus.completed ||
        trip.status == TripStatus.cancelled) {
      return;
    }

    _routeProgress = (_routeProgress + 0.04).clamp(0.0, 1.0);
    final lat =
        trip.pickupLat + (trip.dropoffLat - trip.pickupLat) * _routeProgress;
    final lng =
        trip.pickupLng + (trip.dropoffLng - trip.pickupLng) * _routeProgress;

    bloc.add(
      DriverActiveTripLocationUpdateRequested(
        tripId: widget.tripId,
        lat: lat,
        lng: lng,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('driver_active_trip'.tr())),
      body: BlocConsumer<DriverActiveTripBloc, DriverActiveTripState>(
        listener: (context, state) {
          if (state is DriverActiveTripLoaded &&
              state.trip.status == TripStatus.completed) {
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          if (state is DriverActiveTripLoading) {
            return LoadingView(message: 'loading');
          }
          if (state is DriverActiveTripError) {
            return ErrorView(
              message: state.message.tr(),
              onRetry: () => context.read<DriverActiveTripBloc>().add(
                DriverActiveTripLoadRequested(tripId: widget.tripId),
              ),
            );
          }
          if (state is DriverActiveTripLoaded) {
            final trip = state.trip;
            final driverPoint = trip.driverLat != null && trip.driverLng != null
                ? LatLng(trip.driverLat!, trip.driverLng!)
                : LatLng(trip.pickupLat, trip.pickupLng);
            final center = driverPoint;

            return Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      DeliveryMap(
                        center: center,
                        zoom: MapConfig.defaultZoom,
                        markers: [
                          MapMarkerData(
                            point: LatLng(trip.pickupLat, trip.pickupLng),
                            color: AppColors.primary,
                          ),
                          MapMarkerData(
                            point: LatLng(trip.dropoffLat, trip.dropoffLng),
                            color: AppColors.error,
                          ),
                          MapMarkerData(
                            point: driverPoint,
                            color: AppColors.secondary,
                          ),
                        ],
                        polylines: [
                          LatLng(trip.pickupLat, trip.pickupLng),
                          LatLng(trip.dropoffLat, trip.dropoffLng),
                        ],
                      ),
                      Positioned(
                        left: AppSpacing.md,
                        right: AppSpacing.md,
                        bottom: AppSpacing.md,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: TripHeroCard(
                              trip: trip,
                              highlighted: true,
                              liveStatus: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.canMarkArrived)
                          AppButton(
                            label: 'driver_mark_arrived'.tr(),
                            loading: state.isUpdating,
                            onPressed: state.isUpdating
                                ? null
                                : () =>
                                      context.read<DriverActiveTripBloc>().add(
                                        DriverActiveTripArrivedRequested(
                                          tripId: widget.tripId,
                                        ),
                                      ),
                          ),
                        if (state.canStartTrip) ...[
                          AppButton(
                            label: 'driver_start_trip'.tr(),
                            loading: state.isUpdating,
                            onPressed: state.isUpdating
                                ? null
                                : () =>
                                      context.read<DriverActiveTripBloc>().add(
                                        DriverActiveTripStartRequested(
                                          tripId: widget.tripId,
                                        ),
                                      ),
                          ),
                        ],
                        if (state.canCompleteTrip)
                          AppButton(
                            label: 'driver_complete_trip'.tr(),
                            loading: state.isUpdating,
                            onPressed: state.isUpdating
                                ? null
                                : () =>
                                      context.read<DriverActiveTripBloc>().add(
                                        DriverActiveTripCompleteRequested(
                                          tripId: widget.tripId,
                                        ),
                                      ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
