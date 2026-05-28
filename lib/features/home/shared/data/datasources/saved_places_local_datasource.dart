import 'dart:convert';

import 'package:delivery_app/features/trips/shared/domain/entities/location_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SavedPlaceType { home, work }

class SavedPlacesLocalDataSource {
  SavedPlacesLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _homeKey = 'saved_place_home';
  static const _workKey = 'saved_place_work';

  LocationEntity? getHome() => _read(_homeKey);

  LocationEntity? getWork() => _read(_workKey);

  LocationEntity? getPlace(SavedPlaceType type) => switch (type) {
        SavedPlaceType.home => getHome(),
        SavedPlaceType.work => getWork(),
      };

  Future<void> saveHome(LocationEntity location) =>
      _write(_homeKey, location);

  Future<void> saveWork(LocationEntity location) =>
      _write(_workKey, location);

  LocationEntity? _read(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return LocationEntity.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _write(String key, LocationEntity location) async {
    await _prefs.setString(key, jsonEncode(location.toJson()));
  }
}
