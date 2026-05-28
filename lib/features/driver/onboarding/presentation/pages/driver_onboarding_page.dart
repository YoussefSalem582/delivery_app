import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/features/auth/shared/domain/entities/user_entity.dart';
import 'package:delivery_app/features/auth/shared/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/driver/onboarding/presentation/cubit/driver_onboarding_cubit.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/banners/app_toast.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:delivery_app/shared/widgets/inputs/app_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Stored on [DriverProfileEntity.vehicleType] — matches ride tiers.
const driverVehicleTypeKeys = ['economy', 'premium', 'delivery'];

String driverVehicleTypeLabel(String key) {
  return switch (key) {
    'economy' => 'driver_vehicle_economy'.tr(),
    'premium' => 'driver_vehicle_premium'.tr(),
    'delivery' => 'driver_vehicle_delivery'.tr(),
    _ => key,
  };
}

class DriverOnboardingPage extends StatefulWidget {
  const DriverOnboardingPage({super.key});

  @override
  State<DriverOnboardingPage> createState() => _DriverOnboardingPageState();
}

class _DriverOnboardingPageState extends State<DriverOnboardingPage> {
  late final TextEditingController _phoneController;
  late final TextEditingController _makeModelController;
  late final TextEditingController _plateController;
  String? _selectedVehicleType;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _makeModelController = TextEditingController();
    _plateController = TextEditingController();

    final authState = sl<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.user.phone.isNotEmpty) {
      _phoneController.text = authState.user.phone;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _makeModelController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated &&
            authState.user.isDriverRegistered) {
          return _RegisteredSummary(user: authState.user);
        }

        return BlocProvider(
          create: (_) {
            final cubit = sl<DriverOnboardingCubit>();
            if (_phoneController.text.isNotEmpty) {
              cubit.initializePhone(_phoneController.text);
            }
            return cubit;
          },
          child: BlocConsumer<DriverOnboardingCubit, DriverOnboardingState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == DriverOnboardingStatus.success) {
                AppToast.success(context, 'driver_onboarding_success'.tr());
                Navigator.of(context).pop(true);
              } else if (state.status == DriverOnboardingStatus.failure &&
                  state.errorMessage != null) {
                AppToast.error(context, state.errorMessage!);
              }
            },
            builder: (context, state) {
              return Scaffold(
                appBar: AppBar(title: Text('driver_onboarding_title'.tr())),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'driver_onboarding_subtitle'.tr(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        controller: _phoneController,
                        labelText: 'driver_onboarding_phone'.tr(),
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        errorText: state.phoneError?.tr(),
                        onChanged: context
                            .read<DriverOnboardingCubit>()
                            .phoneChanged,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String>(
                        value: _selectedVehicleType,
                        decoration: InputDecoration(
                          labelText: 'driver_onboarding_vehicle_type'.tr(),
                          prefixIcon: const Icon(Icons.directions_car_outlined),
                          errorText: state.vehicleTypeError?.tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                        ),
                        items: driverVehicleTypeKeys
                            .map(
                              (key) => DropdownMenuItem(
                                value: key,
                                child: Text(driverVehicleTypeLabel(key)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedVehicleType = value);
                          if (value != null) {
                            context
                                .read<DriverOnboardingCubit>()
                                .vehicleTypeChanged(value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _makeModelController,
                        labelText: 'driver_onboarding_make_model'.tr(),
                        prefixIcon: Icons.build_outlined,
                        errorText: state.vehicleMakeModelError?.tr(),
                        onChanged: context
                            .read<DriverOnboardingCubit>()
                            .vehicleMakeModelChanged,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _plateController,
                        labelText: 'driver_onboarding_plate'.tr(),
                        prefixIcon: Icons.confirmation_number_outlined,
                        errorText: state.licensePlateError?.tr(),
                        onChanged: context
                            .read<DriverOnboardingCubit>()
                            .licensePlateChanged,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      CheckboxListTile(
                        value: state.termsAccepted,
                        onChanged: (value) => context
                            .read<DriverOnboardingCubit>()
                            .termsChanged(value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: Text('driver_onboarding_terms'.tr()),
                        subtitle: state.termsError != null
                            ? Text(
                                state.termsError!.tr(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: 'driver_onboarding_submit'.tr(),
                        loading: state.isSubmitting,
                        onPressed: state.isSubmitting
                            ? null
                            : () => context
                                  .read<DriverOnboardingCubit>()
                                  .submit(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _RegisteredSummary extends StatelessWidget {
  const _RegisteredSummary({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final profile = user.driverProfile;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('driver_onboarding_title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.check_circle,
              size: 64,
              color: AppColors.secondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'driver_onboarding_already_registered'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (profile != null) ...[
              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: Text(profile.phone),
              ),
              ListTile(
                leading: const Icon(Icons.directions_car_outlined),
                title: Text(driverVehicleTypeLabel(profile.vehicleType)),
                subtitle: Text(profile.vehicleMakeModel),
              ),
              ListTile(
                leading: const Icon(Icons.confirmation_number_outlined),
                title: Text(profile.licensePlate),
              ),
            ],
            const Spacer(),
            AppButton(
              label: 'driver_onboarding_close'.tr(),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'driver_onboarding_registered_hint'.tr(),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
