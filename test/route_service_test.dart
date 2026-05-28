import 'package:delivery_app/core/cache/datasources/route_cache_local_datasource.dart';
import 'package:delivery_app/core/cache/entities/hive_adapters.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/route_cache_entity.dart';
import 'package:delivery_app/core/network/route_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker_flutter/talker_flutter.dart';

class _MockDio extends Mock implements Dio {}

class _MockTalker extends Mock implements Talker {}

void main() {
  late _MockDio dio;
  late _MockTalker talker;
  late RouteService routeService;
  late Box<RouteCacheEntity> routeBox;

  setUpAll(() {
    Hive.init('test_route_cache');
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(RouteCacheEntityAdapter());
    }
  });

  setUp(() async {
    dio = _MockDio();
    talker = _MockTalker();
    routeBox = await Hive.openBox<RouteCacheEntity>(
      'route_cache_test_${DateTime.now().microsecondsSinceEpoch}',
    );
    routeService = RouteService(dio, talker, RouteCacheLocalDataSource(routeBox));

    when(() => talker.info(any())).thenReturn(null);
    when(
      () => talker.handle(any(), any(), any()),
    ).thenReturn(null);
  });

  tearDown(() async {
    await routeBox.deleteFromDisk();
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

    const pickup = LatLng(30.0, 31.0);
    const dropoff = LatLng(30.1, 31.1);

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

  test('deduplicates concurrent requests for the same route', () async {
    when(() => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        )).thenAnswer(
      (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return Response(
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
        );
      },
    );

    const pickup = LatLng(30.0, 31.0);
    const dropoff = LatLng(30.1, 31.1);

    final results = await Future.wait([
      routeService.getRoute(pickup: pickup, dropoff: dropoff),
      routeService.getRoute(pickup: pickup, dropoff: dropoff),
    ]);

    expect(results[0].distanceMeters, results[1].distanceMeters);
    verify(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).called(1);
  });

  test('caches fallback route after OSRM failure', () async {
    when(() => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        )).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/route'),
        type: DioExceptionType.connectionTimeout,
      ),
    );

    const pickup = LatLng(30.0, 31.0);
    const dropoff = LatLng(30.1, 31.1);

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

  test('loads route from disk cache after service restart', () async {
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
              'distance': 2000.0,
              'duration': 240.0,
              'geometry': {
                'coordinates': [
                  [31.0, 30.0],
                  [31.05, 30.05],
                ],
              },
            },
          ],
        },
      ),
    );

    final pickup = const LatLng(30.0, 31.0);
    final dropoff = const LatLng(30.05, 31.05);

    await routeService.getRoute(pickup: pickup, dropoff: dropoff);

    final secondService =
        RouteService(dio, talker, RouteCacheLocalDataSource(routeBox));
    final cached = await secondService.getRoute(
      pickup: pickup,
      dropoff: dropoff,
    );

    expect(cached.fromCache, isTrue);
    verify(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).called(1);
  });
}
