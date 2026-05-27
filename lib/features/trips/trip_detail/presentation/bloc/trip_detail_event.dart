part of 'trip_detail_bloc.dart';

abstract class TripDetailEvent extends Equatable {
  const TripDetailEvent();
  @override
  List<Object?> get props => [];
}

class TripDetailLoadRequested extends TripDetailEvent {
  const TripDetailLoadRequested(this.tripId);
  final String tripId;
  @override
  List<Object?> get props => [tripId];
}

class TripDetailStatusUpdateRequested extends TripDetailEvent {
  const TripDetailStatusUpdateRequested(this.tripId, this.status);
  final String tripId;
  final TripStatus status;
  @override
  List<Object?> get props => [tripId, status];
}

class TripDetailCompleteRequested extends TripDetailEvent {
  const TripDetailCompleteRequested(this.tripId);
  final String tripId;
  @override
  List<Object?> get props => [tripId];
}
