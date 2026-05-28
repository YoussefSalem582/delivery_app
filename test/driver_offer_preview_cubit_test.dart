import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_app/core/network/route_service.dart';
import 'package:delivery_app/features/driver/offers/presentation/cubit/driver_offer_preview_cubit.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/rider_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/get_rider_for_trip_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockRouteService extends Mock implements RouteService {}

class MockGetRiderForTripUseCase extends Mock implements GetRiderForTripUseCase {}

TripEntity _sampleOffer() {
  return TripEntity(
    id: 'trip-demo-offer',
    pickupAddress: 'Nasr City',
    dropoffAddress: 'Zamalek',
    pickupLat: 30.0561,
    pickupLng: 31.3302,
    dropoffLat: 30.0626,
    dropoffLng: 31.2189,
    status: TripStatus.requested,
    riderId: 'user-rider-demo',
    fare: 95,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

const _rider = RiderEntity(
  id: 'user-rider-demo',
  name: 'Sara Ali',
  phone: '+201112223344',
  rating: 4.9,
);

TripRoutePlan _sampleRoutePlan() {
  final approachPoints = [
    const LatLng(30.055, 31.245),
    const LatLng(30.03, 31.02),
    const LatLng(30.0561, 31.3302),
  ];
  final tripPoints = [
    const LatLng(30.0561, 31.3302),
    const LatLng(30.0626, 31.2189),
  ];
  return TripRoutePlan(
    driverStart: approachPoints.first,
    approachLeg: RouteResult(
      points: approachPoints,
      distanceMeters: 2000,
      durationSeconds: 240,
    ),
    tripLeg: RouteResult(
      points: tripPoints,
      distanceMeters: 5000,
      durationSeconds: 600,
    ),
    fullRoute: [...approachPoints, ...tripPoints.skip(1)],
    phaseBoundaryProgress: 2000 / 7000,
    totalDistanceMeters: 7000,
    totalDurationSeconds: 840,
  );
}

void main() {
  late MockRouteService routeService;
  late MockGetRiderForTripUseCase getRiderForTrip;

  setUpAll(() {
    registerFallbackValue(const LatLng(0, 0));
    registerFallbackValue(const GetRiderForTripParams(riderId: ''));
  });

  setUp(() {
    routeService = MockRouteService();
    getRiderForTrip = MockGetRiderForTripUseCase();

    when(
      () => routeService.getTripRoutePlan(
        pickup: any(named: 'pickup'),
        dropoff: any(named: 'dropoff'),
        placementSeed: any(named: 'placementSeed'),
      ),
    ).thenAnswer((_) async => _sampleRoutePlan());

    when(() => getRiderForTrip(any())).thenAnswer(
      (_) async => const Right(_rider),
    );
  });

  DriverOfferPreviewCubit buildCubit() {
    return DriverOfferPreviewCubit(
      routeService: routeService,
      getRiderForTrip: getRiderForTrip,
    );
  }

  blocTest<DriverOfferPreviewCubit, DriverOfferPreviewState>(
    'emits loaded with route plan and rider',
    build: buildCubit,
    act: (cubit) => cubit.load(_sampleOffer()),
    expect: () => [
      isA<DriverOfferPreviewLoading>(),
      isA<DriverOfferPreviewLoaded>(),
    ],
    verify: (cubit) {
      final loaded = cubit.state as DriverOfferPreviewLoaded;
      expect(loaded.rider?.name, 'Sara Ali');
      expect(loaded.routePlan.totalDistanceMeters, 7000);
    },
  );

  blocTest<DriverOfferPreviewCubit, DriverOfferPreviewState>(
    'emits error when route plan fails',
    build: buildCubit,
    setUp: () {
      when(
        () => routeService.getTripRoutePlan(
          pickup: any(named: 'pickup'),
          dropoff: any(named: 'dropoff'),
          placementSeed: any(named: 'placementSeed'),
        ),
      ).thenThrow(Exception('route failed'));
    },
    act: (cubit) => cubit.load(_sampleOffer()),
    expect: () => [
      isA<DriverOfferPreviewLoading>(),
      isA<DriverOfferPreviewError>(),
    ],
  );
}
