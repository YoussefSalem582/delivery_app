part of 'trip_detail_bloc.dart';

abstract class TripDetailState extends Equatable {
  const TripDetailState();
  @override
  List<Object?> get props => [];
}

class TripDetailInitial extends TripDetailState {
  const TripDetailInitial();
}

class TripDetailLoading extends TripDetailState {
  const TripDetailLoading();
}

class TripDetailLoaded extends TripDetailState {
  const TripDetailLoaded(this.trip);
  final TripEntity trip;
  @override
  List<Object?> get props => [trip];
}

class TripDetailError extends TripDetailState {
  const TripDetailError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
