import 'package:delivery_app/features/auth/shared/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/driver/jobs/presentation/bloc/driver_jobs_bloc.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_extensions.dart';
import 'package:delivery_app/features/trips/shared/presentation/widgets/trip_card.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/skeleton_trip_card.dart';
import 'package:delivery_app/shared/widgets/navigation/shell_app_bar_logo.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DriverJobsPage extends StatefulWidget {
  const DriverJobsPage({super.key});

  @override
  State<DriverJobsPage> createState() => _DriverJobsPageState();
}

class _DriverJobsPageState extends State<DriverJobsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadJobs());
  }

  void _loadJobs() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<DriverJobsBloc>().add(
        DriverJobsLoadRequested(driverId: authState.user.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        toolbarHeight: ShellAppBarLogo.tabToolbarHeight,
        leadingWidth: ShellAppBarLogo.leadingWidth,
        automaticallyImplyLeading: false,
        leading: const ShellAppBarLogo(),
        title: Text('driver_jobs_title'.tr()),
        actions: [
          BlocBuilder<DriverJobsBloc, DriverJobsState>(
            builder: (context, state) {
              final isRefreshing =
                  state is DriverJobsLoaded && state.isRefreshing;
              return IconButton(
                tooltip: 'retry'.tr(),
                onPressed: isRefreshing
                    ? null
                    : () {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is AuthAuthenticated) {
                          context.read<DriverJobsBloc>().add(
                            DriverJobsRefreshRequested(
                              driverId: authState.user.id,
                            ),
                          );
                        }
                      },
                icon: isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: BlocBuilder<DriverJobsBloc, DriverJobsState>(
              builder: (context, state) {
                if (state is DriverJobsLoading) {
                  return Skeletonizer(
                    enabled: true,
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      children: const [
                        SkeletonTripCard(),
                        SizedBox(height: AppSpacing.md),
                        SkeletonTripCard(),
                      ],
                    ),
                  );
                }
                if (state is DriverJobsError) {
                  return ErrorView(message: state.message, onRetry: _loadJobs);
                }
                if (state is DriverJobsLoaded) {
                  if (state.trips.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 64,
                            color: scheme.outline,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'driver_no_jobs'.tr(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthAuthenticated) {
                        context.read<DriverJobsBloc>().add(
                          DriverJobsRefreshRequested(
                            driverId: authState.user.id,
                          ),
                        );
                      }
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: state.trips.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final trip = state.trips[index];
                        return TripHeroCard(
                          trip: trip,
                          highlighted: trip.isCurrentTrip,
                          liveStatus: trip.isCurrentTrip,
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
