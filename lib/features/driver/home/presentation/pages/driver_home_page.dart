import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/core/network/connectivity_cubit.dart';
import 'package:delivery_app/core/network/connectivity_state.dart';
import 'package:delivery_app/features/auth/shared/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/driver/active_trip/presentation/bloc/driver_active_trip_bloc.dart';
import 'package:delivery_app/features/driver/active_trip/presentation/pages/driver_active_trip_page.dart';
import 'package:delivery_app/features/driver/jobs/presentation/bloc/driver_jobs_bloc.dart';
import 'package:delivery_app/features/driver/offers/presentation/bloc/driver_offers_bloc.dart';
import 'package:delivery_app/features/driver/shared/domain/entities/driver_availability.dart';
import 'package:delivery_app/features/driver/shared/presentation/cubit/driver_availability_cubit.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/presentation/widgets/active_trip_section.dart';
import 'package:delivery_app/features/trips/shared/presentation/widgets/trip_card.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:delivery_app/shared/widgets/feedback/empty_state_view.dart';
import 'package:delivery_app/shared/widgets/feedback/section_header.dart';
import 'package:delivery_app/shared/widgets/navigation/app_bar_refresh_button.dart';
import 'package:delivery_app/shared/widgets/navigation/shell_tab_app_bar.dart';
import 'package:delivery_app/shared/widgets/navigation/shell_tab_scaffold.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  void _bootstrap() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final driverId = authState.user.id;
    context.read<DriverOffersBloc>().add(const DriverOffersLoadRequested());
    context.read<DriverJobsBloc>().add(
      DriverJobsLoadRequested(driverId: driverId),
    );
  }

  void _openActiveTrip(BuildContext context, String tripId) {
    Navigator.of(context)
        .push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => BlocProvider(
              create: (_) =>
                  sl<DriverActiveTripBloc>()
                    ..add(DriverActiveTripLoadRequested(tripId: tripId)),
              child: DriverActiveTripPage(tripId: tripId),
            ),
          ),
        )
        .then((completed) {
          if (!context.mounted) return;
          if (completed == true) {
            context.read<DriverAvailabilityCubit>().releaseFromTrip();
          }
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            context.read<DriverJobsBloc>().add(
              DriverJobsRefreshRequested(driverId: authState.user.id),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return ShellTabScaffold(
      appBar: ShellTabAppBar(title: Text('driver_home_title'.tr())),
      body: MultiBlocListener(
        listeners: [
          BlocListener<DriverOffersBloc, DriverOffersState>(
            listenWhen: (previous, current) =>
                current is DriverOffersLoaded && current.acceptedTripId != null,
            listener: (context, state) {
              if (state is! DriverOffersLoaded ||
                  state.acceptedTripId == null) {
                return;
              }
              context.read<DriverAvailabilityCubit>().lockOnTrip();
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                context.read<DriverJobsBloc>().add(
                  DriverJobsRefreshRequested(driverId: authState.user.id),
                );
              }
              _openActiveTrip(context, state.acceptedTripId!);
            },
          ),
          BlocListener<DriverJobsBloc, DriverJobsState>(
            listenWhen: (previous, current) => current is DriverJobsLoaded,
            listener: (context, state) {
              if (state is! DriverJobsLoaded) return;
              final availability =
                  context.read<DriverAvailabilityCubit>().state.availability;
              if (availability == DriverAvailability.onTrip &&
                  state.activeTrip == null) {
                context.read<DriverAvailabilityCubit>().releaseFromTrip();
              }
            },
          ),
        ],
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _AvailabilityCard(
              onGoOnline: () =>
                  context.read<DriverAvailabilityCubit>().goOnline(),
              onGoOffline: () =>
                  context.read<DriverAvailabilityCubit>().goOffline(),
            ),
            const SizedBox(height: AppSpacing.lg),
            BlocBuilder<DriverJobsBloc, DriverJobsState>(
              builder: (context, jobsState) {
                if (jobsState is DriverJobsLoaded) {
                  final activeTrip = jobsState.activeTrip;
                  if (activeTrip != null) {
                    return ActiveTripSection(
                      title: 'driver_active_trip'.tr(),
                      trip: activeTrip,
                      actionLabel: 'driver_open_active_trip'.tr(),
                      onAction: () => _openActiveTrip(context, activeTrip.id),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
            BlocBuilder<DriverAvailabilityCubit, DriverAvailabilityState>(
              builder: (context, availabilityState) {
                return BlocBuilder<DriverJobsBloc, DriverJobsState>(
                  builder: (context, jobsState) {
                    final availability = availabilityState.availability;

                    if (availability == DriverAvailability.onTrip) {
                      if (jobsState is DriverJobsLoaded &&
                          jobsState.activeTrip != null) {
                        return const SizedBox.shrink();
                      }
                      return EmptyStateView(
                        icon: Icons.local_taxi_outlined,
                        iconSize: 48,
                        title: 'driver_on_trip_hint'.tr(),
                      );
                    }

                    if (availability != DriverAvailability.online) {
                      return EmptyStateView(
                        icon: Icons.power_settings_new,
                        iconSize: 48,
                        title: 'driver_go_online_hint'.tr(),
                      );
                    }

                    return const _OffersSection();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({
    required this.onGoOnline,
    required this.onGoOffline,
  });

  final VoidCallback onGoOnline;
  final VoidCallback onGoOffline;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<DriverAvailabilityCubit, DriverAvailabilityState>(
      builder: (context, state) {
        final isOnline = state.availability == DriverAvailability.online;
        final isOnTrip = state.availability == DriverAvailability.onTrip;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    isOnline || isOnTrip ? Icons.circle : Icons.circle_outlined,
                    color: isOnline || isOnTrip
                        ? AppColors.secondary
                        : scheme.outline,
                    size: 12,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      isOnTrip
                          ? 'driver_status_on_trip'.tr()
                          : isOnline
                          ? 'driver_status_online'.tr()
                          : 'driver_status_offline'.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (isOnTrip)
                Text(
                  'driver_on_trip_hint'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else if (isOnline)
                AppButton(
                  label: 'driver_go_offline'.tr(),
                  loading: state.isUpdating,
                  usePrimaryContainer: true,
                  onPressed: state.isUpdating ? null : onGoOffline,
                )
              else
                BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
                  builder: (context, connectivity) {
                    final canGoOnline =
                        connectivity == ConnectivityStatus.online;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!canGoOnline) ...[
                          Text(
                            'driver_go_online_requires_internet'.tr(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.outline),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        AppButton(
                          label: 'driver_go_online'.tr(),
                          loading: state.isUpdating,
                          onPressed: !canGoOnline || state.isUpdating
                              ? null
                              : onGoOnline,
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _OffersSection extends StatelessWidget {
  const _OffersSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverOffersBloc, DriverOffersState>(
      builder: (context, state) {
        if (state is DriverOffersLoading) {
          return const LoadingView();
        }
        if (state is DriverOffersError) {
          return ErrorView(
            message: state.message,
            onRetry: () => context.read<DriverOffersBloc>().add(
              const DriverOffersRefreshRequested(),
            ),
          );
        }
        if (state is DriverOffersLoaded) {
          if (state.offers.isEmpty) {
            return EmptyStateView(
              icon: Icons.local_offer_outlined,
              title: 'driver_no_offers'.tr(),
              subtitle: 'driver_no_offers_hint'.tr(),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                title: 'driver_offers_title'.tr(),
                trailing: AppBarRefreshIconButton(
                  isRefreshing: state.isRefreshing,
                  onPressed: state.isActionInProgress
                      ? null
                      : () => context.read<DriverOffersBloc>().add(
                          const DriverOffersRefreshRequested(),
                        ),
                ),
              ),
              ...state.offers.map(
                (offer) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _OfferCard(
                    trip: offer,
                    isBusy: state.isActionInProgress,
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.trip, required this.isBusy});

  final TripEntity trip;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TripHeroCard(trip: trip),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isBusy
                    ? null
                    : () => context.read<DriverOffersBloc>().add(
                        DriverOffersDeclineRequested(tripId: trip.id),
                      ),
                child: Text('driver_decline_offer'.tr()),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppButton(
                label: 'driver_accept_offer'.tr(),
                loading: isBusy,
                onPressed: isBusy
                    ? null
                    : () => context.read<DriverOffersBloc>().add(
                        DriverOffersAcceptRequested(tripId: trip.id),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
