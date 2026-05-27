import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/architecture/entities/trip_entity.dart';
import 'package:delivery_app/core/architecture/repositories/trip_repository.dart';
import 'package:delivery_app/core/utils/map_config.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/delivery_map.dart';
import 'package:delivery_app/features/home/presentation/bloc/map_bloc.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

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
        body: LoadingView(message: 'loading'),
      );
    }

    return BlocProvider.value(
      value: _trackingBloc,
      child: Scaffold(
        appBar: AppBar(title: Text('tracking_title'.tr())),
        body: BlocBuilder<TrackingBloc, TrackingState>(
          builder: (context, state) {
            if (state is! TrackingActive) {
              return LoadingView(message: 'loading');
            }

            final active = state;
            final scheme = Theme.of(context).colorScheme;

            return Stack(
              children: [
                DeliveryMap(
                  center: active.driverPosition,
                  zoom: MapConfig.defaultZoom,
                  followCenter: true,
                  polylines: active.route,
                  markers: [
                    MapMarkerData(
                      point: active.route.first,
                      color: Colors.green,
                      icon: Icons.trip_origin,
                    ),
                    MapMarkerData(
                      point: active.driverPosition,
                      color: scheme.primary,
                      icon: Icons.local_taxi,
                      size: 40,
                    ),
                    MapMarkerData(
                      point: active.route.last,
                      color: scheme.error,
                      icon: Icons.location_on,
                    ),
                  ],
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(blurRadius: 12, color: Colors.black26),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: Lottie.asset(
                                'assets/lottie/loading.json',
                                animate: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    active.trip.driverName ?? 'driver'.tr(),
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(tripStatusLabel(active.trip.status)),
                                ],
                              ),
                            ),
                            Text(
                              '${active.etaMinutes} ${'minutes'.tr()}',
                              style:
                                  Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(value: active.progress),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
