import 'package:dio/dio.dart';
import 'package:delivery_app/core/network/api_endpoints.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/driver_review_entity.dart';

class DriverReviewRemoteDataSource {
  DriverReviewRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<DriverReviewEntity>> fetchReviews(String driverId) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.driverReviews(driverId),
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => DriverReviewEntity.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
