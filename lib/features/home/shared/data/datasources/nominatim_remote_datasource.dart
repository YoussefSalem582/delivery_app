import 'dart:async';

import 'package:delivery_app/config/environment/env_config.dart';
import 'package:delivery_app/core/constants/app_constants.dart';
import 'package:delivery_app/core/error/exceptions.dart';
import 'package:delivery_app/features/home/shared/data/models/nominatim_place_model.dart';
import 'package:dio/dio.dart';

class NominatimRemoteDataSource {
  NominatimRemoteDataSource(this._dio);

  final Dio _dio;

  static const _maxResults = 6;
  static const _viewboxRadiusDegrees = 0.45;
  static const _minRequestInterval = Duration(seconds: 1);

  final _searchCache = <String, List<NominatimPlaceModel>>{};
  final _reverseCache = <String, NominatimPlaceModel>{};
  DateTime? _lastRequestAt;

  Future<List<NominatimPlaceModel>> searchPlaces({
    required String query,
    required double biasLat,
    required double biasLng,
    required String languageCode,
    CancelToken? cancelToken,
  }) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return const [];

    final viewbox = _viewbox(biasLat, biasLng);
    final cacheKey = '$normalized|$viewbox|$languageCode';
    final cached = _searchCache[cacheKey];
    if (cached != null) return cached;

    await _respectRateLimit();

    try {
      final response = await _dio.get<List<dynamic>>(
        '${EnvConfig.nominatimBaseUrl}/search',
        queryParameters: {
          'q': normalized,
          'format': 'json',
          'addressdetails': 1,
          'limit': _maxResults,
          'viewbox': viewbox,
          'bounded': 0,
        },
        options: Options(
          extra: {'skipMockInterceptor': true},
          headers: {
            'User-Agent': '${AppConstants.appName}/1.0',
            'Accept-Language': languageCode,
          },
          responseType: ResponseType.json,
        ),
        cancelToken: cancelToken,
      );

      final data = response.data ?? const [];
      final results = data
          .whereType<Map<String, dynamic>>()
          .map(NominatimPlaceModel.fromJson)
          .toList();

      _searchCache[cacheKey] = results;
      return results;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) rethrow;
      throw AppException(
        e.message ?? 'Location search failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<NominatimPlaceModel> reverseGeocode({
    required double lat,
    required double lng,
    required String languageCode,
    CancelToken? cancelToken,
  }) async {
    final cacheKey =
        '${lat.toStringAsFixed(4)},${lng.toStringAsFixed(4)}|$languageCode';
    final cached = _reverseCache[cacheKey];
    if (cached != null) return cached;

    await _respectRateLimit();

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${EnvConfig.nominatimBaseUrl}/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lng,
          'format': 'json',
          'addressdetails': 1,
        },
        options: Options(
          extra: {'skipMockInterceptor': true},
          headers: {
            'User-Agent': '${AppConstants.appName}/1.0',
            'Accept-Language': languageCode,
          },
          responseType: ResponseType.json,
        ),
        cancelToken: cancelToken,
      );

      final data = response.data;
      if (data == null || data.isEmpty) {
        throw const AppException('Reverse geocode returned no data');
      }

      final result = NominatimPlaceModel.fromJson(data);
      _reverseCache[cacheKey] = result;
      return result;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) rethrow;
      throw AppException(
        e.message ?? 'Reverse geocode failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  String _viewbox(double lat, double lng) {
    final left = lng - _viewboxRadiusDegrees;
    final right = lng + _viewboxRadiusDegrees;
    final top = lat + _viewboxRadiusDegrees;
    final bottom = lat - _viewboxRadiusDegrees;
    return '$left,$top,$right,$bottom';
  }

  Future<void> _respectRateLimit() async {
    final last = _lastRequestAt;
    if (last != null) {
      final elapsed = DateTime.now().difference(last);
      if (elapsed < _minRequestInterval) {
        await Future<void>.delayed(_minRequestInterval - elapsed);
      }
    }
    _lastRequestAt = DateTime.now();
  }
}
