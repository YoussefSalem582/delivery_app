import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/home/shared/domain/entities/place_suggestion.dart';
import 'package:delivery_app/features/home/shared/domain/repositories/geocoding_repository.dart';

class SearchPlacesParams extends Equatable {
  const SearchPlacesParams({
    required this.query,
    required this.biasLat,
    required this.biasLng,
    required this.languageCode,
    this.cancelToken,
  });

  final String query;
  final double biasLat;
  final double biasLng;
  final String languageCode;
  final CancelToken? cancelToken;

  @override
  List<Object?> get props => [query, biasLat, biasLng, languageCode, cancelToken];
}

class SearchPlacesUseCase extends UseCase<List<PlaceSuggestion>, SearchPlacesParams> {
  SearchPlacesUseCase(this._repository);

  final GeocodingRepository _repository;

  @override
  Future<Either<Failure, List<PlaceSuggestion>>> call(
    SearchPlacesParams params,
  ) {
    return _repository.searchPlaces(
      query: params.query,
      biasLat: params.biasLat,
      biasLng: params.biasLng,
      languageCode: params.languageCode,
      cancelToken: params.cancelToken,
    );
  }
}
