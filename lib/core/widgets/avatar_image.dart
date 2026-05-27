import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AvatarImage extends StatelessWidget {
  const AvatarImage({
    super.key,
    this.imageUrl,
    required this.fallback,
    this.radius = 40,
  });

  final String? imageUrl;
  final String fallback;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        child: Text(
          fallback.isNotEmpty ? fallback[0].toUpperCase() : '?',
          style: TextStyle(fontSize: radius * 0.7),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (_, __) => SizedBox(
            width: radius,
            height: radius,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (_, __, ___) => Text(
            fallback.isNotEmpty ? fallback[0].toUpperCase() : '?',
            style: TextStyle(fontSize: radius * 0.7),
          ),
        ),
      ),
    );
  }
}
