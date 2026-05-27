import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delivery_app/core/error/failures.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_extensions.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/trip_usecases.dart';

part 'trip_list_event.dart';
part 'trip_list_state.dart';

class TripListBloc extends Bloc<TripListEvent, TripListState> {
  TripListBloc({
    required GetCachedTripsUseCase getCachedTrips,
    required GetTripsUseCase getTrips,
    required RefreshTripsUseCase refreshTrips,
    required NetworkStatus networkStatus,
  })  : _getCachedTrips = getCachedTrips,
        _getTrips = getTrips,
        _refreshTrips = refreshTrips,
        _networkStatus = networkStatus,
        super(const TripListInitial()) {
    on<TripListLoadRequested>(_onLoad);
    on<TripListRefreshRequested>(_onRefresh);
  }

  final GetCachedTripsUseCase _getCachedTrips;
  final GetTripsUseCase _getTrips;
  final RefreshTripsUseCase _refreshTrips;
  final NetworkStatus _networkStatus;

  Future<void> _onLoad(
    TripListLoadRequested event,
    Emitter<TripListState> emit,
  ) async {
    emit(const TripListLoading());
    final isOffline = !(await _networkStatus.isOnline);
    final cachedResult = await _getCachedTrips(const NoParams());
    cachedResult.fold(
      (_) {},
      (cached) {
        if (cached.isNotEmpty) {
          emit(TripListLoaded(trips: cached, isOffline: isOffline));
        }
      },
    );
    final result = await _getTrips(const NoParams());
    result.fold(
      (Failure failure) => emit(TripListError(failure.message)),
      (trips) => emit(TripListLoaded(trips: trips, isOffline: isOffline)),
    );
  }

  Future<void> _onRefresh(
    TripListRefreshRequested event,
    Emitter<TripListState> emit,
  ) async {
    final current = state;
    if (current is TripListLoaded) {
      emit(current.copyWith(isRefreshing: true));
    }
    final result = await _refreshTrips(const NoParams());
    final isOffline = !(await _networkStatus.isOnline);
    result.fold(
      (Failure failure) => emit(TripListError(failure.message)),
      (trips) => emit(TripListLoaded(trips: trips, isOffline: isOffline)),
    );
  }
}
