import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_app/core/error/failures.dart';
import 'package:delivery_app/core/network/route_service.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/driver_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/get_driver_for_trip_usecase.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/trip_usecases.dart';
import 'package:delivery_app/features/trips/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockRouteService extends Mock implements RouteService {}

class MockGetTripDetailUseCase extends Mock implements GetTripDetailUseCase {}

class MockGetDriverForTripUseCase extends Mock
    implements GetDriverForTripUseCase {}

TripEntity _sampleTrip({TripStatus status = TripStatus.inProgress}) {
  return TripEntity(
    id: '1',
    pickupAddress: 'A',
    dropoffAddress: 'B',
    pickupLat: 30,
    pickupLng: 31,
    dropoffLat: 30.1,
    dropoffLng: 31.1,
    status: status,
    driverName: 'Sara Mohamed',
    fare: 50,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

const _driver = DriverEntity(
  id: 'driver-002',
  name: 'Sara Mohamed',
  phone: '+201987654321',
  rating: 4.8,
  vehicle: 'Hyundai Elantra - Silver',
  lat: 30.055,
  lng: 31.245,
);

void main() {
  late MockRouteService routeService;
  late MockGetTripDetailUseCase getTripDetail;
  late MockGetDriverForTripUseCase getDriverForTrip;

  setUpAll(() {
    registerFallbackValue(const LatLng(0, 0));
    registerFallbackValue(const GetTripDetailParams(''));
    registerFallbackValue(const GetDriverForTripParams());
  });

  setUp(() {
    routeService = MockRouteService();
    getTripDetail = MockGetTripDetailUseCase();
    getDriverForTrip = MockGetDriverForTripUseCase();

    when(() => getDriverForTrip(any())).thenAnswer(
      (_) async => const Right(_driver),
    );
    when(
      () => routeService.getRoute(
        pickup: any(named: 'pickup'),
        dropoff: any(named: 'dropoff'),
      ),
    ).thenAnswer(
      (_) async => RouteResult(
        points: [
          const LatLng(30.055, 31.245),
          const LatLng(30.05, 31.05),
          const LatLng(30.1, 31.1),
        ],
        distanceMeters: 5000,
        durationSeconds: 600,
      ),
    );
  });

  TrackingBloc buildBloc() {
    return TrackingBloc(
      routeService: routeService,
      getTripDetail: getTripDetail,
      getDriverForTrip: getDriverForTrip,
    );
  }

  blocTest<TrackingBloc, TrackingState>(
    'loads route from driver GPS on tracking start',
    build: () {
      when(() => getTripDetail(any())).thenAnswer(
        (_) async => Right(_sampleTrip()),
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(const TrackingLoadRequested('1')),
    expect: () => [
      isA<TrackingLoading>(),
      isA<TrackingActive>(),
    ],
    verify: (bloc) {
      final active = bloc.state as TrackingActive;
      expect(active.driverRating, 4.8);
      expect(active.driverVehicle, 'Hyundai Elantra - Silver');
      expect(active.driverPhone, '+201987654321');
      verify(
        () => routeService.getRoute(
          pickup: const LatLng(30.055, 31.245),
          dropoff: const LatLng(30.1, 31.1),
        ),
      ).called(1);
    },
  );

  blocTest<TrackingBloc, TrackingState>(
    'falls back to pickup when driver lookup returns null',
    build: () {
      when(() => getTripDetail(any())).thenAnswer(
        (_) async => Right(_sampleTrip()),
      );
      when(() => getDriverForTrip(any())).thenAnswer(
        (_) async => const Right(null),
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(const TrackingLoadRequested('1')),
    expect: () => [
      isA<TrackingLoading>(),
      isA<TrackingActive>(),
    ],
    verify: (_) {
      verify(
        () => routeService.getRoute(
          pickup: const LatLng(30, 31),
          dropoff: const LatLng(30.1, 31.1),
        ),
      ).called(1);
    },
  );

  blocTest<TrackingBloc, TrackingState>(
    'increases progress over time-based ticks',
    build: () {
      when(() => getTripDetail(any())).thenAnswer(
        (_) async => Right(_sampleTrip()),
      );
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
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(const TrackingLoadRequested('1'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(TrackingTick(DateTime.now().add(const Duration(seconds: 5))));
    },
    verify: (bloc) {
      final active = bloc.state as TrackingActive;
      expect(active.progress, greaterThan(0.4));
      expect(active.progress, lessThan(0.6));
    },
  );

  blocTest<TrackingBloc, TrackingState>(
    'emits TrackingCompleted when progress reaches 1.0',
    build: () {
      when(() => getTripDetail(any())).thenAnswer(
        (_) async => Right(_sampleTrip()),
      );
      when(
        () => routeService.getRoute(
          pickup: any(named: 'pickup'),
          dropoff: any(named: 'dropoff'),
        ),
      ).thenAnswer(
        (_) async => RouteResult(
          points: [
            const LatLng(30, 31),
            const LatLng(30.1, 31.1),
          ],
          distanceMeters: 1000,
          durationSeconds: 10,
        ),
      );
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(const TrackingLoadRequested('1'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(TrackingTick(DateTime.now().add(const Duration(seconds: 12))));
    },
    expect: () => [
      isA<TrackingLoading>(),
      isA<TrackingActive>(),
      isA<TrackingCompleted>(),
    ],
  );

  blocTest<TrackingBloc, TrackingState>(
    'emits TrackingError when trip is not found',
    build: () {
      when(() => getTripDetail(any())).thenAnswer(
        (_) async => const Left(NotFoundFailure(message: 'Trip not found')),
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(const TrackingLoadRequested('missing')),
    expect: () => [
      isA<TrackingLoading>(),
      isA<TrackingError>(),
    ],
  );
}
