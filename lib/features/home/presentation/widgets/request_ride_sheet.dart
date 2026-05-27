import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/utils/constants.dart';
import 'package:delivery_app/core/widgets/nokta_bottom_nav_bar.dart';
import 'package:delivery_app/core/widgets/nokta_primary_button.dart';
import 'package:delivery_app/core/widgets/nokta_ride_option.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class RequestRideSheet extends StatefulWidget {
  const RequestRideSheet({
    super.key,
    required this.pickupLat,
    required this.pickupLng,
    this.initialDropoff,
  });

  final double pickupLat;
  final double pickupLng;
  final String? initialDropoff;

  @override
  State<RequestRideSheet> createState() => _RequestRideSheetState();
}

class _RequestRideSheetState extends State<RequestRideSheet> {
  late final TextEditingController _pickupController;
  late final TextEditingController _dropoffController;

  @override
  void initState() {
    super.initState();
    _pickupController = TextEditingController(text: 'Current Location');
    _dropoffController = TextEditingController(
      text: widget.initialDropoff ?? 'City Mall',
    );
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  void _continue() {
    Navigator.of(context).pop(
      RideRequestDraft(
        pickupAddress: _pickupController.text,
        dropoffAddress: _dropoffController.text,
        pickupLat: widget.pickupLat,
        pickupLng: widget.pickupLng,
        dropoffLat: AppConstants.defaultDropoffLat,
        dropoffLng: AppConstants.defaultDropoffLng,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(NoktaSpacing.radiusSheet),
          ),
          boxShadow: const [
            BoxShadow(
              color: NoktaColors.elevationShadow,
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              NoktaSpacing.md,
              0,
              NoktaSpacing.md,
              NoktaSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const NoktaSheetHandle(),
                Text(
                  'request_ride_title'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: NoktaSpacing.lg),
                _LocationInputs(
                  pickupController: _pickupController,
                  dropoffController: _dropoffController,
                ),
                const SizedBox(height: NoktaSpacing.lg),
                NoktaPrimaryButton(
                  label: 'continue'.tr(),
                  usePrimaryContainer: true,
                  onPressed: _continue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationInputs extends StatelessWidget {
  const _LocationInputs({
    required this.pickupController,
    required this.dropoffController,
  });

  final TextEditingController pickupController;
  final TextEditingController dropoffController;

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
              hint: 'pickup'.tr(),
            ),
            const SizedBox(height: NoktaSpacing.sm),
            _LocationRow(
              icon: Icons.location_on,
              iconColor: scheme.error,
              controller: dropoffController,
              hint: 'dropoff'.tr(),
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
  });

  final IconData icon;
  final Color iconColor;
  final TextEditingController controller;
  final String hint;

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
            height: NoktaSpacing.inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: NoktaSpacing.md),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: controller,
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
