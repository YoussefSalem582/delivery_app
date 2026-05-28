import 'package:delivery_app/features/trips/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:delivery_app/features/trips/tracking/presentation/pages/live_tracking_page.dart';
import 'package:flutter/material.dart';

class DriverActiveTripPage extends StatelessWidget {
  const DriverActiveTripPage({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return LiveTrackingPage(
      tripId: tripId,
      titleKey: 'driver_active_trip',
      role: TrackingRole.driver,
      onBack: () => Navigator.of(context).pop(),
      onDriverTripCompleted: () => Navigator.of(context).pop(true),
    );
  }
}
