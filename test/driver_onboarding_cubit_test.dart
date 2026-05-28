import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_app/core/error/failures.dart';
import 'package:delivery_app/features/driver/onboarding/presentation/cubit/driver_onboarding_cubit.dart';
import 'package:delivery_app/features/driver/shared/domain/entities/driver_profile_entity.dart';
import 'package:delivery_app/features/driver/shared/domain/usecases/driver_profile_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterDriverUseCase extends Mock implements RegisterDriverUseCase {}

void main() {
  late MockRegisterDriverUseCase registerDriver;

  setUpAll(() {
    registerFallbackValue(
      const RegisterDriverParams(
        phone: '+201000000000',
        vehicleType: 'economy',
        vehicleMakeModel: 'Toyota Corolla',
        licensePlate: 'ABC 123',
        termsAccepted: true,
      ),
    );
  });

  setUp(() {
    registerDriver = MockRegisterDriverUseCase();
  });

  DriverOnboardingCubit buildCubit() =>
      DriverOnboardingCubit(registerDriver: registerDriver);

  void fillValidForm(DriverOnboardingCubit cubit) {
    cubit
      ..phoneChanged('+201000000001')
      ..vehicleTypeChanged('economy')
      ..vehicleMakeModelChanged('Toyota Corolla')
      ..licensePlateChanged('ABC 123')
      ..termsChanged(true);
  }

  group('DriverOnboardingCubit', () {
    test('validation fails when required fields are empty', () async {
      final cubit = buildCubit();
      await cubit.submit();

      expect(cubit.state.phoneError, isNotNull);
      expect(cubit.state.vehicleTypeError, isNotNull);
      expect(cubit.state.status, DriverOnboardingStatus.editing);
    });

    test('emits success when registration succeeds', () async {
      when(() => registerDriver(any())).thenAnswer(
        (_) async => Right(
          DriverProfileEntity(
            phone: '+201000000001',
            vehicleType: 'economy',
            vehicleMakeModel: 'Toyota Corolla',
            licensePlate: 'ABC 123',
            registeredAt: DateTime.utc(2026, 5, 28),
            termsAccepted: true,
          ),
        ),
      );

      final cubit = buildCubit();
      fillValidForm(cubit);
      await cubit.submit();

      expect(cubit.state.status, DriverOnboardingStatus.success);
      expect(cubit.state.profile?.licensePlate, 'ABC 123');
    });

    blocTest<DriverOnboardingCubit, DriverOnboardingState>(
      'emits failure when registration fails',
      build: () {
        when(() => registerDriver(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Registration failed')),
        );
        final cubit = buildCubit();
        fillValidForm(cubit);
        return cubit;
      },
      act: (cubit) => cubit.submit(),
      expect: () => [
        isA<DriverOnboardingState>().having(
          (s) => s.status,
          'status',
          DriverOnboardingStatus.submitting,
        ),
        isA<DriverOnboardingState>().having(
          (s) => s.status,
          'status',
          DriverOnboardingStatus.failure,
        ),
      ],
    );
  });
}
