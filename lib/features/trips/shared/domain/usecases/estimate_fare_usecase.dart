import 'package:dartz/dartz.dart';
import 'package:delivery_app/core/config/pricing_config.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/fare_estimate.dart';
import 'package:equatable/equatable.dart';

class EstimateFareUseCase extends UseCase<FareEstimate, EstimateFareParams> {
  @override
  Future<Either<Failure, FareEstimate>> call(EstimateFareParams params) async {
    if (params.distanceKm < 0) {
      return const Left(
        ValidationFailure(
          message: 'Invalid distance',
          fieldErrors: {'distanceKm': ['must be non-negative']},
        ),
      );
    }

    final pricing = PricingConfig.forTierKey(params.tierKey);
    final distanceCharge =
        (params.distanceKm * pricing.ratePerKm * 100).roundToDouble() / 100;
    final fare = pricing.calculateFare(params.distanceKm);

    return Right(
      FareEstimate(
        tierKey: pricing.tierKey,
        distanceKm: params.distanceKm,
        baseFare: pricing.baseFare,
        distanceCharge: distanceCharge,
        fare: fare,
        minimumFare: pricing.minimumFare,
      ),
    );
  }
}

class EstimateFareParams extends Equatable {
  const EstimateFareParams({
    required this.tierKey,
    required this.distanceKm,
  });

  final String tierKey;
  final double distanceKm;

  @override
  List<Object?> get props => [tierKey, distanceKm];
}
