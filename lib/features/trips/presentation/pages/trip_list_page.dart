import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/architecture/repositories/trip_repository.dart';
import 'package:delivery_app/core/sync/sync_service.dart';
import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/nokta_trip_card.dart';
import 'package:delivery_app/core/widgets/skeleton_trip_card.dart';
import 'package:delivery_app/features/trips/presentation/bloc/trip_list_bloc.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/routes/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

@RoutePage()
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
          title: Text('trips_title'.tr()),
          leading: IconButton(
            icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.onSurfaceVariant),
            onPressed: () {},
          ),
          actions: [
            IconButton(
              tooltip: 'simulate_offline'.tr(),
              onPressed: () => sl<SyncService>().syncAll(),
              icon: const Icon(Icons.sync),
            ),
            Padding(
              padding: const EdgeInsets.only(right: NoktaSpacing.sm),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                child: Icon(
                  Icons.person,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<TripListBloc, TripListState>(
          builder: (context, state) {
            if (state is TripListLoading) {
              return Skeletonizer(
                enabled: true,
                child: ListView(
                  padding: const EdgeInsets.all(NoktaSpacing.md),
                  children: List.generate(
                    4,
                    (_) => const Padding(
                      padding: EdgeInsets.only(bottom: NoktaSpacing.md),
                      child: SkeletonTripCard(),
                    ),
                  ),
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
                      const SizedBox(height: NoktaSpacing.md),
                      Text('no_trips'.tr(), style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<TripListBloc>()
                      .add(const TripListRefreshRequested());
                },
                child: ListView(
                  padding: const EdgeInsets.all(NoktaSpacing.md),
                  children: [
                    if (state.isOffline) const NoktaOfflineTripsBanner(),
                    ...state.trips.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: NoktaSpacing.md),
                        child: NoktaTripCard(
                          trip: entry.value,
                          pendingRetryCount:
                              sl<TripRepository>().getPendingRetryCount(
                            entry.value.id,
                          ),
                          onTap: () => context.router.push(
                            TripDetailRoute(tripId: entry.value.id),
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
