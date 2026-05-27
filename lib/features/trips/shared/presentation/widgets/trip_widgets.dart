import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TripStatusChip extends StatelessWidget {
  const TripStatusChip({
    super.key,
    required this.status,
    this.compact = false,
    this.live = false,
  });

  final TripStatus status;
  final bool compact;
  final bool live;

  bool get _isLiveStatus =>
      status == TripStatus.inProgress ||
      status == TripStatus.accepted ||
      status == TripStatus.driverArrived;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = _style(status, Theme.of(context).colorScheme);
    final showPulse = live && _isLiveStatus;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 6 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPulse) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(begin: 1, end: 0.35, duration: 800.ms)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(0.85, 0.85),
                  duration: 800.ms,
                ),
            const SizedBox(width: 6),
          ] else ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
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

class TripRouteColumn extends StatelessWidget {
  const TripRouteColumn({
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
        const SizedBox(width: AppSpacing.md),
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
              const SizedBox(height: AppSpacing.md),
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
