import 'package:delivery_app/shared/widgets/branding/app_brand_icon.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:flutter/material.dart';

/// Compact Nokta wordmark for main-shell tab AppBars.
class ShellAppBarLogo extends StatelessWidget {
  const ShellAppBarLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: AppSpacing.sm),
      child: Center(
        child: AppBrandIcon(size: 36, filled: false),
      ),
    );
  }
}
