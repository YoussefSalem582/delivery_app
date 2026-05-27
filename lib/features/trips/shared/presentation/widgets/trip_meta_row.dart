import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/presentation/widgets/trip_meta_helpers.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:flutter/material.dart';

class TripMetaRow extends StatelessWidget {
  const TripMetaRow({
    super.key,
    required this.trip,
    this.compact = false,
  });

  final TripEntity trip;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final labels = tripMetaLabels(trip);
    if (labels.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final style = (compact
            ? Theme.of(context).textTheme.labelSmall
            : Theme.of(context).textTheme.bodySmall)
        ?.copyWith(color: scheme.outline);

    return Padding(
      padding: EdgeInsets.only(top: compact ? AppSpacing.xs : AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: labels
            .map(
              (label) => Text(
                label,
                style: style,
              ),
            )
            .toList(),
      ),
    );
  }
}
