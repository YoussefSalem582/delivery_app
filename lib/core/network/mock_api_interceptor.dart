import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:delivery_app/core/network/api_endpoints.dart';

class MockApiInterceptor extends Interceptor {
  MockApiInterceptor({this.failureRate = 0.05});

  final double failureRate;
  final _random = Random();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipMockInterceptor'] == true ||
        options.uri.isAbsolute && !options.uri.host.contains('localhost')) {
      handler.next(options);
      return;
    }

    await Future<void>.delayed(
      Duration(milliseconds: 300 + _random.nextInt(500)),
    );

    if (_random.nextDouble() < failureRate &&
        options.method == 'GET' &&
        !options.path.contains('profile')) {
      handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 503,
            statusMessage: 'Service temporarily unavailable',
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      return;
    }

    try {
      final response = await _handleRequest(options);
      handler.resolve(response);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: e,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  Future<Response<dynamic>> _handleRequest(RequestOptions options) async {
    final path = options.path;
    final method = options.method.toUpperCase();

    if (method == 'GET' && path == ApiEndpoints.trips) {
      final data = await _loadJsonList('assets/mock/trips.json');
      return _ok(options, data);
    }

    if (method == 'GET' && path.startsWith('/trips/') && !path.endsWith('/status')) {
      final id = path.split('/').last;
      final trips = await _loadJsonList('assets/mock/trips.json');
      final trip = trips.cast<Map<String, dynamic>>().firstWhere(
            (t) => t['id'] == id,
            orElse: () => trips.first as Map<String, dynamic>,
          );
      return _ok(options, trip);
    }

    if (method == 'GET' && path == ApiEndpoints.orders) {
      final data = await _loadJsonList('assets/mock/orders.json');
      return _ok(options, data);
    }

    if (method == 'GET' && path == ApiEndpoints.profile) {
      final data = await _loadJsonMap('assets/mock/profile.json');
      return _ok(options, data);
    }

    if (method == 'GET' && path == ApiEndpoints.drivers) {
      final data = await _loadJsonList('assets/mock/drivers.json');
      return _ok(options, data);
    }

    if (method == 'POST' && path == ApiEndpoints.requestTrip) {
      final body = options.data as Map<String, dynamic>? ?? {};
      final now = DateTime.now().toUtc().toIso8601String();
      return _ok(options, {
        'id': 'trip-${DateTime.now().millisecondsSinceEpoch}',
        'pickupAddress': body['pickupAddress'] ?? 'Current Location',
        'dropoffAddress': body['dropoffAddress'] ?? 'Destination',
        'pickupLat': body['pickupLat'] ?? 30.0444,
        'pickupLng': body['pickupLng'] ?? 31.2357,
        'dropoffLat': body['dropoffLat'] ?? 30.0626,
        'dropoffLng': body['dropoffLng'] ?? 31.2497,
        'status': 'accepted',
        'driverName': 'Demo Driver',
        'driverPhone': '+201555555555',
        'driverAvatarUrl': 'https://i.pravatar.cc/150?img=33',
        'fare': 75.0,
        'createdAt': now,
        'updatedAt': now,
      });
    }

    if (method == 'PATCH' && path.contains('/status')) {
      final parts = path.split('/');
      final id = parts[2];
      final body = options.data as Map<String, dynamic>? ?? {};
      final now = DateTime.now().toUtc().toIso8601String();
      return _ok(options, {
        'id': id,
        'status': body['status'] ?? 'inProgress',
        'updatedAt': now,
      });
    }

    return _ok(options, {'message': 'ok'});
  }

  Response<dynamic> _ok(RequestOptions options, dynamic data) {
    return Response(
      requestOptions: options,
      statusCode: 200,
      data: data,
    );
  }

  Future<List<dynamic>> _loadJsonList(String asset) async {
    final raw = await rootBundle.loadString(asset);
    return jsonDecode(raw) as List<dynamic>;
  }

  Future<Map<String, dynamic>> _loadJsonMap(String asset) async {
    final raw = await rootBundle.loadString(asset);
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
