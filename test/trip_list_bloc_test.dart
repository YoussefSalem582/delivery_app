import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_app/core/network/fcm_service.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/home/map_view/presentation/bloc/map_bloc.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/trip_usecases.dart';
import 'package:delivery_app/features/trips/trip_list/presentation/bloc/trip_list_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCachedTripsUseCase extends Mock implements GetCachedTripsUseCase {}

class MockGetTripsUseCase extends Mock implements GetTripsUseCase {}

class MockRefreshTripsUseCase extends Mock implements RefreshTripsUseCase {}

class MockNetworkStatus extends Mock implements NetworkStatus {}

void main() {
  late MockGetCachedTripsUseCase getCachedTrips;
  late MockGetTripsUseCase getTrips;
  late MockRefreshTripsUseCase refreshTrips;
  late MockNetworkStatus networkStatus;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      const RequestTripParams(
        pickupAddress: '',
        dropoffAddress: '',
        pickupLat: 0,
        pickupLng: 0,
        dropoffLat: 0,
        dropoffLng: 0,
      ),
    );
    registerFallbackValue(const LatLng(0, 0));
  });

  setUp(() {
    getCachedTrips = MockGetCachedTripsUseCase();
    getTrips = MockGetTripsUseCase();
    refreshTrips = MockRefreshTripsUseCase();
    networkStatus = MockNetworkStatus();
    when(() => networkStatus.isOnline).thenAnswer((_) async => true);
  });

  TripListBloc buildBloc() => TripListBloc(
        getCachedTrips: getCachedTrips,
        getTrips: getTrips,
        refreshTrips: refreshTrips,
        networkStatus: networkStatus,
      );

  group('TripListBloc', () {
    final trips = [
      TripEntity(
        id: '1',
        pickupAddress: 'A',
        dropoffAddress: 'B',
        pickupLat: 1,
        pickupLng: 1,
        dropoffLat: 2,
        dropoffLng: 2,
        status: TripStatus.requested,
        fare: 10,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    ];

    blocTest<TripListBloc, TripListState>(
      'emits loaded trips when repository returns data',
      build: () {
        when(() => getCachedTrips(any())).thenAnswer((_) async => Right(trips));
        when(() => getTrips(any())).thenAnswer((_) async => Right(trips));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const TripListLoadRequested()),
      expect: () => [
        const TripListLoading(),
        TripListLoaded(trips: trips, isOffline: false),
      ],
    );

    final cachedTrips = [trips.first.copyWith(id: 'cached')];
    final freshTrips = [trips.first.copyWith(id: 'fresh')];

    blocTest<TripListBloc, TripListState>(
      'emits cached trips before remote refresh when cache differs',
      build: () {
        when(() => getCachedTrips(any()))
            .thenAnswer((_) async => Right(cachedTrips));
        when(() => getTrips(any())).thenAnswer((_) async => Right(freshTrips));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const TripListLoadRequested()),
      expect: () => [
        const TripListLoading(),
        TripListLoaded(trips: cachedTrips, isOffline: false),
        TripListLoaded(trips: freshTrips, isOffline: false),
      ],
    );
  });

  group('RequestRideBloc', () {
    late MockFcmService fcmService;
    late MockRequestTripUseCase requestTrip;

    setUp(() {
      fcmService = MockFcmService();
      requestTrip = MockRequestTripUseCase();
      when(
        () => fcmService.simulateTripNotification(
          title: any(named: 'title'),
          body: any(named: 'body'),
          tripId: any(named: 'tripId'),
        ),
      ).thenAnswer((_) async {});
    });

    blocTest<RequestRideBloc, RequestRideState>(
      'emits success when trip is created',
      build: () {
        final trip = TripEntity(
          id: 'new',
          pickupAddress: 'A',
          dropoffAddress: 'B',
          pickupLat: 1,
          pickupLng: 1,
          dropoffLat: 2,
          dropoffLng: 2,
          status: TripStatus.accepted,
          fare: 75,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );
        when(() => requestTrip(any())).thenAnswer((_) async => Right(trip));
        return RequestRideBloc(
          requestTrip: requestTrip,
          fcmService: fcmService,
        );
      },
      act: (bloc) => bloc.add(
        const RequestRideSubmitted(
          pickupAddress: 'A',
          dropoffAddress: 'B',
          pickupLat: 1,
          pickupLng: 1,
          dropoffLat: 2,
          dropoffLng: 2,
        ),
      ),
      expect: () => [
        const RequestRideLoading(),
        isA<RequestRideSuccess>(),
      ],
    );
  });
}

class MockRequestTripUseCase extends Mock implements RequestTripUseCase {}

class MockFcmService extends Mock implements FcmService {}
