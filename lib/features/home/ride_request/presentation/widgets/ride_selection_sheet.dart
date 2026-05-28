import 'dart:async';

import 'package:delivery_app/core/network/route_service.dart';
import 'package:delivery_app/features/home/ride_request/presentation/widgets/ride_option_card.dart';
import 'package:delivery_app/features/home/map_view/presentation/bloc/map_bloc.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/fare_estimate.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/estimate_fare_usecase.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/banners/app_toast.dart';
import 'package:delivery_app/shared/widgets/inputs/app_text_field.dart';
import 'package:delivery_app/shared/widgets/navigation/app_bottom_nav_bar.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class RideSelectionSheet extends StatefulWidget {
  const RideSelectionSheet({super.key, required this.draft});

  final RideRequestDraft draft;

  @override
  State<RideSelectionSheet> createState() => _RideSelectionSheetState();
}

class _RideSelectionSheetState extends State<RideSelectionSheet> {
  late List<RideOption> _options;
  final Map<String, FareEstimate> _fareEstimates = {};
  RideTier _selected = RideTier.economy;
  String _paymentMethodKey = 'payment_card';
  String? _appliedPromo;
  int? _routeEtaMinutes;
  double? _routeDistanceKm;
  bool _loadingRoute = true;

  @override
  void initState() {
    super.initState();
    _options = List<RideOption>.from(RideOption.defaults());
    unawaited(_loadRouteQuote());
  }

  RideOption get _selectedOption =>
      _options.firstWhere((o) => o.tier == _selected);

  String get _selectedTierKey => _selectedOption.nameKey;

  FareEstimate? get _selectedFareEstimate => _fareEstimates[_selectedTierKey];

  Future<void> _loadRouteQuote() async {
    try {
      final result = await sl<RouteService>().getRoute(
        pickup: LatLng(widget.draft.pickupLat, widget.draft.pickupLng),
        dropoff: LatLng(widget.draft.dropoffLat, widget.draft.dropoffLng),
      );
      if (!mounted) return;

      final distanceKm = result.distanceMeters / 1000;
      final estimateFare = sl<EstimateFareUseCase>();
      final updatedOptions = <RideOption>[];
      final estimates = <String, FareEstimate>{};

      for (final option in RideOption.defaults()) {
        final fareResult = await estimateFare(
          EstimateFareParams(
            tierKey: option.nameKey,
            distanceKm: distanceKm,
          ),
        );
        fareResult.fold(
          (_) {},
          (estimate) {
            estimates[option.nameKey] = estimate;
            updatedOptions.add(
              RideOption(
                tier: option.tier,
                nameKey: option.nameKey,
                subtitleKey: option.subtitleKey,
                icon: option.icon,
                price: estimate.fare,
                etaMinutes: option.etaMinutes,
                capacity: option.capacity,
              ),
            );
          },
        );
      }

      if (!mounted) return;
      setState(() {
        _routeEtaMinutes = result.etaMinutes;
        _routeDistanceKm = distanceKm;
        _fareEstimates
          ..clear()
          ..addAll(estimates);
        _options = updatedOptions.isNotEmpty ? updatedOptions : _options;
        _loadingRoute = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingRoute = false);
    }
  }

  Future<void> _showPaymentMethodSheet() async {
    final scheme = Theme.of(context).colorScheme;
    final methods = [
      ('payment_cash', Icons.payments_outlined),
      ('payment_card', Icons.credit_card),
    ];

    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  'payment_method'.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ...methods.map(
                (method) => ListTile(
                  leading: Icon(method.$2, color: scheme.primary),
                  title: Text(method.$1.tr()),
                  onTap: () => Navigator.of(sheetContext).pop(method.$1),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selected != null && mounted) {
      setState(() => _paymentMethodKey = selected);
    }
  }

  Future<void> _showPromoDialog() async {
    final controller = TextEditingController(text: _appliedPromo ?? '');

    final applied = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('promo'.tr()),
          content: AppTextField(
            controller: controller,
            hintText: 'promo_code_hint'.tr(),
            textInputAction: TextInputAction.done,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('cancel'.tr()),
            ),
            FilledButton(
              onPressed: () {
                final code = controller.text.trim();
                if (code.isEmpty) return;
                Navigator.of(dialogContext).pop(code);
              },
              child: Text('promo_apply'.tr()),
            ),
          ],
        );
      },
    );

    if (applied != null && mounted) {
      setState(() => _appliedPromo = applied);
      AppToast.info(context, 'promo_applied'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.72,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusSheet),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: BlocConsumer<RequestRideBloc, RequestRideState>(
          listener: (context, state) {
            if (state is RequestRideSuccess) {
              Navigator.of(context).pop(state.trip);
            } else if (state is RequestRideError) {
              AppToast.error(context, state.message);
            }
          },
          builder: (context, state) {
            final loading = state is RequestRideLoading;

            return SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppSheetHandle(),
                    if (_loadingRoute)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: LinearProgressIndicator(
                          color: scheme.primary,
                          backgroundColor: scheme.surfaceContainerHighest,
                        ),
                      ),
                    ..._options.map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: RideOptionCard(
                          option: option,
                          selected: _selected == option.tier,
                          etaMinutes: _routeEtaMinutes,
                          distanceKm: _routeDistanceKm,
                          onTap: () => setState(() => _selected = option.tier),
                        ),
                      ),
                    ),
                    if (_selectedFareEstimate != null && !_loadingRoute)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          'fare_base_plus_distance'.tr(
                            namedArgs: {
                              'distance':
                                  _routeDistanceKm?.toStringAsFixed(1) ?? '0',
                              'base': _selectedFareEstimate!.baseFare
                                  .toStringAsFixed(0),
                              'distance_charge': _selectedFareEstimate!
                                  .distanceCharge
                                  .toStringAsFixed(2),
                            },
                          ),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _PaymentChip(
                            label: _paymentMethodKey.tr(),
                            icon: _paymentMethodKey == 'payment_cash'
                                ? Icons.payments_outlined
                                : Icons.credit_card,
                            onTap: _showPaymentMethodSheet,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _PaymentChip(
                          label: _appliedPromo ?? 'promo'.tr(),
                          icon: null,
                          compact: true,
                          onTap: _showPromoDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'confirm_ride_tier'.tr(
                        args: [_selectedOption.nameKey.tr()],
                      ),
                      loading: loading,
                      onPressed: loading ||
                              _loadingRoute ||
                              _fareEstimates.isEmpty
                          ? null
                          : () {
                              context.read<RequestRideBloc>().add(
                                    RequestRideSubmitted(
                                      pickupAddress: widget.draft.pickupAddress,
                                      dropoffAddress:
                                          widget.draft.dropoffAddress,
                                      pickupLat: widget.draft.pickupLat,
                                      pickupLng: widget.draft.pickupLng,
                                      dropoffLat: widget.draft.dropoffLat,
                                      dropoffLng: widget.draft.dropoffLng,
                                      fare: _selectedOption.price,
                                      distanceKm: _routeDistanceKm,
                                      etaMinutes: _routeEtaMinutes,
                                      paymentMethodKey: _paymentMethodKey,
                                      rideTierKey: _selectedTierKey,
                                    ),
                                  );
                            },
                    )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.1, end: 0),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({
    required this.label,
    this.icon,
    this.compact = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: compact ? scheme.primary : scheme.onSurface,
        );

    if (compact) {
      return Material(
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: AppSpacing.buttonHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Center(
              child: Text(
                label,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: AppSpacing.buttonHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  label,
                  style: textStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.expand_more, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
