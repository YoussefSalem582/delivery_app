import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delivery_app/core/error/failures.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/auth/shared/domain/repositories/auth_repository.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_extensions.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_snapshot.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/trip_usecases.dart';

part 'trip_list_event.dart';
part 'trip_list_state.dart';

class TripListBloc extends Bloc<TripListEvent, TripListState> {
  TripListBloc({
    required GetCachedTripsUseCase getCachedTrips,
    required GetRiderTripsUseCase getRiderTrips,
    required RefreshTripsUseCase refreshTrips,
    required NetworkStatus networkStatus,
    required AuthRepository authRepository,
  })  : _getCachedTrips = getCachedTrips,
        _getRiderTrips = getRiderTrips,
        _refreshTrips = refreshTrips,
        _networkStatus = networkStatus,
        _authRepository = authRepository,
        super(const TripListInitial()) {
    on<TripListLoadRequested>(_onLoad);
    on<TripListRefreshRequested>(_onRefresh);
    on<TripListCacheSyncRequested>(_onCacheSync);
  }

  final GetCachedTripsUseCase _getCachedTrips;
  final GetRiderTripsUseCase _getRiderTrips;
  final RefreshTripsUseCase _refreshTrips;
  final NetworkStatus _networkStatus;
  final AuthRepository _authRepository;

  String get _riderId =>
      _authRepository.cachedUser?.id ?? 'user-001';

  List<TripEntity> _filterRiderTrips(List<TripEntity> trips) {
    return TripQuery.forRider(trips, _riderId);
  }

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
        final riderTrips = _filterRiderTrips(cached);
        if (riderTrips.isNotEmpty) {
          emit(TripListLoaded(trips: riderTrips, isOffline: isOffline));
        }
      },
    );
    final result = await _getRiderTrips(const NoParams());
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
      (trips) => emit(
        TripListLoaded(
          trips: _filterRiderTrips(trips),
          isOffline: isOffline,
        ),
      ),
    );
  }

  Future<void> _onCacheSync(
    TripListCacheSyncRequested event,
    Emitter<TripListState> emit,
  ) async {
    final current = state;
    final cachedResult = await _getCachedTrips(const NoParams());
    final isOffline = !(await _networkStatus.isOnline);

    await cachedResult.fold(
      (_) async {
        if (current is! TripListLoaded) {
          add(const TripListLoadRequested());
        }
      },
      (cached) async {
        final riderTrips = _filterRiderTrips(cached);
        if (current is TripListLoaded) {
          if (tripsSnapshotEquals(current.trips, riderTrips) &&
              current.isOffline == isOffline) {
            return;
          }
          emit(current.copyWith(trips: riderTrips, isOffline: isOffline));
          return;
        }
        if (riderTrips.isNotEmpty) {
          emit(TripListLoaded(trips: riderTrips, isOffline: isOffline));
          return;
        }
        if (current is! TripListLoaded && current is! TripListLoading) {
          add(const TripListLoadRequested());
        }
      },
    );
  }
}
