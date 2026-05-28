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
import 'package:delivery_app/features/trips/shared/presentation/widgets/trip_card.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:delivery_app/shared/widgets/navigation/shell_app_bar_logo.dart';
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) =>
              sl<DriverActiveTripBloc>()
                ..add(DriverActiveTripLoadRequested(tripId: tripId)),
          child: DriverActiveTripPage(tripId: tripId),
        ),
      ),
    );
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
        title: Text('driver_home_title'.tr()),
      ),
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
        ],
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
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
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'driver_active_trip'.tr(),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              TripHeroCard(trip: activeTrip, highlighted: true),
                              const SizedBox(height: AppSpacing.sm),
                              AppButton(
                                label: 'driver_open_active_trip'.tr(),
                                onPressed: () =>
                                    _openActiveTrip(context, activeTrip.id),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  BlocBuilder<DriverAvailabilityCubit, DriverAvailabilityState>(
                    builder: (context, availabilityState) {
                      if (availabilityState.availability !=
                          DriverAvailability.online) {
                        return _OfflineHint();
                      }
                      return const _OffersSection();
                    },
                  ),
                ],
              ),
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

class _OfflineHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Column(
          children: [
            Icon(
              Icons.power_settings_new,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'driver_go_online_hint'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Column(
                  children: [
                    Text(
                      'driver_no_offers'.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'driver_no_offers_hint'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'driver_offers_title'.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'retry'.tr(),
                    onPressed: state.isActionInProgress
                        ? null
                        : () => context.read<DriverOffersBloc>().add(
                            const DriverOffersRefreshRequested(),
                          ),
                    icon: state.isRefreshing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
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
