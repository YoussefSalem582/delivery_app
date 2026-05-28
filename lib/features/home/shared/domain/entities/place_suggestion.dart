import 'package:equatable/equatable.dart';

class PlaceSuggestion extends Equatable {
  const PlaceSuggestion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.lat,
    required this.lng,
  });

  final String id;
  final String title;
  final String subtitle;
  final double lat;
  final double lng;

  String get displayAddress {
    if (subtitle.isEmpty) return title;
    return '$title, $subtitle';
  }

  @override
  List<Object?> get props => [id, title, subtitle, lat, lng];
}
