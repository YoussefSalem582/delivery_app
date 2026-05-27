import 'package:delivery_app/core/utils/map_config.dart';
import 'package:delivery_app/core/widgets/animated_map_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DeliveryMap extends StatefulWidget {
  const DeliveryMap({
    super.key,
    required this.center,
    this.zoom = MapConfig.defaultZoom,
    this.polylines = const [],
    this.markers = const [],
    this.followCenter = false,
    this.darkDim = false,
  });

  final LatLng center;
  final double zoom;
  final List<LatLng> polylines;
  final List<MapMarkerData> markers;
  final bool followCenter;
  final bool darkDim;

  @override
  State<DeliveryMap> createState() => DeliveryMapState();
}

class DeliveryMapState extends State<DeliveryMap> {
  final _controller = MapController();

  void recenter([LatLng? point]) {
    _controller.move(point ?? widget.center, widget.zoom);
  }

  @override
  void didUpdateWidget(covariant DeliveryMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.followCenter && oldWidget.center != widget.center) {
      _controller.move(widget.center, widget.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final map = FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: widget.center,
        initialZoom: widget.zoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: MapConfig.tileUrlTemplate,
          userAgentPackageName: MapConfig.userAgentPackageName,
        ),
        if (widget.polylines.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.polylines,
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 4,
              ),
            ],
          ),
        MarkerLayer(
          markers: widget.markers
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

    if (!widget.darkDim) return map;

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        0.4, 0, 0, 0, 0,
        0, 0.4, 0, 0, 0,
        0, 0, 0.4, 0, 0,
        0, 0, 0, 1, 0,
      ]),
      child: map,
    );
  }
}
