part of 'driver_onboarding_cubit.dart';

enum DriverOnboardingStatus { editing, submitting, success, failure }

class DriverOnboardingState extends Equatable {
  const DriverOnboardingState({
    this.phone = '',
    this.vehicleType = '',
    this.vehicleMakeModel = '',
    this.licensePlate = '',
    this.termsAccepted = false,
    this.phoneError,
    this.vehicleTypeError,
    this.vehicleMakeModelError,
    this.licensePlateError,
    this.termsError,
    this.status = DriverOnboardingStatus.editing,
    this.errorMessage,
    this.profile,
  });

  final String phone;
  final String vehicleType;
  final String vehicleMakeModel;
  final String licensePlate;
  final bool termsAccepted;
  final String? phoneError;
  final String? vehicleTypeError;
  final String? vehicleMakeModelError;
  final String? licensePlateError;
  final String? termsError;
  final DriverOnboardingStatus status;
  final String? errorMessage;
  final DriverProfileEntity? profile;

  bool get isSubmitting => status == DriverOnboardingStatus.submitting;

  DriverOnboardingState copyWith({
    String? phone,
    String? vehicleType,
    String? vehicleMakeModel,
    String? licensePlate,
    bool? termsAccepted,
    String? phoneError,
    String? vehicleTypeError,
    String? vehicleMakeModelError,
    String? licensePlateError,
    String? termsError,
    DriverOnboardingStatus? status,
    String? errorMessage,
    DriverProfileEntity? profile,
  }) {
    return DriverOnboardingState(
      phone: phone ?? this.phone,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleMakeModel: vehicleMakeModel ?? this.vehicleMakeModel,
      licensePlate: licensePlate ?? this.licensePlate,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      phoneError: phoneError,
      vehicleTypeError: vehicleTypeError,
      vehicleMakeModelError: vehicleMakeModelError,
      licensePlateError: licensePlateError,
      termsError: termsError,
      status: status ?? this.status,
      errorMessage: errorMessage,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [
    phone,
    vehicleType,
    vehicleMakeModel,
    licensePlate,
    termsAccepted,
    phoneError,
    vehicleTypeError,
    vehicleMakeModelError,
    licensePlateError,
    termsError,
    status,
    errorMessage,
    profile,
  ];
}
