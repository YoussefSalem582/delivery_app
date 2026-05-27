import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/avatar_image.dart';
import 'package:delivery_app/core/widgets/skeleton_trip_card.dart';
import 'package:delivery_app/features/trips/driver_profile/presentation/bloc/driver_profile_bloc.dart';
import 'package:delivery_app/features/trips/driver_profile/presentation/widgets/driver_rating_summary_card.dart';
import 'package:delivery_app/features/trips/driver_profile/presentation/widgets/driver_review_card.dart';
import 'package:delivery_app/features/trips/driver_profile/presentation/widgets/driver_profile_stats_row.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DriverProfilePage extends StatelessWidget {
  const DriverProfilePage({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DriverProfileBloc>()
        ..add(DriverProfileLoadRequested(tripId)),
      child: BlocBuilder<DriverProfileBloc, DriverProfileState>(
        builder: (context, state) {
          if (state is DriverProfileLoading || state is DriverProfileInitial) {
            return Scaffold(
              appBar: AppBar(title: Text('driver_profile_title'.tr())),
              body: Skeletonizer(
                enabled: true,
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: const [
                    SkeletonListTile(),
                    SizedBox(height: AppSpacing.lg),
                    SkeletonListTile(),
                  ],
                ),
              ),
            );
          }

          if (state is DriverProfileError) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                title: Text('driver_profile_title'.tr()),
              ),
              body: ErrorView(
                message: state.message.tr(),
                onRetry: () => context.read<DriverProfileBloc>().add(
                      DriverProfileLoadRequested(tripId),
                    ),
              ),
            );
          }

          if (state is DriverProfileLoaded) {
            return _DriverProfileBody(profile: state.profile);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DriverProfileBody extends StatelessWidget {
  const _DriverProfileBody({required this.profile});

  final DriverProfileData profile;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('driver_profile_title'.tr()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? scheme.outlineVariant.withValues(alpha: 0.5)
                      : scheme.surfaceContainerLowest,
                  width: 3,
                ),
                boxShadow: isDark
                    ? null
                    : const [
                        BoxShadow(
                          color: AppColors.elevationShadow,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
              ),
              child: AvatarImage(
                imageUrl: profile.avatarUrl,
                fallback: profile.name,
                radius: 42,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          DriverProfileStatsRow(
            rating: profile.rating,
            totalRides: '124',
          ),
          if (profile.vehicle != null && profile.vehicle!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _InfoTile(
              icon: Icons.directions_car_outlined,
              label: 'driver_vehicle'.tr(),
              value: profile.vehicle!,
            ),
          ],
          if (profile.hasPhone) ...[
            const SizedBox(height: AppSpacing.sm),
            _InfoTile(
              icon: Icons.phone_outlined,
              label: 'driver'.tr(),
              value: profile.phone!,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Text(
            'driver_reviews_title'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (profile.ratingSummary != null)
            DriverRatingSummaryCard(summary: profile.ratingSummary!)
          else if (profile.rating != null)
            _OverallRatingFallback(rating: profile.rating!)
          else
            const SizedBox.shrink(),
          const SizedBox(height: AppSpacing.md),
          if (profile.reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Text(
                  'no_reviews'.tr(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
            )
          else
            ...profile.reviews.map(
              (review) => DriverReviewCard(review: review),
            ),
          if (profile.hasPhone) ...[
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'message_driver'.tr(),
              icon: Icons.chat_bubble_outline,
              onPressed: () => context.pushNamed(
                RouteNames.driverChat,
                pathParameters: {'tripId': profile.tripId},
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => context.pushNamed(
                RouteNames.driverCall,
                pathParameters: {'tripId': profile.tripId},
              ),
              icon: const Icon(Icons.call),
              label: Text('call_driver'.tr()),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OverallRatingFallback extends StatelessWidget {
  const _OverallRatingFallback({required this.rating});

  final double rating;

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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < rating.round()
                        ? Icons.star
                        : Icons.star_border,
                    size: 18,
                    color: AppColors.tertiaryFixedDim,
                  ),
                ),
              ),
              Text(
                'driver_rating'.tr(args: [rating.toStringAsFixed(1)]),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

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
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
