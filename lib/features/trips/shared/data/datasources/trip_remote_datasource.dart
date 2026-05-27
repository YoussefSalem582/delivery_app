import 'package:dio/dio.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/core/network/api_endpoints.dart';

class TripRemoteDataSource {
  TripRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<TripEntity>> fetchTrips() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.trips);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => TripEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TripEntity> fetchTripById(String id) async {
    final response = await _dio.get<dynamic>(ApiEndpoints.tripById(id));
    return TripEntity.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TripEntity> requestTrip(Map<String, dynamic> body) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.requestTrip,
      data: body,
    );
    return TripEntity.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TripEntity> updateStatus(String id, TripStatus status) async {
    final response = await _dio.patch<dynamic>(
      ApiEndpoints.tripStatus(id),
      data: {'status': status.name},
    );
    final data = response.data as Map<String, dynamic>;
    return TripEntity(
      id: data['id'] as String,
      pickupAddress: '',
      dropoffAddress: '',
      pickupLat: 0,
      pickupLng: 0,
      dropoffLat: 0,
      dropoffLng: 0,
      status: TripStatus.values.firstWhere((e) => e.name == data['status']),
      fare: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }
}
