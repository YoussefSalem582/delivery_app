import 'package:latlong2/latlong.dart';

/// Demo dropoff coordinates offset from the user's current position.
class DemoDestinations {
  DemoDestinations._();

  static const maxOsrmDistanceMeters = 500000;

  static LatLng nearPickup({
    required double pickupLat,
    required double pickupLng,
    String key = 'default',
  }) {
    return switch (key) {
      'home' => LatLng(pickupLat + 0.012, pickupLng + 0.008),
      'work' => LatLng(pickupLat + 0.006, pickupLng + 0.018),
      'airport' => LatLng(pickupLat - 0.015, pickupLng + 0.022),
      _ => LatLng(pickupLat + 0.01, pickupLng + 0.01),
    };
  }

  static String labelKey(String key) => switch (key) {
        'home' => 'quick_home',
        'work' => 'quick_work',
        'airport' => 'quick_airport',
        _ => 'search_destination',
      };
}
