import 'package:delivery_app/core/utils/route_geometry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  const route = [
    LatLng(30.0, 31.0),
    LatLng(30.01, 31.0),
    LatLng(30.02, 31.01),
  ];

  test('buildCumulativeDistances returns increasing values', () {
    final cumulative = buildCumulativeDistances(route);

    expect(cumulative.first, 0);
    expect(cumulative.length, route.length);
    expect(cumulative.last, greaterThan(cumulative[1]));
  });

  test('interpolateAlongRoute returns endpoints at 0 and 1', () {
    expect(interpolateAlongRoute(route, 0), route.first);
    expect(interpolateAlongRoute(route, 1), route.last);
  });

  test('interpolateAlongRoute returns midpoint between first two vertices', () {
    final midpoint = interpolateAlongRoute(route, 0.5);

    expect(midpoint.latitude, greaterThan(route.first.latitude));
    expect(midpoint.latitude, lessThan(route.last.latitude));
  });

  test('bearingAtProgress returns a valid heading', () {
    final bearing = bearingAtProgress(route, 0.25);

    expect(bearing, inInclusiveRange(0, 360));
  });

  test('splitRouteAtProgress divides route at progress point', () {
    final split = splitRouteAtProgress(route, 0.5);

    expect(split.traveled.first, route.first);
    expect(split.traveled.last, split.remaining.first);
    expect(split.remaining.last, route.last);
    expect(split.traveled.length, greaterThan(1));
    expect(split.remaining.length, greaterThan(1));
  });

  test('densifyRoute adds intermediate points for long segments', () {
    const sparse = [
      LatLng(30.0, 31.0),
      LatLng(30.1, 31.0),
    ];

    final densified = densifyRoute(sparse, maxSegmentMeters: 1000);

    expect(densified.length, greaterThan(sparse.length));
    expect(densified.first, sparse.first);
    expect(densified.last, sparse.last);
  });

  test('densifyRoute preserves short routes', () {
    const short = [
      LatLng(30.0, 31.0),
      LatLng(30.0001, 31.0001),
    ];

    final densified = densifyRoute(short);

    expect(densified.length, 2);
  });

  test('totalRouteDistance sums segment lengths', () {
    final total = totalRouteDistance(route);

    expect(total, greaterThan(0));
    expect(total, buildCumulativeDistances(route).last);
  });

  test('remainingDistanceMeters decreases with progress', () {
    final atStart = remainingDistanceMeters(route, 0);
    final atHalf = remainingDistanceMeters(route, 0.5);
    final atEnd = remainingDistanceMeters(route, 1);

    expect(atStart, greaterThan(atHalf));
    expect(atHalf, greaterThan(atEnd));
    expect(atEnd, 0);
  });

  test('progressAtDistance maps meters to normalized progress', () {
    final total = totalRouteDistance(route);
    final half = progressAtDistance(route, total / 2);

    expect(half, closeTo(0.5, 0.01));
  });

  test('concatenateRoutes merges without duplicate junction point', () {
    const first = [LatLng(30.0, 31.0), LatLng(30.01, 31.0)];
    const second = [LatLng(30.01, 31.0), LatLng(30.02, 31.01)];

    final merged = concatenateRoutes(first, second);

    expect(merged.first, first.first);
    expect(merged.last, second.last);
    expect(merged.length, 3);
  });

  test('projectPointOntoRoute snaps point to nearest segment', () {
    const segmentRoute = [
      LatLng(30.0, 31.0),
      LatLng(30.01, 31.0),
    ];
    const nearPoint = LatLng(30.005, 31.001);

    final projection = projectPointOntoRoute(segmentRoute, nearPoint);

    expect(projection.distanceAlongRoute, greaterThan(0));
    expect(projection.distanceAlongRoute, lessThan(totalRouteDistance(segmentRoute)));
  });
}
