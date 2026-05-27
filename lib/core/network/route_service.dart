import 'package:delivery_app/core/architecture/datasources/route_cache_local_datasource.dart';
import 'package:delivery_app/core/architecture/entities/route_cache_entity.dart';
import 'package:delivery_app/core/utils/demo_destinations.dart';
import 'package:delivery_app/core/utils/route_geometry.dart';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:talker_flutter/talker_flutter.dart';

class RouteResult {
  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    this.fromCache = false,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final bool fromCache;

  int get etaMinutes => (durationSeconds / 60).ceil().clamp(1, 99);
}

class RouteService {
  RouteService(this._dio, this._talker, this._routeCache);

  final Dio _dio;
  final Talker _talker;
  final RouteCacheLocalDataSource _routeCache;

  static const _osrmBase = 'https://router.project-osrm.org';
  final _memoryCache = <String, RouteResult>{};

  Future<RouteResult> getRoute({
    required LatLng pickup,
    required LatLng dropoff,
  }) async {
    final cacheKey =
        '${pickup.latitude},${pickup.longitude}_${dropoff.latitude},${dropoff.longitude}';

    final memory = _memoryCache[cacheKey];
    if (memory != null) return memory;

    final disk = _routeCache.get(cacheKey);
    if (disk != null) {
      final result = RouteResult(
        points: disk.points,
        distanceMeters: disk.distanceMeters,
        durationSeconds: disk.durationSeconds,
        fromCache: true,
      );
      _memoryCache[cacheKey] = result;
      _talker.info('[RouteService] Disk cache hit for route');
      return result;
    }

    const distanceCalc = Distance();
    final straightMeters = distanceCalc(pickup, dropoff);
    if (straightMeters > DemoDestinations.maxOsrmDistanceMeters) {
      _talker.info(
        '[RouteService] Route exceeds OSRM demo range, using straight line',
      );
      return _fallbackRoute(pickup, dropoff, straightMeters);
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_osrmBase/route/v1/driving/'
        '${pickup.longitude},${pickup.latitude};'
        '${dropoff.longitude},${dropoff.latitude}',
        queryParameters: {
          'overview': 'full',
          'geometries': 'geojson',
        },
        options: Options(
          extra: {'skipMockInterceptor': true},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 400) {
        _talker.info('[RouteService] OSRM returned no route, using straight line');
        return _fallbackRoute(pickup, dropoff, straightMeters);
      }

      final data = response.data;
      final routes = data?['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) {
        return _fallbackRoute(pickup, dropoff, straightMeters);
      }

      final route = routes.first as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List<dynamic>;
      final rawPoints = coordinates
          .map(
            (c) => LatLng(
              (c[1] as num).toDouble(),
              (c[0] as num).toDouble(),
            ),
          )
          .toList();
      final points = densifyRoute(rawPoints);

      final result = RouteResult(
        points: points,
        distanceMeters: (route['distance'] as num).toDouble(),
        durationSeconds: (route['duration'] as num).toDouble(),
      );
      _memoryCache[cacheKey] = result;
      await _routeCache.put(
        RouteCacheEntity(
          cacheKey: cacheKey,
          points: points,
          distanceMeters: result.distanceMeters,
          durationSeconds: result.durationSeconds,
          createdAt: DateTime.now(),
        ),
      );
      _talker.info('[RouteService] OSRM route with ${points.length} points');
      return result;
    } catch (e, st) {
      _talker.handle(e, st, '[RouteService] Falling back to straight line');
      return _fallbackRoute(pickup, dropoff, straightMeters);
    }
  }

  RouteResult _fallbackRoute(
    LatLng pickup,
    LatLng dropoff, [
    double? straightMeters,
  ]) {
    const steps = 30;
    final rawPoints = List.generate(steps + 1, (i) {
      final t = i / steps;
      return LatLng(
        pickup.latitude + (dropoff.latitude - pickup.latitude) * t,
        pickup.longitude + (dropoff.longitude - pickup.longitude) * t,
      );
    });
    final points = densifyRoute(rawPoints);
    const distance = Distance();
    final meters = straightMeters ?? distance(pickup, dropoff);
    const avgSpeedMps = 8.33; // ~30 km/h
    return RouteResult(
      points: points,
      distanceMeters: meters,
      durationSeconds: meters / avgSpeedMps,
      fromCache: false,
    );
  }
}
