import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openExternalMaps({
  required double lat,
  required double lng,
  String? label,
}) async {
  final encodedLabel = Uri.encodeComponent(label ?? 'Destination');
  final Uri uri;

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    uri = Uri.parse(
      'https://maps.apple.com/?ll=$lat,$lng&q=$encodedLabel',
    );
  } else {
    uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
  }

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
