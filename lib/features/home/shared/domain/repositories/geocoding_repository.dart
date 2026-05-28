import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/home/shared/domain/entities/place_suggestion.dart';

abstract class GeocodingRepository {
  Future<Either<Failure, List<PlaceSuggestion>>> searchPlaces({
    required String query,
    required double biasLat,
    required double biasLng,
    required String languageCode,
    CancelToken? cancelToken,
  });

  Future<Either<Failure, PlaceSuggestion>> reverseGeocode({
    required double lat,
    required double lng,
    required String languageCode,
    CancelToken? cancelToken,
  });
}
