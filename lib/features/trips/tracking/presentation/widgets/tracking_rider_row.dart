import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/core/widgets/avatar_image.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TrackingRiderRow extends StatelessWidget {
  const TrackingRiderRow({
    super.key,
    required this.tripId,
    required this.riderName,
    this.avatarUrl,
    this.rating,
    this.phone,
  });

  final String tripId;
  final String riderName;
  final String? avatarUrl;
  final double? rating;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final subtitleParts = <String>[];
    if (rating != null) subtitleParts.add(rating!.toStringAsFixed(1));

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              AvatarImage(
                imageUrl: avatarUrl,
                fallback: riderName,
                radius: 24,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'passenger'.tr()}: $riderName',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: scheme.onSurface,
                          ),
                    ),
                    if (subtitleParts.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: AppColors.tertiaryFixedDim,
                          ),
                          const SizedBox(width: 4),
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
            ],
          ),
        ),
        if (phone != null && phone!.isNotEmpty) ...[
          Semantics(
            label: 'message_passenger'.tr(),
            button: true,
            child: _ContactButton(
              icon: Icons.chat_bubble_outline,
              onPressed: () => context.pushNamed(
                RouteNames.driverChat,
                pathParameters: {'tripId': tripId},
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Semantics(
            label: 'call_passenger'.tr(),
            button: true,
            child: _ContactButton(
              icon: Icons.call,
              onPressed: () => context.pushNamed(
                RouteNames.driverCall,
                pathParameters: {'tripId': tripId},
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({required this.icon, required this.onPressed});

  final IconData icon;
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
          child: Icon(icon, size: 22, color: scheme.primary),
        ),
      ),
    );
  }
}
