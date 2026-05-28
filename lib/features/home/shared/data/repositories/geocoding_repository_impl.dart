import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:delivery_app/core/error/exceptions.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/home/shared/data/datasources/nominatim_remote_datasource.dart';
import 'package:delivery_app/features/home/shared/data/datasources/photon_remote_datasource.dart';
import 'package:delivery_app/features/home/shared/data/models/nominatim_place_model.dart';
import 'package:delivery_app/features/home/shared/domain/entities/place_suggestion.dart';
import 'package:delivery_app/features/home/shared/domain/repositories/geocoding_repository.dart';

class GeocodingRepositoryImpl implements GeocodingRepository {
  GeocodingRepositoryImpl({
    required NominatimRemoteDataSource nominatim,
    required PhotonRemoteDataSource photon,
  })  : _nominatim = nominatim,
        _photon = photon;

  final NominatimRemoteDataSource _nominatim;
  final PhotonRemoteDataSource _photon;

  Future<List<NominatimPlaceModel>> _searchPlaces({
    required String query,
    required double biasLat,
    required double biasLng,
    required String languageCode,
    CancelToken? cancelToken,
  }) {
    if (kIsWeb) {
      return _photon.searchPlaces(
        query: query,
        biasLat: biasLat,
        biasLng: biasLng,
        languageCode: languageCode,
        cancelToken: cancelToken,
      );
    }
    return _nominatim.searchPlaces(
      query: query,
      biasLat: biasLat,
      biasLng: biasLng,
      languageCode: languageCode,
      cancelToken: cancelToken,
    );
  }

  Future<NominatimPlaceModel> _reverseGeocode({
    required double lat,
    required double lng,
    required String languageCode,
    CancelToken? cancelToken,
  }) {
    if (kIsWeb) {
      return _photon.reverseGeocode(
        lat: lat,
        lng: lng,
        languageCode: languageCode,
        cancelToken: cancelToken,
      );
    }
    return _nominatim.reverseGeocode(
      lat: lat,
      lng: lng,
      languageCode: languageCode,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Either<Failure, List<PlaceSuggestion>>> searchPlaces({
    required String query,
    required double biasLat,
    required double biasLng,
    required String languageCode,
    CancelToken? cancelToken,
  }) async {
    try {
      final results = await _searchPlaces(
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
      final result = await _reverseGeocode(
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
