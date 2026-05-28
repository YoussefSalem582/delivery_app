import 'package:delivery_app/features/trips/shared/domain/entities/tier_pricing.dart';

/// Demo per-km pricing rates for Egypt MVP (EGP).
class PricingConfig {
  PricingConfig._();

  static const economy = TierPricing(
    tierKey: 'ride_economy',
    baseFare: 5.0,
    ratePerKm: 2.5,
    minimumFare: 8.0,
  );

  static const premium = TierPricing(
    tierKey: 'ride_premium',
    baseFare: 8.0,
    ratePerKm: 4.0,
    minimumFare: 15.0,
  );

  static const delivery = TierPricing(
    tierKey: 'ride_delivery',
    baseFare: 4.0,
    ratePerKm: 2.0,
    minimumFare: 6.0,
  );

  static const all = [economy, premium, delivery];

  static TierPricing forTierKey(String tierKey) {
    return all.firstWhere(
      (tier) => tier.tierKey == tierKey,
      orElse: () => economy,
    );
  }
}
