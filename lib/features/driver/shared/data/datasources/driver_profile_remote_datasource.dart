import 'package:dio/dio.dart';
import 'package:delivery_app/core/network/api_endpoints.dart';
import 'package:delivery_app/features/auth/shared/domain/entities/user_entity.dart';

class DriverProfileRemoteDataSource {
  DriverProfileRemoteDataSource(this._dio);

  final Dio _dio;

  Future<UserEntity> registerDriver(Map<String, dynamic> body) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.driverRegister,
      data: body,
    );
    return UserEntity.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserEntity> fetchProfile() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.driverProfile);
    return UserEntity.fromJson(response.data as Map<String, dynamic>);
  }

  Future<String> updateAvailability(String status) async {
    final response = await _dio.patch<dynamic>(
      ApiEndpoints.driverAvailability,
      data: {'status': status},
    );
    final data = response.data as Map<String, dynamic>;
    return data['status'] as String;
  }
}
