import 'package:dio/dio.dart';
import 'package:delivery_app/core/network/api_endpoints.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';

class DriverTripRemoteDataSource {
  DriverTripRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<TripEntity>> fetchOffers() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.driverOffers);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => TripEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TripEntity> acceptOffer(String tripId) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.driverOfferAccept(tripId),
    );
    return TripEntity.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> declineOffer(String tripId) async {
    await _dio.post<dynamic>(ApiEndpoints.driverOfferDecline(tripId));
  }

  Future<TripEntity> updateDriverTripStatus(
    String tripId,
    TripStatus status,
  ) async {
    final response = await _dio.patch<dynamic>(
      ApiEndpoints.driverTripStatus(tripId),
      data: {'status': status.name},
    );
    return TripEntity.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TripEntity> updateDriverLocation(
    String tripId, {
    required double lat,
    required double lng,
  }) async {
    final response = await _dio.patch<dynamic>(
      ApiEndpoints.driverTripLocation(tripId),
      data: {'lat': lat, 'lng': lng},
    );
    return TripEntity.fromJson(response.data as Map<String, dynamic>);
  }
}
