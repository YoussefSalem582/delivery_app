import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/widgets/nokta_trip_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Compact offline indicator for list tabs and profile sections.
class NoktaOfflineSectionBanner extends StatelessWidget {
  const NoktaOfflineSectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return const NoktaOfflineTripsBanner();
  }
}

/// App-wide slim banner shown when the device has no network link.
class NoktaGlobalOfflineBanner extends StatelessWidget {
  const NoktaGlobalOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: NoktaColors.tertiaryFixedDim,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: NoktaSpacing.md,
            vertical: NoktaSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 18, color: scheme.onSurface),
              const SizedBox(width: NoktaSpacing.sm),
              Text(
                'offline_banner'.tr(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
