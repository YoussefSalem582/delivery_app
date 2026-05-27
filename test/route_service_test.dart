import 'package:delivery_app/core/network/route_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker_flutter/talker_flutter.dart';

class _MockDio extends Mock implements Dio {}

class _MockTalker extends Mock implements Talker {}

void main() {
  late _MockDio dio;
  late _MockTalker talker;
  late RouteService routeService;

  setUp(() {
    dio = _MockDio();
    talker = _MockTalker();
    routeService = RouteService(dio, talker);

    when(() => talker.info(any())).thenReturn(null);
    when(
      () => talker.handle(any(), any(), any()),
    ).thenReturn(null);
  });

  test('parses OSRM GeoJSON route response', () async {
    when(() => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        )).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/route'),
        data: {
          'routes': [
            {
              'distance': 5000.0,
              'duration': 600.0,
              'geometry': {
                'coordinates': [
                  [31.2357, 30.0444],
                  [31.2400, 30.0500],
                  [31.2497, 30.0626],
                ],
              },
            },
          ],
        },
      ),
    );

    final result = await routeService.getRoute(
      pickup: const LatLng(30.0444, 31.2357),
      dropoff: const LatLng(30.0626, 31.2497),
    );

    expect(result.points.length, greaterThanOrEqualTo(3));
    expect(result.points.first.latitude, closeTo(30.0444, 0.0001));
    expect(result.points.first.longitude, closeTo(31.2357, 0.0001));
    expect(result.distanceMeters, 5000.0);
    expect(result.etaMinutes, 10);
  });

  test('falls back to straight line when OSRM fails', () async {
    when(() => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        )).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/route'),
        type: DioExceptionType.connectionError,
      ),
    );

    final result = await routeService.getRoute(
      pickup: const LatLng(30.0444, 31.2357),
      dropoff: const LatLng(30.0626, 31.2497),
    );

    expect(result.points.length, greaterThan(31));
    expect(result.etaMinutes, greaterThan(0));
  });

  test('returns cached route on second request', () async {
    when(() => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        )).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/route'),
        data: {
          'routes': [
            {
              'distance': 1000.0,
              'duration': 120.0,
              'geometry': {
                'coordinates': [
                  [31.0, 30.0],
                  [31.1, 30.1],
                ],
              },
            },
          ],
        },
      ),
    );

    final pickup = const LatLng(30.0, 31.0);
    final dropoff = const LatLng(30.1, 31.1);

    await routeService.getRoute(pickup: pickup, dropoff: dropoff);
    await routeService.getRoute(pickup: pickup, dropoff: dropoff);

    verify(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).called(1);
  });
}
