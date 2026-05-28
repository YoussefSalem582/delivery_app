import 'package:delivery_app/core/utils/map_config.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/delivery_map.dart';
import 'package:delivery_app/core/widgets/map_trip_scaffold.dart';
import 'package:delivery_app/features/driver/offers/presentation/bloc/driver_offers_bloc.dart';
import 'package:delivery_app/features/driver/offers/presentation/cubit/driver_offer_preview_cubit.dart';
import 'package:delivery_app/features/driver/offers/presentation/widgets/driver_offer_bottom_sheet.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class DriverOfferPreviewPage extends StatefulWidget {
  const DriverOfferPreviewPage({super.key, required this.trip});

  final TripEntity trip;

  @override
  State<DriverOfferPreviewPage> createState() => _DriverOfferPreviewPageState();
}

class _DriverOfferPreviewPageState extends State<DriverOfferPreviewPage> {
  final _mapKey = GlobalKey<DeliveryMapState>();
  late final DriverOfferPreviewCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = DriverOfferPreviewCubit(
      routeService: sl(),
      getRiderForTrip: sl(),
    )..load(widget.trip);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _accept() {
    context.read<DriverOffersBloc>().add(
          DriverOffersAcceptRequested(tripId: widget.trip.id),
        );
  }

  void _decline() {
    context.read<DriverOffersBloc>().add(
          DriverOffersDeclineRequested(tripId: widget.trip.id),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DriverOffersBloc, DriverOffersState>(
          listenWhen: (previous, current) =>
              current is DriverOffersLoaded &&
              current.acceptedTripId == widget.trip.id,
          listener: (context, state) {
            Navigator.of(context).pop();
          },
        ),
      ],
      child: BlocBuilder<DriverOffersBloc, DriverOffersState>(
        builder: (context, offersState) {
          final isBusy = offersState is DriverOffersLoaded &&
              offersState.isActionInProgress;

          return BlocBuilder<DriverOfferPreviewCubit, DriverOfferPreviewState>(
            bloc: _cubit,
            builder: (context, state) {
              final title = 'driver_offer_preview_title'.tr();

              if (state is DriverOfferPreviewError) {
                return MapTripScaffold(
                  title: title,
                  onBack: () => Navigator.of(context).pop(),
                  useOverlayAppBar: false,
                  body: ErrorView(
                    message: state.message,
                    onRetry: () => _cubit.load(widget.trip),
                  ),
                );
              }

              if (state is! DriverOfferPreviewLoaded) {
                return MapTripScaffold(
                  title: title,
                  onBack: () => Navigator.of(context).pop(),
                  useOverlayAppBar: false,
                  body: LoadingView(message: 'loading'),
                );
              }

              final plan = state.routePlan;
              final pickup = LatLng(widget.trip.pickupLat, widget.trip.pickupLng);
              final dropoff =
                  LatLng(widget.trip.dropoffLat, widget.trip.dropoffLng);
              final scheme = Theme.of(context).colorScheme;

              return MapTripScaffold(
                title: title,
                onBack: () => Navigator.of(context).pop(),
                body: Stack(
                  children: [
                    Positioned.fill(
                      child: DeliveryMap(
                        key: _mapKey,
                        center: pickup,
                        zoom: MapConfig.defaultZoom,
                        fitRouteBounds: true,
                        remainingRoute: plan.fullRoute,
                        markers: [
                          MapMarkerData(
                            point: plan.driverStart,
                            color: scheme.tertiary,
                            icon: Icons.local_taxi_outlined,
                            size: 32,
                          ),
                          MapMarkerData(
                            point: pickup,
                            color: scheme.secondary,
                            icon: Icons.trip_origin,
                          ),
                          MapMarkerData(
                            point: dropoff,
                            color: scheme.error,
                            icon: Icons.location_on,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: AppSpacing.md,
                      bottom: 280,
                      child: FloatingActionButton(
                        onPressed: () =>
                            _mapKey.currentState?.recenter(pickup),
                        child: const Icon(Icons.my_location),
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      bottom: AppSpacing.md,
                      child: SafeArea(
                        top: false,
                        child: DriverOfferBottomSheet(
                          loaded: state,
                          isBusy: isBusy,
                          onAccept: _accept,
                          onDecline: _decline,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
