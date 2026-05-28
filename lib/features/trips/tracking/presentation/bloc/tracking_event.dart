part of 'tracking_bloc.dart';

abstract class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object?> get props => [];
}

class TrackingLoadRequested extends TrackingEvent {
  const TrackingLoadRequested(
    this.tripId, {
    this.role = TrackingRole.rider,
  });

  final String tripId;
  final TrackingRole role;

  @override
  List<Object?> get props => [tripId, role];
}

class TrackingTick extends TrackingEvent {
  const TrackingTick(this.now);

  final DateTime now;

  @override
  List<Object?> get props => [now];
}

class TrackingStatusPollRequested extends TrackingEvent {
  const TrackingStatusPollRequested();
}

class TrackingStopped extends TrackingEvent {
  const TrackingStopped();
}

class TrackingDriverStatusRequested extends TrackingEvent {
  const TrackingDriverStatusRequested({
    required this.tripId,
    required this.status,
  });

  final String tripId;
  final TripStatus status;

  @override
  List<Object?> get props => [tripId, status];
}
