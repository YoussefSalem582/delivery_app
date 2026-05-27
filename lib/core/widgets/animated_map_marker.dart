import 'package:flutter/material.dart';

class AnimatedMapMarker extends StatefulWidget {
  const AnimatedMapMarker({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.rotation,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double? rotation;

  @override
  State<AnimatedMapMarker> createState() => _AnimatedMapMarkerState();
}

class _AnimatedMapMarkerState extends State<AnimatedMapMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marker = ScaleTransition(
      scale: _scale,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(widget.icon, color: widget.color, size: widget.size),
        ),
      ),
    );

    if (widget.rotation == null) return marker;

    return Transform.rotate(
      angle: widget.rotation! * 3.141592653589793 / 180,
      child: marker,
    );
  }
}
