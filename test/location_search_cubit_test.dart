import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_app/core/error/failures.dart';
import 'package:delivery_app/core/network/connectivity_cubit.dart';
import 'package:delivery_app/core/network/connectivity_service.dart';
import 'package:delivery_app/features/home/ride_request/presentation/cubit/location_search_cubit.dart';
import 'package:delivery_app/features/home/ride_request/presentation/cubit/location_search_state.dart';
import 'package:delivery_app/features/home/shared/domain/entities/place_suggestion.dart';
import 'package:delivery_app/features/home/shared/domain/usecases/reverse_geocode.dart';
import 'package:delivery_app/features/home/shared/domain/usecases/search_places.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchPlacesUseCase extends Mock implements SearchPlacesUseCase {}

class MockReverseGeocodeUseCase extends Mock implements ReverseGeocodeUseCase {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockSearchPlacesUseCase searchPlaces;
  late MockReverseGeocodeUseCase reverseGeocode;
  late ConnectivityCubit connectivityCubit;

  const samplePlace = PlaceSuggestion(
    id: '1',
    title: 'City Mall',
    subtitle: 'Cairo',
    lat: 30.05,
    lng: 31.24,
  );

  setUpAll(() {
    registerFallbackValue(
      const SearchPlacesParams(
        query: '',
        biasLat: 0,
        biasLng: 0,
        languageCode: 'en',
      ),
    );
    registerFallbackValue(
      const ReverseGeocodeParams(lat: 0, lng: 0, languageCode: 'en'),
    );
  });
  setUp(() {
    searchPlaces = MockSearchPlacesUseCase();
    reverseGeocode = MockReverseGeocodeUseCase();
    connectivityCubit = ConnectivityCubit(
      service: MockConnectivityService()..stubOnline(),
    );
  });

  tearDown(() async {
    await connectivityCubit.close();
  });

  blocTest<LocationSearchCubit, LocationSearchState>(
    'emits offline when search is requested without connectivity',
    build: () => LocationSearchCubit(
      searchPlaces: searchPlaces,
      reverseGeocode: reverseGeocode,
      connectivityCubit: connectivityCubit,
    ),
    setUp: () async {
      await connectivityCubit.close();
      connectivityCubit = ConnectivityCubit(
        service: MockConnectivityService()..stubOffline(),
      );
    },
    act: (cubit) => cubit.search(
      query: 'mall',
      biasLat: 30.0,
      biasLng: 31.0,
      languageCode: 'en',
    ),
    expect: () => [
      isA<LocationSearchState>().having(
        (s) => s.status,
        'status',
        LocationSearchStatus.offline,
      ),
    ],
    verify: (_) {
      verifyNever(() => searchPlaces(any()));
    },
  );

  blocTest<LocationSearchCubit, LocationSearchState>(
    'debounces search and emits loaded suggestions',
    build: () {
      when(() => searchPlaces(any())).thenAnswer(
        (_) async => const Right([samplePlace]),
      );
      return LocationSearchCubit(
        searchPlaces: searchPlaces,
        reverseGeocode: reverseGeocode,
        connectivityCubit: connectivityCubit,
      );
    },
    act: (cubit) async {
      cubit.search(
        query: 'mall',
        biasLat: 30.0,
        biasLng: 31.0,
        languageCode: 'en',
      );
      await Future<void>.delayed(const Duration(milliseconds: 450));
    },
    expect: () => [
      isA<LocationSearchState>().having(
        (s) => s.status,
        'status',
        LocationSearchStatus.loading,
      ),
      isA<LocationSearchState>()
          .having((s) => s.status, 'status', LocationSearchStatus.loaded)
          .having((s) => s.suggestions, 'suggestions', [samplePlace]),
    ],
  );

  blocTest<LocationSearchCubit, LocationSearchState>(
    'reverseGeocodePickup emits pickup suggestion',
    build: () {
      when(() => reverseGeocode(any())).thenAnswer(
        (_) async => const Right(samplePlace),
      );
      return LocationSearchCubit(
        searchPlaces: searchPlaces,
        reverseGeocode: reverseGeocode,
        connectivityCubit: connectivityCubit,
      );
    },
    act: (cubit) => cubit.reverseGeocodePickup(
      lat: 30.0,
      lng: 31.0,
      languageCode: 'en',
    ),
    expect: () => [
      isA<LocationSearchState>().having(
        (s) => s.status,
        'status',
        LocationSearchStatus.loading,
      ),
      isA<LocationSearchState>().having(
        (s) => s.reverseGeocodedPickup,
        'reverseGeocodedPickup',
        samplePlace,
      ),
    ],
  );

  blocTest<LocationSearchCubit, LocationSearchState>(
    'emits error when reverse geocode fails',
    build: () {
      when(() => reverseGeocode(any())).thenAnswer(
        (_) async => const Left(NetworkFailure()),
      );
      return LocationSearchCubit(
        searchPlaces: searchPlaces,
        reverseGeocode: reverseGeocode,
        connectivityCubit: connectivityCubit,
      );
    },
    act: (cubit) => cubit.reverseGeocodePickup(
      lat: 30.0,
      lng: 31.0,
      languageCode: 'en',
    ),
    expect: () => [
      isA<LocationSearchState>().having(
        (s) => s.status,
        'status',
        LocationSearchStatus.loading,
      ),
      isA<LocationSearchState>().having(
        (s) => s.status,
        'status',
        LocationSearchStatus.error,
      ),
    ],
  );
}

extension on MockConnectivityService {
  void stubOnline() {
    when(() => lastKnownStatus).thenReturn(true);
    when(() => onConnectivityChanged).thenAnswer(
      (_) => const Stream.empty(),
    );
  }

  void stubOffline() {
    when(() => lastKnownStatus).thenReturn(false);
    when(() => onConnectivityChanged).thenAnswer(
      (_) => const Stream.empty(),
    );
  }
}
