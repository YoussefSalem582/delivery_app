import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/widgets/nokta_bottom_nav_bar.dart';
import 'package:delivery_app/core/widgets/nokta_primary_button.dart';
import 'package:delivery_app/core/widgets/nokta_ride_option.dart';
import 'package:delivery_app/features/home/presentation/bloc/map_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RideSelectionSheet extends StatefulWidget {
  const RideSelectionSheet({super.key, required this.draft});

  final RideRequestDraft draft;

  @override
  State<RideSelectionSheet> createState() => _RideSelectionSheetState();
}

class _RideSelectionSheetState extends State<RideSelectionSheet> {
  final _options = RideOption.defaults();
  RideTier _selected = RideTier.economy;

  RideOption get _selectedOption =>
      _options.firstWhere((o) => o.tier == _selected);

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
            top: Radius.circular(NoktaSpacing.radiusSheet),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final loading = state is RequestRideLoading;

            return SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  NoktaSpacing.md,
                  0,
                  NoktaSpacing.md,
                  NoktaSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const NoktaSheetHandle(),
                    ..._options.map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: NoktaSpacing.sm),
                        child: NoktaRideOptionCard(
                          option: option,
                          selected: _selected == option.tier,
                          onTap: () => setState(() => _selected = option.tier),
                        ),
                      ),
                    ),
                    const SizedBox(height: NoktaSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _PaymentChip(
                            label: 'payment_card'.tr(),
                            icon: Icons.credit_card,
                          ),
                        ),
                        const SizedBox(width: NoktaSpacing.sm),
                        _PaymentChip(
                          label: 'promo'.tr(),
                          icon: null,
                          compact: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: NoktaSpacing.md),
                    NoktaPrimaryButton(
                      label: 'confirm_ride_tier'.tr(
                        args: [_selectedOption.nameKey.tr()],
                      ),
                      loading: loading,
                      onPressed: () {
                        context.read<RequestRideBloc>().add(
                              RequestRideSubmitted(
                                pickupAddress: widget.draft.pickupAddress,
                                dropoffAddress: widget.draft.dropoffAddress,
                                pickupLat: widget.draft.pickupLat,
                                pickupLng: widget.draft.pickupLng,
                                dropoffLat: widget.draft.dropoffLat,
                                dropoffLng: widget.draft.dropoffLng,
                              ),
                            );
                      },
                    ),
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
  });

  final String label;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: NoktaSpacing.buttonHeight,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? NoktaSpacing.md : NoktaSpacing.md,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment:
            compact ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(width: NoktaSpacing.sm),
          ],
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: compact ? scheme.primary : scheme.onSurface,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!compact)
            Icon(Icons.expand_more, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
