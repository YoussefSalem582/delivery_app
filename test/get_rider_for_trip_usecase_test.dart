import 'package:delivery_app/features/trips/shared/domain/entities/rider_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/repositories/rider_repository.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/get_rider_for_trip_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRiderRepository extends Mock implements RiderRepository {}

const _rider = RiderEntity(
  id: 'user-rider-demo',
  name: 'Sara Ali',
  phone: '+201112223344',
  rating: 4.9,
  avatarUrl: 'https://example.com/avatar.png',
);

void main() {
  late MockRiderRepository repository;
  late GetRiderForTripUseCase useCase;

  setUp(() {
    repository = MockRiderRepository();
    useCase = GetRiderForTripUseCase(repository);
  });

  test('returns rider when found by id', () async {
    when(() => repository.findById('user-rider-demo'))
        .thenAnswer((_) async => _rider);

    final result = await useCase(
      const GetRiderForTripParams(riderId: 'user-rider-demo'),
    );

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('expected success'), (rider) {
      expect(rider?.name, 'Sara Ali');
      expect(rider?.phone, '+201112223344');
    });
  });

  test('returns null when rider id is empty', () async {
    final result = await useCase(const GetRiderForTripParams(riderId: ''));

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('expected success'), (rider) {
      expect(rider, isNull);
    });
    verifyNever(() => repository.findById(any()));
  });
}
