import 'dart:convert';

import 'package:flutter/services.dart';

/// In-memory mock backend state seeded from JSON assets.
class MockApiStore {
  MockApiStore._();

  static final MockApiStore instance = MockApiStore._();

  bool _initialized = false;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _trips = [];
  List<Map<String, dynamic>> _drivers = [];
  List<Map<String, dynamic>> _riders = [];
  final Set<String> _declinedOfferIds = {};
  DriverAvailabilityState _availability = DriverAvailabilityState.offline;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _profile = await _loadJsonMap('assets/mock/profile.json');
    _trips = (await _loadJsonList('assets/mock/trips.json'))
        .cast<Map<String, dynamic>>()
        .map(_normalizeTrip)
        .toList();
    _drivers = (await _loadJsonList('assets/mock/drivers.json'))
        .cast<Map<String, dynamic>>()
        .toList();
    _riders = (await _loadJsonList('assets/mock/riders.json'))
        .cast<Map<String, dynamic>>()
        .toList();
    _initialized = true;
  }

  void reset() {
    _initialized = false;
    _profile = null;
    _trips = [];
    _drivers = [];
    _riders = [];
    _declinedOfferIds.clear();
    _availability = DriverAvailabilityState.offline;
  }

  Map<String, dynamic>? get profile => _profile == null
      ? null
      : Map<String, dynamic>.from(_profile!);

  List<Map<String, dynamic>> get trips =>
      _trips.map(Map<String, dynamic>.from).toList();

  List<Map<String, dynamic>> get drivers =>
      _drivers.map(Map<String, dynamic>.from).toList();

  List<Map<String, dynamic>> get riders =>
      _riders.map(Map<String, dynamic>.from).toList();

  DriverAvailabilityState get availability => _availability;

  void setAvailability(DriverAvailabilityState value) {
    _availability = value;
  }

  Map<String, dynamic>? tripById(String id) {
    for (final trip in _trips) {
      if (trip['id'] == id) return Map<String, dynamic>.from(trip);
    }
    return null;
  }

  void upsertTrip(Map<String, dynamic> trip) {
    final id = trip['id'] as String;
    final index = _trips.indexWhere((t) => t['id'] == id);
    if (index >= 0) {
      _trips[index] = Map<String, dynamic>.from(trip);
    } else {
      _trips.insert(0, Map<String, dynamic>.from(trip));
    }
  }

  void updateProfile(Map<String, dynamic> profile) {
    _profile = Map<String, dynamic>.from(profile);
  }

  void upsertDriver(Map<String, dynamic> driver) {
    final id = driver['id'] as String;
    final index = _drivers.indexWhere((d) => d['id'] == id);
    if (index >= 0) {
      _drivers[index] = Map<String, dynamic>.from(driver);
    } else {
      _drivers.add(Map<String, dynamic>.from(driver));
    }
  }

  Map<String, dynamic>? driverById(String id) {
    for (final driver in _drivers) {
      if (driver['id'] == id) return Map<String, dynamic>.from(driver);
    }
    return null;
  }

  List<Map<String, dynamic>> offersForDriver(String driverUserId) {
    return _trips.where((trip) {
      final id = trip['id'] as String;
      if (_declinedOfferIds.contains(id)) return false;
      if (trip['status'] != 'requested') return false;
      if (trip['driverId'] != null) return false;
      final riderId = trip['riderId'] as String?;
      if (riderId == null || riderId == driverUserId) return false;
      return true;
    }).map((t) => Map<String, dynamic>.from(t)).toList();
  }

  void declineOffer(String tripId) {
    _declinedOfferIds.add(tripId);
  }

  Map<String, dynamic> _normalizeTrip(Map<String, dynamic> trip) {
    final normalized = Map<String, dynamic>.from(trip);
    normalized.putIfAbsent('riderId', () => 'user-001');
    return normalized;
  }

  Future<List<dynamic>> _loadJsonList(String asset) async {
    final raw = await rootBundle.loadString(asset);
    return jsonDecode(raw) as List<dynamic>;
  }

  Future<Map<String, dynamic>> _loadJsonMap(String asset) async {
    final raw = await rootBundle.loadString(asset);
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}

enum DriverAvailabilityState {
  offline,
  online,
  onTrip,
}
