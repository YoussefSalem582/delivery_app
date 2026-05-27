import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/utils/map_config.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/nokta_primary_button.dart';
import 'package:delivery_app/core/widgets/nokta_ride_option.dart';
import 'package:delivery_app/core/widgets/delivery_map.dart';
import 'package:delivery_app/features/home/presentation/bloc/map_bloc.dart';
import 'package:delivery_app/features/home/presentation/widgets/request_ride_sheet.dart';
import 'package:delivery_app/features/home/presentation/widgets/ride_selection_sheet.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/routes/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class HomeMapPage extends StatelessWidget {
  const HomeMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MapBloc>()..add(const MapStarted()),
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          final scheme = Theme.of(context).colorScheme;

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: scheme.surface,
              title: Text('app_name'.tr()),
              leading: IconButton(
                icon: Icon(Icons.menu, color: scheme.onSurfaceVariant),
                onPressed: () {},
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: NoktaSpacing.sm),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: scheme.surfaceContainerHigh,
                    child: Icon(Icons.person, color: scheme.primary, size: 22),
                  ),
                ),
              ],
            ),
            body: Stack(
              children: [
                if (state is MapReady)
                  DeliveryMap(
                    center: state.userPosition,
                    zoom: MapConfig.defaultZoom,
                    followCenter: true,
                    markers: [
                      MapMarkerData(
                        point: state.userPosition,
                        color: scheme.primaryContainer,
                        icon: Icons.my_location,
                      ),
                    ],
                  )
                else
                  const LoadingView(),
                if (state is MapReady && state.usingFallback)
                  Positioned(
                    top: kToolbarHeight + MediaQuery.paddingOf(context).top,
                    left: 0,
                    right: 0,
                    child: Material(
                      color: NoktaColors.tertiaryFixedDim,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: NoktaSpacing.md,
                          vertical: NoktaSpacing.sm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_off,
                              size: 18,
                              color: scheme.onSurface,
                            ),
                            const SizedBox(width: NoktaSpacing.sm),
                            Text(
                              'offline_banner'.tr(),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (state is MapReady)
                  Positioned(
                    left: NoktaSpacing.md,
                    right: NoktaSpacing.md,
                    bottom: NoktaSpacing.md,
                    child: AnimatedSlide(
                      offset: Offset.zero,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(NoktaSpacing.radiusMd),
                          boxShadow: const [
                            BoxShadow(
                              color: NoktaColors.elevationShadow,
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: NoktaPrimaryButton(
                          label: 'request_ride'.tr(),
                          icon: Icons.directions_car,
                          onPressed: () => _showRequestSheet(context, state),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showRequestSheet(
    BuildContext context,
    MapReady mapState,
  ) async {
    final draft = await showModalBottomSheet<RideRequestDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RequestRideSheet(
        pickupLat: mapState.userPosition.latitude,
        pickupLng: mapState.userPosition.longitude,
      ),
    );

    if (draft == null || !context.mounted) return;

    final trip = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => sl<RequestRideBloc>(),
        child: RideSelectionSheet(draft: draft),
      ),
    );

    if (trip != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('trip_requested_success'.tr())));
      context.router.push(TrackingRoute(tripId: trip.id));
    }
  }
}
