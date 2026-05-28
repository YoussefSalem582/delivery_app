import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/home/shared/domain/entities/place_suggestion.dart';
import 'package:delivery_app/features/home/shared/domain/repositories/geocoding_repository.dart';

class ReverseGeocodeParams extends Equatable {
  const ReverseGeocodeParams({
    required this.lat,
    required this.lng,
    required this.languageCode,
    this.cancelToken,
  });

  final double lat;
  final double lng;
  final String languageCode;
  final CancelToken? cancelToken;

  @override
  List<Object?> get props => [lat, lng, languageCode, cancelToken];
}

class ReverseGeocodeUseCase
    extends UseCase<PlaceSuggestion, ReverseGeocodeParams> {
  ReverseGeocodeUseCase(this._repository);

  final GeocodingRepository _repository;

  @override
  Future<Either<Failure, PlaceSuggestion>> call(
    ReverseGeocodeParams params,
  ) {
    return _repository.reverseGeocode(
      lat: params.lat,
      lng: params.lng,
      languageCode: params.languageCode,
      cancelToken: params.cancelToken,
    );
  }
}
