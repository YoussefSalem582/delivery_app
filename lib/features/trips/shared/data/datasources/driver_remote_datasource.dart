import 'package:dio/dio.dart';
import 'package:delivery_app/core/network/api_endpoints.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/driver_entity.dart';

class DriverRemoteDataSource {
  DriverRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<DriverEntity>> fetchDrivers() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.drivers);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => DriverEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
