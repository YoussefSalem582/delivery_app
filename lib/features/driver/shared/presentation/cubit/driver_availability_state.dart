part of 'driver_availability_cubit.dart';

class DriverAvailabilityState extends Equatable {
  const DriverAvailabilityState({
    this.availability = DriverAvailability.offline,
    this.isUpdating = false,
  });

  final DriverAvailability availability;
  final bool isUpdating;

  bool get isOnline =>
      availability == DriverAvailability.online ||
      availability == DriverAvailability.onTrip;

  DriverAvailabilityState copyWith({
    DriverAvailability? availability,
    bool? isUpdating,
  }) {
    return DriverAvailabilityState(
      availability: availability ?? this.availability,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [availability, isUpdating];
}
