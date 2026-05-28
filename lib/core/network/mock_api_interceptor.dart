import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:delivery_app/core/network/api_endpoints.dart';
import 'package:delivery_app/core/network/mock_api_store.dart';
import 'package:delivery_app/core/network/mock_session_context.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_payment.dart';

class MockApiInterceptor extends Interceptor {
  MockApiInterceptor({this.failureRate = 0.05});

  final double failureRate;
  final _random = Random();
  final _store = MockApiStore.instance;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipMockInterceptor'] == true) {
      handler.next(options);
      return;
    }

    final host = options.uri.host;
    final mockHost = Uri.parse(ApiEndpoints.baseUrl).host;
    final isMockRequest = host.isEmpty ||
        host == mockHost ||
        host.contains('localhost') ||
        host == '127.0.0.1';

    if (!isMockRequest) {
      handler.next(options);
      return;
    }

    await _store.ensureInitialized();

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
    final path = _normalizeMockPath(options.path);
    final method = options.method.toUpperCase();

    if (method == 'GET' && path == ApiEndpoints.trips) {
      return _ok(options, _store.trips);
    }

    if (method == 'GET' &&
        path.startsWith('/trips/') &&
        !path.endsWith('/status')) {
      final id = path.split('/').last;
      final trip = _store.tripById(id);
      if (trip == null) {
        throw StateError('Trip not found: $id');
      }
      return _ok(options, trip);
    }

    if (method == 'GET' && path == ApiEndpoints.orders) {
      final raw = await rootBundle.loadString('assets/mock/orders.json');
      return _ok(options, jsonDecode(raw) as List<dynamic>);
    }

    if (method == 'GET' && path == ApiEndpoints.profile) {
      return _ok(options, _store.profile);
    }

    if (method == 'GET' && path == ApiEndpoints.drivers) {
      return _ok(options, _store.drivers);
    }

    if (method == 'GET' && path == ApiEndpoints.riders) {
      return _ok(options, _store.riders);
    }

    if (method == 'GET' &&
        path.startsWith('/drivers/') &&
        path.endsWith('/reviews')) {
      final segments = path.split('/');
      final driverId = segments[2];
      final raw = await rootBundle.loadString('assets/mock/driver_reviews.json');
      final allReviews = jsonDecode(raw) as List<dynamic>;
      final filtered = allReviews
          .cast<Map<String, dynamic>>()
          .where((r) => r['driverId'] == driverId)
          .toList();
      return _ok(options, filtered);
    }

    if (method == 'POST' && path == ApiEndpoints.requestTrip) {
      final body = options.data as Map<String, dynamic>? ?? {};
      final now = DateTime.now().toUtc().toIso8601String();
      final riderId =
          body['riderId'] as String? ?? MockSessionContext.currentUserId ?? 'user-001';
      final trip = {
        'id': 'trip-${DateTime.now().millisecondsSinceEpoch}',
        'pickupAddress': body['pickupAddress'] ?? 'Current Location',
        'dropoffAddress': body['dropoffAddress'] ?? 'Destination',
        'pickupLat': body['pickupLat'] ?? 30.0444,
        'pickupLng': body['pickupLng'] ?? 31.2357,
        'dropoffLat': body['dropoffLat'] ?? 30.0626,
        'dropoffLng': body['dropoffLng'] ?? 31.2497,
        'status': 'requested',
        'riderId': riderId,
        'fare': body['fare'] ?? 75.0,
        if (body['distanceKm'] != null) 'distanceKm': body['distanceKm'],
        if (body['etaMinutes'] != null) 'etaMinutes': body['etaMinutes'],
        if (body['paymentMethodKey'] != null)
          'paymentMethodKey': body['paymentMethodKey'],
        if (body['rideTierKey'] != null) 'rideTierKey': body['rideTierKey'],
        'createdAt': now,
        'updatedAt': now,
      };
      _store.upsertTrip(trip);
      return _ok(options, trip);
    }

    if (method == 'PATCH' && path.contains('/status')) {
      final parts = path.split('/');
      final id = parts[2];
      final body = options.data as Map<String, dynamic>? ?? {};
      final existing = _store.tripById(id);
      if (existing == null) throw StateError('Trip not found: $id');
      final updated = Map<String, dynamic>.from(existing)
        ..['status'] = body['status'] ?? 'inProgress'
        ..['updatedAt'] = DateTime.now().toUtc().toIso8601String();
      _store.upsertTrip(updated);
      return _ok(options, updated);
    }

    if (method == 'POST' && path == ApiEndpoints.driverRegister) {
      final body = options.data as Map<String, dynamic>? ?? {};
      final profile = Map<String, dynamic>.from(_store.profile ?? {});
      profile
        ..['phone'] = body['phone'] ?? profile['phone']
        ..['isDriverRegistered'] = true
        ..['driverProfile'] = {
          'phone': body['phone'],
          'vehicleType': body['vehicleType'],
          'vehicleMakeModel': body['vehicleMakeModel'],
          'licensePlate': body['licensePlate'],
          'registeredAt': DateTime.now().toUtc().toIso8601String(),
          'termsAccepted': body['termsAccepted'] ?? true,
        };
      _store.updateProfile(profile);
      _store.upsertDriver({
        'id': profile['id'],
        'name': profile['name'],
        'phone': body['phone'],
        'rating': 5.0,
        'vehicle':
            '${body['vehicleMakeModel']} (${body['vehicleType']})',
        'lat': 30.0444,
        'lng': 31.2357,
      });
      return _ok(options, profile);
    }

    if (method == 'GET' && path == ApiEndpoints.driverProfile) {
      return _ok(options, _store.profile);
    }

    if (method == 'PATCH' && path == ApiEndpoints.driverAvailability) {
      final body = options.data as Map<String, dynamic>? ?? {};
      final status = body['status'] as String? ?? 'offline';
      _store.setAvailability(
        DriverAvailabilityState.values.firstWhere(
          (e) => e.name == status,
          orElse: () => DriverAvailabilityState.offline,
        ),
      );
      return _ok(options, {'status': _store.availability.name});
    }

    if (method == 'GET' && path == ApiEndpoints.driverOffers) {
      final driverId = MockSessionContext.currentUserId ?? 'user-001';
      return _ok(options, _store.offersForDriver(driverId));
    }

    if (method == 'POST' && path.startsWith('/driver/offers/') && path.endsWith('/accept')) {
      final tripId = path.split('/')[3];
      final driverId = MockSessionContext.currentUserId ?? 'user-001';
      final profile = _store.profile ?? {};
      final driverProfile =
          profile['driverProfile'] as Map<String, dynamic>? ?? {};
      final existing = _store.tripById(tripId);
      if (existing == null) throw StateError('Trip not found: $tripId');
      if (existing['riderId'] == driverId) {
        throw StateError('Driver cannot accept own trip');
      }
      final vehicleLabel =
          '${driverProfile['vehicleMakeModel']} (${driverProfile['vehicleType']})';
      final updated = Map<String, dynamic>.from(existing)
        ..['driverId'] = driverId
        ..['status'] = 'accepted'
        ..['driverName'] = profile['name']
        ..['driverPhone'] = driverProfile['phone'] ?? profile['phone']
        ..['driverAvatarUrl'] = profile['avatarUrl']
        ..['driverRating'] = 5.0
        ..['driverVehicle'] = vehicleLabel
        ..['updatedAt'] = DateTime.now().toUtc().toIso8601String();
      _store.upsertTrip(updated);
      _store.setAvailability(DriverAvailabilityState.onTrip);
      return _ok(options, updated);
    }

    if (method == 'POST' && path.startsWith('/driver/offers/') && path.endsWith('/decline')) {
      final tripId = path.split('/')[3];
      _store.declineOffer(tripId);
      return _ok(options, {'id': tripId, 'declined': true});
    }

    if (method == 'PATCH' && path.endsWith('/location')) {
      final tripId = path.split('/')[3];
      final body = options.data as Map<String, dynamic>? ?? {};
      final existing = _store.tripById(tripId);
      if (existing == null) throw StateError('Trip not found: $tripId');
      final updated = Map<String, dynamic>.from(existing)
        ..['driverLat'] = body['lat']
        ..['driverLng'] = body['lng']
        ..['updatedAt'] = DateTime.now().toUtc().toIso8601String();
      _store.upsertTrip(updated);
      return _ok(options, updated);
    }

    if (method == 'PATCH' && path.startsWith('/driver/trips/')) {
      final tripId = path.split('/')[3];
      final body = options.data as Map<String, dynamic>? ?? {};
      final existing = _store.tripById(tripId);
      if (existing == null) throw StateError('Trip not found: $tripId');
      final updated = Map<String, dynamic>.from(existing)
        ..['status'] = body['status'] ?? existing['status']
        ..['updatedAt'] = DateTime.now().toUtc().toIso8601String();
      if (body['driverLat'] != null) updated['driverLat'] = body['driverLat'];
      if (body['driverLng'] != null) updated['driverLng'] = body['driverLng'];
      _store.upsertTrip(updated);
      if (updated['status'] == 'completed' || updated['status'] == 'cancelled') {
        _store.setAvailability(DriverAvailabilityState.online);
      }
      if (updated['status'] == 'completed') {
        _debitRiderWalletIfNeeded(existing);
      }
      return _ok(options, updated);
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

  /// Maps production `/v1/driver/*` paths to mock handlers.
  String _normalizeMockPath(String path) {
    if (path.startsWith('/v1/driver')) {
      return path.replaceFirst('/v1/driver', '/driver');
    }
    return path;
  }

  void _debitRiderWalletIfNeeded(Map<String, dynamic> trip) {
    if (!tripUsesWallet(trip['paymentMethodKey'] as String?)) return;

    final riderId = trip['riderId'] as String?;
    final profile = _store.profile;
    if (riderId == null || profile == null || profile['id'] != riderId) return;

    final fare = (trip['fare'] as num?)?.toDouble() ?? 0;
    final balance = (profile['walletBalance'] as num?)?.toDouble() ?? 0;
    _store.updateProfile({
      ...profile,
      'walletBalance': (balance - fare).clamp(0, double.infinity),
    });
  }
}
