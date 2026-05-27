import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_app/core/network/route_service.dart';
import 'package:delivery_app/features/home/map_view/presentation/bloc/map_bloc.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockRouteService extends Mock implements RouteService {}

void main() {
  setUpAll(() {
    registerFallbackValue(const LatLng(0, 0));
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
