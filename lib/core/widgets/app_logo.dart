import 'package:delivery_app/core/widgets/nokta_brand_icon.dart';
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return NoktaBrandIcon(size: size, filled: false);
  }
}
