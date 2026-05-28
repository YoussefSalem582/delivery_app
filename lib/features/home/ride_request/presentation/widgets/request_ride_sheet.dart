import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/features/home/ride_request/presentation/cubit/location_search_cubit.dart';
import 'package:delivery_app/features/home/ride_request/presentation/cubit/location_search_state.dart';
import 'package:delivery_app/features/home/ride_request/presentation/widgets/ride_option_card.dart';
import 'package:delivery_app/features/home/shared/domain/entities/place_suggestion.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/widgets/navigation/app_bottom_nav_bar.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestRideSheet extends StatelessWidget {
  const RequestRideSheet({
    super.key,
    required this.pickupLat,
    required this.pickupLng,
    this.initialDropoff,
    this.initialDropoffQuery,
    this.hintMessageKey,
    this.initialActiveField,
  });

  final double pickupLat;
  final double pickupLng;
  final PlaceSuggestion? initialDropoff;
  final String? initialDropoffQuery;
  final String? hintMessageKey;
  final LocationSearchField? initialActiveField;

  @override
  Widget build(BuildContext context) {
    final languageCode = context.locale.languageCode;

    return BlocProvider(
      create: (_) {
        final cubit = sl<LocationSearchCubit>();
        cubit.reverseGeocodePickup(
          lat: pickupLat,
          lng: pickupLng,
          languageCode: languageCode,
        );
        if (initialDropoffQuery != null && initialDropoffQuery!.trim().isNotEmpty) {
          cubit.searchImmediately(
            query: initialDropoffQuery!,
            biasLat: pickupLat,
            biasLng: pickupLng,
            languageCode: languageCode,
          );
        }
        if (initialActiveField != null) {
          cubit.setActiveField(initialActiveField!);
        }
        return cubit;
      },
      child: _RequestRideSheetBody(
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        initialDropoff: initialDropoff,
        initialDropoffQuery: initialDropoffQuery,
        hintMessageKey: hintMessageKey,
        initialActiveField: initialActiveField,
      ),
    );
  }
}

class _RequestRideSheetBody extends StatefulWidget {
  const _RequestRideSheetBody({
    required this.pickupLat,
    required this.pickupLng,
    this.initialDropoff,
    this.initialDropoffQuery,
    this.hintMessageKey,
    this.initialActiveField,
  });

  final double pickupLat;
  final double pickupLng;
  final PlaceSuggestion? initialDropoff;
  final String? initialDropoffQuery;
  final String? hintMessageKey;
  final LocationSearchField? initialActiveField;

  @override
  State<_RequestRideSheetBody> createState() => _RequestRideSheetBodyState();
}

class _RequestRideSheetBodyState extends State<_RequestRideSheetBody> {
  late final TextEditingController _pickupController;
  late final TextEditingController _dropoffController;
  late final FocusNode _pickupFocus;
  late final FocusNode _dropoffFocus;

  PlaceSuggestion? _selectedPickup;
  PlaceSuggestion? _selectedDropoff;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _pickupController = TextEditingController(text: 'current_location'.tr());
    _dropoffController = TextEditingController();
    _pickupFocus = FocusNode()..addListener(_onPickupFocusChanged);
    _dropoffFocus = FocusNode()..addListener(_onDropoffFocusChanged);

    if (widget.initialDropoff != null) {
      _selectedDropoff = widget.initialDropoff;
      _dropoffController.text = widget.initialDropoff!.displayAddress;
    } else if (widget.initialDropoffQuery != null) {
      _dropoffController.text = widget.initialDropoffQuery!;
    }

    _pickupController.addListener(_onPickupTextChanged);
    _dropoffController.addListener(_onDropoffTextChanged);
  }

  @override
  void dispose() {
    _pickupController.removeListener(_onPickupTextChanged);
    _dropoffController.removeListener(_onDropoffTextChanged);
    _pickupFocus.removeListener(_onPickupFocusChanged);
    _dropoffFocus.removeListener(_onDropoffFocusChanged);
    _pickupController.dispose();
    _dropoffController.dispose();
    _pickupFocus.dispose();
    _dropoffFocus.dispose();
    super.dispose();
  }

  String get _languageCode => context.locale.languageCode;

  double get _biasLat => _selectedPickup?.lat ?? widget.pickupLat;

  double get _biasLng => _selectedPickup?.lng ?? widget.pickupLng;

  void _onPickupFocusChanged() {
    if (_pickupFocus.hasFocus) {
      context.read<LocationSearchCubit>().setActiveField(LocationSearchField.pickup);
      setState(() => _showSuggestions = true);
      _refreshSearch(_pickupController.text);
    }
  }

  void _onDropoffFocusChanged() {
    if (_dropoffFocus.hasFocus) {
      context.read<LocationSearchCubit>().setActiveField(LocationSearchField.dropoff);
      setState(() => _showSuggestions = true);
      _refreshSearch(_dropoffController.text);
    }
  }

  void _onPickupTextChanged() {
    final selected = _selectedPickup;
    if (selected != null &&
        _pickupController.text != selected.displayAddress) {
      _selectedPickup = null;
    }
    if (_pickupFocus.hasFocus) {
      _refreshSearch(_pickupController.text);
    }
  }

  void _onDropoffTextChanged() {
    final selected = _selectedDropoff;
    if (selected != null &&
        _dropoffController.text != selected.displayAddress) {
      _selectedDropoff = null;
    }
    if (_dropoffFocus.hasFocus) {
      _refreshSearch(_dropoffController.text);
    }
  }

  void _refreshSearch(String query) {
    context.read<LocationSearchCubit>().search(
          query: query,
          biasLat: _biasLat,
          biasLng: _biasLng,
          languageCode: _languageCode,
        );
  }

  void _selectPlace(PlaceSuggestion place) {
    final activeField = context.read<LocationSearchCubit>().state.activeField;
    setState(() {
      if (activeField == LocationSearchField.pickup) {
        _selectedPickup = place;
        _pickupController.text = place.displayAddress;
        _pickupFocus.unfocus();
      } else {
        _selectedDropoff = place;
        _dropoffController.text = place.displayAddress;
        _dropoffFocus.unfocus();
      }
      _showSuggestions = false;
    });
    context.read<LocationSearchCubit>().clearSuggestions();
  }

  void _continue() {
    final pickup = _selectedPickup;
    final dropoff = _selectedDropoff;
    if (pickup == null || dropoff == null) return;

    Navigator.of(context).pop(
      RideRequestDraft(
        pickupAddress: pickup.displayAddress,
        dropoffAddress: dropoff.displayAddress,
        pickupLat: pickup.lat,
        pickupLng: pickup.lng,
        dropoffLat: dropoff.lat,
        dropoffLng: dropoff.lng,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final canContinue = _selectedPickup != null && _selectedDropoff != null;

    return BlocListener<LocationSearchCubit, LocationSearchState>(
      listenWhen: (prev, curr) =>
          prev.reverseGeocodedPickup != curr.reverseGeocodedPickup,
      listener: (context, state) {
        final pickup = state.reverseGeocodedPickup;
        if (pickup == null || _selectedPickup != null) return;
        setState(() {
          _selectedPickup = pickup;
          _pickupController.text = pickup.displayAddress;
        });
      },
      child: BlocListener<LocationSearchCubit, LocationSearchState>(
        listenWhen: (prev, curr) =>
            widget.initialDropoff == null &&
            widget.initialDropoffQuery != null &&
            prev.suggestions != curr.suggestions &&
            curr.suggestions.isNotEmpty &&
            curr.status == LocationSearchStatus.loaded,
        listener: (context, state) {
          if (_selectedDropoff != null) return;
          _selectPlace(state.suggestions.first);
        },
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            ),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusSheet),
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.elevationShadow,
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppSheetHandle(),
                    Text(
                      'request_ride_title'.tr(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _LocationInputs(
                      pickupController: _pickupController,
                      dropoffController: _dropoffController,
                      pickupFocus: _pickupFocus,
                      dropoffFocus: _dropoffFocus,
                      onPickupTap: () {
                        context
                            .read<LocationSearchCubit>()
                            .setActiveField(LocationSearchField.pickup);
                        setState(() {
                          _showSuggestions = true;
                          _refreshSearch(_pickupController.text);
                        });
                      },
                      onDropoffTap: () {
                        context
                            .read<LocationSearchCubit>()
                            .setActiveField(LocationSearchField.dropoff);
                        setState(() {
                          _showSuggestions = true;
                          _refreshSearch(_dropoffController.text);
                        });
                      },
                    ),
                    if (widget.hintMessageKey != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          widget.hintMessageKey!.tr(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.tertiary,
                                  ),
                        ),
                      ),
                    if (!canContinue)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          'location_select_both_hint'.tr(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                        ),
                      ),
                    if (_showSuggestions) ...[
                      const SizedBox(height: AppSpacing.sm),
                      BlocBuilder<LocationSearchCubit, LocationSearchState>(
                        builder: (context, searchState) {
                          final hasQuery = searchState.activeField ==
                                  LocationSearchField.pickup
                              ? _pickupController.text.trim().isNotEmpty
                              : _dropoffController.text.trim().isNotEmpty;
                          return _PlaceSuggestions(
                            state: searchState,
                            hasQuery: hasQuery,
                            onSelect: _selectPlace,
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'continue'.tr(),
                      usePrimaryContainer: true,
                      onPressed: canContinue ? _continue : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceSuggestions extends StatelessWidget {
  const _PlaceSuggestions({
    required this.state,
    required this.hasQuery,
    required this.onSelect,
  });

  final LocationSearchState state;
  final bool hasQuery;
  final ValueChanged<PlaceSuggestion> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (state.status == LocationSearchStatus.loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: scheme.primary,
            ),
          ),
        ),
      );
    }

    if (state.status == LocationSearchStatus.offline) {
      return _MessageText(
        text: 'location_search_offline'.tr(),
        color: scheme.error,
      );
    }

    if (state.status == LocationSearchStatus.error) {
      return _MessageText(
        text: 'location_search_error'.tr(),
        color: scheme.error,
      );
    }

    if (!hasQuery) {
      return _MessageText(
        text: 'location_search_type_hint'.tr(),
        color: scheme.onSurfaceVariant,
      );
    }

    if (state.status == LocationSearchStatus.empty || state.suggestions.isEmpty) {
      return _MessageText(
        text: 'destination_no_results'.tr(),
        color: scheme.onSurfaceVariant,
      );
    }

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: state.suggestions.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.4),
                ),
                itemBuilder: (context, index) {
                  final place = state.suggestions[index];
                  return ListTile(
                    leading: Icon(
                      Icons.location_on_outlined,
                      color: scheme.primary,
                    ),
                    title: Text(place.title),
                    subtitle:
                        place.subtitle.isNotEmpty ? Text(place.subtitle) : null,
                    onTap: () => onSelect(place),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                'location_osm_attribution'.tr(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageText extends StatelessWidget {
  const _MessageText({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
      ),
    );
  }
}

class _LocationInputs extends StatelessWidget {
  const _LocationInputs({
    required this.pickupController,
    required this.dropoffController,
    required this.pickupFocus,
    required this.dropoffFocus,
    required this.onPickupTap,
    required this.onDropoffTap,
  });

  final TextEditingController pickupController;
  final TextEditingController dropoffController;
  final FocusNode pickupFocus;
  final FocusNode dropoffFocus;
  final VoidCallback onPickupTap;
  final VoidCallback onDropoffTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned(
          left: 23,
          top: 40,
          bottom: 40,
          child: Container(
            width: 2,
            color: scheme.outlineVariant,
          ),
        ),
        Column(
          children: [
            _LocationRow(
              icon: Icons.trip_origin,
              iconColor: scheme.primary,
              controller: pickupController,
              hint: 'pickup_search_hint'.tr(),
              focusNode: pickupFocus,
              onTap: onPickupTap,
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: AppSpacing.sm),
            _LocationRow(
              icon: Icons.location_on,
              iconColor: scheme.error,
              controller: dropoffController,
              hint: 'dropoff_search_hint'.tr(),
              focusNode: dropoffFocus,
              onTap: onDropoffTap,
              textInputAction: TextInputAction.search,
            ),
          ],
        ),
      ],
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.controller,
    required this.hint,
    required this.focusNode,
    required this.onTap,
    required this.textInputAction,
  });

  final IconData icon;
  final Color iconColor;
  final TextEditingController controller;
  final String hint;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Icon(icon, color: iconColor),
        ),
        Expanded(
          child: Container(
            height: AppSpacing.inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onTap: onTap,
              textInputAction: textInputAction,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
