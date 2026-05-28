import 'package:equatable/equatable.dart';

class TierPricing extends Equatable {
  const TierPricing({
    required this.tierKey,
    required this.baseFare,
    required this.ratePerKm,
    required this.minimumFare,
  });

  final String tierKey;
  final double baseFare;
  final double ratePerKm;
  final double minimumFare;

  double calculateFare(double distanceKm) {
    final raw = baseFare + (distanceKm * ratePerKm);
    final clamped = raw < minimumFare ? minimumFare : raw;
    return (clamped * 100).roundToDouble() / 100;
  }

  @override
  List<Object?> get props => [tierKey, baseFare, ratePerKm, minimumFare];
}
