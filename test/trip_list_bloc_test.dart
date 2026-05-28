import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_app/core/network/fcm_service.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/auth/shared/domain/entities/user_entity.dart';
import 'package:delivery_app/features/notifications/shared/domain/entities/notification_type.dart';
import 'package:delivery_app/features/auth/shared/domain/repositories/auth_repository.dart';
import 'package:delivery_app/features/home/map_view/presentation/bloc/map_bloc.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/trip_usecases.dart';
import 'package:delivery_app/features/trips/trip_list/presentation/bloc/trip_list_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCachedTripsUseCase extends Mock implements GetCachedTripsUseCase {}

class MockGetRiderTripsUseCase extends Mock implements GetRiderTripsUseCase {}

class MockRefreshTripsUseCase extends Mock implements RefreshTripsUseCase {}

class MockNetworkStatus extends Mock implements NetworkStatus {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockGetCachedTripsUseCase getCachedTrips;
  late MockGetRiderTripsUseCase getRiderTrips;
  late MockRefreshTripsUseCase refreshTrips;
  late MockNetworkStatus networkStatus;
  late MockAuthRepository authRepository;

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
        fare: 0,
      ),
    );
    registerFallbackValue(const LatLng(0, 0));
    registerFallbackValue(NotificationType.tripAccepted);
  });

  setUp(() {
    getCachedTrips = MockGetCachedTripsUseCase();
    getRiderTrips = MockGetRiderTripsUseCase();
    refreshTrips = MockRefreshTripsUseCase();
    networkStatus = MockNetworkStatus();
    authRepository = MockAuthRepository();
    when(() => networkStatus.isOnline).thenAnswer((_) async => true);
    when(() => authRepository.cachedUser).thenReturn(
      UserEntity(
        id: 'user-001',
        name: 'Test',
        email: 't@test.com',
        phone: '+201000000000',
        walletBalance: 100,
      ),
    );
  });

  TripListBloc buildBloc() => TripListBloc(
        getCachedTrips: getCachedTrips,
        getRiderTrips: getRiderTrips,
        refreshTrips: refreshTrips,
        networkStatus: networkStatus,
        authRepository: authRepository,
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
        riderId: 'user-001',
        fare: 10,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    ];

    blocTest<TripListBloc, TripListState>(
      'emits loaded trips when repository returns data',
      build: () {
        when(() => getCachedTrips(any())).thenAnswer((_) async => Right(trips));
        when(() => getRiderTrips(any())).thenAnswer((_) async => Right(trips));
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
        when(() => getRiderTrips(any()))
            .thenAnswer((_) async => Right(freshTrips));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const TripListLoadRequested()),
      expect: () => [
        const TripListLoading(),
        TripListLoaded(trips: cachedTrips, isOffline: false),
        TripListLoaded(trips: freshTrips, isOffline: false),
      ],
    );

    final syncedTrips = [trips.first.copyWith(id: 'synced-current')];

    blocTest<TripListBloc, TripListState>(
      'cache sync updates loaded trips from hive without loading state',
      build: () {
        when(() => getCachedTrips(any()))
            .thenAnswer((_) async => Right(syncedTrips));
        when(() => networkStatus.isOnline).thenAnswer((_) async => true);
        return buildBloc();
      },
      seed: () => TripListLoaded(trips: trips, isOffline: false),
      act: (bloc) => bloc.add(const TripListCacheSyncRequested()),
      expect: () => [
        TripListLoaded(trips: syncedTrips, isOffline: false),
      ],
    );

    blocTest<TripListBloc, TripListState>(
      'cache sync skips emit when snapshot unchanged',
      build: () {
        when(() => getCachedTrips(any())).thenAnswer((_) async => Right(trips));
        when(() => networkStatus.isOnline).thenAnswer((_) async => true);
        return buildBloc();
      },
      seed: () => TripListLoaded(trips: trips, isOffline: false),
      act: (bloc) => bloc.add(const TripListCacheSyncRequested()),
      expect: () => [],
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
          type: any(named: 'type'),
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
          status: TripStatus.requested,
          riderId: 'user-001',
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
          fare: 12.5,
          distanceKm: 5.2,
          etaMinutes: 10,
          paymentMethodKey: 'payment_card',
          rideTierKey: 'ride_economy',
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
