import 'dart:math' as math;

import 'package:delivery_app/core/utils/map_config.dart';
import 'package:delivery_app/core/utils/map_tile_cache.dart';
import 'package:delivery_app/core/widgets/animated_map_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';

class DeliveryMap extends StatefulWidget {
  const DeliveryMap({
    super.key,
    required this.center,
    this.zoom = MapConfig.defaultZoom,
    this.polylines = const [],
    this.traveledRoute = const [],
    this.remainingRoute = const [],
    this.markers = const [],
    this.followCenter = false,
    this.showUserLocation = false,
    this.fitRouteBounds = false,
  });

  final LatLng center;
  final double zoom;
  final List<LatLng> polylines;
  final List<LatLng> traveledRoute;
  final List<LatLng> remainingRoute;
  final List<MapMarkerData> markers;
  final bool followCenter;
  final bool showUserLocation;
  final bool fitRouteBounds;

  @override
  State<DeliveryMap> createState() => DeliveryMapState();
}

class DeliveryMapState extends State<DeliveryMap> with TickerProviderStateMixin {
  late final AnimatedMapController _animatedController;
  bool _didFitBounds = false;

  @override
  void initState() {
    super.initState();
    _animatedController = AnimatedMapController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeFitBounds());
  }

  @override
  void dispose() {
    _animatedController.dispose();
    super.dispose();
  }

  void recenter([LatLng? point]) {
    _animatedController.animateTo(
      dest: point ?? widget.center,
      zoom: widget.zoom,
    );
  }

  void _maybeFitBounds() {
    final routePoints = _allRoutePoints();
    if (!widget.fitRouteBounds || routePoints.length < 2 || _didFitBounds) {
      return;
    }
    _didFitBounds = true;
    final bounds = LatLngBounds.fromPoints(routePoints);
    _animatedController.animatedFitCamera(
      cameraFit: CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(48),
      ),
    );
  }

  List<LatLng> _allRoutePoints() {
    if (widget.traveledRoute.isNotEmpty || widget.remainingRoute.isNotEmpty) {
      return [...widget.traveledRoute, ...widget.remainingRoute];
    }
    return widget.polylines;
  }

  @override
  void didUpdateWidget(covariant DeliveryMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.followCenter && oldWidget.center != widget.center) {
      _animatedController.animateTo(
        dest: widget.center,
        zoom: widget.zoom,
      );
    }
    if (widget.fitRouteBounds &&
        _allRoutePoints().length >= 2 &&
        (oldWidget.polylines != widget.polylines ||
            oldWidget.traveledRoute != widget.traveledRoute ||
            oldWidget.remainingRoute != widget.remainingRoute)) {
      _didFitBounds = false;
      _maybeFitBounds();
    }
  }

  List<MapMarkerData> get _allMarkers {
    final markers = List<MapMarkerData>.from(widget.markers);
    if (widget.showUserLocation &&
        !markers.any((m) => m.icon == Icons.my_location)) {
      markers.insert(
        0,
        MapMarkerData(
          point: widget.center,
          color: Theme.of(context).colorScheme.primaryContainer,
          icon: Icons.my_location,
          size: 32,
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final tileProvider = MapTileCache.tileProvider;

    return FlutterMap(
      mapController: _animatedController.mapController,
      options: MapOptions(
        initialCenter: widget.center,
        initialZoom: widget.zoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: isDark
              ? MapConfig.darkTileUrlTemplate
              : MapConfig.tileUrlTemplate,
          userAgentPackageName: MapConfig.userAgentPackageName,
          tileProvider: tileProvider,
        ),
        if (widget.traveledRoute.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.traveledRoute,
                color: scheme.outline.withValues(alpha: 0.55),
                strokeWidth: 4,
              ),
            ],
          ),
        if (widget.remainingRoute.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.remainingRoute,
                color: scheme.primary,
                strokeWidth: 4,
              ),
            ],
          )
        else if (widget.polylines.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.polylines,
                color: scheme.primary,
                strokeWidth: 4,
              ),
            ],
          ),
        MarkerLayer(
          markers: _allMarkers
              .map(
                (m) => Marker(
                  point: m.point,
                  width: m.animate ? m.size + 12 : m.size,
                  height: m.animate ? m.size + 12 : m.size,
                  child: m.animate
                      ? AnimatedMapMarker(
                          icon: m.icon,
                          color: m.color,
                          size: m.size,
                          rotation: m.rotation,
                        )
                      : _buildMarkerIcon(m),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMarkerIcon(MapMarkerData marker) {
    final icon = Icon(marker.icon, color: marker.color, size: marker.size);
    if (marker.rotation == null) return icon;

    return Transform.rotate(
      angle: marker.rotation! * math.pi / 180,
      child: icon,
    );
  }
}
