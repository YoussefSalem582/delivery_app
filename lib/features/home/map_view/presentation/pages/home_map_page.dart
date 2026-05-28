import 'dart:async';

import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/core/network/route_service.dart';
import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/banners/app_toast.dart';
import 'package:delivery_app/core/utils/map_config.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/delivery_map.dart';
import 'package:delivery_app/features/home/ride_request/domain/entities/quick_destination_type.dart';
import 'package:delivery_app/features/home/ride_request/presentation/cubit/location_search_state.dart';
import 'package:delivery_app/features/home/ride_request/presentation/widgets/ride_option_card.dart';
import 'package:delivery_app/features/home/map_view/presentation/bloc/map_bloc.dart';
import 'package:delivery_app/features/home/ride_request/presentation/widgets/home_destination_panel.dart';
import 'package:delivery_app/features/home/ride_request/presentation/widgets/request_ride_sheet.dart';
import 'package:delivery_app/features/home/ride_request/presentation/widgets/ride_selection_sheet.dart';
import 'package:delivery_app/features/home/shared/data/datasources/saved_places_local_datasource.dart';
import 'package:delivery_app/features/home/shared/domain/entities/place_suggestion.dart';
import 'package:delivery_app/shared/widgets/navigation/profile_avatar_button.dart';
import 'package:delivery_app/shared/widgets/navigation/shell_app_bar_logo.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class HomeMapPage extends StatefulWidget {
  const HomeMapPage({super.key});

  @override
  State<HomeMapPage> createState() => _HomeMapPageState();
}

class _HomeMapPageState extends State<HomeMapPage> {
  final _mapKey = GlobalKey<DeliveryMapState>();
  RideRequestDraft? _previewDraft;
  List<LatLng> _previewRoute = const [];

  Future<void> _startRideFlow(
    BuildContext context,
    MapReady mapState, {
    QuickDestinationType? quickDestination,
  }) async {
    PlaceSuggestion? initialDropoff;
    String? initialDropoffQuery;
    String? hintMessageKey;
    LocationSearchField? initialActiveField;

    if (quickDestination != null) {
      initialActiveField = LocationSearchField.dropoff;
      switch (quickDestination) {
        case QuickDestinationType.home:
          final saved = sl<SavedPlacesLocalDataSource>().getHome();
          if (saved != null) {
            initialDropoff = PlaceSuggestion(
              id: 'saved_home',
              title: saved.address ?? 'quick_home'.tr(),
              subtitle: '',
              lat: saved.lat,
              lng: saved.lng,
            );
          } else {
            hintMessageKey = 'saved_place_missing_home';
          }
        case QuickDestinationType.work:
          final saved = sl<SavedPlacesLocalDataSource>().getWork();
          if (saved != null) {
            initialDropoff = PlaceSuggestion(
              id: 'saved_work',
              title: saved.address ?? 'quick_work'.tr(),
              subtitle: '',
              lat: saved.lat,
              lng: saved.lng,
            );
          } else {
            hintMessageKey = 'saved_place_missing_work';
          }
        case QuickDestinationType.airport:
          initialDropoffQuery = 'place_airport_search_query'.tr();
      }
    }

    final draft = await showModalBottomSheet<RideRequestDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RequestRideSheet(
        pickupLat: mapState.userPosition.latitude,
        pickupLng: mapState.userPosition.longitude,
        initialDropoff: initialDropoff,
        initialDropoffQuery: initialDropoffQuery,
        hintMessageKey: hintMessageKey,
        initialActiveField: initialActiveField,
      ),
    );

    if (draft == null || !context.mounted) return;

    setState(() {
      _previewDraft = draft;
      _previewRoute = _fallbackRoutePoints(draft);
    });
    unawaited(_loadPreviewRoute(draft));

    final trip = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => sl<RequestRideBloc>(),
        child: RideSelectionSheet(draft: draft),
      ),
    );

    if (context.mounted) {
      setState(() {
        _previewDraft = null;
        _previewRoute = const [];
      });
    }

    if (trip != null && context.mounted) {
      AppToast.success(context, 'trip_requested_success'.tr());
      context.pushNamed(
        RouteNames.tracking,
        pathParameters: {'tripId': trip.id},
      );
    }
  }

  List<LatLng> _fallbackRoutePoints(RideRequestDraft draft) => [
        LatLng(draft.pickupLat, draft.pickupLng),
        LatLng(draft.dropoffLat, draft.dropoffLng),
      ];

  Future<void> _loadPreviewRoute(RideRequestDraft draft) async {
    final result = await sl<RouteService>().getRoute(
      pickup: LatLng(draft.pickupLat, draft.pickupLng),
      dropoff: LatLng(draft.dropoffLat, draft.dropoffLng),
    );

    if (!mounted || _previewDraft != draft) return;

    setState(() {
      _previewRoute = result.points;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => sl<MapBloc>()..add(const MapStarted()),
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: scheme.surface.withValues(alpha: isDark ? 0.92 : 1),
              automaticallyImplyLeading: false,
              leading: const ShellAppBarLogo(),
              title: Text(
                'app_name'.tr(),
                style: TextStyle(color: scheme.primary),
              ),
              actions: const [
                ProfileAvatarButton(radius: 20),
              ],
            ),
            body: Stack(
              children: [
                if (state is MapReady)
                  DeliveryMap(
                    key: _mapKey,
                    center: state.userPosition,
                    zoom: MapConfig.defaultZoom,
                    followCenter: true,
                    showUserLocation: true,
                    polylines: _previewDraft != null ? _previewRoute : const [],
                    markers: [
                      if (_previewDraft != null) ...[
                        MapMarkerData(
                          point: LatLng(
                            _previewDraft!.pickupLat,
                            _previewDraft!.pickupLng,
                          ),
                          color: scheme.secondary,
                          icon: Icons.trip_origin,
                        ),
                        MapMarkerData(
                          point: LatLng(
                            _previewDraft!.dropoffLat,
                            _previewDraft!.dropoffLng,
                          ),
                          color: scheme.error,
                          icon: Icons.location_on,
                        ),
                      ],
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
                      color: AppColors.tertiaryFixedDim,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_off, size: 18, color: scheme.onSurface),
                            const SizedBox(width: AppSpacing.sm),
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
                    right: AppSpacing.md,
                    bottom: 220,
                    child: FloatingActionButton(
                      onPressed: () => _mapKey.currentState?.recenter(state.userPosition),
                      backgroundColor: isDark
                          ? scheme.surfaceContainerHigh
                          : scheme.surfaceContainerLowest,
                      foregroundColor: scheme.primary,
                      elevation: isDark ? 2 : 4,
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                if (state is MapReady)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: HomeDestinationPanel(
                      onSearchTap: () => _startRideFlow(context, state),
                      onQuickDestination: (type) =>
                          _startRideFlow(context, state, quickDestination: type),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
