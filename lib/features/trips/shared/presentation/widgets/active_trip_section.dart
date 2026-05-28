import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/presentation/widgets/trip_card.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:delivery_app/shared/widgets/feedback/section_header.dart';
import 'package:flutter/material.dart';

/// Highlighted active trip block with CTA — shared by rider and driver home.
class ActiveTripSection extends StatelessWidget {
  const ActiveTripSection({
    super.key,
    required this.title,
    required this.trip,
    required this.actionLabel,
    required this.onAction,
    this.onCardTap,
    this.actionIcon,
    this.footer,
    this.pendingRetryCount = 0,
  });

  final String title;
  final TripEntity trip;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback? onCardTap;
  final IconData? actionIcon;
  final Widget? footer;
  final int pendingRetryCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: title),
        TripAccentCard(
          trip: trip,
          highlighted: true,
          liveStatus: true,
          pendingRetryCount: pendingRetryCount,
          onTap: onCardTap,
        ),
        if (footer != null) ...[
          const SizedBox(height: AppSpacing.sm),
          footer!,
        ],
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: actionLabel,
          icon: actionIcon,
          onPressed: onAction,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
