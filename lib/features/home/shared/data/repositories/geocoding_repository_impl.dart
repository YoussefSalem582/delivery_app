import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'package:delivery_app/core/error/exceptions.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/home/shared/data/datasources/nominatim_remote_datasource.dart';
import 'package:delivery_app/features/home/shared/domain/entities/place_suggestion.dart';
import 'package:delivery_app/features/home/shared/domain/repositories/geocoding_repository.dart';

class GeocodingRepositoryImpl implements GeocodingRepository {
  GeocodingRepositoryImpl({required NominatimRemoteDataSource remote})
      : _remote = remote;

  final NominatimRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<PlaceSuggestion>>> searchPlaces({
    required String query,
    required double biasLat,
    required double biasLng,
    required String languageCode,
    CancelToken? cancelToken,
  }) async {
    try {
      final results = await _remote.searchPlaces(
        query: query,
        biasLat: biasLat,
        biasLng: biasLng,
        languageCode: languageCode,
        cancelToken: cancelToken,
      );
      return Right(results.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, PlaceSuggestion>> reverseGeocode({
    required double lat,
    required double lng,
    required String languageCode,
    CancelToken? cancelToken,
  }) async {
    try {
      final result = await _remote.reverseGeocode(
        lat: lat,
        lng: lng,
        languageCode: languageCode,
        cancelToken: cancelToken,
      );
      return Right(result.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
