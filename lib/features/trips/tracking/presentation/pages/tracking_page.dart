import 'package:delivery_app/features/trips/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:delivery_app/features/trips/tracking/presentation/pages/live_tracking_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return LiveTrackingPage(
      tripId: tripId,
      titleKey: 'tracking_title',
      role: TrackingRole.rider,
      onBack: () => context.pop(),
    );
  }
}
