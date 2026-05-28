enum DriverAvailability { offline, online, onTrip }

extension DriverAvailabilityX on DriverAvailability {
  String get storageKey => name;
}
