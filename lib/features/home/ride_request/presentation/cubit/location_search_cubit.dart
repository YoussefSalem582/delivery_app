import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delivery_app/core/network/connectivity_cubit.dart';
import 'package:delivery_app/features/home/ride_request/presentation/cubit/location_search_state.dart';
import 'package:delivery_app/features/home/shared/domain/usecases/reverse_geocode.dart';
import 'package:delivery_app/features/home/shared/domain/usecases/search_places.dart';

class LocationSearchCubit extends Cubit<LocationSearchState> {
  LocationSearchCubit({
    required SearchPlacesUseCase searchPlaces,
    required ReverseGeocodeUseCase reverseGeocode,
    required ConnectivityCubit connectivityCubit,
  })  : _searchPlaces = searchPlaces,
        _reverseGeocode = reverseGeocode,
        _connectivityCubit = connectivityCubit,
        super(const LocationSearchState());

  final SearchPlacesUseCase _searchPlaces;
  final ReverseGeocodeUseCase _reverseGeocode;
  final ConnectivityCubit _connectivityCubit;

  static const _debounceDuration = Duration(milliseconds: 400);

  Timer? _debounceTimer;
  CancelToken? _cancelToken;
  int _requestGeneration = 0;

  void setActiveField(LocationSearchField field) {
    emit(state.copyWith(activeField: field, clearError: true));
  }

  Future<void> reverseGeocodePickup({
    required double lat,
    required double lng,
    required String languageCode,
  }) async {
    if (!_connectivityCubit.isOnline) {
      emit(
        state.copyWith(
          status: LocationSearchStatus.offline,
          errorMessage: 'location_search_offline',
        ),
      );
      return;
    }

    _cancelInFlight();
    final generation = ++_requestGeneration;
    emit(state.copyWith(status: LocationSearchStatus.loading, clearError: true));

    final result = await _reverseGeocode(
      ReverseGeocodeParams(
        lat: lat,
        lng: lng,
        languageCode: languageCode,
        cancelToken: _cancelToken,
      ),
    );

    if (generation != _requestGeneration || isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LocationSearchStatus.error,
          errorMessage: 'location_search_error',
        ),
      ),
      (place) => emit(
        state.copyWith(
          status: LocationSearchStatus.idle,
          reverseGeocodedPickup: place,
          clearError: true,
          clearSuggestions: true,
        ),
      ),
    );
  }

  void search({
    required String query,
    required double biasLat,
    required double biasLng,
    required String languageCode,
  }) {
    _debounceTimer?.cancel();

    if (!_connectivityCubit.isOnline) {
      emit(
        state.copyWith(
          status: LocationSearchStatus.offline,
          suggestions: const [],
          errorMessage: 'location_search_offline',
        ),
      );
      return;
    }

    final normalized = query.trim();
    if (normalized.isEmpty) {
      _cancelInFlight();
      emit(
        state.copyWith(
          status: LocationSearchStatus.idle,
          suggestions: const [],
          clearError: true,
          clearSuggestions: true,
        ),
      );
      return;
    }

    emit(state.copyWith(status: LocationSearchStatus.loading, clearError: true));

    _debounceTimer = Timer(_debounceDuration, () {
      unawaited(
        _performSearch(
          query: normalized,
          biasLat: biasLat,
          biasLng: biasLng,
          languageCode: languageCode,
        ),
      );
    });
  }

  Future<void> searchImmediately({
    required String query,
    required double biasLat,
    required double biasLng,
    required String languageCode,
  }) async {
    _debounceTimer?.cancel();

    if (!_connectivityCubit.isOnline) {
      emit(
        state.copyWith(
          status: LocationSearchStatus.offline,
          suggestions: const [],
          errorMessage: 'location_search_offline',
        ),
      );
      return;
    }

    await _performSearch(
      query: query.trim(),
      biasLat: biasLat,
      biasLng: biasLng,
      languageCode: languageCode,
    );
  }

  Future<void> _performSearch({
    required String query,
    required double biasLat,
    required double biasLng,
    required String languageCode,
  }) async {
    if (query.isEmpty) return;

    _cancelInFlight();
    final generation = ++_requestGeneration;

    final result = await _searchPlaces(
      SearchPlacesParams(
        query: query,
        biasLat: biasLat,
        biasLng: biasLng,
        languageCode: languageCode,
        cancelToken: _cancelToken,
      ),
    );

    if (generation != _requestGeneration || isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LocationSearchStatus.error,
          suggestions: const [],
          errorMessage: 'location_search_error',
        ),
      ),
      (places) {
        if (places.isEmpty) {
          emit(
            state.copyWith(
              status: LocationSearchStatus.empty,
              suggestions: const [],
              clearError: true,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: LocationSearchStatus.loaded,
              suggestions: places,
              clearError: true,
            ),
          );
        }
      },
    );
  }

  void clearSuggestions() {
    emit(state.copyWith(clearSuggestions: true, status: LocationSearchStatus.idle));
  }

  void _cancelInFlight() {
    _cancelToken?.cancel();
    _cancelToken = CancelToken();
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _cancelInFlight();
    return super.close();
  }
}
