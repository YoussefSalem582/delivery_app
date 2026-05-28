import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_app/core/error/failures.dart';
import 'package:delivery_app/core/network/fcm_service.dart';
import 'package:delivery_app/core/network/route_service.dart';
import 'package:delivery_app/features/auth/shared/domain/entities/user_entity.dart';
import 'package:delivery_app/features/auth/shared/domain/repositories/auth_repository.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/driver_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/get_driver_for_trip_usecase.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/trip_usecases.dart';
import 'package:delivery_app/features/trips/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockRouteService extends Mock implements RouteService {}

class MockGetTripDetailUseCase extends Mock implements GetTripDetailUseCase {}

class MockGetDriverForTripUseCase extends Mock
    implements GetDriverForTripUseCase {}

class MockUpdateTripStatusUseCase extends Mock
    implements UpdateTripStatusUseCase {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockFcmService extends Mock implements FcmService {}

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

TripRoutePlan _sampleRoutePlan({
  double approachMeters = 2000,
  double tripMeters = 5000,
  double approachSeconds = 240,
  double tripSeconds = 600,
}) {
  final approachPoints = [
    const LatLng(30.055, 31.245),
    const LatLng(30.03, 31.02),
    const LatLng(30, 31),
  ];
  final tripPoints = [
    const LatLng(30, 31),
    const LatLng(30.05, 31.05),
    const LatLng(30.1, 31.1),
  ];
  final approachLeg = RouteResult(
    points: approachPoints,
    distanceMeters: approachMeters,
    durationSeconds: approachSeconds,
  );
  final tripLeg = RouteResult(
    points: tripPoints,
    distanceMeters: tripMeters,
    durationSeconds: tripSeconds,
  );
  final totalDistance = approachMeters + tripMeters;
  return TripRoutePlan(
    approachLeg: approachLeg,
    tripLeg: tripLeg,
    fullRoute: [...approachPoints, ...tripPoints.skip(1)],
    phaseBoundaryProgress: approachMeters / totalDistance,
    totalDistanceMeters: totalDistance,
    totalDurationSeconds: approachSeconds + tripSeconds,
  );
}

void main() {
  late MockRouteService routeService;
  late MockGetTripDetailUseCase getTripDetail;
  late MockGetDriverForTripUseCase getDriverForTrip;
  late MockUpdateTripStatusUseCase updateTripStatus;
  late MockAuthRepository authRepository;
  late MockFcmService fcmService;

  setUpAll(() {
    registerFallbackValue(const LatLng(0, 0));
    registerFallbackValue(const GetTripDetailParams(''));
    registerFallbackValue(const GetDriverForTripParams());
    registerFallbackValue(
      const UpdateTripStatusParams(
        tripId: '',
        status: TripStatus.inProgress,
      ),
    );
  });

  setUp(() {
    routeService = MockRouteService();
    getTripDetail = MockGetTripDetailUseCase();
    getDriverForTrip = MockGetDriverForTripUseCase();
    updateTripStatus = MockUpdateTripStatusUseCase();
    authRepository = MockAuthRepository();
    fcmService = MockFcmService();

    when(() => getDriverForTrip(any())).thenAnswer(
      (_) async => const Right(_driver),
    );
    when(() => updateTripStatus(any())).thenAnswer(
      (invocation) async {
        final params = invocation.positionalArguments.first
            as UpdateTripStatusParams;
        return Right(_sampleTrip(status: params.status));
      },
    );
    when(() => authRepository.updateWalletBalance(any())).thenAnswer(
      (_) async => UserEntity(
        id: '1',
        name: 'User',
        email: 'user@test.com',
        phone: '+201000000000',
        walletBalance: 0,
      ),
    );
    when(
      () => fcmService.simulateTripNotification(
        title: any(named: 'title'),
        body: any(named: 'body'),
        tripId: any(named: 'tripId'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => routeService.getTripRoutePlan(
        driver: any(named: 'driver'),
        pickup: any(named: 'pickup'),
        dropoff: any(named: 'dropoff'),
      ),
    ).thenAnswer((_) async => _sampleRoutePlan());
  });

  TrackingBloc buildBloc({VoidCallback? onTripsChanged}) {
    return TrackingBloc(
      routeService: routeService,
      getTripDetail: getTripDetail,
      getDriverForTrip: getDriverForTrip,
      updateTripStatus: updateTripStatus,
      authRepository: authRepository,
      fcmService: fcmService,
      onTripsChanged: onTripsChanged,
    );
  }

  blocTest<TrackingBloc, TrackingState>(
    'loads two-leg route plan on tracking start',
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
      expect(active.phase, TrackingPhase.approach);
      expect(active.remainingDistanceKm, greaterThan(0));
      verify(
        () => routeService.getTripRoutePlan(
          driver: const LatLng(30.055, 31.245),
          pickup: const LatLng(30, 31),
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
        () => routeService.getTripRoutePlan(
          driver: const LatLng(30, 31),
          pickup: const LatLng(30, 31),
          dropoff: const LatLng(30.1, 31.1),
        ),
      ).called(1);
    },
  );

  blocTest<TrackingBloc, TrackingState>(
    'increases progress over distance-based ticks',
    build: () {
      when(() => getTripDetail(any())).thenAnswer(
        (_) async => Right(_sampleTrip()),
      );
      when(
        () => routeService.getTripRoutePlan(
          driver: any(named: 'driver'),
          pickup: any(named: 'pickup'),
          dropoff: any(named: 'dropoff'),
        ),
      ).thenAnswer(
        (_) async => _sampleRoutePlan(
          approachMeters: 1000,
          tripMeters: 1000,
          approachSeconds: 10,
          tripSeconds: 10,
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
      expect(active.progress, greaterThan(0.2));
      expect(active.progress, lessThan(0.8));
      expect(active.etaMinutes, greaterThan(0));
    },
  );

  blocTest<TrackingBloc, TrackingState>(
    'transitions to onTrip phase after approach leg',
    build: () {
      when(() => getTripDetail(any())).thenAnswer(
        (_) async => Right(_sampleTrip()),
      );
      when(
        () => routeService.getTripRoutePlan(
          driver: any(named: 'driver'),
          pickup: any(named: 'pickup'),
          dropoff: any(named: 'dropoff'),
        ),
      ).thenAnswer(
        (_) async => _sampleRoutePlan(
          approachMeters: 500,
          tripMeters: 9500,
          approachSeconds: 5,
          tripSeconds: 95,
        ),
      );
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(const TrackingLoadRequested('1'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(TrackingTick(DateTime.now().add(const Duration(seconds: 6))));
    },
    verify: (bloc) {
      final active = bloc.state as TrackingActive;
      expect(active.phase, TrackingPhase.onTrip);
    },
  );

  blocTest<TrackingBloc, TrackingState>(
    'emits TrackingCompleted when progress reaches 1.0',
    build: () {
      when(() => getTripDetail(any())).thenAnswer(
        (_) async => Right(_sampleTrip()),
      );
      when(
        () => routeService.getTripRoutePlan(
          driver: any(named: 'driver'),
          pickup: any(named: 'pickup'),
          dropoff: any(named: 'dropoff'),
        ),
      ).thenAnswer(
        (_) async => _sampleRoutePlan(
          approachMeters: 500,
          tripMeters: 500,
          approachSeconds: 5,
          tripSeconds: 5,
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
