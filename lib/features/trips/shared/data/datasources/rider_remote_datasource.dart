import 'package:dio/dio.dart';
import 'package:delivery_app/core/network/api_endpoints.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/rider_entity.dart';

class RiderRemoteDataSource {
  RiderRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<RiderEntity>> fetchRiders() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.riders);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => RiderEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
