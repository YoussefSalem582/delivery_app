import 'dart:async';

import 'package:delivery_app/core/error/exceptions.dart';
import 'package:delivery_app/features/home/shared/data/models/nominatim_place_model.dart';
import 'package:dio/dio.dart';

/// CORS-friendly geocoding for Flutter Web (Photon / OSM).
class PhotonRemoteDataSource {
  PhotonRemoteDataSource(this._dio);

  final Dio _dio;

  static const _baseUrl = 'https://photon.komoot.io';
  static const _maxResults = 6;
  static const _minRequestInterval = Duration(milliseconds: 300);

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

    final cacheKey = '$normalized|$biasLat,$biasLng|$languageCode';
    final cached = _searchCache[cacheKey];
    if (cached != null) return cached;

    await _respectRateLimit();

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/api/',
        queryParameters: {
          'q': normalized,
          'limit': _maxResults,
          'lang': languageCode,
          'lat': biasLat,
          'lon': biasLng,
        },
        options: Options(
          extra: {'skipMockInterceptor': true},
          responseType: ResponseType.json,
        ),
        cancelToken: cancelToken,
      );

      final features = response.data?['features'] as List<dynamic>? ?? const [];
      final results = features
          .whereType<Map<String, dynamic>>()
          .map(_fromFeature)
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
        '$_baseUrl/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lng,
          'lang': languageCode,
        },
        options: Options(
          extra: {'skipMockInterceptor': true},
          responseType: ResponseType.json,
        ),
        cancelToken: cancelToken,
      );

      final features = response.data?['features'] as List<dynamic>? ?? const [];
      if (features.isEmpty) {
        throw const AppException('Reverse geocode returned no data');
      }

      final first = features.first;
      if (first is! Map<String, dynamic>) {
        throw const AppException('Reverse geocode returned no data');
      }

      final result = _fromFeature(first);
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

  NominatimPlaceModel _fromFeature(Map<String, dynamic> feature) {
    final geometry = feature['geometry'] as Map<String, dynamic>? ?? const {};
    final coordinates = geometry['coordinates'] as List<dynamic>? ?? const [];
    final lng = coordinates.isNotEmpty
        ? (coordinates[0] as num).toDouble()
        : 0.0;
    final lat = coordinates.length > 1
        ? (coordinates[1] as num).toDouble()
        : 0.0;

    final properties =
        feature['properties'] as Map<String, dynamic>? ?? const {};
    final name = properties['name'] as String? ?? '';
    final street = properties['street'] as String? ?? '';
    final city = properties['city'] as String? ??
        properties['town'] as String? ??
        properties['village'] as String? ??
        '';
    final state = properties['state'] as String? ?? '';
    final country = properties['country'] as String? ?? '';

    final address = <String, dynamic>{
      if (name.isNotEmpty) 'name': name,
      if (street.isNotEmpty) 'road': street,
      if (city.isNotEmpty) 'city': city,
      if (state.isNotEmpty) 'state': state,
      if (country.isNotEmpty) 'country': country,
    };

    final displayParts = [name, street, city, state, country]
        .where((part) => part.trim().isNotEmpty)
        .toSet()
        .toList();

    final displayName = displayParts.isNotEmpty
        ? displayParts.join(', ')
        : '$lat, $lng';

    final osmId = properties['osm_id'];
    final placeId = osmId is num
        ? osmId.toInt()
        : displayName.hashCode.abs();

    return NominatimPlaceModel(
      placeId: placeId,
      lat: lat,
      lng: lng,
      displayName: displayName,
      address: address.isEmpty ? null : address,
    );
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
