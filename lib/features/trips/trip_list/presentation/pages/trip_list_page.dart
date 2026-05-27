import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/features/trips/shared/domain/repositories/trip_repository.dart';
import 'package:delivery_app/core/sync/sync_service.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/features/trips/shared/presentation/widgets/trip_card.dart';
import 'package:delivery_app/features/trips/trip_list/presentation/widgets/current_trip_card.dart';
import 'package:delivery_app/shared/widgets/banners/offline_banner.dart';
import 'package:delivery_app/core/widgets/skeleton_trip_card.dart';
import 'package:delivery_app/features/trips/trip_list/presentation/bloc/trip_list_bloc.dart';
import 'package:delivery_app/shared/widgets/navigation/profile_avatar_button.dart';
import 'package:delivery_app/shared/widgets/navigation/shell_app_bar_logo.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TripListPage extends StatelessWidget {
  const TripListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TripListBloc>()..add(const TripListLoadRequested()),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          automaticallyImplyLeading: false,
          leading: const ShellAppBarLogo(),
          title: Text('trips_title'.tr()),
          actions: [
            IconButton(
              tooltip: 'simulate_offline'.tr(),
              onPressed: () => sl<SyncService>().syncAll(),
              icon: const Icon(Icons.sync),
            ),
            const ProfileAvatarButton(),
          ],
        ),
        body: BlocBuilder<TripListBloc, TripListState>(
          builder: (context, state) {
            if (state is TripListLoading) {
              return Skeletonizer(
                enabled: true,
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    _SectionHeader(title: 'current_trip'.tr()),
                    const Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                      child: SkeletonTripCard(),
                    ),
                    const AppButtonSkeleton(),
                    const SizedBox(height: AppSpacing.lg),
                    _SectionHeader(title: 'trip_history'.tr()),
                    ...List.generate(
                      3,
                      (_) => const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: SkeletonTripCard(),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (state is TripListError) {
              return ErrorView(
                message: state.message,
                onRetry: () => context
                    .read<TripListBloc>()
                    .add(const TripListLoadRequested()),
              );
            }
            if (state is TripListLoaded) {
              if (state.trips.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'no_trips'.tr(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                );
              }

              final currentTrip = state.currentTrip;
              final historyTrips = state.historyTrips;

              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<TripListBloc>()
                      .add(const TripListRefreshRequested());
                },
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    if (state.isOffline) const OfflineTripsBanner(),
                    if (currentTrip != null) ...[
                      _SectionHeader(title: 'current_trip'.tr()),
                      CurrentTripCard(
                        trip: currentTrip,
                        pendingRetryCount:
                            sl<TripRepository>().getPendingRetryCount(
                          currentTrip.id,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 350.ms)
                          .slideY(
                            begin: 0.05,
                            end: 0,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    _SectionHeader(title: 'trip_history'.tr()),
                    if (historyTrips.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        child: Text(
                          'no_trip_history'.tr(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ...historyTrips.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: TripCard(
                            trip: entry.value,
                            pendingRetryCount:
                                sl<TripRepository>().getPendingRetryCount(
                              entry.value.id,
                            ),
                            onTap: () => context.pushNamed(
                              RouteNames.tripDetail,
                              pathParameters: {'tripId': entry.value.id},
                            ),
                          )
                              .animate()
                              .fadeIn(
                                delay: (entry.key * 80).ms,
                                duration: 350.ms,
                              )
                              .slideX(
                                begin: 0.05,
                                end: 0,
                                curve: Curves.easeOutCubic,
                              ),
                        ),
                      ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class AppButtonSkeleton extends StatelessWidget {
  const AppButtonSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.buttonHeight,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    );
  }
}
