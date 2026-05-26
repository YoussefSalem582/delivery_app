import 'package:delivery_app/core/utils/map_config.dart';
import 'package:delivery_app/core/utils/map_tile_cache.dart';
import 'package:delivery_app/core/widgets/animated_map_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

class DeliveryMap extends StatefulWidget {
  const DeliveryMap({
    super.key,
    required this.center,
    this.zoom = MapConfig.defaultZoom,
    this.polylines = const [],
    this.markers = const [],
    this.followCenter = false,
    this.showUserLocation = false,
    this.fitRouteBounds = false,
  });

  final LatLng center;
  final double zoom;
  final List<LatLng> polylines;
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
    if (!widget.fitRouteBounds ||
        widget.polylines.length < 2 ||
        _didFitBounds) {
      return;
    }
    _didFitBounds = true;
    final bounds = LatLngBounds.fromPoints(widget.polylines);
    _animatedController.animatedFitCamera(
      cameraFit: CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(48),
      ),
    );
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
        widget.polylines.length >= 2 &&
        oldWidget.polylines != widget.polylines) {
      _didFitBounds = false;
      _maybeFitBounds();
    }
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
        if (widget.polylines.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.polylines,
                color: scheme.primary,
                strokeWidth: 4,
              ),
            ],
          ),
        if (widget.showUserLocation)
          CurrentLocationLayer(
            alignPositionOnUpdate: widget.followCenter
                ? AlignOnUpdate.always
                : AlignOnUpdate.never,
            alignDirectionOnUpdate: AlignOnUpdate.never,
            headingStream: Stream<LocationMarkerHeading?>.empty(),
            style: LocationMarkerStyle(
              marker: DefaultLocationMarker(
                color: scheme.primaryContainer,
              ),
              markerSize: const Size(28, 28),
              accuracyCircleColor: scheme.primary.withValues(alpha: 0.15),
              showHeadingSector: false,
            ),
          ),
        MarkerLayer(
          markers: widget.markers
              .where(
                (m) => !(widget.showUserLocation && m.icon == Icons.my_location),
              )
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
                        )
                      : Icon(m.icon, color: m.color, size: m.size),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
