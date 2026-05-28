import 'package:delivery_app/features/home/shared/domain/entities/place_suggestion.dart';

class NominatimPlaceModel {
  const NominatimPlaceModel({
    required this.placeId,
    required this.lat,
    required this.lng,
    required this.displayName,
    this.address,
  });

  final int placeId;
  final double lat;
  final double lng;
  final String displayName;
  final Map<String, dynamic>? address;

  factory NominatimPlaceModel.fromJson(Map<String, dynamic> json) {
    return NominatimPlaceModel(
      placeId: json['place_id'] as int,
      lat: double.parse(json['lat'] as String),
      lng: double.parse(json['lon'] as String),
      displayName: json['display_name'] as String? ?? '',
      address: json['address'] as Map<String, dynamic>?,
    );
  }

  PlaceSuggestion toEntity() {
    final addr = address ?? const {};
    return PlaceSuggestion(
      id: placeId.toString(),
      title: _titleFromAddress(addr, displayName),
      subtitle: _subtitleFromAddress(addr, displayName),
      lat: lat,
      lng: lng,
    );
  }

  static String _titleFromAddress(
    Map<String, dynamic> addr,
    String displayName,
  ) {
    for (final key in [
      'name',
      'building',
      'road',
      'pedestrian',
      'footway',
      'suburb',
      'neighbourhood',
      'city',
      'town',
      'village',
    ]) {
      final value = addr[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    final parts = displayName.split(',');
    return parts.isNotEmpty ? parts.first.trim() : displayName;
  }

  static String _subtitleFromAddress(
    Map<String, dynamic> addr,
    String displayName,
  ) {
    final parts = <String>[];

    void add(String key) {
      final value = addr[key];
      if (value is String && value.trim().isNotEmpty) {
        parts.add(value.trim());
      }
    }

    add('suburb');
    add('city');
    add('town');
    add('state');
    add('country');

    if (parts.isNotEmpty) {
      return parts.toSet().join(', ');
    }

    final segments = displayName.split(',');
    if (segments.length > 1) {
      return segments.skip(1).take(2).join(', ').trim();
    }

    return '';
  }
}
