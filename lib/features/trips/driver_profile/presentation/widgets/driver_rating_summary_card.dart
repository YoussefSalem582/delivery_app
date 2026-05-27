import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/driver_review_entity.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DriverRatingSummaryCard extends StatelessWidget {
  const DriverRatingSummaryCard({
    super.key,
    required this.summary,
  });

  final DriverRatingSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: isDark ? 0.45 : 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                summary.averageRating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < summary.averageRating.round()
                        ? Icons.star
                        : Icons.star_border,
                    size: 16,
                    color: AppColors.tertiaryFixedDim,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'driver_review_count'.tr(args: ['${summary.totalReviews}']),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final stars = 5 - index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _RatingBar(
                    stars: stars,
                    fraction: summary.fractionForStars(stars),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({
    required this.stars,
    required this.fraction,
  });

  final int stars;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 12,
          child: Text(
            '$stars',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        Icon(Icons.star, size: 12, color: AppColors.tertiaryFixedDim),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: scheme.surfaceContainerHighest,
              color: AppColors.tertiaryFixedDim,
            ),
          ),
        ),
      ],
    );
  }
}
