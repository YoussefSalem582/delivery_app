part of 'driver_jobs_bloc.dart';

abstract class DriverJobsEvent extends Equatable {
  const DriverJobsEvent();

  @override
  List<Object?> get props => [];
}

class DriverJobsLoadRequested extends DriverJobsEvent {
  const DriverJobsLoadRequested({required this.driverId});

  final String driverId;

  @override
  List<Object?> get props => [driverId];
}

class DriverJobsRefreshRequested extends DriverJobsEvent {
  const DriverJobsRefreshRequested({required this.driverId});

  final String driverId;

  @override
  List<Object?> get props => [driverId];
}

/// Re-reads driver trips from Hive without a loading state or remote force-refresh.
class DriverJobsCacheSyncRequested extends DriverJobsEvent {
  const DriverJobsCacheSyncRequested({required this.driverId});

  final String driverId;

  @override
  List<Object?> get props => [driverId];
}
