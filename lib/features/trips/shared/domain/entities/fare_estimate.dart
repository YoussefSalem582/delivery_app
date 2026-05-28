import 'package:equatable/equatable.dart';

class FareEstimate extends Equatable {
  const FareEstimate({
    required this.tierKey,
    required this.distanceKm,
    required this.baseFare,
    required this.distanceCharge,
    required this.fare,
    required this.minimumFare,
  });

  final String tierKey;
  final double distanceKm;
  final double baseFare;
  final double distanceCharge;
  final double fare;
  final double minimumFare;

  bool get usedMinimumFare =>
      fare <= minimumFare && (baseFare + distanceCharge) < minimumFare;

  @override
  List<Object?> get props => [
        tierKey,
        distanceKm,
        baseFare,
        distanceCharge,
        fare,
        minimumFare,
      ];
}
