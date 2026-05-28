enum AppMode { passenger, driver }

extension AppModeX on AppMode {
  bool get isDriver => this == AppMode.driver;
  bool get isPassenger => this == AppMode.passenger;

  String get storageKey => name;
}
