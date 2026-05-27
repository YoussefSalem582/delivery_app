import 'package:delivery_app/core/widgets/nokta_brand_icon.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Parses [NoktaBrandIcon.assetPath] once at startup for smoother first paint.
Future<void> precacheNoktaLogo() async {
  final loader = SvgAssetLoader(NoktaBrandIcon.assetPath);
  await svg.cache.putIfAbsent(
    loader.cacheKey(null),
    () => loader.loadBytes(null),
  );
}
