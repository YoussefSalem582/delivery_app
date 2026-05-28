part of 'driver_jobs_bloc.dart';

class DriverJobsState extends Equatable {
  const DriverJobsState();

  @override
  List<Object?> get props => [];
}

class DriverJobsInitial extends DriverJobsState {
  const DriverJobsInitial();
}

class DriverJobsLoading extends DriverJobsState {
  const DriverJobsLoading();
}

class DriverJobsLoaded extends DriverJobsState {
  const DriverJobsLoaded({
    required this.driverId,
    required this.trips,
    this.isOffline = false,
    this.isRefreshing = false,
  });

  final String driverId;
  final List<TripEntity> trips;
  final bool isOffline;
  final bool isRefreshing;

  TripEntity? get activeTrip => TripQuery.activeDriverTrip(trips, driverId);

  DriverJobsLoaded copyWith({
    String? driverId,
    List<TripEntity>? trips,
    bool? isOffline,
    bool? isRefreshing,
  }) {
    return DriverJobsLoaded(
      driverId: driverId ?? this.driverId,
      trips: trips ?? this.trips,
      isOffline: isOffline ?? this.isOffline,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [driverId, trips, isOffline, isRefreshing];
}

class DriverJobsError extends DriverJobsState {
  const DriverJobsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
