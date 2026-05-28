import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/features/driver/shared/domain/repositories/driver_trip_repository.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_extensions.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_snapshot.dart';
import 'package:delivery_app/features/trips/shared/domain/repositories/trip_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'driver_jobs_event.dart';
part 'driver_jobs_state.dart';

class DriverJobsBloc extends Bloc<DriverJobsEvent, DriverJobsState> {
  DriverJobsBloc({
    required DriverTripRepository driverTripRepository,
    required TripRepository tripRepository,
    required NetworkStatus networkStatus,
  }) : _driverTripRepository = driverTripRepository,
       _tripRepository = tripRepository,
       _networkStatus = networkStatus,
       super(const DriverJobsInitial()) {
    on<DriverJobsLoadRequested>(_onLoad);
    on<DriverJobsRefreshRequested>(_onRefresh);
    on<DriverJobsCacheSyncRequested>(_onCacheSync);
  }

  final DriverTripRepository _driverTripRepository;
  final TripRepository _tripRepository;
  final NetworkStatus _networkStatus;

  Future<void> _onLoad(
    DriverJobsLoadRequested event,
    Emitter<DriverJobsState> emit,
  ) async {
    emit(const DriverJobsLoading());
    final isOffline = !(await _networkStatus.isOnline);
    final cached = _driverTripRepository.getCachedDriverTrips(event.driverId);
    if (cached.isNotEmpty) {
      emit(
        DriverJobsLoaded(
          driverId: event.driverId,
          trips: cached,
          isOffline: isOffline,
        ),
      );
    }

    try {
      final remoteTrips = await _tripRepository.getTrips();
      final trips = TripQuery.forDriver(remoteTrips, event.driverId);
      emit(
        DriverJobsLoaded(
          driverId: event.driverId,
          trips: trips,
          isOffline: isOffline,
        ),
      );
    } catch (e) {
      emit(DriverJobsError(e.toString()));
    }
  }

  Future<void> _onRefresh(
    DriverJobsRefreshRequested event,
    Emitter<DriverJobsState> emit,
  ) async {
    final current = state;
    if (current is DriverJobsLoaded) {
      emit(current.copyWith(isRefreshing: true));
    }

    final isOffline = !(await _networkStatus.isOnline);
    try {
      final remoteTrips = await _tripRepository.getTrips(forceRefresh: true);
      final trips = TripQuery.forDriver(remoteTrips, event.driverId);
      emit(
        DriverJobsLoaded(
          driverId: event.driverId,
          trips: trips,
          isOffline: isOffline,
        ),
      );
    } catch (e) {
      emit(DriverJobsError(e.toString()));
    }
  }

  Future<void> _onCacheSync(
    DriverJobsCacheSyncRequested event,
    Emitter<DriverJobsState> emit,
  ) async {
    final current = state;
    final cached = _driverTripRepository.getCachedDriverTrips(event.driverId);
    final isOffline = !(await _networkStatus.isOnline);

    if (current is DriverJobsLoaded) {
      if (tripsSnapshotEquals(current.trips, cached) &&
          current.isOffline == isOffline) {
        return;
      }
      emit(current.copyWith(trips: cached, isOffline: isOffline));
      return;
    }

    if (cached.isNotEmpty) {
      emit(
        DriverJobsLoaded(
          driverId: event.driverId,
          trips: cached,
          isOffline: isOffline,
        ),
      );
      return;
    }

    if (current is! DriverJobsLoaded && current is! DriverJobsLoading) {
      add(DriverJobsLoadRequested(driverId: event.driverId));
    }
  }
}
