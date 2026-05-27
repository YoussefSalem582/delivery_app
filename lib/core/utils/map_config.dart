import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapMarkerData {
  const MapMarkerData({
    required this.point,
    required this.color,
    this.icon = Icons.place,
    this.size = 36,
    this.animate = false,
    this.rotation,
  });

  final LatLng point;
  final Color color;
  final IconData icon;
  final double size;
  final bool animate;
  final double? rotation;
}

class MapConfig {
  static const defaultZoom = 14.0;
  static const tileUrlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const darkTileUrlTemplate =
      'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
  static const userAgentPackageName = 'com.showcase.delivery.delivery_app';
}
