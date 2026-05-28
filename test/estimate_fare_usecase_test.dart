import 'package:delivery_app/core/config/pricing_config.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/estimate_fare_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final useCase = EstimateFareUseCase();

  test('calculates economy fare as base plus distance charge', () async {
    final result = await useCase(
      const EstimateFareParams(
        tierKey: 'ride_economy',
        distanceKm: 5,
      ),
    );

    result.fold(
      (_) => fail('Expected success'),
      (estimate) {
        expect(estimate.baseFare, 5);
        expect(estimate.distanceCharge, 12.5);
        expect(estimate.fare, 17.5);
      },
    );
  });

  test('applies minimum fare when raw total is below minimum', () async {
    final result = await useCase(
      const EstimateFareParams(
        tierKey: 'ride_economy',
        distanceKm: 0.5,
      ),
    );

    result.fold(
      (_) => fail('Expected success'),
      (estimate) {
        expect(estimate.fare, PricingConfig.economy.minimumFare);
        expect(estimate.usedMinimumFare, isTrue);
      },
    );
  });

  test('calculates premium fare with higher per-km rate', () async {
    final result = await useCase(
      const EstimateFareParams(
        tierKey: 'ride_premium',
        distanceKm: 10,
      ),
    );

    result.fold(
      (_) => fail('Expected success'),
      (estimate) {
        expect(estimate.baseFare, 8);
        expect(estimate.distanceCharge, 40);
        expect(estimate.fare, 48);
      },
    );
  });

  test('returns validation failure for negative distance', () async {
    final result = await useCase(
      const EstimateFareParams(
        tierKey: 'ride_delivery',
        distanceKm: -1,
      ),
    );

    expect(result.isLeft(), isTrue);
  });
}
