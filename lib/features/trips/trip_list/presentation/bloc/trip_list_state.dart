part of 'trip_list_bloc.dart';

class TripListState extends Equatable {
  const TripListState();
  @override
  List<Object?> get props => [];
}

class TripListInitial extends TripListState {
  const TripListInitial();
}

class TripListLoading extends TripListState {
  const TripListLoading();
}

class TripListLoaded extends TripListState {
  const TripListLoaded({
    required this.trips,
    this.isOffline = false,
    this.isRefreshing = false,
  });

  final List<TripEntity> trips;
  final bool isOffline;
  final bool isRefreshing;

  TripListLoaded copyWith({
    List<TripEntity>? trips,
    bool? isOffline,
    bool? isRefreshing,
  }) {
    return TripListLoaded(
      trips: trips ?? this.trips,
      isOffline: isOffline ?? this.isOffline,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [trips, isOffline, isRefreshing];
}

class TripListError extends TripListState {
  const TripListError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
