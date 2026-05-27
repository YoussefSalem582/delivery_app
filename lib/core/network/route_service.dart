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
  RouteService(this._dio, this._talker);

  final Dio _dio;
  final Talker _talker;

  static const _osrmBase = 'https://router.project-osrm.org';
  final _memoryCache = <String, RouteResult>{};

  Future<RouteResult> getRoute({
    required LatLng pickup,
    required LatLng dropoff,
  }) async {
    final cacheKey =
        '${pickup.latitude},${pickup.longitude}_${dropoff.latitude},${dropoff.longitude}';
    final cached = _memoryCache[cacheKey];
    if (cached != null) return cached;

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
        ),
      );

      final data = response.data;
      final routes = data?['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) {
        return _fallbackRoute(pickup, dropoff);
      }

      final route = routes.first as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List<dynamic>;
      final points = coordinates
          .map(
            (c) => LatLng(
              (c[1] as num).toDouble(),
              (c[0] as num).toDouble(),
            ),
          )
          .toList();

      final result = RouteResult(
        points: points,
        distanceMeters: (route['distance'] as num).toDouble(),
        durationSeconds: (route['duration'] as num).toDouble(),
      );
      _memoryCache[cacheKey] = result;
      _talker.info('[RouteService] OSRM route with ${points.length} points');
      return result;
    } catch (e, st) {
      _talker.handle(e, st, '[RouteService] Falling back to straight line');
      return _fallbackRoute(pickup, dropoff);
    }
  }

  RouteResult _fallbackRoute(LatLng pickup, LatLng dropoff) {
    const steps = 30;
    final points = List.generate(steps + 1, (i) {
      final t = i / steps;
      return LatLng(
        pickup.latitude + (dropoff.latitude - pickup.latitude) * t,
        pickup.longitude + (dropoff.longitude - pickup.longitude) * t,
      );
    });
    const distance = Distance();
    final meters = distance(pickup, dropoff);
    const avgSpeedMps = 8.33; // ~30 km/h
    return RouteResult(
      points: points,
      distanceMeters: meters,
      durationSeconds: meters / avgSpeedMps,
      fromCache: false,
    );
  }
}
