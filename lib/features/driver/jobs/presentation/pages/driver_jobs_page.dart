import 'package:delivery_app/features/auth/shared/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/driver/jobs/presentation/bloc/driver_jobs_bloc.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_extensions.dart';
import 'package:delivery_app/features/trips/shared/presentation/widgets/trip_card.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/skeleton_trip_card.dart';
import 'package:delivery_app/shared/widgets/feedback/empty_state_view.dart';
import 'package:delivery_app/shared/widgets/navigation/app_bar_refresh_button.dart';
import 'package:delivery_app/shared/widgets/navigation/shell_tab_app_bar.dart';
import 'package:delivery_app/shared/widgets/navigation/shell_tab_scaffold.dart';
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

  void _refreshJobs() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<DriverJobsBloc>().add(
        DriverJobsRefreshRequested(driverId: authState.user.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShellTabScaffold(
      appBar: ShellTabAppBar(
        title: Text('driver_jobs_title'.tr()),
        actions: [
          BlocBuilder<DriverJobsBloc, DriverJobsState>(
            builder: (context, state) {
              final isRefreshing =
                  state is DriverJobsLoaded && state.isRefreshing;
              return AppBarRefreshIconButton(
                isRefreshing: isRefreshing,
                onPressed: _refreshJobs,
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<DriverJobsBloc, DriverJobsState>(
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
              return EmptyStateView(
                icon: Icons.work_outline,
                title: 'driver_no_jobs'.tr(),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _refreshJobs(),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: state.trips.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final trip = state.trips[index];
                  return TripAccentCard(
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
    );
  }
}
