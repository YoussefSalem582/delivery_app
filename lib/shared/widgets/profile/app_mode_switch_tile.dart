import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/features/driver/shared/presentation/cubit/app_mode_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Symmetric driver/passenger mode toggle for profile settings surfaces.
class AppModeSwitchTile extends StatelessWidget {
  const AppModeSwitchTile.passenger({super.key}) : _variant = _Variant.passenger;

  const AppModeSwitchTile.driver({super.key}) : _variant = _Variant.driver;

  final _Variant _variant;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return switch (_variant) {
      _Variant.passenger => Switch.adaptive(
          value: context.watch<AppModeCubit>().state.isDriver,
          activeTrackColor: scheme.primary.withValues(alpha: 0.5),
          activeThumbColor: scheme.primary,
          onChanged: (enabled) async {
            await context.read<AppModeCubit>().toggleDriverMode(enabled);
            if (!context.mounted) return;
            context.goNamed(
              enabled ? RouteNames.driverHome : RouteNames.home,
            );
          },
        ),
      _Variant.driver => SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('driver_switch_passenger_mode'.tr()),
          subtitle: Text('driver_switch_passenger_hint'.tr()),
          value: false,
          onChanged: (_) async {
            await context.read<AppModeCubit>().resetToPassenger();
            if (context.mounted) {
              context.goNamed(RouteNames.home);
            }
          },
        ),
    };
  }
}

enum _Variant { passenger, driver }
