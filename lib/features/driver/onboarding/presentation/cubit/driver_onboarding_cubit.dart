import 'package:delivery_app/features/driver/shared/domain/entities/driver_profile_entity.dart';
import 'package:delivery_app/features/driver/shared/domain/usecases/driver_profile_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'driver_onboarding_state.dart';

class DriverOnboardingCubit extends Cubit<DriverOnboardingState> {
  DriverOnboardingCubit({required RegisterDriverUseCase registerDriver})
    : _registerDriver = registerDriver,
      super(const DriverOnboardingState());

  final RegisterDriverUseCase _registerDriver;

  void phoneChanged(String value) {
    emit(
      state.copyWith(
        phone: value,
        phoneError: null,
        status: DriverOnboardingStatus.editing,
      ),
    );
  }

  void vehicleTypeChanged(String value) {
    emit(
      state.copyWith(
        vehicleType: value,
        vehicleTypeError: null,
        status: DriverOnboardingStatus.editing,
      ),
    );
  }

  void vehicleMakeModelChanged(String value) {
    emit(
      state.copyWith(
        vehicleMakeModel: value,
        vehicleMakeModelError: null,
        status: DriverOnboardingStatus.editing,
      ),
    );
  }

  void licensePlateChanged(String value) {
    emit(
      state.copyWith(
        licensePlate: value,
        licensePlateError: null,
        status: DriverOnboardingStatus.editing,
      ),
    );
  }

  void termsChanged(bool value) {
    emit(
      state.copyWith(
        termsAccepted: value,
        termsError: null,
        status: DriverOnboardingStatus.editing,
      ),
    );
  }

  void initializePhone(String phone) {
    if (state.phone.isNotEmpty) return;
    emit(state.copyWith(phone: phone));
  }

  bool _validate() {
    String? phoneError;
    String? vehicleTypeError;
    String? vehicleMakeModelError;
    String? licensePlateError;
    String? termsError;

    final phone = state.phone.trim();
    if (phone.isEmpty) {
      phoneError = 'driver_onboarding_phone_required';
    } else if (phone.replaceAll(RegExp(r'\D'), '').length < 8) {
      phoneError = 'driver_onboarding_phone_invalid';
    }

    if (state.vehicleType.trim().isEmpty) {
      vehicleTypeError = 'driver_onboarding_vehicle_type_required';
    }

    if (state.vehicleMakeModel.trim().isEmpty) {
      vehicleMakeModelError = 'driver_onboarding_make_model_required';
    }

    if (state.licensePlate.trim().isEmpty) {
      licensePlateError = 'driver_onboarding_plate_required';
    }

    if (!state.termsAccepted) {
      termsError = 'driver_onboarding_terms_required';
    }

    emit(
      state.copyWith(
        phoneError: phoneError,
        vehicleTypeError: vehicleTypeError,
        vehicleMakeModelError: vehicleMakeModelError,
        licensePlateError: licensePlateError,
        termsError: termsError,
      ),
    );

    return phoneError == null &&
        vehicleTypeError == null &&
        vehicleMakeModelError == null &&
        licensePlateError == null &&
        termsError == null;
  }

  Future<void> submit() async {
    if (!_validate()) return;

    emit(state.copyWith(status: DriverOnboardingStatus.submitting));
    final result = await _registerDriver(
      RegisterDriverParams(
        phone: state.phone.trim(),
        vehicleType: state.vehicleType.trim(),
        vehicleMakeModel: state.vehicleMakeModel.trim(),
        licensePlate: state.licensePlate.trim(),
        termsAccepted: state.termsAccepted,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DriverOnboardingStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (profile) => emit(
        state.copyWith(
          status: DriverOnboardingStatus.success,
          profile: profile,
        ),
      ),
    );
  }
}
