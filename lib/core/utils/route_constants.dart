/// Constants for OSRM route fetching.
abstract final class RouteConstants {
  /// Max straight-line distance for OSRM demo routing (avoids timeout on far coords).
  static const maxOsrmDistanceMeters = 50000;
}
