import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/core/utils/phone_launcher.dart';
import 'package:delivery_app/core/widgets/avatar_image.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TrackingDriverRow extends StatelessWidget {
  const TrackingDriverRow({
    super.key,
    required this.driverName,
    this.avatarUrl,
    this.rating,
    this.vehicle,
    this.phone,
  });

  final String driverName;
  final String? avatarUrl;
  final double? rating;
  final String? vehicle;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final subtitleParts = <String>[];
    if (rating != null) subtitleParts.add(rating!.toStringAsFixed(1));
    if (vehicle != null && vehicle!.isNotEmpty) {
      subtitleParts.add(vehicle!);
    }

    return Row(
      children: [
        AvatarImage(
          imageUrl: avatarUrl,
          fallback: driverName,
          radius: 24,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${'driver'.tr()}: $driverName',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.onSurface,
                    ),
              ),
              if (subtitleParts.isNotEmpty)
                Row(
                  children: [
                    if (rating != null) ...[
                      Icon(
                        Icons.star,
                        size: 16,
                        color: AppColors.tertiaryFixedDim,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        subtitleParts.join(' • '),
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (phone != null && phone!.isNotEmpty)
          Semantics(
            label: 'call_driver'.tr(),
            button: true,
            child: _CallButton(
              onPressed: () => launchPhoneCall(phone!),
            ),
          ),
      ],
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainer,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.call, size: 22, color: scheme.primary),
        ),
      ),
    );
  }
}
