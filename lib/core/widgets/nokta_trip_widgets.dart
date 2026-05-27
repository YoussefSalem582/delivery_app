import 'package:delivery_app/core/architecture/entities/trip_entity.dart';
import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NoktaStatusChip extends StatelessWidget {
  const NoktaStatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  final TripStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = _style(status, Theme.of(context).colorScheme);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            tripStatusLabel(status),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  static (Color bg, Color fg, IconData icon) _style(
    TripStatus status,
    ColorScheme scheme,
  ) {
    return switch (status) {
      TripStatus.inProgress ||
      TripStatus.accepted ||
      TripStatus.driverArrived =>
        (scheme.primaryContainer, scheme.onPrimary, Icons.directions_car),
      TripStatus.completed =>
        (scheme.secondaryContainer, scheme.onSecondaryContainer, Icons.check_circle),
      TripStatus.cancelled =>
        (scheme.errorContainer, scheme.onErrorContainer, Icons.cancel),
      TripStatus.requested =>
        (scheme.surfaceContainer, scheme.onSurfaceVariant, Icons.schedule),
    };
  }
}

class NoktaTripRouteColumn extends StatelessWidget {
  const NoktaTripRouteColumn({
    super.key,
    required this.pickup,
    required this.dropoff,
    this.pickupSubtitle,
    this.dropoffSubtitle,
    this.dimmed = false,
  });

  final String pickup;
  final String dropoff;
  final String? pickupSubtitle;
  final String? dropoffSubtitle;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final iconColor = dimmed ? scheme.onSurfaceVariant : scheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(Icons.radio_button_checked, size: 18, color: iconColor),
            Container(
              width: 2,
              height: 32,
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            Icon(
              Icons.location_on_outlined,
              size: 18,
              color: dimmed ? scheme.onSurfaceVariant : scheme.outline,
            ),
          ],
        ),
        const SizedBox(width: NoktaSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pickup,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (pickupSubtitle != null)
                Text(pickupSubtitle!, style: textTheme.bodyMedium),
              const SizedBox(height: NoktaSpacing.md),
              Text(
                dropoff,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyLarge,
              ),
              if (dropoffSubtitle != null)
                Text(dropoffSubtitle!, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

String formatTripDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tripDay = DateTime(date.year, date.month, date.day);
  final time = DateFormat.jm().format(date);

  if (tripDay == today) return '${'today'.tr()}, $time';
  if (tripDay == today.subtract(const Duration(days: 1))) {
    return '${'yesterday'.tr()}, $time';
  }
  return DateFormat('MMM d, y • h:mm a').format(date);
}
