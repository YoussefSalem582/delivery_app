part of 'tracking_bloc.dart';

abstract class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object?> get props => [];
}

class TrackingLoadRequested extends TrackingEvent {
  const TrackingLoadRequested(this.tripId);

  final String tripId;

  @override
  List<Object?> get props => [tripId];
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
