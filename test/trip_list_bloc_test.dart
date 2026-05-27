import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_app/core/architecture/entities/trip_entity.dart';
import 'package:delivery_app/core/architecture/repositories/trip_repository.dart';
import 'package:delivery_app/core/network/fcm_service.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/core/network/route_service.dart';
import 'package:delivery_app/features/home/presentation/bloc/map_bloc.dart';
import 'package:delivery_app/features/trips/presentation/bloc/trip_list_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockTripRepository extends Mock implements TripRepository {}

class MockNetworkStatus extends Mock implements NetworkStatus {}

class MockFcmService extends Mock implements FcmService {}

class MockRouteService extends Mock implements RouteService {}

void main() {
  late MockTripRepository tripRepository;
  late MockNetworkStatus networkStatus;

  setUpAll(() {
    registerFallbackValue(const LatLng(0, 0));
  });

  setUp(() {
    tripRepository = MockTripRepository();
    networkStatus = MockNetworkStatus();
    when(() => networkStatus.isOnline).thenAnswer((_) async => true);
  });

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
        when(() => tripRepository.getCachedTrips()).thenReturn(trips);
        when(() => tripRepository.getTrips()).thenAnswer((_) async => trips);
        return TripListBloc(
          repository: tripRepository,
          networkStatus: networkStatus,
        );
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
        when(() => tripRepository.getCachedTrips()).thenReturn(cachedTrips);
        when(() => tripRepository.getTrips()).thenAnswer((_) async => freshTrips);
        return TripListBloc(
          repository: tripRepository,
          networkStatus: networkStatus,
        );
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

    setUp(() {
      fcmService = MockFcmService();
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
        when(
          () => tripRepository.requestTrip(
            pickupAddress: any(named: 'pickupAddress'),
            dropoffAddress: any(named: 'dropoffAddress'),
            pickupLat: any(named: 'pickupLat'),
            pickupLng: any(named: 'pickupLng'),
            dropoffLat: any(named: 'dropoffLat'),
            dropoffLng: any(named: 'dropoffLng'),
          ),
        ).thenAnswer((_) async => trip);
        return RequestRideBloc(
          repository: tripRepository,
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

  blocTest<TrackingBloc, TrackingState>(
    'loads route on tracking start',
    build: () {
      final routeService = MockRouteService();
      when(
        () => routeService.getRoute(
          pickup: any(named: 'pickup'),
          dropoff: any(named: 'dropoff'),
        ),
      ).thenAnswer(
        (_) async => RouteResult(
          points: [
            const LatLng(30, 31),
            const LatLng(30.05, 31.05),
            const LatLng(30.1, 31.1),
          ],
          distanceMeters: 5000,
          durationSeconds: 600,
        ),
      );
      return TrackingBloc(routeService);
    },
    act: (bloc) => bloc.add(
      TrackingStarted(
        TripEntity(
          id: '1',
          pickupAddress: 'A',
          dropoffAddress: 'B',
          pickupLat: 30,
          pickupLng: 31,
          dropoffLat: 30.1,
          dropoffLng: 31.1,
          status: TripStatus.inProgress,
          fare: 50,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ),
    ),
    expect: () => [
      isA<TrackingLoading>(),
      isA<TrackingActive>(),
    ],
  );

  blocTest<TrackingBloc, TrackingState>(
    'increases progress over time-based ticks',
    build: () {
      final routeService = MockRouteService();
      when(
        () => routeService.getRoute(
          pickup: any(named: 'pickup'),
          dropoff: any(named: 'dropoff'),
        ),
      ).thenAnswer(
        (_) async => RouteResult(
          points: [
            const LatLng(30, 31),
            const LatLng(30.05, 31.05),
            const LatLng(30.1, 31.1),
          ],
          distanceMeters: 5000,
          durationSeconds: 10,
        ),
      );
      return TrackingBloc(routeService);
    },
    act: (bloc) async {
      bloc.add(
        TrackingStarted(
          TripEntity(
            id: '1',
            pickupAddress: 'A',
            dropoffAddress: 'B',
            pickupLat: 30,
            pickupLng: 31,
            dropoffLat: 30.1,
            dropoffLng: 31.1,
            status: TripStatus.inProgress,
            fare: 50,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      bloc.add(TrackingTick(DateTime.now().add(const Duration(seconds: 5))));
    },
    verify: (bloc) {
      final active = bloc.state as TrackingActive;
      expect(active.progress, greaterThan(0.4));
      expect(active.progress, lessThan(0.6));
      expect(active.traveledRoute.length, greaterThan(1));
      expect(active.remainingRoute.length, greaterThan(1));
    },
  );
}
