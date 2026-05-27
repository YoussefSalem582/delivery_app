import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

const _distance = Distance();

/// Precomputes cumulative distance from the route start to each vertex.
List<double> buildCumulativeDistances(List<LatLng> route) {
  if (route.isEmpty) return [];
  if (route.length == 1) return [0];

  final cumulative = <double>[0];
  var total = 0.0;
  for (var i = 1; i < route.length; i++) {
    total += _distance(route[i - 1], route[i]);
    cumulative.add(total);
  }
  return cumulative;
}

/// Returns the exact position on the polyline for [progress] in 0.0–1.0.
LatLng interpolateAlongRoute(List<LatLng> route, double progress) {
  if (route.isEmpty) {
    throw ArgumentError('Route must not be empty');
  }
  if (route.length == 1) return route.first;

  final clamped = progress.clamp(0.0, 1.0);
  if (clamped <= 0) return route.first;
  if (clamped >= 1) return route.last;

  final cumulative = buildCumulativeDistances(route);
  final totalDistance = cumulative.last;
  if (totalDistance == 0) return route.first;

  final targetDistance = totalDistance * clamped;

  for (var i = 1; i < cumulative.length; i++) {
    if (targetDistance <= cumulative[i]) {
      final segmentStart = cumulative[i - 1];
      final segmentLength = cumulative[i] - segmentStart;
      final t = segmentLength == 0
          ? 0.0
          : (targetDistance - segmentStart) / segmentLength;
      return _lerpLatLng(route[i - 1], route[i], t);
    }
  }

  return route.last;
}

/// Returns heading in degrees (0 = north, clockwise) at [progress].
double bearingAtProgress(List<LatLng> route, double progress) {
  if (route.length < 2) return 0;

  final clamped = progress.clamp(0.0, 1.0);
  final cumulative = buildCumulativeDistances(route);
  final totalDistance = cumulative.last;
  if (totalDistance == 0) return 0;

  final targetDistance = totalDistance * clamped;

  for (var i = 1; i < cumulative.length; i++) {
    if (targetDistance <= cumulative[i] || i == cumulative.length - 1) {
      return _bearing(route[i - 1], route[i]);
    }
  }

  return _bearing(route[route.length - 2], route.last);
}

/// Splits [route] into traveled and remaining polylines at [progress].
({List<LatLng> traveled, List<LatLng> remaining}) splitRouteAtProgress(
  List<LatLng> route,
  double progress,
) {
  if (route.isEmpty) {
    return (traveled: const [], remaining: const []);
  }
  if (route.length == 1) {
    return (traveled: [route.first], remaining: [route.first]);
  }

  final clamped = progress.clamp(0.0, 1.0);
  if (clamped <= 0) {
    return (traveled: [route.first], remaining: List<LatLng>.from(route));
  }
  if (clamped >= 1) {
    return (traveled: List<LatLng>.from(route), remaining: [route.last]);
  }

  final splitPoint = interpolateAlongRoute(route, clamped);
  final cumulative = buildCumulativeDistances(route);
  final targetDistance = cumulative.last * clamped;

  var segmentIndex = 1;
  for (var i = 1; i < cumulative.length; i++) {
    if (targetDistance <= cumulative[i]) {
      segmentIndex = i;
      break;
    }
  }

  final traveled = [
    ...route.sublist(0, segmentIndex),
    splitPoint,
  ];
  final remaining = [
    splitPoint,
    ...route.sublist(segmentIndex),
  ];

  return (traveled: traveled, remaining: remaining);
}

/// Inserts intermediate points so consecutive vertices are at most [maxSegmentMeters] apart.
List<LatLng> densifyRoute(List<LatLng> route, {double maxSegmentMeters = 20}) {
  if (route.length < 2) return List<LatLng>.from(route);

  final densified = <LatLng>[route.first];

  for (var i = 1; i < route.length; i++) {
    final start = route[i - 1];
    final end = route[i];
    final segmentLength = _distance(start, end);

    if (segmentLength <= maxSegmentMeters) {
      densified.add(end);
      continue;
    }

    final steps = (segmentLength / maxSegmentMeters).ceil();
    for (var step = 1; step <= steps; step++) {
      final t = step / steps;
      densified.add(_lerpLatLng(start, end, t));
    }
  }

  return densified;
}

LatLng _lerpLatLng(LatLng a, LatLng b, double t) {
  return LatLng(
    a.latitude + (b.latitude - a.latitude) * t,
    a.longitude + (b.longitude - a.longitude) * t,
  );
}

double _bearing(LatLng from, LatLng to) {
  final lat1 = _toRadians(from.latitude);
  final lat2 = _toRadians(to.latitude);
  final dLng = _toRadians(to.longitude - from.longitude);

  final y = math.sin(dLng) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

  return (_toDegrees(math.atan2(y, x)) + 360) % 360;
}

double _toRadians(double degrees) => degrees * math.pi / 180;

double _toDegrees(double radians) => radians * 180 / math.pi;
